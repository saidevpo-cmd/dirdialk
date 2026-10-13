import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart' show BuildContext;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import 'app_images.dart';
import 'image_store.dart';

/// Outcome of an image selection attempt. Exactly one of [reference]/[error] is
/// non-null, or both are null when the user cancelled.
class PickImageOutcome {
  const PickImageOutcome._(this.reference, this.error);

  const PickImageOutcome.cancelled() : this._(null, null);
  const PickImageOutcome.success(String reference) : this._(reference, null);
  const PickImageOutcome.failure(String error) : this._(null, error);

  final String? reference;
  final String? error;

  bool get isSuccess => reference != null;
  bool get isCancelled => reference == null && error == null;
  bool get isFailure => error != null;
}

/// Recommended ratios used across the app. Recommendations only: any uploaded
/// image is accepted and never stretched (cards use `BoxFit.cover`).
class ImageSpecs {
  ImageSpecs._();

  static const double productAspectRatio = 4 / 5; // 800 x 1000
  static const double categoryAspectRatio = 1; // 600 x 600
  static const double bannerAspectRatio = 1600 / 600;
}

/// Handles the full pick → crop/reposition → persist pipeline and converts all
/// platform failures into user-presentable outcomes.
///
/// The service is injectable so widget tests can supply fakes and never touch
/// platform channels.
class ImageService {
  ImageService({
    ImagePicker? picker,
    ImageCropper? cropper,
    ImageStore? store,
    this.maxBytes = 12 * 1024 * 1024,
  })  : _picker = picker ?? ImagePicker(),
        _cropper = cropper ?? ImageCropper(),
        _store = store ?? AppImages.instance;

  final ImagePicker _picker;
  final ImageCropper _cropper;
  final ImageStore _store;

  /// Upper bound for a single stored image (12 MB by default).
  final int maxBytes;

  /// Lets the user select an image from their device and optionally crop or
  /// reposition it. Returns a `localimg://` reference on success.
  Future<PickImageOutcome> pickAndStore({
    double aspectRatio = ImageSpecs.productAspectRatio,
    int maxWidth = 1600,
    int maxHeight = 2000,
    bool allowCrop = true,
    required BuildContext context,
  }) async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
        imageQuality: 88,
      );
      if (picked == null) return const PickImageOutcome.cancelled();

      Uint8List bytes = await _readPicked(picked);
      if (bytes.isEmpty) {
        return const PickImageOutcome.failure('The selected file is empty.');
      }
      if (bytes.lengthInBytes > maxBytes) {
        return PickImageOutcome.failure(
          'Image is too large (${_mb(bytes.lengthInBytes)} MB). '
          'Please choose a smaller image.',
        );
      }

      if (allowCrop && context.mounted) {
        final cropped = await _tryCrop(
          picked,
          aspectRatio: aspectRatio,
          maxWidth: maxWidth,
          maxHeight: maxHeight,
          context: context,
        );
        if (cropped != null) bytes = cropped;
      }

      final id = await _store.save(bytes);
      return PickImageOutcome.success(ImageRef.forId(id));
    } catch (error) {
      return PickImageOutcome.failure('Could not read the image: $error');
    }
  }

  Future<Uint8List> _readPicked(XFile picked) => picked.readAsBytes();

  Future<Uint8List?> _tryCrop(
    XFile picked, {
    required double aspectRatio,
    required int maxWidth,
    required int maxHeight,
    required BuildContext context,
  }) async {
    try {
      final uiSettings = <PlatformUiSettings>[
        AndroidUiSettings(
          toolbarTitle: 'Crop image',
          lockAspectRatio: true,
          aspectRatioPresets: [
            _presetFor(aspectRatio),
            CropAspectRatioPreset.original,
          ],
        ),
        IOSUiSettings(
          title: 'Crop image',
          aspectRatioLockEnabled: true,
        ),
      ];
      if (kIsWeb && context.mounted) {
        uiSettings.add(WebUiSettings(context: context));
      }

      final cropped = await _cropper.cropImage(
        sourcePath: picked.path,
        aspectRatio: CropAspectRatio(ratioX: aspectRatio, ratioY: 1),
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 88,
        uiSettings: uiSettings,
      );
      if (cropped == null) return null; // user cancelled crop, keep original
      return await cropped.readAsBytes();
    } catch (_) {
      // Cropping is best-effort; if the platform does not support it we still
      // persist the original picked bytes.
      return null;
    }
  }

  CropAspectRatioPreset _presetFor(double ratio) {
    if ((ratio - 1).abs() < 0.01) return CropAspectRatioPreset.square;
    if ((ratio - 16 / 9).abs() < 0.01) return CropAspectRatioPreset.ratio16x9;
    if ((ratio - 3 / 2).abs() < 0.01) return CropAspectRatioPreset.ratio3x2;
    if ((ratio - 4 / 3).abs() < 0.01) return CropAspectRatioPreset.ratio4x3;
    return CropAspectRatioPreset.original;
  }

  String _mb(int bytes) => (bytes / (1024 * 1024)).toStringAsFixed(1);
}
