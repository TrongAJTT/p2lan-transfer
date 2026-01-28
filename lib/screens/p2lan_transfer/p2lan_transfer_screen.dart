import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:p2lan/l10n/app_localizations.dart';
import 'package:p2lan/layouts/three_panels_layout.dart';
import 'package:p2lan/models/p2p_models.dart';
import 'package:p2lan/services/settings_models_service.dart';
import 'package:p2lan/screens/main_settings.dart';
import 'package:p2lan/screens/p2lan_transfer/p2lan_chat_screen.dart';
import 'package:p2lan/screens/p2lan_transfer/p2lan_local_files_screen.dart';
import 'package:p2lan/screens/p2lan_transfer/remote_control_screen.dart';
import 'package:p2lan/screens/p2lan_transfer/screen_sharing_viewer_screen.dart';
import 'package:p2lan/services/function_info_service.dart';
import 'package:p2lan/utils/generic_dialog_utils.dart';
import 'package:p2lan/utils/permission_utils.dart';
import 'package:p2lan/utils/url_utils.dart';
import 'package:p2lan/utils/variables_utils.dart';
import 'package:p2lan/variables.dart';
import 'package:p2lan/widgets/generic/icon_button_list.dart';
import 'package:p2lan/widgets/p2p/network_security_warning_dialog.dart';
import 'package:p2lan/widgets/p2p/pairing_request_dialog.dart';
import 'package:p2lan/widgets/p2p/file_transfer_request_dialog.dart';
import 'package:p2lan/widgets/p2p/user_pairing_dialog.dart';
import 'package:p2lan/widgets/p2p/remote_control_dialogs.dart';
import 'package:p2lan/widgets/p2p/screen_sharing_request_dialog.dart';
import 'package:p2lan/widgets/floating_window_manager.dart';

import 'package:p2lan/widgets/hold_to_confirm_dialog.dart';
import 'package:p2lan/services/app_logger.dart';
import 'package:p2lan/utils/generic_settings_utils.dart';
import 'package:p2lan/widgets/p2p/user_info_dialog.dart';
import 'package:p2lan/widgets/p2p/multi_file_sender_dialog.dart';
import 'package:p2lan/widgets/p2p/device_info_card.dart';
import 'package:p2lan/widgets/p2p/transfer_batch_widget.dart';
import 'package:p2lan/widgets/manual_connect_dialog.dart';
import 'package:p2lan/services/network_security_service.dart';
import 'package:p2lan/services/p2p_services/p2p_navigation_service.dart';
import 'package:p2lan/services/p2p_services/p2p_notification_service.dart';
import 'package:p2lan/utils/snackbar_utils.dart';
import 'package:p2lan/utils/generic_table_builder.dart' as table_builder;
import 'package:p2lan/utils/shortcut_tooltip_utils.dart';

// Import MVVM components
import 'package:p2lan/view_models/p2p_view_model.dart';
import 'package:p2lan/view_models/widgets/command_builder.dart';
import 'package:p2lan/view_models/commands/p2p_commands.dart';
import 'package:p2lan/view_models/states/p2p_ui_state.dart';

/// P2P Transfer Screen following proper MVVM pattern
/// - Only contains UI logic and widgets
/// - Communicates with ViewModel through commands
/// - No business logic or direct service calls
class P2LanTransferScreen extends StatefulWidget {
  final bool isEmbedded;
  final Function(Widget, String, {String? parentCategory, IconData? icon})?
      onToolSelected;

  const P2LanTransferScreen({
    super.key,
    this.isEmbedded = false,
    this.onToolSelected,
  });

  @override
  State<P2LanTransferScreen> createState() => _P2LanTransferScreenState();
}

