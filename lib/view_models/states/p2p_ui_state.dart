import 'package:flutter/material.dart';
import 'package:p2lan/models/p2p_models.dart';

/// Transfer filter mode for viewing transfer tasks
enum TransferFilterMode { all, outgoing, incoming }

/// UI State for P2P Transfer Screen
/// Contains all UI-specific state that doesn't belong to business logic
@immutable
class P2PUIState {
  // Tab and navigation state
  final int currentTabIndex;
  final bool useCompactLayout;
  final bool enableKeyboardShortcuts;

  // Cache management UI state
  final bool isCalculatingCacheSize;
  final String cachedFileCacheSize;

  // Device sections expand/collapse state
  final bool expandedOnlineDevices;
  final bool expandedNewDevices;
  final bool expandedSavedDevices;
  final bool expandedBlockedDevices;

  // Transfer view filter state
  final TransferFilterMode transferFilterMode;

  // Status card visibility state
  final Map<String, bool> statusCardVisibility;

  // Loading and error states
  final bool isLoading;
  final String? errorMessage;

  // Remote control session state
  final RemoteControlSession? currentRemoteControlSession;

  // Screen sharing session state
  final ScreenSharingSession? currentScreenSharingSession;

  const P2PUIState({
    this.currentTabIndex = 0,
    this.useCompactLayout = false,
    this.enableKeyboardShortcuts = true,
    this.isCalculatingCacheSize = false,
    this.cachedFileCacheSize = 'Unknown',
    this.expandedOnlineDevices = true,
    this.expandedNewDevices = true,
    this.expandedSavedDevices = true,
    this.expandedBlockedDevices = true,
    this.transferFilterMode = TransferFilterMode.all,
    this.statusCardVisibility = const {
      'thisDevice': true,
      'connectionStatus': true,
      'statistics': true,
    },
    this.isLoading = false,
    this.errorMessage,
    this.currentRemoteControlSession,
    this.currentScreenSharingSession,
  });

  /// Initial state
  factory P2PUIState.initial() => const P2PUIState();

  /// Loading state
  P2PUIState loading() => copyWith(isLoading: true, errorMessage: null);

  /// Error state
  P2PUIState error(String message) =>
      copyWith(isLoading: false, errorMessage: message);

  /// Success state
  P2PUIState success() => copyWith(isLoading: false, errorMessage: null);

  /// Copy with method for immutable updates
  P2PUIState copyWith({
    int? currentTabIndex,
    bool? useCompactLayout,
    bool? enableKeyboardShortcuts,
    bool? isCalculatingCacheSize,
    String? cachedFileCacheSize,
    bool? expandedOnlineDevices,
    bool? expandedNewDevices,
    bool? expandedSavedDevices,
    bool? expandedBlockedDevices,
    TransferFilterMode? transferFilterMode,
    Map<String, bool>? statusCardVisibility,
    bool? isLoading,
    String? errorMessage,
    RemoteControlSession? currentRemoteControlSession,
    ScreenSharingSession? currentScreenSharingSession,
  }) {
    return P2PUIState(
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
      useCompactLayout: useCompactLayout ?? this.useCompactLayout,
      enableKeyboardShortcuts:
          enableKeyboardShortcuts ?? this.enableKeyboardShortcuts,
      isCalculatingCacheSize:
          isCalculatingCacheSize ?? this.isCalculatingCacheSize,
      cachedFileCacheSize: cachedFileCacheSize ?? this.cachedFileCacheSize,
      expandedOnlineDevices:
          expandedOnlineDevices ?? this.expandedOnlineDevices,
      expandedNewDevices: expandedNewDevices ?? this.expandedNewDevices,
      expandedSavedDevices: expandedSavedDevices ?? this.expandedSavedDevices,
      expandedBlockedDevices:
          expandedBlockedDevices ?? this.expandedBlockedDevices,
      transferFilterMode: transferFilterMode ?? this.transferFilterMode,
      statusCardVisibility: statusCardVisibility ?? this.statusCardVisibility,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      currentRemoteControlSession: currentRemoteControlSession,
      currentScreenSharingSession: currentScreenSharingSession,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is P2PUIState &&
          runtimeType == other.runtimeType &&
          currentTabIndex == other.currentTabIndex &&
          useCompactLayout == other.useCompactLayout &&
          enableKeyboardShortcuts == other.enableKeyboardShortcuts &&
          isCalculatingCacheSize == other.isCalculatingCacheSize &&
          cachedFileCacheSize == other.cachedFileCacheSize &&
          expandedOnlineDevices == other.expandedOnlineDevices &&
          expandedNewDevices == other.expandedNewDevices &&
          expandedSavedDevices == other.expandedSavedDevices &&
          expandedBlockedDevices == other.expandedBlockedDevices &&
          transferFilterMode == other.transferFilterMode &&
          const DeepCollectionEquality()
              .equals(statusCardVisibility, other.statusCardVisibility) &&
          isLoading == other.isLoading &&
          errorMessage == other.errorMessage &&
          currentRemoteControlSession == other.currentRemoteControlSession &&
          currentScreenSharingSession == other.currentScreenSharingSession;

  @override
  int get hashCode =>
      currentTabIndex.hashCode ^
      useCompactLayout.hashCode ^
      enableKeyboardShortcuts.hashCode ^
      isCalculatingCacheSize.hashCode ^
      cachedFileCacheSize.hashCode ^
      expandedOnlineDevices.hashCode ^
      expandedNewDevices.hashCode ^
      expandedSavedDevices.hashCode ^
      expandedBlockedDevices.hashCode ^
      transferFilterMode.hashCode ^
      const DeepCollectionEquality().hash(statusCardVisibility) ^
      isLoading.hashCode ^
      errorMessage.hashCode ^
      currentRemoteControlSession.hashCode ^
      currentScreenSharingSession.hashCode;
}

/// Extension for DeepCollectionEquality
class DeepCollectionEquality {
  const DeepCollectionEquality();

  bool equals(Object? e1, Object? e2) {
    if (e1 == null && e2 == null) return true;
    if (e1 == null || e2 == null) return false;
    if (e1 is Map && e2 is Map) {
      if (e1.length != e2.length) return false;
      for (var key in e1.keys) {
        if (!e2.containsKey(key) || e1[key] != e2[key]) return false;
      }
      return true;
    }
    return e1 == e2;
  }

  int hash(Object? o) {
    if (o == null) return 0;
    if (o is Map) {
      var h = 0;
      for (var entry in o.entries) {
        h ^= entry.key.hashCode ^ (entry.value?.hashCode ?? 0);
      }
      return h;
    }
    return o.hashCode;
  }
}
