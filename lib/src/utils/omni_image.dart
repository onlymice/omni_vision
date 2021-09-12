import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:omni_vision/src/utils/utils.dart';

class OmniImage {
  OmniImage({required CameraImage image, required int rotation}) {
    this.format = image.format;
    this.height = image.height;
    this.width = image.width;
    this.lensAperture = image.lensAperture;
    this.planes = image.planes;
    this.sensorExposureTime = image.sensorExposureTime;
    this.sensorSensitivity = image.sensorSensitivity;
    this.rotation = rotation;
  }

  InputImage toInputImage(CameraImage image) => InputImage.fromBytes(
        bytes: OmniUtils.concatenatePlanes(image.planes),
        inputImageData: OmniUtils.buildMetaData(image, this.rotation.toInputImageRotation()),
      );

  late final int rotation;

  /// Format of the image provided.
  ///
  /// Determines the number of planes needed to represent the image, and
  /// the general layout of the pixel data in each [Uint8List].
  late final ImageFormat format;

  /// Height of the image in pixels.
  ///
  /// For formats where some color channels are subsampled, this is the height
  /// of the largest-resolution plane.
  late final int height;

  /// Width of the image in pixels.
  ///
  /// For formats where some color channels are subsampled, this is the width
  /// of the largest-resolution plane.
  late final int width;

  /// The pixels planes for this image.
  ///
  /// The number of planes is determined by the format of the image.
  late final List<Plane> planes;

  /// The aperture settings for this image.
  ///
  /// Represented as an f-stop value.
  late final double? lensAperture;

  /// The sensor exposure time for this image in nanoseconds.
  late final int? sensorExposureTime;

  /// The sensor sensitivity in standard ISO arithmetic units.
  late final double? sensorSensitivity;
}