class _P2LanTransferScreenState extends State<P2LanTransferScreen>
    with CommandExecutor {
  // =============================================================================
  // FIELDS - ONLY UI RELATED
  // =============================================================================

  late P2PViewModel _viewModel;
  final ScrollController _transfersScrollController = ScrollController();
  final FocusNode _keyboardFocusNode = FocusNode();

  // =============================================================================
  // LIFECYCLE
  // =============================================================================

  @override
  void initState() {
    super.initState();
    _viewModel = P2PViewModel();

    // Set up callbacks for auto-showing dialogs
    _viewModel.setNewPairingRequestCallback(_onNewPairingRequest);
    _viewModel.setNewFileTransferRequestCallback(_onNewFileTransferRequest);
    _viewModel.setNewRemoteControlRequestCallback(_onNewRemoteControlRequest);
    _viewModel.setRemoteControlAcceptedCallback(_onRemoteControlAccepted);
    _viewModel.setNewScreenSharingRequestCallback(_onNewScreenSharingRequest);
    _viewModel
        .setScreenSharingSessionStartedCallback(_onScreenSharingSessionStarted);

    // Set up navigation callbacks for P2P
    P2PNavigationService.instance.setP2LanCallbacks(
      switchTabCallback: _switchToTab,
      showDialogCallback: _showDialogFromNotification,
      getCurrentTabCallback: () => _viewModel.uiState.currentTabIndex,
    );

    // Set up notification callbacks (only if service is available)
    final notificationService = P2PNotificationService.instanceOrNull;
    if (notificationService != null) {
      notificationService.setCallbacks(
        onNotificationTapped: _handleNotificationTapped,
        onActionPressed: _handleNotificationAction,
      );
    }

    // Initialize view model
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeViewModel();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Request focus for keyboard shortcuts on desktop
    final isDesktop = !isMobileLayoutContext(context);
    if (_viewModel.uiState.enableKeyboardShortcuts && isDesktop) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_keyboardFocusNode.hasFocus) {
          _keyboardFocusNode.requestFocus();
        }
      });
    }
  }

  @override
  void didUpdateWidget(P2LanTransferScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Process pending requests when returning to screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.processPendingFileTransferRequests();
      executeCommand(_viewModel, P2PCommands.reloadTransferSettings());
    });
  }

  @override
  void dispose() {
    // Clear callbacks
    _viewModel.clearNewPairingRequestCallback();
    _viewModel.clearNewFileTransferRequestCallback();
    _viewModel.clearNewRemoteControlRequestCallback();
    _viewModel.clearRemoteControlAcceptedCallback();
    _viewModel.clearScreenSharingSessionStartedCallback();
    P2PNavigationService.instance.clearP2LanCallbacks();

    final notificationService = P2PNotificationService.instanceOrNull;
    if (notificationService != null) {
      notificationService.clearCallbacks();
    }

    // Dispose resources
    _viewModel.dispose();
    _transfersScrollController.dispose();
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  // =============================================================================
  // INITIALIZATION
  // =============================================================================

  /// Initialize the view model
  Future<void> _initializeViewModel() async {
    await _viewModel.initialize();
  }

  // =============================================================================
  // EVENT HANDLERS - CALLBACKS
  // =============================================================================

  /// Handle new pairing request
  void _onNewPairingRequest(PairingRequest request) {
    if (mounted) {
      logInfo(
          'Auto-showing pairing request dialog for: ${request.fromUserName}');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSinglePairingRequestDialog(request);
      });
    }
  }

  /// Handle new file transfer request
  void _onNewFileTransferRequest(FileTransferRequest request) {
    if (mounted) {
      logInfo(
          'Auto-showing file transfer request dialog from: ${request.fromUserName}');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showFileTransferRequestDialog(request);
      });
    }
  }

  /// Handle when remote control request is accepted - sender should navigate to control screen
  void _onRemoteControlAccepted(P2PUser user) {
    print(
        '[DEBUG] Remote control accepted for user: ${user.displayName}, navigating to control screen');
    _navigateToRemoteControlScreen(user);
  }

  /// Handle new remote control request
  void _onNewRemoteControlRequest(RemoteControlRequest request) {
    if (mounted) {
      logInfo(
          'Auto-showing remote control request dialog from: ${request.fromUserName}');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showRemoteControlRequestDialog(request);
      });
    }
  }

  void _onNewScreenSharingRequest(ScreenSharingRequest request) {
    if (mounted) {
      logInfo(
          'Auto-showing screen sharing request dialog from: ${request.fromUserId}');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showScreenSharingRequestDialog(request);
      });
    }
  }

  /// Handle when screen sharing session started - receiver should open viewer window
  void _onScreenSharingSessionStarted(ScreenSharingSession session) {
    logInfo(
        '[DEBUG] _onScreenSharingSessionStarted called with session: ${session.senderUser.displayName} -> ${session.receiverUser.displayName}');

    // Only open viewer if we are the receiver
    final currentUser = _viewModel.currentUser;
    logInfo(
        '[DEBUG] currentUser: ${currentUser?.displayName}, mounted: $mounted');

    if (mounted && currentUser != null) {
      final isReceiver = session.receiverUser.id == currentUser.id;
      logInfo(
          '[DEBUG] isReceiver: $isReceiver (session.receiverUser.id=${session.receiverUser.id}, currentUser.id=${currentUser.id})');

      if (isReceiver) {
        logInfo(
            'Screen sharing session started, auto-opening viewer window for: ${session.senderUser.displayName}');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          logInfo(
              '[DEBUG] PostFrameCallback executing, calling _openScreenSharingViewer');
          _openScreenSharingViewer(session);
        });
      } else {
        logInfo('[DEBUG] Not receiver, skipping auto-open viewer');
      }
    } else {
      logInfo('[DEBUG] Mounted=$mounted or currentUser is null, skipping');
    }
  }

  // =============================================================================
  // EVENT HANDLERS - NAVIGATION
  // =============================================================================

  /// Navigate to chat screen
  void _navigateToChatScreen({String? initialUserBId}) {
    _disableKeyboardShortcuts();

    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => P2LanChatListScreen(
          viewModel: _viewModel, // Note: chat screen still uses old interface
          initialUserBId: initialUserBId,
        ),
      ),
    )
        .then((_) {
      _enableKeyboardShortcutsOnReturn();
    });
  }

  /// Navigate to remote control screen
  void _navigateToRemoteControlScreen(P2PUser targetUser) {
    _disableKeyboardShortcuts();

    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => RemoteControlScreen(
          targetUser: targetUser,
        ),
      ),
    )
        .then((_) {
      _enableKeyboardShortcutsOnReturn();
    });
  }

  /// Navigate to local files viewer
  void _navigateToFilesViewer() async {
    if (Platform.isAndroid) {
      _disableKeyboardShortcuts();

      Navigator.of(context)
          .push(
        MaterialPageRoute(
          builder: (context) => const P2LanLocalFilesScreen(),
        ),
      )
          .then((_) {
        _enableKeyboardShortcutsOnReturn();
      });
    } else if (Platform.isWindows) {
      final settings = await ExtensibleSettingsService.getReceiverSettings();
      UriUtils.openFolderInFileExplorer(settings.downloadPath);
    }
    // Handle other platforms here.
  }

  /// Navigate to settings
  void _navigateToSettings() {
    _disableKeyboardShortcuts();

    Navigator.of(context)
        .push(
      MaterialPageRoute(builder: (context) => const MainSettingsScreen()),
    )
        .then((_) {
      _enableKeyboardShortcutsOnReturn();
    });
  }

  // =============================================================================
  // EVENT HANDLERS - KEYBOARD SHORTCUTS
  // =============================================================================

  /// Disable keyboard shortcuts when navigating away
  void _disableKeyboardShortcuts() {
    executeCommand(_viewModel, P2PCommands.toggleKeyboardShortcuts(false));
    if (_keyboardFocusNode.hasFocus) {
      _keyboardFocusNode.unfocus();
    }
  }

  /// Re-enable keyboard shortcuts when returning
  void _enableKeyboardShortcutsOnReturn() {
    executeCommand(_viewModel, P2PCommands.toggleKeyboardShortcuts(true));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _viewModel.uiState.enableKeyboardShortcuts) {
        _keyboardFocusNode.requestFocus();
      }
    });
  }

  /// Handle keyboard shortcuts
  void _handleKeyboardShortcuts(KeyDownEvent event) {
    final isControlPressed = HardwareKeyboard.instance.isControlPressed;
    if (!isControlPressed) return;

    // Ctrl+1: Local Files (Android only)
    if (event.logicalKey == LogicalKeyboardKey.digit1) {
      _navigateToFilesViewer();
      return;
    }

    // Ctrl+2: Pairing Requests (if available)
    if (event.logicalKey == LogicalKeyboardKey.digit2 &&
        _viewModel.pendingRequests.isNotEmpty) {
      _showPairingRequests();
      return;
    }

    // Ctrl+3: Chat
    if (event.logicalKey == LogicalKeyboardKey.digit3) {
      _navigateToChatScreen();
      return;
    }

    // Ctrl+4: Settings
    if (event.logicalKey == LogicalKeyboardKey.digit4) {
      _navigateToSettings();
      return;
    }

    // Ctrl+5: Help
    if (event.logicalKey == LogicalKeyboardKey.digit5) {
      FunctionInfo.show(context, FunctionInfoKeys.p2lanDataTransfer);
      return;
    }

    // Ctrl+6: About
    if (event.logicalKey == LogicalKeyboardKey.digit6) {
      GenericSettingsUtils.navigateAbout(context);
      return;
    }

    // Ctrl+O: Start/Stop Networking
    if (event.logicalKey == LogicalKeyboardKey.keyO) {
      _toggleNetworking();
      return;
    }

    // Ctrl+R: Manual Discovery
    if (event.logicalKey == LogicalKeyboardKey.keyR &&
        _viewModel.isEnabled &&
        !_viewModel.isRefreshing) {
      executeCommand(_viewModel, P2PCommands.manualDiscovery());
      return;
    }

    // Ctrl+Del: Clear All Transfers
    if (event.logicalKey == LogicalKeyboardKey.delete &&
        _viewModel.activeTransfers.isNotEmpty) {
      _showClearAllTransfersDialog();
      return;
    }
  }

  // =============================================================================
  // EVENT HANDLERS - USER ACTIONS
  // =============================================================================

  /// Toggle networking on/off
  void _toggleNetworking() {
    if (_viewModel.isEnabled) {
      executeCommand(_viewModel, P2PCommands.stopNetworking());
    } else {
      _startNetworking();
    }
  }

  /// Show manual connect dialog
  void _showManualConnectDialog() {
    showDialog(
      context: context,
      builder: (context) => ManualConnectDialog(
        onConnect: (user, saveConnection, trustUser) async {
          await executeCommand(
              _viewModel,
              SendPairingRequestCommand(
                targetUser: user,
                saveConnection: saveConnection,
                trustUser: trustUser,
              ));

          if (_viewModel.errorMessage != null) {
            logError(_viewModel.errorMessage!);
          } else if (context.mounted) {
            SnackbarUtils.showTyped(
              context,
              'Connection request sent to ${user.ipAddress}:${user.port}',
              SnackBarType.success,
            );
          }
        },
      ),
    );
  }

  /// Start networking with permission checks
  void _startNetworking() async {
    try {
      final permissionsGranted =
          await PermissionUtils.requestAllP2PPermissions(context);

      if (!permissionsGranted) {
        if (mounted) {
          _showErrorSnackBar(
              'Permissions are required to start P2P networking');
        }
        return;
      }

      await executeCommand(_viewModel, P2PCommands.startNetworking());

      if (_viewModel.errorMessage != null && mounted) {
        _showErrorSnackBar(_viewModel.errorMessage!);
      }
    } catch (e) {
      logError('Error in _startNetworking: $e');
      if (mounted) {
        final errorMessage = e.toString().replaceFirst('Exception: ', '');
        _showErrorSnackBar(errorMessage);
      }
    }
  }

  /// Select user for pairing or file transfer
  void _selectUser(P2PUser user) {
    _viewModel.selectUser(user);

    if (!user.isBlocked) {
      if (!user.isPaired) {
        _showPairingDialog(user);
      } else if (user.isPaired) {
        _showMultiFileSenderDialog(user);
      }
    }
  }

  /// Add user to chat and switch to chat screen
  void _addUserToChatAndOpen(P2PUser user) async {
    final chatService = _viewModel.p2pChatService;
    final currentUserId = _viewModel.currentUser?.id;

    if (currentUserId == null) {
      _showErrorSnackBar('Current user not available');
      return;
    }

    final chat = await chatService.findChatByUsers(user.id);
    if (chat == null) {
      await chatService.addChat(user.id);
    }

    _navigateToChatScreen(initialUserBId: user.id);
  }

  /// Send remote control request to user
  void _sendRemoteControlRequest(P2PUser user) async {
    await executeCommand(
        _viewModel, SendRemoteControlRequestCommand(targetUser: user));
  }

  /// Send screen sharing request to user
  void _sendScreenSharingRequest(P2PUser user) async {
    // Check notification permission first (Android only)
    if (Platform.isAndroid) {
      final hasPermission =
          await PermissionUtils.requestNotificationPermission(context);
      if (!hasPermission) {
        if (mounted) {
          _showErrorSnackBar(
              'Notification permission is required for screen sharing');
        }
        return;
      }
    }

    await executeCommand(
        _viewModel, SendScreenSharingRequestCommand(targetUser: user));
  }

  /// Open screen sharing viewer
  void _openScreenSharingViewer(ScreenSharingSession session) async {
    logInfo(
        '[DEBUG] _openScreenSharingViewer called for session: ${session.senderUser.displayName}');

    // On desktop platforms, open in a floating window
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      try {
        logInfo('[DEBUG] Desktop platform detected, opening floating window');

        // Get FloatingWindowManager from context
        final windowManager = FloatingWindowManager.of(context);
        if (windowManager != null) {
          windowManager.openScreenSharingWindow(session);
          logInfo(
              'Opened floating window for ${session.senderUser.displayName}');
        } else {
          logError(
              'FloatingWindowManager not found in context, falling back to in-app viewer');
          _openScreenSharingViewerInApp(session);
        }
      } catch (e) {
        logError('Failed to open floating window: $e');
        // Fallback to in-app navigation
        _openScreenSharingViewerInApp(session);
      }
    } else {
      // On mobile, use in-app navigation
      logInfo('[DEBUG] Mobile platform detected, using in-app navigation');
      _openScreenSharingViewerInApp(session);
    }
  }

  /// Open screen sharing viewer in the same app (fallback for mobile or if window creation fails)
  void _openScreenSharingViewerInApp(ScreenSharingSession session) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScreenSharingViewerScreen(session: session),
        settings: const RouteSettings(name: '/screen_sharing_viewer'),
      ),
    );
  }

  // =============================================================================
  // EVENT HANDLERS - TRANSFERS
  // =============================================================================

  /// Show dialog to clear all transfers
  void _showClearAllTransfersDialog() {
    final l10n = AppLocalizations.of(context);

    if (_viewModel.activeTransfers.isEmpty) {
      SnackbarUtils.showTyped(
          context, 'No transfers to clear', SnackBarType.info);
      return;
    }

    showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearAllTransfers),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.clearAllTransfersDesc),
            const SizedBox(height: 16),
            Text(
              'Total transfers to clear: ${_viewModel.activeTransfers.length}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            const Text('Choose how to clear transfers:'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop({'deleteFiles': false}),
            child: const Text('Clear transfers only'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop({'deleteFiles': true}),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear transfers and files'),
          ),
        ],
      ),
    ).then((result) {
      if (result != null) {
        final deleteFiles = result['deleteFiles'] as bool;
        executeCommand(_viewModel,
            P2PCommands.clearAllTransfers(deleteFiles: deleteFiles));
      }
    });
  }

  /// Handle batch expand change
  void _onBatchExpandChanged(String? batchId, bool expanded) {
    // Do nothing - batch expand state is no longer remembered
  }

  /// Handle batch clear
  void _onClearBatch(String? batchId) {
    executeCommand(_viewModel, ClearBatchCommand(batchId: batchId));
  }

  /// Handle batch clear with files
  void _onClearBatchWithFiles(String? batchId) {
    executeCommand(
        _viewModel, ClearBatchCommand(batchId: batchId, deleteFiles: true));
  }

  // =============================================================================
  // EVENT HANDLERS - DIALOGS
  // =============================================================================

  /// Show pairing dialog
  void _showPairingDialog(P2PUser user) {
    showDialog(
      context: context,
      builder: (context) => UserPairingDialog(
        user: user,
        onPair: (saveConnection, trustUser) async {
          await executeCommand(
              _viewModel,
              SendPairingRequestCommand(
                targetUser: user,
                saveConnection: saveConnection,
                trustUser: trustUser,
              ));

          if (_viewModel.errorMessage != null) {
            _showErrorSnackBar(_viewModel.errorMessage!);
          }
        },
      ),
    );
  }

  /// Show pairing requests dialog
  void _showPairingRequests() {
    showDialog(
      context: context,
      builder: (context) => PairingRequestDialog(
        requests: _viewModel.pendingRequests,
        onRespond: (requestId, accept, trustUser, saveConnection) async {
          await executeCommand(
              _viewModel,
              RespondToPairingRequestCommand(
                requestId: requestId,
                accept: accept,
                trustUser: trustUser,
                saveConnection: saveConnection,
              ));

          if (_viewModel.errorMessage != null) {
            _showErrorSnackBar(_viewModel.errorMessage!);
          }
        },
      ),
    );
  }

  /// Show single pairing request dialog
  void _showSinglePairingRequestDialog(PairingRequest request) {
    showDialog(
      context: context,
      builder: (context) => PairingRequestDialog(
        requests: [request],
        onRespond: (requestId, accept, trustUser, saveConnection) async {
          await executeCommand(
              _viewModel,
              RespondToPairingRequestCommand(
                requestId: requestId,
                accept: accept,
                trustUser: trustUser,
                saveConnection: saveConnection,
              ));

          if (_viewModel.errorMessage != null) {
            _showErrorSnackBar(_viewModel.errorMessage!);
          }
        },
      ),
    );
  }

  /// Show file transfer request dialog
  void _showFileTransferRequestDialog(FileTransferRequest request,
      {int? initialCountdown}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => FileTransferRequestDialog(
        request: request,
        initialCountdown: initialCountdown,
        onResponse: (accept, rejectMessage) async {
          await executeCommand(
              _viewModel,
              RespondToFileTransferRequestCommand(
                requestId: request.requestId,
                accept: accept,
                rejectMessage: rejectMessage,
              ));

          if (_viewModel.errorMessage != null) {
            _showErrorSnackBar(_viewModel.errorMessage!);
          }
        },
      ),
    );
  }

  /// Show remote control request dialog
  void _showRemoteControlRequestDialog(RemoteControlRequest request) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => RemoteControlRequestDialog(
        request: request,
        onResponse: (requestId, accept, rejectReason) async {
          await executeCommand(
              _viewModel,
              RespondToRemoteControlRequestCommand(
                requestId: requestId,
                accepted: accept,
              ));

          if (_viewModel.errorMessage != null) {
            _showErrorSnackBar(_viewModel.errorMessage!);
          }
          // Note: No navigation here - the sender should navigate when receiving acceptance
        },
      ),
    );
  }

  /// Show screen sharing request dialog
  void _showScreenSharingRequestDialog(ScreenSharingRequest request) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ScreenSharingRequestDialog(
        request: request,
      ),
    );
  }

  /// Show security warning dialog
  void _showSecurityWarningDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => NetworkSecurityWarningDialog(
        networkInfo: _viewModel.networkInfo!,
        onProceed: () async {
          Navigator.of(context).pop();
          await _viewModel.startNetworkingWithWarning();
        },
        onCancel: () {
          Navigator.of(context).pop();
          _viewModel.dismissSecurityWarning();
        },
      ),
    );
  }

  /// Show user info dialog
  void _showUserInfoDialog(P2PUser user) {
    showDialog(
      context: context,
      builder: (context) => UserInfoDialog(user: user),
    );
  }

  /// Show multi-file sender dialog
  void _showMultiFileSenderDialog(P2PUser user) {
    final scaffoldContext = context;

    showDialog(
      context: context,
      builder: (context) => MultiFileSenderDialog(
        targetUser: user,
        onSendFiles: (filePaths) async {
          await executeCommand(
              _viewModel,
              SendFilesToUserCommand(
                filePaths: filePaths,
                targetUser: user,
              ));

          if (!scaffoldContext.mounted) return;

          if (_viewModel.errorMessage != null) {
            SnackbarUtils.showTyped(
                scaffoldContext, _viewModel.errorMessage!, SnackBarType.error);
          } else {
            final l10n = AppLocalizations.of(scaffoldContext);
            SnackbarUtils.showTyped(
              scaffoldContext,
              l10n.startedSending(filePaths.length, user.displayName),
              SnackBarType.info,
            );
            _switchToTransfers();
          }
        },
      ),
    );
  }

  /// Show status card customization dialog
  void _showStatusCardCustomizationDialog() {
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.customStatusCards),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.customStatusCardsDesc),
                const SizedBox(height: 16),
                // When a remote control session is active, prevent toggling
                // and show an explanatory message instead.
                if (_viewModel.currentRemoteControlSession != null)
                  ListTile(
                    leading:
                        const Icon(Icons.desktop_mac, color: Colors.orange),
                    title: Text(l10n.remoteControl),
                    subtitle: Text(l10n.endRemoteToCustomizeStatus),
                    enabled: true,
                  ),
                const SizedBox(height: 8),
                CheckboxListTile(
                  title: Text(l10n.thisDevice),
                  subtitle: Text(l10n.thisDeviceDesc),
                  value:
                      _viewModel.uiState.statusCardVisibility['thisDevice'] ??
                          true,
                  onChanged: _viewModel.currentRemoteControlSession != null
                      ? null
                      : (value) {
                          setDialogState(() {
                            executeCommand(_viewModel,
                                P2PCommands.toggleStatusCard('thisDevice'));
                          });
                        },
                ),
                CheckboxListTile(
                  title: Text(l10n.connectionStatus),
                  subtitle: Text(l10n.connectionStatusDesc),
                  value: _viewModel
                          .uiState.statusCardVisibility['connectionStatus'] ??
                      true,
                  onChanged: _viewModel.currentRemoteControlSession != null
                      ? null
                      : (value) {
                          setDialogState(() {
                            executeCommand(
                                _viewModel,
                                P2PCommands.toggleStatusCard(
                                    'connectionStatus'));
                          });
                        },
                ),
                CheckboxListTile(
                  title: Text(l10n.statistics),
                  subtitle: Text(l10n.statisticsDesc),
                  value:
                      _viewModel.uiState.statusCardVisibility['statistics'] ??
                          true,
                  onChanged: _viewModel.currentRemoteControlSession != null
                      ? null
                      : (value) {
                          setDialogState(() {
                            executeCommand(_viewModel,
                                P2PCommands.toggleStatusCard('statistics'));
                          });
                        },
                ),
              ],
            ),
          ),
          // Remove actions because changes apply immediately
          actions: const [],
        ),
      ),
    );
  }

  // =============================================================================
  // EVENT HANDLERS - TRUST MANAGEMENT
  // =============================================================================

  /// Confirm and block user
  void _confirmBlock(P2PUser user) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.blockTitle),
        content: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 400, maxWidth: 600),
          child: Text(l10n.blockDesc),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              await executeCommand(
                  _viewModel, BlockUserCommand(user: user, blocked: true));
              if (context.mounted) Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.blockTitle),
          ),
        ],
      ),
    );
  }

  /// Confirm and unblock user
  void _confirmUnblock(P2PUser user) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.unblockTitle),
        content: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 400, maxWidth: 600),
          child: Text(l10n.unblockDesc),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              await executeCommand(
                  _viewModel, BlockUserCommand(user: user, blocked: false));
              if (context.mounted) Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.green),
            child: Text(l10n.unblockTitle),
          ),
        ],
      ),
    );
  }

  /// Show unpair dialog
  void _showUnpairDialog(P2PUser user) {
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (context) => HoldToConfirmDialog(
        title: l10n.unpairFrom(user.displayName),
        content: l10n.unpairDescription,
        cancelText: l10n.holdToUnpair,
        holdText: l10n.holdToUnpair,
        processingText: l10n.unpairing,
        instructionText: l10n.holdButtonToConfirmUnpair,
        actionIcon: Icons.link_off,
        holdDuration: const Duration(seconds: 1),
        l10n: l10n,
        onConfirmed: () async {
          Navigator.of(context).pop();
          await executeCommand(_viewModel, P2PCommands.unpairUser(user.id));

          if (_viewModel.errorMessage != null) {
            _showErrorSnackBar(_viewModel.errorMessage!);
          } else if (context.mounted) {
            SnackbarUtils.showTyped(
              context,
              l10n.unpairFrom(user.displayName),
              SnackBarType.info,
            );
          }
        },
      ),
    );
  }

  /// Add trust to user
  void _addTrust(P2PUser user) async {
    await executeCommand(_viewModel, P2PCommands.addTrust(user.id));

    if (_viewModel.errorMessage != null) {
      _showErrorSnackBar(_viewModel.errorMessage!);
    } else if (mounted) {
      SnackbarUtils.showTyped(
        context,
        'Trusted ${user.displayName}',
        SnackBarType.success,
      );
    }
  }

  /// Remove trust from user
  void _removeTrust(P2PUser user) {
    final l10n = AppLocalizations.of(context);
    GenericDialogUtils.showSimpleGenericClearDialog(
      context: context,
      onConfirm: () async {
        await executeCommand(_viewModel, P2PCommands.removeTrust(user.id));

        if (_viewModel.errorMessage != null) {
          _showErrorSnackBar(_viewModel.errorMessage!);
        } else if (mounted) {
          SnackbarUtils.showTyped(
            context,
            l10n.removeTrustFrom(user.displayName),
            SnackBarType.info,
          );
        }
      },
      title: l10n.removeTrust,
      description: l10n.removeTrustFrom(user.displayName),
    );
  }

  // =============================================================================
  // EVENT HANDLERS - TRANSFERS MANAGEMENT
  // =============================================================================

  /// Cancel transfer
  void _cancelTransfer(String taskId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).cancelTransfer),
        content: Text(AppLocalizations.of(context).confirmCancelTransfer),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              executeCommand(_viewModel, P2PCommands.cancelTransfer(taskId));
            },
            child: Text(AppLocalizations.of(context).cancelTransfer),
          ),
        ],
      ),
    );
  }

  /// Clear transfer
  void _clearTransfer(String taskId) {
    executeCommand(_viewModel, P2PCommands.clearTransfer(taskId));
  }

  /// Clear transfer with file
  void _clearTransferWithFile(String taskId, bool deleteFile) async {
    await executeCommand(
        _viewModel, P2PCommands.clearTransfer(taskId, deleteFile: deleteFile));

    if (_viewModel.errorMessage != null) {
      _showErrorSnackBar(_viewModel.errorMessage!);
    } else if (deleteFile && mounted) {
      final l10n = AppLocalizations.of(context);
      SnackbarUtils.showTyped(
          context, l10n.taskAndFileDeletedSuccessfully, SnackBarType.success);
    } else if (mounted) {
      SnackbarUtils.showTyped(context, 'Task cleared', SnackBarType.info);
    }
  }

  // =============================================================================
  // EVENT HANDLERS - NOTIFICATIONS
  // =============================================================================

  /// Switch to specific tab (called from navigation service)
  void _switchToTab(int tabIndex) {
    if (mounted && tabIndex >= 0 && tabIndex < 3) {
      executeCommand(_viewModel, P2PCommands.switchTab(tabIndex));
    }
  }

  /// Show dialog from notification
  void _showDialogFromNotification(
      String dialogType, Map<String, dynamic> dialogData) {
    if (!mounted) return;

    switch (dialogType) {
      case 'pairing_request':
        final requestId = dialogData['requestId'] as String?;
        if (requestId != null) {
          final request = _viewModel.pendingRequests.firstWhere(
            (r) => r.id == requestId,
            orElse: () => throw StateError('Request not found'),
          );
          _showSinglePairingRequestDialog(request);
        }
        break;
      case 'file_transfer_request':
        final requestId = dialogData['requestId'] as String?;
        if (requestId != null) {
          final request = _viewModel.pendingFileTransferRequests.firstWhere(
            (r) => r.requestId == requestId,
            orElse: () => throw StateError('Request not found'),
          );
          _showFileTransferRequestDialog(request);
        }
        break;
    }
  }

  /// Handle notification tap
  void _handleNotificationTapped(P2PNotificationPayload payload) {
    if (!mounted) return;

    switch (payload.type) {
      case P2PNotificationType.fileTransferRequest:
        executeCommand(_viewModel, P2PCommands.switchTab(0));
        if (payload.requestId != null) {
          _showDialogFromNotification('file_transfer_request', {
            'requestId': payload.requestId,
          });
        }
        break;
      case P2PNotificationType.fileTransferProgress:
      case P2PNotificationType.fileTransferCompleted:
      case P2PNotificationType.fileTransferStatus:
        executeCommand(_viewModel, P2PCommands.switchTab(1));
        break;
      case P2PNotificationType.pairingRequest:
        executeCommand(_viewModel, P2PCommands.switchTab(0));
        if (payload.requestId != null) {
          _showDialogFromNotification('pairing_request', {
            'requestId': payload.requestId,
          });
        }
        break;
      default:
        executeCommand(_viewModel, P2PCommands.switchTab(0));
        break;
    }
  }

  /// Handle notification action
  void _handleNotificationAction(
      P2PNotificationAction action, P2PNotificationPayload payload) {
    if (!mounted) return;

    switch (action) {
      case P2PNotificationAction.approveTransfer:
        if (payload.requestId != null) {
          executeCommand(
              _viewModel,
              RespondToFileTransferRequestCommand(
                requestId: payload.requestId!,
                accept: true,
                rejectMessage: null,
              ));
        }
        break;
      case P2PNotificationAction.rejectTransfer:
        if (payload.requestId != null) {
          executeCommand(
              _viewModel,
              RespondToFileTransferRequestCommand(
                requestId: payload.requestId!,
                accept: false,
                rejectMessage: 'Rejected from notification',
              ));
        }
        break;
      case P2PNotificationAction.acceptPairing:
        if (payload.requestId != null) {
          executeCommand(
              _viewModel,
              RespondToPairingRequestCommand(
                requestId: payload.requestId!,
                accept: true,
                trustUser: false,
                saveConnection: true,
              ));
        }
        break;
      case P2PNotificationAction.rejectPairing:
        if (payload.requestId != null) {
          executeCommand(
              _viewModel,
              RespondToPairingRequestCommand(
                requestId: payload.requestId!,
                accept: false,
                trustUser: false,
                saveConnection: false,
              ));
        }
        break;
      case P2PNotificationAction.openP2Lan:
        _handleNotificationTapped(payload);
        break;
    }
  }

  // =============================================================================
  // UTILITIES
  // =============================================================================

  /// Switch to transfers tab (without auto-scrolling)
  void _switchToTransfers() {
    executeCommand(_viewModel, P2PCommands.switchTab(1));

    // Scroll to bottom
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (_transfersScrollController.hasClients) {
    //     _transfersScrollController.animateTo(
    //       _transfersScrollController.position.maxScrollExtent,
    //       duration: const Duration(milliseconds: 500),
    //       curve: Curves.easeOut,
    //     );
    //   }
    // });
  }

  /// Show error snackbar
  void _showErrorSnackBar(String message) {
    if (mounted) {
      SnackbarUtils.showTyped(context, message, SnackBarType.error);
    }
  }

  // =============================================================================
  // BUILD METHODS
  // =============================================================================

  @override
  Widget build(BuildContext context) {
    return P2PViewModelBuilder(
      viewModel: _viewModel,
      builder: (context, viewModel, uiState) {
        // Show loading state
        if (!viewModel.isInitialized) {
          return Scaffold(
            appBar: AppBar(title: Text(AppLocalizations.of(context).title)),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        // Handle security warning
        if (viewModel.showSecurityWarning) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showSecurityWarningDialog();
          });
        }

        return _buildMainContent(uiState);
      },
    );
  }

  /// Build main content with keyboard listener if needed
  Widget _buildMainContent(P2PUIState uiState) {
    final l10n = AppLocalizations.of(context);
    final isDesktop = MediaQuery.of(context).size.width > 800;

    final mainContent = _buildContent(l10n, isDesktop, uiState);

    // Add keyboard shortcuts for desktop
    final isDesktopForShortcuts = !isMobileLayoutContext(context);
    if (uiState.enableKeyboardShortcuts && isDesktopForShortcuts) {
      return KeyboardListener(
        focusNode: _keyboardFocusNode,
        autofocus: true,
        onKeyEvent: (KeyEvent event) {
          if (event is KeyDownEvent) {
            _handleKeyboardShortcuts(event);
          }
        },
        child: mainContent,
      );
    }

    return mainContent;
  }

  /// Build the main content
  Widget _buildContent(
      AppLocalizations l10n, bool isDesktop, P2PUIState uiState) {
    final devicesPanel = PanelInfo(
      title: l10n.devices,
      icon: Icons.devices,
      content: _DevicesTabWidget(
        viewModel: _viewModel,
        onSelectUser: _selectUser,
        onUserAction: _handleUserAction,
        onToggleSection: (section) => executeCommand(
            _viewModel, P2PCommands.toggleDeviceSection(section)),
        onToggleNetworking: _toggleNetworking,
        onShowManualConnectDialog: _showManualConnectDialog,
      ),
      actions: [
        if (_viewModel.isEnabled && !_viewModel.isRefreshing)
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () =>
                executeCommand(_viewModel, P2PCommands.manualDiscovery()),
            tooltip:
                ShortcutTooltipUtils.I.build(l10n.manualDiscovery, 'Ctrl+R'),
          ),
        if (_viewModel.isRefreshing)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
      ],
      flex: 2,
    );

    final transfersPanel = PanelInfo(
      title: l10n.transfers,
      icon: Icons.swap_horiz,
      content: _TransfersTabWidget(
        viewModel: _viewModel,
        uiState: uiState,
        scrollController: _transfersScrollController,
        onCancelTransfer: _cancelTransfer,
        onClearTransfer: _clearTransfer,
        onClearTransferWithFile: _clearTransferWithFile,
        onBatchExpandChanged: _onBatchExpandChanged,
        onClearBatch: _onClearBatch,
        onClearBatchWithFiles: _onClearBatchWithFiles,
      ),
      actions: [
        if (_viewModel.activeTransfers.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: _showClearAllTransfersDialog,
            tooltip: ShortcutTooltipUtils.I.build(l10n.clearAll, 'Ctrl+Del'),
          ),
      ],
    );

    final statusPanel = PanelInfo(
      title: l10n.status,
      icon: Icons.info,
      content: Column(
        children: [
          // Remote control card - always show when active, independent of settings
          if (_viewModel.currentRemoteControlSession != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: KeyedSubtree(
                key: const ValueKey('remote_control_card'),
                child: _buildRemoteControlStatusCard(
                    context, l10n, _viewModel.currentRemoteControlSession!),
              ),
            ),
          // Screen sharing card - always show when active
          if (_viewModel.currentScreenSharingSession != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: KeyedSubtree(
                key: const ValueKey('screen_sharing_card'),
                child: _buildScreenSharingStatusCard(
                    context, l10n, _viewModel.currentScreenSharingSession!),
              ),
            ),
          // Other status content
          Expanded(
            child: _StatusPanelWidget(
              viewModel: _viewModel,
              uiState: uiState,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.tune),
          onPressed: _showStatusCardCustomizationDialog,
          tooltip: 'Customize status cards',
        ),
      ],
    );

    final panels = isDesktop
        ? [transfersPanel, devicesPanel, statusPanel]
        : [devicesPanel, transfersPanel, statusPanel];

    final pairingRequestsIcon = Platform.isWindows
        ? Badge(
            label: Text('${_viewModel.pendingRequests.length}'),
            child: const Icon(Icons.notifications),
          )
        : const Icon(Icons.notifications);

    return ThreePanelsLayout(
      panelInfos: panels,
      useCompactTabLayout: uiState.useCompactLayout,
      appBar: AppBar(
        title: Text(l10n.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.folder),
            onPressed: _navigateToFilesViewer,
            tooltip: ShortcutTooltipUtils.I.build(
                Platform.isAndroid ? l10n.localFiles : l10n.downloadLocation,
                'Ctrl+1'),
          ),
          if (_viewModel.pendingRequests.isNotEmpty)
            IconButton(
              icon: pairingRequestsIcon,
              onPressed: _showPairingRequests,
              tooltip:
                  ShortcutTooltipUtils.I.build(l10n.pairingRequests, 'Ctrl+2'),
            ),
          IconButton(
            onPressed: _navigateToChatScreen,
            tooltip: ShortcutTooltipUtils.I.build(l10n.chat, 'Ctrl+3'),
            icon: const Icon(Icons.message),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _navigateToSettings,
            tooltip: ShortcutTooltipUtils.I.build(l10n.settings, 'Ctrl+4'),
          ),
          IconButton(
            icon: const Icon(Icons.help),
            onPressed: () =>
                FunctionInfo.show(context, FunctionInfoKeys.p2lanDataTransfer),
            tooltip: ShortcutTooltipUtils.I.build(l10n.help, 'Ctrl+5'),
          ),
          IconButton(
            icon: const Icon(Icons.info),
            tooltip: ShortcutTooltipUtils.I.build(l10n.about, 'Ctrl+6'),
            onPressed: () => GenericSettingsUtils.navigateAbout(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      initialIndex: uiState.currentTabIndex,
      onIndexChanged: (index) =>
          executeCommand(_viewModel, P2PCommands.switchTab(index)),
      maxWidthDisplayFullActions: 500,
      otherItemsWidth: 300,
    );
  }

  /// Handle user actions
  void _handleUserAction(String action, P2PUser user) {
    switch (action) {
      case 'view_info':
        _showUserInfoDialog(user);
        break;
      case 'pair':
        _showPairingDialog(user);
        break;
      case 'chat':
        _addUserToChatAndOpen(user);
        break;
      case 'remote_control':
        _sendRemoteControlRequest(user);
        break;
      case 'screen_sharing':
        _sendScreenSharingRequest(user);
        break;
      case 'add_trust':
        _addTrust(user);
        break;
      case 'remove_trust':
        _removeTrust(user);
        break;
      case 'unpair':
        _showUnpairDialog(user);
        break;
      case 'block':
        _confirmBlock(user);
        break;
      case 'unblock':
        _confirmUnblock(user);
        break;
    }
  }

  /// Build remote control status card for Status tab
  Widget _buildRemoteControlStatusCard(BuildContext context,
      AppLocalizations l10n, RemoteControlSession session) {
    final currentUser = _viewModel.currentUser;
    if (currentUser == null) return const SizedBox.shrink();

    final isBeingControlled = session.controlledUser.id == currentUser.id;
    final otherUser =
        isBeingControlled ? session.controllerUser : session.controlledUser;
    final duration = session.duration;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Theme-aware colors
    final cardColor = isBeingControlled
        ? (isDarkMode ? theme.colorScheme.errorContainer : Colors.orange[50])
        : (isDarkMode ? theme.colorScheme.primaryContainer : Colors.blue[50]);

    final iconColor = isBeingControlled
        ? (isDarkMode ? theme.colorScheme.onErrorContainer : Colors.orange[700])
        : (isDarkMode
            ? theme.colorScheme.onPrimaryContainer
            : Colors.blue[700]);

    final titleColor = isBeingControlled
        ? (isDarkMode ? theme.colorScheme.onErrorContainer : Colors.orange[800])
        : (isDarkMode
            ? theme.colorScheme.onPrimaryContainer
            : Colors.blue[800]);

    final subtitleColor =
        isDarkMode ? theme.colorScheme.onSurfaceVariant : Colors.grey[700];
    final timeTextColor =
        isDarkMode ? theme.colorScheme.onSurfaceVariant : Colors.grey[600];

    return Card(
      margin: const EdgeInsets.all(0),
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isBeingControlled ? Icons.screen_share : Icons.control_camera,
                  color: iconColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isBeingControlled
                            ? l10n.beingRemoteControlled
                            : l10n.remoteControlling,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: titleColor,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isBeingControlled
                            ? l10n
                                .isControllingThisDevice(otherUser.displayName)
                            : l10n.controllingUser(otherUser.displayName),
                        style: TextStyle(
                          color: subtitleColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.timer, size: 16, color: timeTextColor),
                const SizedBox(width: 4),
                Text(
                  '${l10n.duration}: ${_formatDuration(duration)}',
                  style: TextStyle(
                    color: timeTextColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            if (isBeingControlled) ...[
              // Only controlled device can end session
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: () =>
                        _viewModel.endCurrentRemoteControlSession(),
                    icon: const Icon(Icons.stop, size: 16),
                    label: Text(l10n.endSession),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.error,
                      foregroundColor: theme.colorScheme.onError,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build screen sharing status card for Status tab
  Widget _buildScreenSharingStatusCard(BuildContext context,
      AppLocalizations l10n, ScreenSharingSession session) {
    final currentUser = _viewModel.currentUser;
    if (currentUser == null) return const SizedBox.shrink();

    final isReceivingScreen = session.receiverUser.id == currentUser.id;
    final otherUser =
        isReceivingScreen ? session.senderUser : session.receiverUser;
    final duration = session.duration;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Theme-aware colors
    final cardColor = isReceivingScreen
        ? (isDarkMode ? theme.colorScheme.primaryContainer : Colors.green[50])
        : (isDarkMode
            ? theme.colorScheme.secondaryContainer
            : Colors.purple[50]);

    final iconColor = isReceivingScreen
        ? (isDarkMode
            ? theme.colorScheme.onPrimaryContainer
            : Colors.green[700])
        : (isDarkMode
            ? theme.colorScheme.onSecondaryContainer
            : Colors.purple[700]);

    final titleColor = isReceivingScreen
        ? (isDarkMode
            ? theme.colorScheme.onPrimaryContainer
            : Colors.green[800])
        : (isDarkMode
            ? theme.colorScheme.onSecondaryContainer
            : Colors.purple[800]);

    final subtitleColor =
        isDarkMode ? theme.colorScheme.onSurfaceVariant : Colors.grey[700];
    final timeTextColor =
        isDarkMode ? theme.colorScheme.onSurfaceVariant : Colors.grey[600];

    return Card(
      margin: const EdgeInsets.all(0),
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isReceivingScreen ? Icons.screen_share : Icons.cast,
                  color: iconColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isReceivingScreen
                            ? l10n.viewingScreen
                            : l10n.sharingScreen,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: titleColor,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isReceivingScreen
                            ? 'Viewing ${otherUser.displayName}\'s screen'
                            : 'Sharing screen with ${otherUser.displayName}',
                        style: TextStyle(
                          color: subtitleColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.timer, size: 16, color: timeTextColor),
                const SizedBox(width: 4),
                Text(
                  '${l10n.duration}: ${_formatDuration(duration)}',
                  style: TextStyle(
                    color: timeTextColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (isReceivingScreen) ...[
              // Only show Open Viewer button for receiver
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _openScreenSharingViewer(session),
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: Text('Open Viewer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}

// =============================================================================
// HELPER WIDGETS - ONLY UI LOGIC
// =============================================================================

/// Devices tab widget
class _DevicesTabWidget extends StatelessWidget {
  final P2PViewModel viewModel;
  final Function(P2PUser) onSelectUser;
  final Function(String, P2PUser) onUserAction;
  final Function(String) onToggleSection;
  final VoidCallback onToggleNetworking;
  final VoidCallback onShowManualConnectDialog;

  const _DevicesTabWidget({
    required this.viewModel,
    required this.onSelectUser,
    required this.onUserAction,
    required this.onToggleSection,
    required this.onToggleNetworking,
    required this.onShowManualConnectDialog,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        _buildNetworkStatusCard(context, l10n),
        const SizedBox(height: 16),
        Expanded(
          child: _buildDevicesSections(context, l10n),
        ),
      ],
    );
  }

  Widget _buildNetworkStatusCard(BuildContext context, AppLocalizations l10n) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDesktop =
        MediaQuery.of(context).size.width > tabletScreenWidthThreshold * 2.5;

    final compactLayout = viewModel.uiState.useCompactLayout;

    // Toggle network components
    final toggleNetworkIcon = Icon(viewModel.isTemporarilyDisabled
        ? Icons.pause_circle_outline
        : (viewModel.isEnabled ? Icons.wifi_off : Icons.wifi));
    final toggleNetworkMsg = viewModel.isTemporarilyDisabled
        ? l10n.pausedNoInternet
        : (viewModel.isEnabled
            ? ShortcutTooltipUtils.I.build(l10n.stopNetworking, 'Ctrl+O')
            : ShortcutTooltipUtils.I.build(l10n.startNetworking, 'Ctrl+O'));
    void toggleNetworkOnPressed() =>
        viewModel.isTemporarilyDisabled ? null : onToggleNetworking();
    final toggleNetworkBg = viewModel.isTemporarilyDisabled
        ? Colors.orange[700]
        : (viewModel.isEnabled ? Colors.red[700] : theme.colorScheme.primary);
    final toggleNetworkFg =
        (viewModel.isTemporarilyDisabled || viewModel.isEnabled)
            ? Colors.white
            : theme.colorScheme.onPrimary;

    // Toggle network button
    final toggleNetworkBtn = Tooltip(
      message: toggleNetworkMsg,
      child: compactLayout
          ? _buildChip(
              onPressed: toggleNetworkOnPressed,
              icon: toggleNetworkIcon.icon!,
              color: toggleNetworkBg!,
              size: 28)
          : ElevatedButton.icon(
              onPressed: toggleNetworkOnPressed,
              icon: toggleNetworkIcon,
              label: Text(toggleNetworkMsg, overflow: TextOverflow.ellipsis),
              style: ElevatedButton.styleFrom(
                backgroundColor: toggleNetworkBg,
                foregroundColor: toggleNetworkFg,
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  overflow: TextOverflow.ellipsis,
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
    );

    // Connect to device button components
    const connectToDeviceIcon = Icon(Icons.link);
    final connectToDeviceMsg = l10n.connectToDevice;
    void connectToDeviceOnPressed() =>
        viewModel.isEnabled ? onShowManualConnectDialog() : null;
    final connectToDeviceBg =
        viewModel.isEnabled ? theme.colorScheme.primary : theme.disabledColor;
    final connectToDeviceFg =
        viewModel.isEnabled ? theme.colorScheme.primary : theme.disabledColor;

    // Connect to device button
    final connectToDeviceBtn = Tooltip(
      message: l10n.connectToDevice,
      child: compactLayout
          ? _buildChip(
              onPressed: connectToDeviceOnPressed,
              icon: connectToDeviceIcon.icon!,
              color: connectToDeviceBg,
              size: 28)
          : ElevatedButton.icon(
              onPressed: connectToDeviceOnPressed,
              icon: connectToDeviceIcon,
              label: Text(connectToDeviceMsg, overflow: TextOverflow.ellipsis),
              style: ElevatedButton.styleFrom(
                foregroundColor: connectToDeviceFg,
                textStyle: const TextStyle(
                  overflow: TextOverflow.ellipsis,
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: connectToDeviceBg,
                  ),
                ),
              ),
            ),
    );

    // Fix: Do not use Expanded inside Row/Column that is not constrained
    Widget networkStatusTexts = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!compactLayout) ...[
          Text(
            viewModel.getNetworkStatusDescription(l10n),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
        ],
        Text(viewModel.getConnectionStatusDescription(l10n),
            style: compactLayout
                ? Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    )
                : Theme.of(context).textTheme.bodySmall),
      ],
    );

    final networkIconAndStatus = [
      Icon(
        _getNetworkStatusIcon(),
        color: _getNetworkStatusColor(),
        size: 32,
      ),
      const SizedBox(width: 16),
      // Use Flexible instead of Expanded, and do not nest Expanded in Column
      Expanded(child: networkStatusTexts),
    ];

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...networkIconAndStatus,
                if (isDesktop || compactLayout) ...[
                  const SizedBox(width: 12),
                  connectToDeviceBtn,
                  const SizedBox(width: 8),
                  toggleNetworkBtn,
                ]
              ],
            ),
            if (!isDesktop && !compactLayout) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Do not wrap in Expanded, just use Flexible or leave as is
                  Flexible(child: connectToDeviceBtn),
                  const SizedBox(width: 12),
                  Flexible(child: toggleNetworkBtn),
                ],
              )
            ]
          ],
        ),
      ),
    );
  }

  IconData _getNetworkStatusIcon() {
    if (viewModel.isTemporarilyDisabled) {
      return Icons.pause_circle_outline;
    }

    final networkInfo = viewModel.networkInfo;
    if (networkInfo == null) return Icons.help_outline;

    if (networkInfo.isMobile) {
      return Icons.signal_cellular_4_bar;
    } else if (networkInfo.isWiFi) {
      return networkInfo.isSecure ? Icons.wifi_lock : Icons.wifi;
    } else if (networkInfo.securityType == 'ETHERNET') {
      return Icons.lan;
    } else {
      return Icons.wifi_off;
    }
  }

  Color _getNetworkStatusColor() {
    if (viewModel.isTemporarilyDisabled) {
      return Colors.orange;
    }

    final networkInfo = viewModel.networkInfo;
    if (networkInfo == null) return Colors.grey;

    switch (networkInfo.securityLevel) {
      case NetworkSecurityLevel.secure:
        return Colors.green;
      case NetworkSecurityLevel.unsecure:
        return Colors.orange;
      case NetworkSecurityLevel.unknown:
        return Colors.grey;
    }
  }

  Widget _buildDevicesSections(BuildContext context, AppLocalizations l10n) {
    if (viewModel.discoveredUsers.isEmpty) {
      return _buildEmptyDevicesState(context, l10n);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Online devices section
        if (viewModel.hasOnlineDevices) ...[
          _buildSectionHeader(
            context: context,
            title:
                '🟢 ${l10n.onlineDevices} (${viewModel.onlineDevices.length})',
            subtitle: l10n.savedDevicesCurrentlyAvailable,
            showToggle: viewModel.onlineDevices.length >= 2,
            isExpanded: viewModel.uiState.expandedOnlineDevices,
            onToggle: () => onToggleSection('online'),
            loc: l10n,
          ),
          if (viewModel.uiState.expandedOnlineDevices)
            ...viewModel.onlineDevices
                .map((user) => _buildUserCard(context, user, isOnline: true)),
          const SizedBox(height: 24),
        ],

        // New devices section
        if (viewModel.hasNewDevices) ...[
          _buildSectionHeader(
            context: context,
            title: '🔵 ${l10n.newDevices} (${viewModel.newDevices.length})',
            subtitle: l10n.recentlyDiscoveredDevices,
            showToggle: viewModel.newDevices.length >= 2,
            isExpanded: viewModel.uiState.expandedNewDevices,
            onToggle: () => onToggleSection('new'),
            loc: l10n,
          ),
          if (viewModel.uiState.expandedNewDevices)
            ...viewModel.newDevices
                .map((user) => _buildUserCard(context, user, isNew: true)),
          const SizedBox(height: 24),
        ],

        // Saved devices section
        if (viewModel.hasSavedDevices) ...[
          _buildSectionHeader(
            context: context,
            title: '⚫ ${l10n.savedDevices} (${viewModel.savedDevices.length})',
            subtitle: l10n.previouslyPairedOffline,
            showToggle: viewModel.savedDevices.length >= 2,
            isExpanded: viewModel.uiState.expandedSavedDevices,
            onToggle: () => onToggleSection('saved'),
            loc: l10n,
          ),
          if (viewModel.uiState.expandedSavedDevices)
            ...viewModel.savedDevices
                .map((user) => _buildUserCard(context, user, isSaved: true)),
          const SizedBox(height: 24),
        ],

        // Blocked devices section
        if (viewModel.hasBlockedDevices) ...[
          _buildSectionHeader(
            context: context,
            title:
                '🔴 ${l10n.blockedDevices} (${viewModel.blockedUsers.length})',
            subtitle: l10n.blockedDevicesSubtitle,
            showToggle: viewModel.blockedUsers.length >= 2,
            isExpanded: viewModel.uiState.expandedBlockedDevices,
            onToggle: () => onToggleSection('blocked'),
            loc: l10n,
          ),
          if (viewModel.uiState.expandedBlockedDevices)
            ...viewModel.blockedUsers.map((user) =>
                _buildUserCard(context, user, isSaved: !user.isOnline)),
          const SizedBox(height: 24),
        ],
      ],
    );
  }

  Widget _buildEmptyDevicesState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.devices,
            size: 64,
            color: Theme.of(context).disabledColor,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noDevicesFound,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            viewModel.isTemporarilyDisabled
                ? l10n.p2pNetworkingPaused
                : (viewModel.isRefreshing
                    ? l10n.searchingForDevices
                    : (viewModel.isEnabled
                        ? (viewModel.hasPerformedInitialDiscovery
                            ? l10n.noDevicesInRange
                            : l10n.initialDiscoveryInProgress)
                        : l10n.startNetworkingToDiscover)),
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required BuildContext context,
    required String title,
    String? subtitle,
    bool showToggle = false,
    bool isExpanded = true,
    VoidCallback? onToggle,
    required AppLocalizations loc,
  }) {
    final toggleIcon = isExpanded ? Icons.expand_less : Icons.expand_more;
    final toggleLabel = isExpanded ? loc.collapse : loc.expand;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: showToggle ? onToggle : null,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.9)
                              : Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ],
              ),
            ),
            if (showToggle)
              IconButton(
                onPressed: onToggle,
                icon: Icon(toggleIcon),
                tooltip: toggleLabel,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, P2PUser user,
      {bool isOnline = false, bool isNew = false, bool isSaved = false}) {
    final l10n = AppLocalizations.of(context);
    final width = MediaQuery.of(context).size.width;
    final brightness = Theme.of(context).brightness;

    final buttonList = <IconButtonListItem>[
      IconButtonListItem(
        icon: Icons.info,
        label: l10n.viewInfo,
        onPressed: () => onUserAction('view_info', user),
      ),
      if (user.isBlocked)
        IconButtonListItem(
          icon: Icons.lock_open,
          label: l10n.unblock,
          onPressed: () => onUserAction('unblock', user),
        ),
      if (isOnline && !user.isBlocked)
        IconButtonListItem(
          icon: Icons.chat,
          label: l10n.chatWith(user.displayName),
          onPressed: () => onUserAction('chat', user),
        ),
      if (isOnline &&
          !user.isBlocked &&
          viewModel.canSendRemoteControlRequest(user))
        IconButtonListItem(
          icon: Icons.control_camera,
          label: l10n.remoteControl,
          onPressed: () => onUserAction('remote_control', user),
        ),
      // if (isOnline &&
      //     !user.isBlocked &&
      //     viewModel.canSendScreenSharingRequest(user))
      //   IconButtonListItem(
      //     icon: Icons.screen_share,
      //     label: l10n.screenSharing,
      //     onPressed: () => onUserAction('screen_sharing', user),
      //   ),
      if (!user.isPaired && !user.isBlocked)
        IconButtonListItem(
          icon: Icons.link,
          label: l10n.pair,
          onPressed: () => onUserAction('pair', user),
        ),
      if (user.isPaired && !user.isTrusted && !user.isBlocked)
        IconButtonListItem(
          icon: Icons.verified_user,
          label: l10n.addTrust,
          onPressed: () => onUserAction('add_trust', user),
        ),
      if (user.isTrusted && !user.isBlocked)
        IconButtonListItem(
          icon: Icons.security,
          label: l10n.removeTrust,
          onPressed: () => onUserAction('remove_trust', user),
        ),
      if (user.isStored && !user.isBlocked) ...[
        IconButtonListItem(
          icon: Icons.link_off,
          label: l10n.unpair,
          onPressed: () => onUserAction('unpair', user),
        ),
        IconButtonListItem(
          icon: Icons.block,
          label: l10n.block,
          onPressed: () => onUserAction('block', user),
        ),
      ],
    ];

    const int hiddenItemsCount = 3;

    int visibleCount = width > desktopScreenWidthThreshold
        ? math.max(0, buttonList.length - hiddenItemsCount)
        : 0;

    // Determine card background color
    Color? cardColor;
    if (user.isBlocked && user.isOnline) {
      cardColor = Colors.red.withValues(alpha: .10);
    } else if (isOnline) {
      cardColor = brightness == Brightness.dark
          ? Colors.green.withValues(alpha: .10)
          : Colors.green[50];
    } else if (isNew) {
      cardColor = brightness == Brightness.dark
          ? Colors.blue.withValues(alpha: .10)
          : Colors.blue[50];
    } else if (isSaved) {
      cardColor = brightness == Brightness.dark
          ? Colors.grey.withValues(alpha: .10)
          : Colors.grey[100];
    }

    String userSubtitle =
        '${user.ipAddress}:${user.port}${viewModel.isUserNameDuplicated(user) ? ' - ${user.appInstallationId.substring(0, 4)}' : ''}';

    final Color statusColor = user.isBlocked
        ? (user.isOnline ? Colors.red : Colors.grey)
        : viewModel.getUserStatusColor(user);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: statusColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      color: cardColor,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor,
          child: Icon(
            user.isBlocked ? Icons.block : viewModel.getUserStatusIcon(user),
            color: Colors.white,
          ),
        ),
        title: Text(user.displayName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(userSubtitle),
            if (user.isPaired || user.isTrusted) ...[
              const SizedBox(height: 4),
              Wrap(
                spacing: 6.0,
                runSpacing: 4.0,
                children: [
                  if (user.isStored)
                    _buildChip(
                        label: l10n.saved,
                        icon: Icons.save,
                        color: Colors.grey),
                  if (user.isTrusted)
                    _buildChip(
                        label: l10n.trust,
                        icon: Icons.verified_user,
                        color: Colors.grey),
                ],
              ),
            ],
          ],
        ),
        onTap: () => onSelectUser(user),
        trailing:
            IconButtonList(buttons: buttonList, visibleCount: visibleCount),
      ),
    );
  }

  Widget _buildChip({
    required IconData icon,
    required Color color,
    String? label,
    double size = 14,
    VoidCallback? onPressed,
  }) {
    final chipContent = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: size, color: color),
        const SizedBox(width: 4),
        if (label != null)
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: size,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );

    if (onPressed != null) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: chipContent,
          ),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: chipContent,
      );
    }
  }
}

