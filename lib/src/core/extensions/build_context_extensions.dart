import 'package:flutter/widgets.dart';
import 'package:tic_tac_toe/src/core/l10n/app_localizations.dart';

extension BuildContextL10nExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
