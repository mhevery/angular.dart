library angular.tools.transformer.options;

import 'dart:async';

import 'package:barback/barback.dart';
import 'package:di/transformer/options.dart' as di;
import 'package:path/path.dart' as path;

/** Options used by Angular transformers */
class TransformOptions {

  /**
   * The file paths of the primary Dart entry point (main) for the application.
   * This is used as the starting point to find all expressions used by the
   * application.
   */
  final Set<String> dartEntries;

  /**
   * List of html file paths which may contain Angular expressions.
   * The paths are relative to the package home and are represented using posix
   * style, which matches the representation used in asset ids in barback.
   */
  final List<String> htmlFiles;

  /**
   * Path to the Dart SDK directory, for resolving Dart libraries.
   */
  final String sdkDirectory;

  /**
   * Template cache path modifiers
   */
  final Map<String, String> templateUriRewrites;

  /**
   * Dependency injection options.
   */
  final di.TransformOptions diOptions;

  TransformOptions({List<String> dartEntries,
      String sdkDirectory, List<String> htmlFiles,
      Map<String, String> templateUriRewrites,
      di.TransformOptions diOptions})
    : dartEntries = dartEntries.toSet(),
      sdkDirectory = sdkDirectory,
      htmlFiles = htmlFiles != null ? htmlFiles : [],
      templateUriRewrites = templateUriRewrites != null ?
          templateUriRewrites : {},
      diOptions = diOptions {
    if (sdkDirectory == null)
      throw new ArgumentError('sdkDirectory must be provided.');
  }

  // Don't need to check package as transformers only run for primary package.
  Future<bool> isDartEntry(AssetId id) =>
      new Future.value(dartEntries.contains(id.path));
}