/// Transfers tab widget
class _TransfersTabWidget extends StatelessWidget {
  final P2PViewModel viewModel;
  final P2PUIState uiState;
  final ScrollController scrollController;
  final Function(String) onCancelTransfer;
  final Function(String) onClearTransfer;
  final Function(String, bool) onClearTransferWithFile;
  final Function(String?, bool) onBatchExpandChanged;
  final Function(String?) onClearBatch;
  final Function(String?) onClearBatchWithFiles;

  const _TransfersTabWidget({
    required this.viewModel,
    required this.uiState,
    required this.scrollController,
    required this.onCancelTransfer,
    required this.onClearTransfer,
    required this.onClearTransferWithFile,
    required this.onBatchExpandChanged,
    required this.onClearBatch,
    required this.onClearBatchWithFiles,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (viewModel.activeTransfers.isEmpty) {
      return Stack(
        children: [
          _buildEmptyTransfersState(context, l10n),
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton(
              onPressed: () =>
                  viewModel.executeCommand(P2PCommands.toggleTransferFilter()),
              tooltip: _getFilterTooltip(l10n),
              child: Icon(_getFilterIcon()),
            ),
          ),
        ],
      );
    }

    // Filter and group transfers
    final filteredTransfers = _getFilteredTransfers();
    final groupedTransfers = _groupTransfersByBatch(filteredTransfers);
    final batchWidgets = _buildBatchWidgets(groupedTransfers);

    return Stack(
      children: [
        ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          children: batchWidgets,
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            onPressed: () =>
                viewModel.executeCommand(P2PCommands.toggleTransferFilter()),
            tooltip: _getFilterTooltip(l10n),
            child: Icon(_getFilterIcon()),
          ),
        ),
      ],
    );
  }

  List<DataTransferTask> _getFilteredTransfers() {
    final sortedTransfers =
        List<DataTransferTask>.from(viewModel.activeTransfers)
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return sortedTransfers.where((t) {
      switch (uiState.transferFilterMode) {
        case TransferFilterMode.all:
          return true;
        case TransferFilterMode.outgoing:
          return t.isOutgoing;
        case TransferFilterMode.incoming:
          return !t.isOutgoing;
      }
    }).toList();
  }

  Map<String?, List<DataTransferTask>> _groupTransfersByBatch(
      List<DataTransferTask> transfers) {
    final Map<String?, List<DataTransferTask>> groupedTransfers = {};
    for (final transfer in transfers) {
      final batchId = transfer.batchId;
      groupedTransfers.putIfAbsent(batchId, () => []);
      groupedTransfers[batchId]!.add(transfer);
    }
    return groupedTransfers;
  }

  List<Widget> _buildBatchWidgets(
      Map<String?, List<DataTransferTask>> groupedTransfers) {
    final batchWidgets = <Widget>[];
    for (final entry in groupedTransfers.entries) {
      final batchId = entry.key;

      // Batch expand state is no longer remembered - always start collapsed
      bool isExpanded = false;

      batchWidgets.add(
        TransferBatchWidget(
          batchId: batchId,
          tasks: entry.value,
          initialExpanded: isExpanded,
          onCancel: onCancelTransfer,
          onClear: onClearTransfer,
          onClearWithFile: onClearTransferWithFile,
          onExpandChanged: onBatchExpandChanged,
          onClearBatch: onClearBatch,
          onClearBatchWithFiles: onClearBatchWithFiles,
        ),
      );
    }

    return batchWidgets;
  }

  Widget _buildEmptyTransfersState(
      BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.swap_horiz,
            size: 64,
            color: Theme.of(context).disabledColor,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noActiveTransfers,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.transfersWillAppearHere,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  IconData _getFilterIcon() {
    switch (uiState.transferFilterMode) {
      case TransferFilterMode.all:
        return Icons.swap_horiz;
      case TransferFilterMode.outgoing:
        return Icons.file_upload;
      case TransferFilterMode.incoming:
        return Icons.file_download;
    }
  }

  String _getFilterTooltip(AppLocalizations l10n) {
    switch (uiState.transferFilterMode) {
      case TransferFilterMode.all:
        return l10n.transferStatusViewAll;
      case TransferFilterMode.outgoing:
        return l10n.transferStatusViewOutgoing;
      case TransferFilterMode.incoming:
        return l10n.transferStatusViewIncoming;
    }
  }
}

