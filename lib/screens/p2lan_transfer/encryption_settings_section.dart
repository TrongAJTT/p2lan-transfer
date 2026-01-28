import 'package:flutter/material.dart';
import 'package:p2lan/l10n/app_localizations.dart';
import 'package:p2lan/models/p2p_models.dart';
import 'package:p2lan/services/crypto_service.dart';
import 'package:p2lan/widgets/generic/option_list_picker.dart';
import 'package:p2lan/widgets/generic/option_item.dart';

/// Encryption settings section widget for P2P transfer settings
class EncryptionSettingsSection extends StatelessWidget {
  final EncryptionType currentEncryptionType;
  final Function(EncryptionType) onEncryptionTypeChanged;
  final bool isCompact;

  const EncryptionSettingsSection({
    super.key,
    required this.currentEncryptionType,
    required this.onEncryptionTypeChanged,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            Icon(
              Icons.security,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              l10n.securityAndEncryption,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Encryption type picker
        OptionListPicker<EncryptionType>(
          options: _buildEncryptionOptions(l10n),
          selectedValue: currentEncryptionType,
          onChanged: (value) =>
              onEncryptionTypeChanged(value as EncryptionType),
          allowNull: false,
          showSelectionControl: true,
          isCompact: isCompact,
        ),

        const SizedBox(height: 12),

        // Information card about the selected encryption
        Card(
          color: Theme.of(context)
              .colorScheme
              .surfaceContainerHighest
              .withValues(alpha: 0.3),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 18,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.about,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _getEncryptionDetailedDescription(
                      currentEncryptionType, l10n),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize:
                            Theme.of(context).textTheme.bodyMedium?.fontSize,
                      ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<OptionItem<EncryptionType>> _buildEncryptionOptions(
      AppLocalizations l10n) {
    return [
      OptionItem<EncryptionType>.withIcon(
        value: EncryptionType.none,
        label: CryptoService.getEncryptionDisplayName(EncryptionType.none),
        subtitle:
            CryptoService.getEncryptionDescription(EncryptionType.none, l10n),
        iconData: Icons.no_encryption,
      ),
      OptionItem<EncryptionType>.withIcon(
        value: EncryptionType.aesGcm,
        label: CryptoService.getEncryptionDisplayName(EncryptionType.aesGcm),
        subtitle:
            CryptoService.getEncryptionDescription(EncryptionType.aesGcm, l10n),
        iconData: Icons.enhanced_encryption,
      ),
      OptionItem<EncryptionType>.withIcon(
        value: EncryptionType.chaCha20,
        label: CryptoService.getEncryptionDisplayName(EncryptionType.chaCha20),
        subtitle: CryptoService.getEncryptionDescription(
            EncryptionType.chaCha20, l10n),
        iconData: Icons.security,
      ),
    ];
  }

  IconData _getEncryptionIcon(EncryptionType type) {
    switch (type) {
      case EncryptionType.none:
        return Icons.no_encryption;
      case EncryptionType.aesGcm:
        return Icons.enhanced_encryption;
      case EncryptionType.chaCha20:
        return Icons.security;
    }
  }

  String _getEncryptionDetailedDescription(
      EncryptionType type, AppLocalizations l10n) {
    switch (type) {
      case EncryptionType.none:
        return l10n.p2lanOptionEncryptionNoneAbout;
      case EncryptionType.aesGcm:
        return l10n.p2lanOptionEncryptionAesGcmAbout;
      case EncryptionType.chaCha20:
        return l10n.p2lanOptionEncryptionChaCha20About;
    }
  }
}
