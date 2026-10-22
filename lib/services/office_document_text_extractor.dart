import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:xml/xml.dart';

class ExtractedOfficeDocument {
  final String text;
  final String formatLabel;
  final bool bestEffort;

  const ExtractedOfficeDocument({
    required this.text,
    required this.formatLabel,
    this.bestEffort = false,
  });
}

/// Extracts quiz-ready plain text from Office files without platform APIs.
/// DOCX and PPTX are parsed from their Open XML ZIP packages. Legacy DOC/PPT
/// files use a conservative printable-text scan because their binary OLE
/// format has no browser-native parser.
class OfficeDocumentTextExtractor {
  static const int _maxInputBytes = 50 * 1024 * 1024;
  static const int _maxArchiveEntries = 2500;
  static const int _maxRelevantXmlBytes = 20 * 1024 * 1024;
  static const int _maxTextCharacters = 400000;

  const OfficeDocumentTextExtractor._();

  static ExtractedOfficeDocument extract({
    required Uint8List bytes,
    required String fileName,
  }) {
    if (bytes.isEmpty) {
      throw const FormatException('The selected Office file is empty.');
    }
    if (bytes.length > _maxInputBytes) {
      throw const FormatException(
        'The Office file is larger than the 50 MB processing limit.',
      );
    }

    final extension = _extensionOf(fileName);
    final result = switch (extension) {
      'docx' => ExtractedOfficeDocument(
        text: _extractDocx(bytes),
        formatLabel: 'DOCX',
      ),
      'pptx' => ExtractedOfficeDocument(
        text: _extractPptx(bytes),
        formatLabel: 'PPTX',
      ),
      'doc' => ExtractedOfficeDocument(
        text: _extractLegacyOfficeText(bytes),
        formatLabel: 'DOC',
        bestEffort: true,
      ),
      'ppt' => ExtractedOfficeDocument(
        text: _extractLegacyOfficeText(bytes),
        formatLabel: 'PPT',
        bestEffort: true,
      ),
      _ => throw FormatException(
        'Unsupported Office file .$extension. Select DOC, DOCX, PPT, or PPTX.',
      ),
    };

    final normalized = _normalizeText(result.text);
    if (normalized.length < 40) {
      throw FormatException(
        'Could not extract enough readable text from the ${result.formatLabel} '
        'file. If it is a legacy DOC/PPT file, save it as DOCX/PPTX and retry.',
      );
    }
    return ExtractedOfficeDocument(
      text: normalized.length > _maxTextCharacters
          ? '${normalized.substring(0, _maxTextCharacters)}\n'
                '[Content truncated for AI processing]'
          : normalized,
      formatLabel: result.formatLabel,
      bestEffort: result.bestEffort,
    );
  }

  static String _extractDocx(Uint8List bytes) {
    final archive = _decodeOfficeArchive(bytes);
    final entries =
        archive.files.where((file) {
          final name = file.name.toLowerCase();
          return file.isFile &&
              (name == 'word/document.xml' ||
                  RegExp(r'^word/(header|footer)\d+\.xml$').hasMatch(name) ||
                  name == 'word/footnotes.xml' ||
                  name == 'word/endnotes.xml');
        }).toList()..sort((a, b) {
          if (a.name.toLowerCase() == 'word/document.xml') return -1;
          if (b.name.toLowerCase() == 'word/document.xml') return 1;
          return a.name.compareTo(b.name);
        });

    if (entries.isEmpty) {
      throw const FormatException('The DOCX document XML was not found.');
    }
    _checkRelevantSize(entries);

    final output = StringBuffer();
    for (final entry in entries) {
      final document = _parseXmlEntry(entry);
      for (final paragraph in document.descendants.whereType<XmlElement>()) {
        if (paragraph.name.local != 'p') continue;
        final text = paragraph.descendants
            .whereType<XmlElement>()
            .where((element) => element.name.local == 't')
            .map((element) => element.innerText)
            .join();
        if (text.trim().isNotEmpty) output.writeln(text.trim());
      }
    }
    return output.toString();
  }