/// Status panel widget
class _StatusPanelWidget extends StatelessWidget {
  final P2PViewModel viewModel;
  final P2PUIState uiState;

  const _StatusPanelWidget({
    required this.viewModel,
    required this.uiState,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final List<Widget> cards = [];

    // File Cache card (Android only)
    if (Platform.isAndroid) {
      cards.addAll([
        _buildFileCacheCard(context, l10n),
        const SizedBox(height: 16),
      ]);
    }

    // Status cards based on visibility settings
    if (uiState.statusCardVisibility['thisDevice'] == true) {
      cards.addAll([
        _buildThisDeviceCard(context, l10n),
        const SizedBox(height: 8),
      ]);
    }

    if (uiState.statusCardVisibility['connectionStatus'] == true) {
      cards.addAll([
        _buildConnectionStatusCard(context, l10n),
        const SizedBox(height: 8),
      ]);
    }

    if (uiState.statusCardVisibility['statistics'] == true) {
      cards.add(_buildStatisticsCard(context, l10n));
    }

    if (cards.isNotEmpty) {
      cards.add(const SizedBox(height: 24));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: cards.isNotEmpty
            ? cards
            : [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.visibility_off,
                          size: 48,
                          color: Theme.of(context).disabledColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.noStatusCardsEnabled,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Theme.of(context).disabledColor,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.useTheCustomizeButtonToEnableStatusCards,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).disabledColor,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
      ),
    );
  }

