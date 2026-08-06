import 'dart:typed_data';
import 'package:gal/gal.dart';

// gallery_saver_mobile.dart — used only on non-web platforms

Future<void> saveImageBytesToGallery(List<int> bytes, String name) async {
  await Gal.putImageBytes(Uint8List.fromList(bytes), name: name);
}