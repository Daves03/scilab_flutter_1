import { strFromU8, unzipSync } from 'fflate';
import { isTemporaryAiError, retryTemporaryAiRequest } from './aiRequestRetry';

const API_ROOT = 'https://generativelanguage.googleapis.com/v1beta';
const MAX_OFFICE_BYTES = 50 * 1024 * 1024;
const MAX_TEXT_CHARACTERS = 400000;

const cleanXmlText = (xml) => xml
  .replace(/<w:tab\s*\/?>/gi, ' ')
  .replace(/<a:br\s*\/?>/gi, '\n')
  .replace(/<[^>]+>/g, ' ')
  .replace(/&amp;/g, '&')
  .replace(/&lt;/g, '<')
  .replace(/&gt;/g, '>')
  .replace(/&quot;/g, '"')
  .replace(/&#39;/g, "'")
  .replace(/[ \t]+/g, ' ')
  .replace(/\n{3,}/g, '\n\n')
  .trim();

const extractXmlTextNodes = (xml) => {
  const matches = [...xml.matchAll(/<(?:w|a):t(?:\s[^>]*)?>([\s\S]*?)<\/(?:w|a):t>/gi)];
  return cleanXmlText(matches.map((match) => match[1]).join(' '));
};

const extractLegacyText = (bytes) => {
  const candidates = new Set();
  const add = (value) => {
    const cleaned = value.replace(/\s+/g, ' ').trim();
    if (cleaned.length >= 4 && /[A-Za-z]{2}/.test(cleaned)) candidates.add(cleaned);
  };
  let ascii = '';
  for (const byte of bytes) {
    if ((byte >= 32 && byte <= 126) || byte === 9 || byte === 10) ascii += String.fromCharCode(byte);
    else { if (ascii.length >= 4) add(ascii); ascii = ''; }
  }
  if (ascii.length >= 4) add(ascii);
  let unicode = '';
  for (let index = 0; index + 1 < bytes.length; index += 2) {
    const low = bytes[index];
    const high = bytes[index + 1];
    if (high === 0 && ((low >= 32 && low <= 126) || low === 9 || low === 10)) unicode += String.fromCharCode(low);
    else { if (unicode.length >= 4) add(unicode); unicode = ''; }
  }
  if (unicode.length >= 4) add(unicode);
  return [...candidates].join('\n');
};

export const extractOfficeText = (arrayBuffer, fileName) => {
  const bytes = new Uint8Array(arrayBuffer);
  if (!bytes.length) throw new Error('The selected module file is empty.');
  if (bytes.length > MAX_OFFICE_BYTES) throw new Error('The Office file is larger than the 50 MB processing limit.');
  const extension = fileName.split('.').pop()?.toLowerCase();
  let text = '';

  if (extension === 'docx' || extension === 'pptx') {
    const archive = unzipSync(bytes);
    const names = Object.keys(archive);
    const relevant = extension === 'docx'
      ? names.filter((name) => /^word\/(document|header\d+|footer\d+|footnotes|endnotes)\.xml$/i.test(name)).sort((left) => left.toLowerCase() === 'word/document.xml' ? -1 : 1)
      : names.filter((name) => /^ppt\/(slides\/slide|notesSlides\/notesSlide)\d+\.xml$/i.test(name)).sort((left, right) => {
        const leftNumber = Number(left.match(/(\d+)\.xml$/)?.[1] || 0);
        const rightNumber = Number(right.match(/(\d+)\.xml$/)?.[1] || 0);
        return leftNumber - rightNumber;
      });
    if (!relevant.length) throw new Error(`No readable ${extension.toUpperCase()} content was found.`);
    text = relevant.map((name, index) => {
      const label = extension === 'pptx' && name.includes('/slides/') ? `Slide ${index + 1}\n` : '';
      return `${label}${extractXmlTextNodes(strFromU8(archive[name]))}`;
    }).join('\n\n');
  } else if (extension === 'doc' || extension === 'ppt') {
    text = extractLegacyText(bytes);
  } else {
    throw new Error('Unsupported Office format. Select DOC, DOCX, PPT, or PPTX.');
  }

  const normalized = text.replace(/\0/g, '').replace(/[ \t]+/g, ' ').replace(/\n{3,}/g, '\n\n').trim();
  if (normalized.length < 40) throw new Error(`Could not extract enough readable text. Save legacy ${extension?.toUpperCase()} files as ${extension === 'doc' ? 'DOCX' : 'PPTX'} and try again.`);
  return normalized.length > MAX_TEXT_CHARACTERS ? `${normalized.slice(0, MAX_TEXT_CHARACTERS)}\n[Content truncated for AI processing]` : normalized;
};

const toBase64 = (arrayBuffer) => {
  const bytes = new Uint8Array(arrayBuffer);
  let binary = '';
  const chunkSize = 0x8000;
  for (let index = 0; index < bytes.length; index += chunkSize) binary += String.fromCharCode(...bytes.subarray(index, index + chunkSize));
  return btoa(binary);
};

// Keep the deadline active while reading the response body, too.
const readWithTimeout = async (url, options, read, timeoutMs, stage) => {
  const controller = new AbortController();
  const parentSignal = options.signal;
  const cancel = () => controller.abort(parentSignal.reason);
  parentSignal?.throwIfAborted();
  parentSignal?.addEventListener('abort', cancel, { once: true });
  const timer = setTimeout(() => controller.abort(new DOMException(
    `${stage} timed out. Check your connection and try again.`, 'TimeoutError',
  )), timeoutMs);
  try {
    const response = await fetch(url, { ...options, signal: controller.signal });
    return await read(response);
  } catch (error) {
    if (controller.signal.aborted) throw controller.signal.reason;
    throw error;
  } finally {
    clearTimeout(timer);
    parentSignal?.removeEventListener('abort', cancel);
  }
};

const listAvailableModels = async (apiKey, signal) => {
  const data = await readWithTimeout(`${API_ROOT}/models?key=${encodeURIComponent(apiKey)}`, { signal }, async (response) => {
    const body = await response.json();
    if (!response.ok) {
      const error = new Error(body.error?.message || `Could not load Gemini models (${response.status}).`);
      error.status = response.status;
      throw error;
    }
    return body;
  }, 15000, 'Checking available Gemini models');
  return (data.models || [])
    .filter((model) => (model.supportedGenerationMethods || []).includes('generateContent'))
    .map((model) => String(model.name || '').replace(/^models\//, ''))
    .filter((name) => /^gemini-/.test(name) && /flash|pro/.test(name)
      && !/image|tts|audio|transcrib|robotics|computer-use|customtools/.test(name))
    .sort((left, right) => Number(right.includes('flash')) - Number(left.includes('flash')));
};

const parseJsonResponse = (text) => {
  const cleaned = text.trim().replace(/^```(?:json)?\s*/i, '').replace(/\s*```$/, '');
  const decoded = JSON.parse(cleaned);
  if (!Array.isArray(decoded) || !decoded.length) throw new Error('Gemini did not return a quiz array.');
  return decoded;
};

const questionRules = {
  multipleChoice: 'multipleChoice: exactly 4 options, correctIndex 0-3, empty correctAnswers.',
  trueFalse: 'trueFalse: options ["True", "False"], correctIndex 0 or 1, empty correctAnswers.',
  identification: 'identification: empty options, correctIndex 0, correctAnswers with the short answer and acceptable equivalents.',
  enumeration: 'enumeration: empty options, correctIndex 0, correctAnswers containing every required item.',
};

const normalizeQuestionType = (value) => {
  const normalized = String(value || '').toLowerCase().replace(/[\s_-]+/g, '');
  if (normalized === 'multiplechoice') return 'multipleChoice';
  if (normalized === 'truefalse') return 'trueFalse';
  if (normalized === 'identification') return 'identification';
  if (normalized === 'enumeration') return 'enumeration';
  return '';
};

export async function generateQuizFromModule({ module, questionCounts, signal, onProgress = () => {} }) {
  const apiKey = import.meta.env.VITE_GEMINI_API_KEY?.trim();
  if (!apiKey) throw new Error('Gemini is not configured for the web portal. Add VITE_GEMINI_API_KEY when building the admin web.');

  onProgress('Downloading the selected module...');
  const arrayBuffer = await readWithTimeout(module.url, { signal }, async (response) => {
    if (!response.ok) throw new Error(`Could not download the module (${response.status}).`);
    return response.arrayBuffer();
  }, 30000, 'Downloading the module');
  onProgress('Reading the module content...');
  const selectedCounts = Object.entries(questionCounts).filter(([, count]) => Number(count) > 0);
  const totalQuestions = selectedCounts.reduce((total, [, count]) => total + Number(count), 0);
  if (!totalQuestions) throw new Error('Select at least one quiz type and question count.');

  const prompt = `You are an expert chemistry teacher. Analyze the provided module and generate exactly one quiz with exactly ${totalQuestions} questions based only on the module content.
Use exactly this distribution:\n${selectedCounts.map(([type, count]) => `- ${type}: ${count}`).join('\n')}
Rules:\n${selectedCounts.map(([type]) => `- ${questionRules[type]}`).join('\n')}
Respond only with a valid JSON array containing one object with this structure:
[{"title":"Short descriptive title","directions":"Clear directions","questions":[{"type":"selected type","question":"Question text","options":[],"correctIndex":0,"correctAnswers":[],"explanation":"Brief explanation"}]}]`;

  const extension = module.title?.split('.').pop()?.toLowerCase();
  const isPdf = module.fileType === 'pdf' || extension === 'pdf';
  const parts = isPdf
    ? [{ text: prompt }, { inlineData: { mimeType: 'application/pdf', data: toBase64(arrayBuffer) } }]
    : [{ text: `${prompt}\n\n--- BEGIN MODULE CONTENT ---\n${extractOfficeText(arrayBuffer, module.title || `module.${module.fileType}`)}\n--- END MODULE CONTENT ---` }];

  const configuredModel = import.meta.env.VITE_GEMINI_MODEL?.trim();
  onProgress('Checking available Gemini models...');
  let discoveredModels = [];
  try {
    discoveredModels = await retryTemporaryAiRequest(() => listAvailableModels(apiKey, signal), {
      signal,
      onRetry: () => onProgress('The AI service is busy. Retrying the available-model check...'),
    });
  } catch (error) {
    if (signal?.aborted) throw error;
    if (!configuredModel) {
      if (isTemporaryAiError(error)) throw new Error('The AI service is still busy after automatic retries. Please try again in a moment.');
      throw error;
    }
  }
  const preferredFallbacks = ['gemini-3.5-flash-lite', 'gemini-3.1-flash-lite', 'gemini-2.5-flash-lite']
    .filter((model) => discoveredModels.includes(model));
  const candidates = [...new Set([configuredModel, ...preferredFallbacks, ...discoveredModels].filter(Boolean))].slice(0, 2);
  if (!candidates.length) throw new Error('No Gemini model supporting quiz generation is available for this API key.');

  let lastError;
  for (const [attempt, model] of candidates.entries()) {
    try {
      signal?.throwIfAborted();
      onProgress(attempt === 0
        ? `Gemini is generating ${totalQuestions} questions...`
        : `The first attempt did not finish. Trying an alternative model for ${totalQuestions} questions...`);
      const generationConfig = { responseMimeType: 'application/json', temperature: 0.25 };
      if (/^gemini-[34][.-]/.test(model)) generationConfig.thinkingConfig = { thinkingLevel: 'low' };
      const data = await retryTemporaryAiRequest(() => readWithTimeout(`${API_ROOT}/models/${model}:generateContent?key=${encodeURIComponent(apiKey)}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ contents: [{ role: 'user', parts }], generationConfig }),
        signal,
      }, async (generation) => {
        const body = await generation.json();
        if (!generation.ok) {
          const error = new Error(body.error?.message || `Gemini request failed (${generation.status}).`);
          error.status = generation.status;
          const retryAfter = generation.headers.get('Retry-After');
          error.retryAfterMs = retryAfter ? (Number.isFinite(Number(retryAfter)) ? Number(retryAfter) * 1000 : Math.max(0, Date.parse(retryAfter) - Date.now())) : 0;
          throw error;
        }
        return body;
      }, attempt === 0 && candidates.length > 1 ? 45000 : 90000, 'Generating the quiz'), {
        signal,
        onRetry: (retry, delay) => onProgress(`The AI service is busy. Retrying in ${Math.ceil(delay / 1000)} seconds (${retry}/2)...`),
      });
      onProgress('Checking the generated questions...');
      const text = data.candidates?.[0]?.content?.parts?.filter((part) => !part.thought).map((part) => part.text || '').join('') || '';
      const quizzes = parseJsonResponse(text);
      const generated = quizzes[0];
      if (!Array.isArray(generated.questions) || generated.questions.length !== totalQuestions) throw new Error(`AI returned ${generated.questions?.length || 0} questions instead of ${totalQuestions}.`);
      const normalizedQuestions = generated.questions.map((question, index) => {
        const type = normalizeQuestionType(question.type) || (selectedCounts.length === 1 ? selectedCounts[0][0] : '');
        if (!questionCounts[type]) throw new Error(`AI returned an unselected or unknown type for question ${index + 1}.`);
        const questionText = String(question.question || '').trim();
        if (!questionText) throw new Error(`AI returned an empty question at item ${index + 1}.`);
        let options = Array.isArray(question.options) ? question.options.map((option) => String(option).trim()) : [];
        let correctIndex = Number(question.correctIndex || 0);
        let correctAnswers = Array.isArray(question.correctAnswers) ? question.correctAnswers.map((answer) => String(answer).trim()).filter(Boolean) : [];
        if (type === 'multipleChoice' && (options.length !== 4 || correctIndex < 0 || correctIndex > 3)) throw new Error(`AI returned invalid choices for question ${index + 1}.`);
        if (type === 'trueFalse') {
          options = ['True', 'False'];
          if (correctIndex < 0 || correctIndex > 1) throw new Error(`AI returned an invalid true-or-false answer for question ${index + 1}.`);
        }
        if ((type === 'identification' || type === 'enumeration') && !correctAnswers.length) throw new Error(`AI returned no written answer for question ${index + 1}.`);
        if (type === 'multipleChoice' || type === 'trueFalse') correctAnswers = [];
        return {
          id: `ai-question-${Date.now()}-${index}`,
          type,
          question: questionText,
          options,
          correctIndex,
          correctAnswers,
          explanation: String(question.explanation || ''),
        };
      });
      selectedCounts.forEach(([type, expected]) => {
        const actual = normalizedQuestions.filter((question) => question.type === type).length;
        if (actual !== Number(expected)) throw new Error(`AI returned ${actual} ${type} questions instead of ${expected}. Please generate again.`);
      });
      return {
        title: generated.title || `Quiz: ${module.title}`,
        directions: generated.directions || 'Read each question carefully and provide the best answer.',
        questions: normalizedQuestions,
      };
    } catch (error) {
      lastError = error;
      if (signal?.aborted || error.name === 'AbortError') throw error;
      if ([400, 401, 403, 429].includes(error.status)) throw error;
    }
  }
  if (lastError?.name === 'TimeoutError') {
    throw new Error('Gemini did not finish generating the quiz in time. Try fewer questions or a smaller module.');
  }
  if (isTemporaryAiError(lastError)) {
    throw new Error('The AI service is still busy after automatic recovery attempts. Please try again in a moment.');
  }
  throw lastError || new Error('AI quiz generation failed. Please try again.');
}
