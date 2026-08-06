import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_selector/file_selector.dart';
import '../models/attachment_model.dart';
import '../models/user_model.dart';

/// Uploads, lists, and deletes the files teachers attach to the Modules
/// panel. Files live in Firebase Storage under
/// `module_attachments/<uid>/<timestamp>_<filename>`; each upload also
/// gets a Firestore doc so the list can be shown/queried without
/// hitting Storage's listing API.
class ModuleService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  static const _collection = 'module_attachments';

  Stream<List<ModuleAttachment>> attachmentsStream() {
    return _db
        .collection(_collection)
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => ModuleAttachment.fromMap(d.id, d.data())).toList());
  }

  Future<void> pickAndUpload({
    required AppUser uploader,
    List<String>? allowedExtensions,
  }) async {
    final typeGroup = XTypeGroup(
      label: 'documents',
      extensions: allowedExtensions,
    );
    final XFile? picked = await openFile(acceptedTypeGroups: [typeGroup]);
    if (picked == null) { return; }

    final bytes = await picked.readAsBytes();
    final safeName = picked.name.replaceAll(RegExp(r'\s+'), '_');
    final storagePath =
        'module_attachments/${uploader.id}/${DateTime.now().millisecondsSinceEpoch}_$safeName';
    final ref = _storage.ref(storagePath);

    final snapshot = await ref.putData(bytes);
    final url = await snapshot.ref.getDownloadURL();

    final attachment = ModuleAttachment(
      id: '',
      title: picked.name,
      fileName: picked.name,
      url: url,
      storagePath: storagePath,
      uploadedByUid: uploader.id,
      uploadedByName: uploader.name,
      uploadedAt: null,
      sizeBytes: bytes.length,
    );
    await _db.collection(_collection).add(attachment.toMap());
  }

  Future<void> delete(ModuleAttachment attachment) async {
    await _db.collection(_collection).doc(attachment.id).delete();
    if (attachment.storagePath.isNotEmpty) {
      await _storage.ref(attachment.storagePath).delete();
    }
  }
}