  Widget _buildFileCacheCard(BuildContext context, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.fileCache,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton.icon(
                      onPressed: () => viewModel
                          .executeCommand(P2PCommands.reloadCacheSize()),
                      icon: const Icon(Icons.refresh, size: 18),
                      label: Text(l10n.reload),
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () => viewModel
                          .executeCommand(P2PCommands.clearFileCache()),
                      icon: const Icon(Icons.clear_all, size: 18),
                      label: Text(l10n.clear),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.orange[700],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '${l10n.cacheSize}: ',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (uiState.isCalculatingCacheSize)
                  Row(
                    children: [
                      SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(l10n.calculating),
                    ],
                  )
                else
                  Text(
                    uiState.cachedFileCacheSize,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              l10n.tempFilesDescription,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThisDeviceCard(BuildContext context, AppLocalizations l10n) {
    return FutureBuilder<Widget>(
      future: _buildThisDeviceCardContent(context, l10n),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return snapshot.data!;
        } else {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.thisDevice,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 8),
                      Text(l10n.loadingDeviceInfo),
                    ],
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Future<Widget> _buildThisDeviceCardContent(
      BuildContext context, AppLocalizations l10n) async {
    try {
      final deviceName = await NetworkSecurityService.getDeviceName();
      final appInstallationId =
          await NetworkSecurityService.getAppInstallationId();

      if (!context.mounted) return Container();

      final deviceUser = P2PUser(
        id: appInstallationId,
        displayName: deviceName,
        profileId: appInstallationId,
        ipAddress: viewModel.currentUser?.ipAddress ?? 'Not connected',
        port: viewModel.currentUser?.port ?? 0,
        isOnline: viewModel.isEnabled,
        lastSeen: DateTime.now(),
        isStored: false,
      );

      return DeviceInfoCard(
        user: deviceUser,
        title: l10n.thisDevice,
        showStatusChips: false,
        isCompact: false,
        showDeviceIdToggle: true,
      );
    } catch (e) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.thisDevice,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Text(
                'Error loading device info',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).disabledColor,
                    ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildConnectionStatusCard(
      BuildContext context, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.connectionStatus,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  _getConnectionStatusIcon(),
                  color: _getConnectionStatusColor(),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(viewModel.getConnectionStatusDescription(l10n)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  _getNetworkStatusIcon(),
                  color: _getNetworkStatusColor(),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    viewModel.getNetworkStatusDescription(l10n),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCard(BuildContext context, AppLocalizations l10n) {
    return (viewModel.currentUser != null)
        ? Card(
            child: SizedBox(
              width: double.infinity,
              child: table_builder.GenericTableBuilder.buildResultCard(
                context,
                title: l10n.statistics,
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceContainerLow,
                style: table_builder.TableStyle.simple,
                rows: [
                  table_builder.TableRow(
                    label: l10n.discoveredDevices,
                    value: '${viewModel.discoveredUsers.length}',
                  ),
                  table_builder.TableRow(
                    label: l10n.pairedDevices,
                    value: '${viewModel.pairedUsers.length}',
                  ),
                  table_builder.TableRow(
                    label: l10n.activeTransfers,
                    value:
                        '${viewModel.activeTransfers.where((t) => t.status == DataTransferStatus.transferring || t.status == DataTransferStatus.pending || t.status == DataTransferStatus.requesting || t.status == DataTransferStatus.waitingForApproval).length}',
                  ),
                  table_builder.TableRow(
                    label: l10n.completedTransfers,
                    value:
                        '${viewModel.activeTransfers.where((t) => t.status == DataTransferStatus.completed).length}',
                  ),
                  table_builder.TableRow(
                    label: l10n.failedTransfers,
                    value:
                        '${viewModel.activeTransfers.where((t) => t.status == DataTransferStatus.failed || t.status == DataTransferStatus.cancelled || t.status == DataTransferStatus.rejected).length}',
                  ),
                ],
              ),
            ),
          )
        : Container();
  }

  IconData _getConnectionStatusIcon() {
    switch (viewModel.connectionStatus) {
      case ConnectionStatus.disconnected:
        return Icons.wifi_off;
      case ConnectionStatus.discovering:
        return Icons.search;
      case ConnectionStatus.connected:
        return Icons.wifi;
      case ConnectionStatus.pairing:
        return Icons.link;
      case ConnectionStatus.paired:
        return Icons.check_circle;
    }
  }

  Color _getConnectionStatusColor() {
    switch (viewModel.connectionStatus) {
      case ConnectionStatus.disconnected:
        return Colors.red;
      case ConnectionStatus.discovering:
        return Colors.orange;
      case ConnectionStatus.connected:
        return Colors.blue;
      case ConnectionStatus.pairing:
        return Colors.orange;
      case ConnectionStatus.paired:
        return Colors.green;
    }
  }

  IconData _getNetworkStatusIcon() {
    if (viewModel.isTemporarilyDisabled) {
      return Icons.pause_circle_outline;
    }

    final networkInfo = viewModel.networkInfo;
    if (networkInfo == null) return Icons.help_outline;

    if (networkInfo.isMobile) {
      return Icons.signal_cellular_4_bar;
    } else if (networkInfo.isWiFi) {
      return networkInfo.isSecure ? Icons.wifi_lock : Icons.wifi;
    } else if (networkInfo.securityType == 'ETHERNET') {
      return Icons.lan;
    } else {
      return Icons.wifi_off;
    }
  }

  Color _getNetworkStatusColor() {
    if (viewModel.isTemporarilyDisabled) {
      return Colors.orange;
    }

    final networkInfo = viewModel.networkInfo;
    if (networkInfo == null) return Colors.grey;

    switch (networkInfo.securityLevel) {
      case NetworkSecurityLevel.secure:
        return Colors.green;
      case NetworkSecurityLevel.unsecure:
        return Colors.orange;
      case NetworkSecurityLevel.unknown:
        return Colors.grey;
    }
  }
}
