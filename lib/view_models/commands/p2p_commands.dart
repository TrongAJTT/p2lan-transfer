import 'package:p2lan/models/p2p_models.dart';

/// Base class for all P2P commands
abstract class P2PCommand {}

/// UI Commands - for UI state changes
abstract class P2PUICommand extends P2PCommand {}

/// Business Commands - for business logic operations
abstract class P2PBusinessCommand extends P2PCommand {}

// =============================================================================
// UI COMMANDS
// =============================================================================

/// Command to switch tabs
class SwitchTabCommand extends P2PUICommand {
  final int tabIndex;
  SwitchTabCommand(this.tabIndex);
}

/// Command to toggle device section expand/collapse
class ToggleDeviceSectionCommand extends P2PUICommand {
  final String sectionType; // 'online', 'new', 'saved', 'blocked'
  ToggleDeviceSectionCommand(this.sectionType);
}

/// Command to toggle transfer filter mode
class ToggleTransferFilterCommand extends P2PUICommand {}

/// Command to toggle status card visibility
class ToggleStatusCardCommand extends P2PUICommand {
  final String cardKey;
  ToggleStatusCardCommand(this.cardKey);
}

/// Command to update compact layout setting
class UpdateCompactLayoutCommand extends P2PUICommand {
  final bool useCompactLayout;
  UpdateCompactLayoutCommand(this.useCompactLayout);
}

/// Command to enable/disable keyboard shortcuts
class ToggleKeyboardShortcutsCommand extends P2PUICommand {
  final bool enabled;
  ToggleKeyboardShortcutsCommand(this.enabled);
}

// =============================================================================
// BUSINESS COMMANDS
// =============================================================================

/// Command to start P2P networking
class StartNetworkingCommand extends P2PBusinessCommand {}

/// Command to stop P2P networking
class StopNetworkingCommand extends P2PBusinessCommand {}

/// Command to perform manual discovery
class ManualDiscoveryCommand extends P2PBusinessCommand {}

/// Command to send pairing request
class SendPairingRequestCommand extends P2PBusinessCommand {
  final P2PUser targetUser;
  final bool saveConnection;
  final bool trustUser;

  SendPairingRequestCommand({
    required this.targetUser,
    required this.saveConnection,
    required this.trustUser,
  });
}

/// Command to respond to pairing request
class RespondToPairingRequestCommand extends P2PBusinessCommand {
  final String requestId;
  final bool accept;
  final bool trustUser;
  final bool saveConnection;

  RespondToPairingRequestCommand({
    required this.requestId,
    required this.accept,
    required this.trustUser,
    required this.saveConnection,
  });
}

/// Command to send files to user
class SendFilesToUserCommand extends P2PBusinessCommand {
  final List<String> filePaths;
  final P2PUser targetUser;

  SendFilesToUserCommand({
    required this.filePaths,
    required this.targetUser,
  });
}

/// Command to cancel transfer
class CancelTransferCommand extends P2PBusinessCommand {
  final String taskId;
  CancelTransferCommand(this.taskId);
}

/// Command to clear transfer
class ClearTransferCommand extends P2PBusinessCommand {
  final String taskId;
  final bool deleteFile;

  ClearTransferCommand({
    required this.taskId,
    this.deleteFile = false,
  });
}

/// Command to clear all transfers
class ClearAllTransfersCommand extends P2PBusinessCommand {
  final bool deleteFiles;
  ClearAllTransfersCommand({this.deleteFiles = false});
}

/// Command to clear batch
class ClearBatchCommand extends P2PBusinessCommand {
  final String? batchId;
  final bool deleteFiles;

  ClearBatchCommand({
    required this.batchId,
    this.deleteFiles = false,
  });
}

/// Command to add trust to user
class AddTrustCommand extends P2PBusinessCommand {
  final String userId;
  AddTrustCommand(this.userId);
}

/// Command to remove trust from user
class RemoveTrustCommand extends P2PBusinessCommand {
  final String userId;
  RemoveTrustCommand(this.userId);
}

/// Command to unpair user
class UnpairUserCommand extends P2PBusinessCommand {
  final String userId;
  UnpairUserCommand(this.userId);
}

/// Command to block/unblock user
class BlockUserCommand extends P2PBusinessCommand {
  final P2PUser user;
  final bool blocked;

  BlockUserCommand({
    required this.user,
    required this.blocked,
  });
}

/// Command to respond to file transfer request
class RespondToFileTransferRequestCommand extends P2PBusinessCommand {
  final String requestId;
  final bool accept;
  final String? rejectMessage;

  RespondToFileTransferRequestCommand({
    required this.requestId,
    required this.accept,
    this.rejectMessage,
  });
}

/// Command to reload cache size
class ReloadCacheSizeCommand extends P2PBusinessCommand {}

/// Command to clear file cache
class ClearFileCacheCommand extends P2PBusinessCommand {}

/// Command to reload transfer settings
class ReloadTransferSettingsCommand extends P2PBusinessCommand {}

/// Command to show dialog
class ShowDialogCommand extends P2PUICommand {
  final String dialogType;
  final Map<String, dynamic> dialogData;

  ShowDialogCommand({
    required this.dialogType,
    required this.dialogData,
  });
}

// Remote Control Commands

/// Command to send remote control request to target user
class SendRemoteControlRequestCommand extends P2PBusinessCommand {
  final P2PUser targetUser;

  SendRemoteControlRequestCommand({
    required this.targetUser,
  });
}

/// Command to respond to a remote control request
class RespondToRemoteControlRequestCommand extends P2PBusinessCommand {
  final String requestId;
  final bool accepted;

  RespondToRemoteControlRequestCommand({
    required this.requestId,
    required this.accepted,
  });
}

/// Command to send remote control event
class SendRemoteControlEventCommand extends P2PBusinessCommand {
  final RemoteControlEventType eventType;
  final Map<String, dynamic> eventData;

  SendRemoteControlEventCommand({
    required this.eventType,
    required this.eventData,
  });
}

/// Command to disconnect remote control session
class DisconnectRemoteControlCommand extends P2PBusinessCommand {}

// Screen Sharing Commands

/// Command to send screen sharing request to target user
class SendScreenSharingRequestCommand extends P2PBusinessCommand {
  final P2PUser targetUser;
  final String? reason;
  final ScreenSharingQuality quality;

  SendScreenSharingRequestCommand({
    required this.targetUser,
    this.reason,
    this.quality = ScreenSharingQuality.medium,
  });
}

/// Command to respond to a screen sharing request
class RespondToScreenSharingRequestCommand extends P2PBusinessCommand {
  final String requestId;
  final bool accepted;
  final String? rejectReason;

  RespondToScreenSharingRequestCommand({
    required this.requestId,
    required this.accepted,
    this.rejectReason,
  });
}

/// Command to start screen sharing
class StartScreenSharingCommand extends P2PBusinessCommand {
  final P2PUser targetUser;
  final ScreenSharingQuality quality;
  final int? screenIndex;

  StartScreenSharingCommand({
    required this.targetUser,
    this.quality = ScreenSharingQuality.medium,
    this.screenIndex,
  });
}

/// Command to stop screen sharing
class StopScreenSharingCommand extends P2PBusinessCommand {}

/// Command to stop screen receiving
class StopScreenReceivingCommand extends P2PBusinessCommand {}

/// Command to disconnect screen sharing session
class DisconnectScreenSharingCommand extends P2PBusinessCommand {}