  static String _extractPptx(Uint8List bytes) {
    final archive = _decodeOfficeArchive(bytes);
    final slidePattern = RegExp(r'^ppt/slides/slide(\d+)\.xml$');
    final notePattern = RegExp(r'^ppt/notesslides/notesslide(\d+)\.xml$');
    final entries =
        archive.files.where((file) {
          final name = file.name.toLowerCase();
          return file.isFile &&
              (slidePattern.hasMatch(name) || notePattern.hasMatch(name));
        }).toList()..sort((a, b) {
          final aName = a.name.toLowerCase();
          final bName = b.name.toLowerCase();
          final aSlide = slidePattern.firstMatch(aName);
          final bSlide = slidePattern.firstMatch(bName);
          if (aSlide != null && bSlide == null) return -1;
          if (aSlide == null && bSlide != null) return 1;
          final aNumber = int.tryParse(
            (aSlide ?? notePattern.firstMatch(aName))?.group(1) ?? '',
          );
          final bNumber = int.tryParse(
            (bSlide ?? notePattern.firstMatch(bName))?.group(1) ?? '',
          );
          return (aNumber ?? 0).compareTo(bNumber ?? 0);
        });

    if (entries.isEmpty) {
      throw const FormatException('No readable slides were found in the PPTX.');
    }
    _checkRelevantSize(entries);

    final output = StringBuffer();
    var slideNumber = 0;
    for (final entry in entries) {
      final isSlide = slidePattern.hasMatch(entry.name.toLowerCase());
      if (isSlide) {
        slideNumber++;
        output.writeln('Slide $slideNumber');
      } else {
        output.writeln('Speaker notes');
      }
      final document = _parseXmlEntry(entry);
      for (final paragraph in document.descendants.whereType<XmlElement>()) {
        if (paragraph.name.local != 'p') continue;
        final text = paragraph.descendants
            .whereType<XmlElement>()
            .where((element) => element.name.local == 't')
            .map((element) => element.innerText)
            .join();
        if (text.trim().isNotEmpty) output.writeln(text.trim());
      }
      output.writeln();
    }
    return output.toString();
  }

  static Archive _decodeOfficeArchive(Uint8List bytes) {
    final archive = ZipDecoder().decodeBytes(bytes);
    if (archive.length > _maxArchiveEntries) {
      throw const FormatException(
        'The Office file contains too many internal entries.',
      );
    }
    return archive;
  }

  static XmlDocument _parseXmlEntry(ArchiveFile entry) {
    final content = entry.readBytes();
    if (content == null) {
      throw FormatException('Could not read ${entry.name}.');
    }
    return XmlDocument.parse(utf8.decode(content, allowMalformed: true));
  }

  static void _checkRelevantSize(List<ArchiveFile> entries) {
    final totalSize = entries.fold<int>(
      0,
      (total, entry) => total + entry.size,
    );
    if (totalSize > _maxRelevantXmlBytes) {
      throw const FormatException(
        'The extracted Office document content is too large to process safely.',
      );
    }
  }

  static String _extractLegacyOfficeText(Uint8List bytes) {
    final candidates = <String>{};

    void addCandidate(String value) {
      final cleaned = value.replaceAll(RegExp(r'\s+'), ' ').trim();
      if (cleaned.length >= 4 && RegExp(r'[A-Za-z]{2}').hasMatch(cleaned)) {
        candidates.add(cleaned);
      }
    }

    final ascii = StringBuffer();
    for (final byte in bytes) {
      if ((byte >= 32 && byte <= 126) || byte == 9 || byte == 10) {
        ascii.writeCharCode(byte);
      } else {
        if (ascii.length >= 4) addCandidate(ascii.toString());
        ascii.clear();
      }
    }
    if (ascii.length >= 4) addCandidate(ascii.toString());

    final unicode = StringBuffer();
    for (var index = 0; index + 1 < bytes.length; index += 2) {
      final low = bytes[index];
      final high = bytes[index + 1];
      if (high == 0 && ((low >= 32 && low <= 126) || low == 9 || low == 10)) {
        unicode.writeCharCode(low);
      } else {
        if (unicode.length >= 4) addCandidate(unicode.toString());
        unicode.clear();
      }
    }
    if (unicode.length >= 4) addCandidate(unicode.toString());

    return candidates.join('\n');
  }

  static String _normalizeText(String value) {
    return value
        .replaceAll('\u0000', '')
        .replaceAll(RegExp(r'[ \t]+'), ' ')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }

  static String _extensionOf(String fileName) {
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex < 0 || dotIndex == fileName.length - 1) return '';
    return fileName.substring(dotIndex + 1).toLowerCase();
  }
}
