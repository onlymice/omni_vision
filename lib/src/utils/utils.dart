import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:omni_vision/src/utils/omni_image.dart';
import 'package:omni_vision/src/widgets/vision.dart';

part 'google_ml_kit.dart';
part 'tflite.dart';

class OmniUtils {
  static Future<CameraDescription?> getCamera(CameraLensDirection dir) async {
    final cameras = await availableCameras();
    final camera = cameras.firstWhereOrNull((camera) => camera.lensDirection == dir);
    return camera ?? (cameras.isEmpty ? null : cameras.first);
  }

  static InputImageData buildMetaData(
    CameraImage image,
    InputImageRotation rotation,
  ) {
    return InputImageData(
      inputImageFormat: image.format.raw,
      size: Size(image.width.toDouble(), image.height.toDouble()),
      imageRotation: rotation,
      planeData: image.planes
          .map(
            (plane) => InputImagePlaneMetadata(
              bytesPerRow: plane.bytesPerRow,
              height: plane.height,
              width: plane.width,
            ),
          )
          .toList(),
    );
  }

  static Uint8List concatenatePlanes(List<Plane> planes) {
    final allBytes = WriteBuffer();
    planes.forEach((plane) => allBytes.putUint8List(plane.bytes));
    return allBytes.done().buffer.asUint8List();
  }

  static Future<T> detect<T>(
    CameraImage image,
    HandleDetection<T> handleDetection,
    int rotation,
  ) async {
    return handleDetection(OmniImage(image: image, rotation: rotation));
  }
}

extension RotationParsing on int {
  InputImageRotation toInputImageRotation() {
    switch (this) {
      case 0:
        return InputImageRotation.Rotation_0deg;
      case 90:
        return InputImageRotation.Rotation_90deg;
      case 180:
        return InputImageRotation.Rotation_180deg;
      default:
        assert(this == 270);
        return InputImageRotation.Rotation_180deg;
    }
  }
}

extension FirstWhereOrNullExtension<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E) test) {
    for (E element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
