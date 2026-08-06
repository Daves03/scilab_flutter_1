import 'package:cloud_firestore/cloud_firestore.dart';

/// A single file a teacher has attached to the Modules panel.
/// Mirrors one document in Firestore `module_attachments`; the actual
/// bytes live in Firebase Storage, this doc points at the download URL.
class ModuleAttachment {
  final String id;
  final String title;
  final String fileName;
  final String url;
  final String storagePath;
  final String uploadedByUid;
  final String uploadedByName;
  final DateTime? uploadedAt;
  final int sizeBytes;

  ModuleAttachment({
    required this.id,
    required this.title,
    required this.fileName,
    required this.url,
    required this.storagePath,
    required this.uploadedByUid,
    required this.uploadedByName,
    required this.uploadedAt,
    required this.sizeBytes,
  });

  String get extension {
    final dot = fileName.lastIndexOf('.');
    if (dot == -1 || dot == fileName.length - 1) { return ''; }
    return fileName.substring(dot + 1).toLowerCase();
  }

  String get friendlySize {
    if (sizeBytes <= 0) { return ''; }
    const kb = 1024;
    const mb = kb * 1024;
    if (sizeBytes >= mb) return '${(sizeBytes / mb).toStringAsFixed(1)} MB';
    return '${(sizeBytes / kb).ceil()} KB';
  }

  factory ModuleAttachment.fromMap(String id, Map<String, dynamic> data) {
    final ts = data['uploadedAt'];
    return ModuleAttachment(
      id: id,
      title: (data['title'] as String?) ?? (data['fileName'] as String? ?? 'Untitled'),
      fileName: (data['fileName'] as String?) ?? '',
      url: (data['url'] as String?) ?? '',
      storagePath: (data['storagePath'] as String?) ?? '',
      uploadedByUid: (data['uploadedByUid'] as String?) ?? '',
      uploadedByName: (data['uploadedByName'] as String?) ?? 'Teacher',
      uploadedAt: ts is Timestamp ? ts.toDate() : null,
      sizeBytes: (data['sizeBytes'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'fileName': fileName,
        'url': url,
        'storagePath': storagePath,
        'uploadedByUid': uploadedByUid,
        'uploadedByName': uploadedByName,
        'uploadedAt': FieldValue.serverTimestamp(),
        'sizeBytes': sizeBytes,
      };
}

