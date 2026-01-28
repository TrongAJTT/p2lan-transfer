import 'package:flutter/material.dart';
import 'package:p2lan/view_models/p2p_view_model.dart';
import 'package:p2lan/view_models/commands/p2p_commands.dart';
import 'package:p2lan/view_models/states/p2p_ui_state.dart';

/// Widget that rebuilds when ViewModel state changes
class ViewModelBuilder<T extends ChangeNotifier> extends StatefulWidget {
  final T viewModel;
  final Widget Function(BuildContext context, T viewModel, Widget? child)
      builder;
  final Widget? child;

  const ViewModelBuilder({
    super.key,
    required this.viewModel,
    required this.builder,
    this.child,
  });

  @override
  State<ViewModelBuilder<T>> createState() => _ViewModelBuilderState<T>();
}

class _ViewModelBuilderState<T extends ChangeNotifier>
    extends State<ViewModelBuilder<T>> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_onViewModelChanged);
  }

  @override
  void didUpdateWidget(ViewModelBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.viewModel != widget.viewModel) {
      oldWidget.viewModel.removeListener(_onViewModelChanged);
      widget.viewModel.addListener(_onViewModelChanged);
    }
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_onViewModelChanged);
    super.dispose();
  }

  void _onViewModelChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, widget.viewModel, widget.child);
  }
}

/// Specialized builder for P2P ViewModel
class P2PViewModelBuilder extends StatelessWidget {
  final P2PViewModel viewModel;
  final Widget Function(
      BuildContext context, P2PViewModel viewModel, P2PUIState uiState) builder;

  const P2PViewModelBuilder({
    super.key,
    required this.viewModel,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<P2PViewModel>(
      viewModel: viewModel,
      builder: (context, viewModel, child) {
        return builder(context, viewModel, viewModel.uiState);
      },
    );
  }
}

/// Mixin for widgets that execute commands
mixin CommandExecutor {
  /// Execute a command on the view model
  Future<void> executeCommand(
      P2PViewModel viewModel, P2PCommand command) async {
    await viewModel.executeCommand(command);
  }

  /// Execute multiple commands
  Future<void> executeCommands(
      P2PViewModel viewModel, List<P2PCommand> commands) async {
    for (final command in commands) {
      await viewModel.executeCommand(command);
    }
  }
}

/// Helper class for creating commonly used commands
class P2PCommands {
  /// UI Commands
  static SwitchTabCommand switchTab(int index) => SwitchTabCommand(index);

  static ToggleDeviceSectionCommand toggleDeviceSection(String section) =>
      ToggleDeviceSectionCommand(section);

  static ToggleTransferFilterCommand toggleTransferFilter() =>
      ToggleTransferFilterCommand();

  static ToggleStatusCardCommand toggleStatusCard(String cardKey) =>
      ToggleStatusCardCommand(cardKey);

  static UpdateCompactLayoutCommand updateCompactLayout(bool useCompact) =>
      UpdateCompactLayoutCommand(useCompact);

  static ToggleKeyboardShortcutsCommand toggleKeyboardShortcuts(bool enabled) =>
      ToggleKeyboardShortcutsCommand(enabled);

  /// Business Commands
  static StartNetworkingCommand startNetworking() => StartNetworkingCommand();

  static StopNetworkingCommand stopNetworking() => StopNetworkingCommand();

  static ManualDiscoveryCommand manualDiscovery() => ManualDiscoveryCommand();

  static ClearAllTransfersCommand clearAllTransfers(
          {bool deleteFiles = false}) =>
      ClearAllTransfersCommand(deleteFiles: deleteFiles);

  static ClearTransferCommand clearTransfer(String taskId,
          {bool deleteFile = false}) =>
      ClearTransferCommand(taskId: taskId, deleteFile: deleteFile);

  static CancelTransferCommand cancelTransfer(String taskId) =>
      CancelTransferCommand(taskId);

  static AddTrustCommand addTrust(String userId) => AddTrustCommand(userId);

  static RemoveTrustCommand removeTrust(String userId) =>
      RemoveTrustCommand(userId);

  static UnpairUserCommand unpairUser(String userId) =>
      UnpairUserCommand(userId);

  static ReloadCacheSizeCommand reloadCacheSize() => ReloadCacheSizeCommand();

  static ClearFileCacheCommand clearFileCache() => ClearFileCacheCommand();

  static ReloadTransferSettingsCommand reloadTransferSettings() =>
      ReloadTransferSettingsCommand();
}

/// Extension to make command execution easier
extension P2PViewModelCommandExtensions on P2PViewModel {
  /// Quick command execution
  Future<void> execute(P2PCommand command) async {
    await executeCommand(command);
  }

  /// Execute multiple commands
  Future<void> executeAll(List<P2PCommand> commands) async {
    for (final command in commands) {
      await executeCommand(command);
    }
  }
}
