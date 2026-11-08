import { MAX_EXPERIMENT_QUESTIONS, MIN_EXPERIMENT_QUESTIONS } from '../services/experimentAssessments';

const groupStyle = { border: '1px solid var(--border-light)', padding: '20px', borderRadius: '12px', minWidth: 0 };
const cardStyle = { border: '1px solid var(--border-light)', padding: '16px', borderRadius: '8px', display: 'grid', gap: '12px', minWidth: 0 };
const hintStyle = { color: 'var(--text-secondary)', fontSize: '0.85rem' };

export default function ExperimentAssessmentEditor({ experiment, onChange }) {
  const ppe = experiment.ppeAssessment;
  const questions = experiment.assessmentQuestions;
  const setPpeOption = (index, patch) => onChange({ ppeAssessment: {
    ...ppe, options: ppe.options.map((option, position) => position === index ? { ...option, ...patch } : option),
  } });
  const setQuestion = (index, patch) => onChange({ assessmentQuestions:
    questions.map((question, position) => position === index ? { ...question, ...patch } : question),
  });

  return <>
    <fieldset style={groupStyle}>
      <legend>PPE Safety Check</legend>
      <p style={hintStyle}>Edit the choices students see and check every correct PPE selection. The explanation appears when a student needs feedback. Leave all choices unchecked if this activity requires no PPE check.</p>
      <div style={{ display: 'grid', gap: '12px' }}>
        {ppe.options.map((option, index) => <div key={option.id} style={cardStyle}>
          <label style={{ display: 'flex', gap: '10px', alignItems: 'center' }}>
            <input type="checkbox" checked={ppe.requiredIds.includes(option.id)} onChange={(event) => onChange({ ppeAssessment: {
              ...ppe, requiredIds: event.target.checked ? [...ppe.requiredIds, option.id] : ppe.requiredIds.filter((id) => id !== option.id),
            } })} />
            Correct selection
          </label>
          <label className="input-label">PPE choice {index + 1}
            <input className="input-field" value={option.label} onChange={(event) => setPpeOption(index, { label: event.target.value })} required />
          </label>
          <label className="input-label">Feedback explanation
            <textarea className="input-field" value={option.reason} onChange={(event) => setPpeOption(index, { reason: event.target.value })} rows={2} required />
          </label>
          <button type="button" className="btn btn-secondary" disabled={ppe.options.length <= 1} onClick={() => onChange({ ppeAssessment: {
            options: ppe.options.filter((_, position) => position !== index), requiredIds: ppe.requiredIds.filter((id) => id !== option.id),
          } })}>Remove PPE choice</button>
        </div>)}
      </div>
      <button type="button" className="btn btn-secondary" style={{ marginTop: '12px' }} onClick={() => onChange({ ppeAssessment: {
        ...ppe, options: [...ppe.options, { id: `ppe_${crypto.randomUUID()}`, label: '', reason: '' }],
      } })}>Add PPE choice</button>
    </fieldset>

    <fieldset style={groupStyle}>
      <legend>End-of-Experiment Mini Quiz ({questions.length}/{MAX_EXPERIMENT_QUESTIONS})</legend>
      <p style={hintStyle}>Keep {MIN_EXPERIMENT_QUESTIONS}–{MAX_EXPERIMENT_QUESTIONS} questions. Each question has four choices and one correct answer.</p>
      <div style={{ display: 'grid', gap: '16px' }}>
        {questions.map((question, index) => <div key={index} style={cardStyle}>
          <label className="input-label">Question {index + 1}
            <textarea className="input-field" value={question.prompt} onChange={(event) => setQuestion(index, { prompt: event.target.value })} rows={2} required />
          </label>
          {question.options.map((choice, choiceIndex) => <div key={choiceIndex} style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
            <label style={{ display: 'flex', alignItems: 'center', gap: '6px', whiteSpace: 'nowrap' }}>
              <input type="radio" name={`ar-correct-answer-${index}`} checked={question.correctOption === choiceIndex} onChange={() => setQuestion(index, { correctOption: choiceIndex })} required />
              {String.fromCharCode(65 + choiceIndex)} correct
            </label>
            <input className="input-field" aria-label={`Question ${index + 1} choice ${String.fromCharCode(65 + choiceIndex)}`} style={{ margin: 0, minWidth: 0 }} value={choice} onChange={(event) => setQuestion(index, {
              options: question.options.map((value, position) => position === choiceIndex ? event.target.value : value),
            })} required />
          </div>)}
          <button type="button" className="btn btn-secondary" disabled={questions.length <= MIN_EXPERIMENT_QUESTIONS} onClick={() => onChange({ assessmentQuestions: questions.filter((_, position) => position !== index) })}>Remove question</button>
        </div>)}
      </div>
      <button type="button" className="btn btn-secondary" style={{ marginTop: '12px' }} disabled={questions.length >= MAX_EXPERIMENT_QUESTIONS} onClick={() => onChange({ assessmentQuestions: [...questions, { prompt: '', options: ['', '', '', ''], correctOption: -1 }] })}>Add question</button>
    </fieldset>
  </>;
}
