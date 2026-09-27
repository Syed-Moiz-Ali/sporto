import 'dart:io';
import 'dart:developer' as developer;

import 'package:core/core.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class PreparedImageUpload {
  const PreparedImageUpload({
    required this.path,
    required this.isTemporary,
  });

  final String path;
  final bool isTemporary;

  Future<void> dispose() async {
    if (!isTemporary) return;
    final file = File(path);
    if (await file.exists()) await file.delete();
  }
}

class UploadImageCompressor {
  const UploadImageCompressor();

  static const int targetBytes = 900 * 1024;
  static const List<int> _qualitySteps = [82, 70, 58, 46, 34];

  Future<PreparedImageUpload> prepare(String sourcePath) async {
    final source = File(sourcePath);
    if (!await source.exists()) {
      throw const SportoApiException(
          'The selected image is no longer available.');
    }
    if (await source.length() <= targetBytes) {
      return PreparedImageUpload(path: sourcePath, isTemporary: false);
    }

    String? smallestPath;
    int? smallestSize;
    try {
      for (final quality in _qualitySteps) {
        final outputPath =
            '${Directory.systemTemp.path}/sporto_referee_${DateTime.now().microsecondsSinceEpoch}_$quality.jpg';
        final compressedBytes = await FlutterImageCompress.compressWithFile(
          sourcePath,
          minWidth: 1600,
          minHeight: 1600,
          quality: quality,
          format: CompressFormat.jpeg,
          keepExif: false,
        );
        if (compressedBytes == null || compressedBytes.isEmpty) continue;

        final compressed = File(outputPath);
        await compressed.writeAsBytes(compressedBytes, flush: true);

        final size = await compressed.length();
        if (size <= targetBytes) {
          if (smallestPath != null && smallestPath != compressed.path) {
            await _deleteIfPresent(smallestPath);
          }
          return PreparedImageUpload(
            path: outputPath,
            isTemporary: true,
          );
        }

        if (smallestSize == null || size < smallestSize) {
          if (smallestPath != null) await _deleteIfPresent(smallestPath);
          smallestPath = outputPath;
          smallestSize = size;
        } else {
          await _deleteIfPresent(outputPath);
        }
      }
    } catch (error, stackTrace) {
      developer.log(
        'Referee onboarding image compression failed',
        name: 'SportoUpload',
        error: error,
        stackTrace: stackTrace,
      );
      if (smallestPath != null) await _deleteIfPresent(smallestPath);
      throw const SportoApiException(
        'Could not compress this image. Please choose a smaller image and retry.',
      );
    }

    if (smallestPath != null) await _deleteIfPresent(smallestPath);
    throw const SportoApiException(
      'The selected image is too large after compression. Please choose a lower-resolution image.',
    );
  }

  Future<void> _deleteIfPresent(String path) async {
    final file = File(path);
    if (await file.exists()) await file.delete();
  }
}
