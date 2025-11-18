import 'package:build/build.dart';

/// Builder that copies the (hidden, `build_to: cache`) output of
/// `build_web_compilers` into `web/` (visible, this builder is defined with
/// `build_to: source`).
class CopyCompiledJs extends Builder {
  CopyCompiledJs([BuilderOptions? options]);

  /// Mapping from input .dart.js files to output files
  static const _fileMappings = {
    'web/worker.dart.js': 'web/drift_worker.js',
    'web/service_worker.dart.js': 'web/sw.js',
  };

  @override
  Future<void> build(BuildStep buildStep) async {
    // Copy each compiled JS file to its destination
    for (final entry in _fileMappings.entries) {
      final inputId = AssetId(buildStep.inputId.package, entry.key);

      try {
        final input = await buildStep.readAsBytes(inputId);
        final outputId = AssetId(buildStep.inputId.package, entry.value);

        if (buildStep.allowedOutputs.contains(outputId)) {
          await buildStep.writeAsBytes(outputId, input);
        }
      } catch (_) {
        // File might not exist yet, continue with others
      }
    }
  }

  @override
  Map<String, List<String>> get buildExtensions => {
    r'$package$': _fileMappings.values.toList(),
  };
}
