import 'package:flutter/material.dart';
import 'package:p2lan/l10n/app_localizations.dart';

class ImportResult {
  final String fileName;
  final bool success;
  final String? errorMessage;

  ImportResult({
    required this.fileName,
    required this.success,
    this.errorMessage,
  });
}

class ImportStatusDialog extends StatelessWidget {
  final List<ImportResult> results;

  const ImportStatusDialog({
    super.key,
    required this.results,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final successfulImports = results.where((r) => r.success).toList();
    final failedImports = results.where((r) => !r.success).toList();

    return AlertDialog(
      title: Text(l10n.importResults),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary
            Text(
              l10n.importSummary(
                  failedImports.length, successfulImports.length),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),

            // Results details
            if (results.isEmpty)
              Text(l10n.noImportsAttempted)
            else
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Successful imports
                      if (successfulImports.isNotEmpty) ...[
                        Text(
                          l10n.successfulImports(successfulImports.length),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...successfulImports.map((result) => Padding(
                              padding:
                                  const EdgeInsets.only(left: 16, bottom: 4),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    size: 16,
                                    color: Colors.green[700],
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      result.fileName,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                  ),
                                ],
                              ),
                            )),
                        const SizedBox(height: 16),
                      ],

                      // Failed imports
                      if (failedImports.isNotEmpty) ...[
                        Text(
                          l10n.failedImports(failedImports.length),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...failedImports.map((result) => Padding(
                              padding:
                                  const EdgeInsets.only(left: 16, bottom: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.error,
                                        size: 16,
                                        color: Colors.red[700],
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          result.fileName,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (result.errorMessage != null)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 24, top: 2),
                                      child: Text(
                                        result.errorMessage!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Colors.red[600],
                                            ),
                                      ),
                                    ),
                                ],
                              ),
                            )),
                      ],
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.close),
        ),
      ],
    );
  }
}
