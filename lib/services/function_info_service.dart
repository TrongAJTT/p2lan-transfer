import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:p2lan/parsers/markdown_info_parser.dart';
import 'package:p2lan/services/app_logger.dart';
import 'package:p2lan/utils/snackbar_utils.dart';
import 'package:p2lan/widgets/generic/generic_settings_helper.dart';
import 'package:p2lan/widgets/generic_function_info_screen.dart';

class FunctionInfo {
  static Future<void> show(BuildContext context, String featureName) async {
    late String path;
    try {
      // Get the locale to determine the language
      final locale = Localizations.localeOf(context);
      final langCode = locale.languageCode; // 'vi' or 'en'

      // Load the markdown file based on featureName and language
      path = 'assets/func_info/${featureName}_$langCode.md';
      final content = await rootBundle.loadString(path);

      // Parse the markdown content
      final parser = MarkdownInfoParser();
      final infoPage = parser.parse(content);

      // Show the info page in a dialog
      if (context.mounted) {
        GenericSettingsHelper.showSettings(
          context,
          GenericSettingsConfig<SingleChildScrollView>(
            title: infoPage.title,
            settingsLayout: GenericInfoScreen(
              page: infoPage,
            ),
            onSettingsChanged: (newInfo) {
              // Handle any changes if needed
            },
            showActions: true,
            isCompact: false,
            // preferredSize: const Size.fromHeight(600), // Dialog size
            barrierDismissible: true,
          ),
        );
      }
    } catch (e) {
      // Handle errors gracefully
      logError('Error showing function info: $e');
      if (context.mounted) {
        SnackbarUtils.showTyped(
          context,
          'Could not load information for $path.',
          SnackBarType.error,
        );
      }
    }
  }

  static Widget buildSectionsFromText(String text) {
    try {
      final parser = MarkdownInfoParser();
      final infoSections = parser.parseSections(text);
      return GenericInfoSectionList(sections: infoSections);
    } catch (e) {
      logError('Error parsing function info text: $e');
      return Center(
        child: Text(
          'Error loading information. Details: $e',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }
  }
}

class FunctionInfoKeys {
  static const String p2lanDataTransfer = 'p2lanDataTransfer';
  static const String remoteControlHelp = 'remoteControlHelp';

  static const String currencyConverter = 'converter_tools/currencyConverter';
  static const String lengthConverter = 'converter_tools/lengthConverter';
  static const String weightConverter = 'converter_tools/weightConverter';
  static const String temperatureConverter =
      'converter_tools/temperatureConverter';
  static const String massConverter = 'converter_tools/massConverter';
  static const String speedConverter = 'converter_tools/speedConverter';
  static const String areaConverter = 'converter_tools/areaConverter';
  static const String volumeConverter = 'converter_tools/volumeConverter';
  static const String timeConverter = 'converter_tools/timeConverter';
  static const String powerConverter = 'converter_tools/powerConverter';
  static const String energyConverter = 'converter_tools/energyConverter';
  static const String pressureConverter = 'converter_tools/pressureConverter';
  static const String dataConverter = 'converter_tools/dataConverter';
  static const String angleConverter = 'converter_tools/angleConverter';
  static const String frequencyConverter = 'converter_tools/frequencyConverter';
  static const String numberSystemConverter =
      'converter_tools/numberSystemConverter';

  static const String scientificCalculator =
      'calculator_tools/scientificCalculator';
  static const String graphingCalculator =
      'calculator_tools/graphingCalculator';
  static const String bmiCalculator = 'calculator_tools/bmiCalculator';
  static const String financialCalculator =
      'calculator_tools/financialCalculator';
  static const String dateCalculator = 'calculator_tools/dateCalculator';
  static const String discountCalculator =
      'calculator_tools/discountCalculator';
}
