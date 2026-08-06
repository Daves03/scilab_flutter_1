// Stub for gal package on web platform
// ignore_for_file: avoid_classes_with_only_static_members
class Gal {
  static Future<void> putImageBytes(List<int> bytes, {String? name}) async {
    // No-op on web — web uses html anchor download instead
  }
}
