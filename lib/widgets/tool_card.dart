import 'package:flutter/material.dart';
import 'package:p2lan/l10n/app_localizations.dart';

class ToolCard extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onTap;
  final IconData icon;
  final Color? iconColor;
  final bool showActions;
  final bool isSelected;
  final VoidCallback? onLongPress;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? quickActionCallback;

  const ToolCard({
    super.key,
    required this.title,
    required this.description,
    required this.onTap,
    this.icon = Icons.apps,
    this.iconColor,
    this.showActions = true,
    this.isSelected = false,
    this.onLongPress,
    this.onEdit,
    this.onDelete,
    this.quickActionCallback,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final showQuickAction = isMobile && quickActionCallback != null;

    return Card(
      elevation: isSelected ? 4 : 2,
      margin: const EdgeInsets.only(bottom: 16),
      color: isSelected ? colorScheme.primaryContainer : null,
      child: Tooltip(
        message: description,
        waitDuration: const Duration(milliseconds: 500),
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: isSelected
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colorScheme.primary,
                      width: 2,
                    ),
                  )
                : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(icon,
                      size: 28,
                      color: isSelected
                          ? colorScheme.primary
                          : (iconColor ?? colorScheme.primary)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected
                                ? colorScheme.onPrimaryContainer
                                : null,
                          ),
                    ),
                  ),
                  if (showQuickAction) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: quickActionCallback,
                      icon: const Icon(Icons.arrow_forward_ios),
                      iconSize: 20,
                      tooltip: AppLocalizations.of(context).quickAccess,
                      color: colorScheme.primary,
                    ),
                  ],
                  if (showActions && !showQuickAction)
                    PopupMenuButton<String>(
                      tooltip: AppLocalizations.of(context).options,
                      icon: const Icon(Icons.more_vert),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'info',
                          child: ListTile(
                            leading: const Icon(Icons.info_outline),
                            title: Text(AppLocalizations.of(context).about),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'info') {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(title),
                              content: Text(description),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child:
                                      Text(AppLocalizations.of(context).close),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
