// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get title => 'P2Lan Transfer';

  @override
  String get version => 'Version';

  @override
  String get versionInfo => 'Version Information';

  @override
  String get appVersion => 'App Version';

  @override
  String get versionType => 'Version Type';

  @override
  String get versionTypeDev => 'Development';

  @override
  String get versionTypeBeta => 'Beta';

  @override
  String get versionTypeRelease => 'Release';

  @override
  String get versionTypeDevDisplay => 'Development Version';

  @override
  String get versionTypeBetaDisplay => 'Beta Version';

  @override
  String get versionTypeReleaseDisplay => 'Release Version';

  @override
  String get githubRepo => 'GitHub Repository';

  @override
  String get githubRepoDesc => 'View source code of the application on GitHub';

  @override
  String get creditAck => 'Credits & Acknowledgements';

  @override
  String get creditAckDesc => 'Libraries and resources used in this app';

  @override
  String get supportDesc =>
      'P2Lan Transfer helps you transfer data between devices on the same network more easily. If you find it useful, consider supporting me to maintain and improve it. Thank you very much!';

  @override
  String get githubSponsorsDesc => 'Official support page on GitHub';

  @override
  String get buyMeACoffeeDesc =>
      'In case you don\'t have a Github Sponsors account';

  @override
  String get donate => 'Donate';

  @override
  String get donateDesc => 'Support me if you find this app useful';

  @override
  String get checkForNewVersion => 'Check for New Version';

  @override
  String get checkForNewVersionDesc =>
      'Check if there is a new version of the app and download the latest version if available';

  @override
  String get platform => 'Platform';

  @override
  String get routine => 'Routine';

  @override
  String get settings => 'Settings';

  @override
  String get view => 'View';

  @override
  String get viewMode => 'View Mode';

  @override
  String get viewDetails => 'View details';

  @override
  String get theme => 'Theme';

  @override
  String get single => 'Single';

  @override
  String get all => 'All';

  @override
  String get images => 'Images';

  @override
  String get videos => 'Videos';

  @override
  String get documents => 'Documents';

  @override
  String get audio => 'Audio';

  @override
  String get archives => 'Archives';

  @override
  String get language => 'Language';

  @override
  String get userInterface => 'User Interface';

  @override
  String get userInterfaceDesc => 'Theme, language and appearance settings';

  @override
  String get system => 'System';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get clearCache => 'Clear Cache';

  @override
  String get viewCacheDetails => 'View Details';

  @override
  String get cacheSize => 'Cache Size';

  @override
  String get clearAllCache => 'Clear All Cache';

  @override
  String get clearStorageSettingsTitle => 'Clear Storage Settings';

  @override
  String get clearStorageSettingsConfirm => 'Clear All';

  @override
  String get clearStorageSettingsCancel => 'Cancel';

  @override
  String get clearStorageSettingsConfirmation =>
      'This action will permanently delete all cached data including templates, history, and temporary files. Your app settings will be preserved.';

  @override
  String get clearStorageSettingsSuccess =>
      'Storage settings cleared successfully';

  @override
  String get viewLogs => 'View Logs';

  @override
  String get clearLogs => 'Clear Logs';

  @override
  String get logRetention => 'Log Retention';

  @override
  String logRetentionDays(int days) {
    return '$days days';
  }

  @override
  String get logRetentionForever => 'Keep forever';

  @override
  String get logRetentionDescDetail =>
      'Choose log retention period (5-30 days in 5-day intervals, or forever)';

  @override
  String get dataAndStorage => 'Data & Storage';

  @override
  String get dataAndStorageDesc => 'Cache, logs & data retention settings';

  @override
  String get cannotClearFollowingCaches =>
      'The following caches cannot be cleared because they are currently in use:';

  @override
  String get back => 'Back';

  @override
  String get close => 'Close';

  @override
  String get custom => 'Custom';

  @override
  String get online => 'Online';

  @override
  String get offline => 'Offline';

  @override
  String get options => 'Options';

  @override
  String get about => 'About';

  @override
  String get add => 'Add';

  @override
  String get save => 'Save';

  @override
  String get saved => 'Saved';

  @override
  String get trusted => 'Trusted';

  @override
  String get edit => 'Edit';

  @override
  String get copy => 'Copy';

  @override
  String get move => 'Move';

  @override
  String get destination => 'Destination';

  @override
  String get fileName => 'File Name';

  @override
  String get overwrite => 'Overwrite';

  @override
  String get cancel => 'Cancel';

  @override
  String get search => 'Search';

  @override
  String get searchHint => 'Search...';

  @override
  String get remoteControl => 'Remote Control';

  @override
  String get beingRemoteControlled => 'Being Remote Controlled';

  @override
  String get remoteControlling => 'Remote Controlling';

  @override
  String get screenSharing => 'Screen Sharing';

  @override
  String get sharingScreen => 'Sharing Screen';

  @override
  String get viewingScreen => 'Viewing Screen';

  @override
  String isControllingThisDevice(Object userName) {
    return '$userName is controlling this device';
  }

  @override
  String controllingUser(Object userName) {
    return 'Controlling $userName';
  }

  @override
  String get endSession => 'End Session';

  @override
  String get duration => 'Duration';

  @override
  String get started => 'Started';

  @override
  String get disconnectRemoteControl => 'Disconnect Remote Control';

  @override
  String disconnectRemoteControlConfirm(Object userName) {
    return 'Are you sure you want to disconnect from $userName?';
  }

  @override
  String get disconnect => 'Disconnect';

  @override
  String connectingTo(Object userName) {
    return 'Connecting to $userName...';
  }

  @override
  String connectedTo(Object userName) {
    return 'Connected to $userName';
  }

  @override
  String get controlsInfo => 'Controls info';

  @override
  String get touchpadArea => 'Touchpad Area';

  @override
  String get moveFingerToControlMouse => 'Move finger to control mouse';

  @override
  String get leftClick => 'Left Mouse';

  @override
  String get middleClick => 'Middle Mouse';

  @override
  String get rightClick => 'Right Mouse';

  @override
  String get scrollUp => 'Scroll Up';

  @override
  String get scrollDown => 'Scroll Down';

  @override
  String get remoteControlHelp => 'Remote Control Help';

  @override
  String get howToControlRemoteComputer =>
      'How to control the remote computer:';

  @override
  String get noteWindowsOnly =>
      'Note: This feature only works when controlling Windows computers.';

  @override
  String get gotIt => 'Got it';

  @override
  String get history => 'History';

  @override
  String get aboutDesc => 'App information and acknowledgements';

  @override
  String get random => 'Random Generator';

  @override
  String get holdToDeleteInstruction =>
      'Hold the delete button for 5 seconds to confirm';

  @override
  String get holdToDelete => 'Hold to delete...';

  @override
  String get deleting => 'Deleting...';

  @override
  String get help => 'Help';

  @override
  String get importResults => 'Import Results';

  @override
  String importSummary(Object failCount, Object successCount) {
    return '$successCount successful, $failCount failed';
  }

  @override
  String successfulImports(Object count) {
    return 'Successful imports ($count)';
  }

  @override
  String failedImports(Object count) {
    return 'Failed imports ($count)';
  }

  @override
  String get noImportsAttempted => 'No files were selected for import';

  @override
  String get selectAll => 'Select All';

  @override
  String get deselectAll => 'Deselect All';

  @override
  String get batchDelete => 'Delete Selected';

  @override
  String get confirmBatchDelete => 'Confirm Batch Delete';

  @override
  String typeConfirmToDelete(Object count) {
    return 'Type \"confirm\" to delete $count selected templates:';
  }

  @override
  String get generate => 'Generate';

  @override
  String get copyToClipboard => 'Copy to Clipboard';

  @override
  String get filterByType => 'Filter by Type';

  @override
  String get bookmark => 'Bookmark';

  @override
  String numberOfDays(int count) {
    return '$count days';
  }

  @override
  String get year => 'Year';

  @override
  String get month => 'Month';

  @override
  String get weekday => 'Weekday';

  @override
  String get first => 'First';

  @override
  String get last => 'Last';

  @override
  String get monday => 'Monday';

  @override
  String get tuesday => 'Tuesday';

  @override
  String get wednesday => 'Wednesday';

  @override
  String get thursday => 'Thursday';

  @override
  String get friday => 'Friday';

  @override
  String get saturday => 'Saturday';

  @override
  String get sunday => 'Sunday';

  @override
  String get january => 'January';

  @override
  String get february => 'February';

  @override
  String get march => 'March';

  @override
  String get april => 'April';

  @override
  String get may => 'May';

  @override
  String get june => 'June';

  @override
  String get july => 'July';

  @override
  String get august => 'August';

  @override
  String get september => 'September';

  @override
  String get october => 'October';

  @override
  String get november => 'November';

  @override
  String get december => 'December';

  @override
  String get noHistoryYet => 'No history yet';

  @override
  String get minValue => 'Minimum Value';

  @override
  String get maxValue => 'Maximum Value';

  @override
  String get other => 'Other';

  @override
  String get yesNo => 'Yes or No?';

  @override
  String get from => 'From';

  @override
  String get actions => 'Actions';

  @override
  String get sortBy => 'Sort by';

  @override
  String get delete => 'Delete';

  @override
  String get deleteWithFile => 'Delete with file';

  @override
  String get deleteTaskOnly => 'Delete task only';

  @override
  String get deleteTaskWithFile => 'Delete task with file';

  @override
  String get deleteTaskWithFileConfirm =>
      'Are you sure you want to delete this task and file?';

  @override
  String get selected => 'Selected';

  @override
  String get generationHistory => 'Generation History';

  @override
  String get generatedAt => 'Generated at';

  @override
  String get noHistoryMessage =>
      'Your BMI calculation history will appear here';

  @override
  String get clearHistory => 'Clear History';

  @override
  String get resetToDefaultsConfirm =>
      'Are you sure you want to reset all settings to their default values?';

  @override
  String get keep => 'Keep';

  @override
  String get clearAll => 'Clear All';

  @override
  String get converterTools => 'Converter Tools';

  @override
  String get calculatorTools => 'Calculator Tools';

  @override
  String get bytes => 'Bytes';

  @override
  String get value => 'Value';

  @override
  String get showAll => 'Show All';

  @override
  String get apply => 'Apply';

  @override
  String cacheWithLogSize(String cacheSize, String logSize) {
    return 'Cache: $cacheSize (+$logSize log)';
  }

  @override
  String get success => 'Success';

  @override
  String get failed => 'Failed';

  @override
  String get timeout => 'Timeout';

  @override
  String get calculate => 'Calculate';

  @override
  String get calculating => 'Calculating...';

  @override
  String get unknown => 'Unknown';

  @override
  String statusInfo(String info) {
    return 'Status: $info';
  }

  @override
  String get logsAvailable => 'Logs available';

  @override
  String get notAvailableYet => 'Not available yet';

  @override
  String get scrollToTop => 'Scroll to Top';

  @override
  String get scrollToBottom => 'Scroll to Bottom';

  @override
  String get logActions => 'Log Actions';

  @override
  String get logApplication => 'Log Application';

  @override
  String get previousChunk => 'Previous Chunk';

  @override
  String get nextChunk => 'Next Chunk';

  @override
  String get load => 'Load';

  @override
  String get loading => 'Loading...';

  @override
  String get loadAll => 'Load All';

  @override
  String get firstPart => 'First Part';

  @override
  String get lastPart => 'Last Part';

  @override
  String get largeFile => 'Large File';

  @override
  String get loadingLargeFile => 'Loading large file...';

  @override
  String get loadingLogContent => 'Loading log content...';

  @override
  String get largeFileDetected =>
      'Large file detected. Using optimized loading...';

  @override
  String get rename => 'Rename';

  @override
  String get focusModeEnabled => 'Focus Mode';

  @override
  String focusModeEnabledMessage(String exitInstruction) {
    return 'Focus mode activated. $exitInstruction';
  }

  @override
  String get focusModeDisabledMessage =>
      'Focus mode deactivated. All interface elements are now visible.';

  @override
  String get exitFocusModeDesktop =>
      'Tap the focus icon in the app bar to exit';

  @override
  String get exitFocusModeMobile => 'Zoom out or tap the focus icon to exit';

  @override
  String get aspectRatio => 'Aspect Ratio';

  @override
  String get joystickMode => 'Joystick Mode';

  @override
  String get reset => 'Reset';

  @override
  String get info => 'Info';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get selectedColor => 'Selected Color';

  @override
  String get predefinedColors => 'Predefined Colors';

  @override
  String get customColor => 'Custom Color';

  @override
  String get select => 'Select';

  @override
  String get deletingOldLogs => 'Deleting old logs...';

  @override
  String deletedOldLogFiles(int count) {
    return 'Deleted $count old log files';
  }

  @override
  String get noOldLogFilesToDelete => 'No old log files to delete';

  @override
  String errorDeletingLogs(String error) {
    return 'Error deleting logs: $error';
  }

  @override
  String get results => 'Results';

  @override
  String get networkSecurityWarning => 'Network Security Warning';

  @override
  String get unsecureNetworkDetected => 'Unsecure network detected';

  @override
  String get currentNetwork => 'Current Network';

  @override
  String get securityLevel => 'Security Level';

  @override
  String get securityRisks => 'Security Risks';

  @override
  String get unsecureNetworkRisks =>
      'On unsecure networks, your data transmissions may be intercepted by malicious users. Only proceed if you trust the network and other users.';

  @override
  String get proceedAnyway => 'Proceed Anyway';

  @override
  String get secureNetwork => 'Secure (WPA/WPA2)';

  @override
  String get unsecureNetwork => 'Unsecure (Open/No Password)';

  @override
  String get unknownSecurity => 'Unknown Security';

  @override
  String get startNetworking => 'Start Networking';

  @override
  String get stopNetworking => 'Stop Networking';

  @override
  String get transferReRequests => 'Transfer Requests';

  @override
  String get transferTasks => 'Transfer Tasks';

  @override
  String get pairingRequests => 'Pairing Requests';

  @override
  String get devices => 'Devices';

  @override
  String get transfers => 'Transfers';

  @override
  String get status => 'Status';

  @override
  String get connectionStatus => 'Connection Status';

  @override
  String get networkInfo => 'Network Info';

  @override
  String get statistics => 'Statistics';

  @override
  String get discoveredDevices => 'Discovered devices';

  @override
  String get pairedDevices => 'Paired devices';

  @override
  String get activeTransfers => 'Active transfers';

  @override
  String get completedTransfers => 'Completed transfers';

  @override
  String get failedTransfers => 'Failed transfers';

  @override
  String get noDevicesFound => 'No devices found';

  @override
  String get searchingForDevices => 'Searching for devices...';

  @override
  String get startNetworkingToDiscover =>
      'Start networking to discover devices';

  @override
  String get noActiveTransfers => 'No active transfers';

  @override
  String get transfersWillAppearHere => 'Data transfers will appear here';

  @override
  String get paired => 'Paired';

  @override
  String get lastSeen => 'Last Seen';

  @override
  String get pairedSince => 'Paired Since';

  @override
  String get pair => 'Pair';

  @override
  String get cancelTransfer => 'Cancel Transfer';

  @override
  String get confirmCancelTransfer =>
      'Are you sure you want to cancel this transfer?';

  @override
  String get p2pPermissionRequiredTitle => 'Permission Required';

  @override
  String get p2pPermissionExplanation =>
      'To discover nearby devices using WiFi, this app needs access to your location. This is an Android requirement for scanning WiFi networks.';

  @override
  String get p2pPermissionContinue => 'Continue';

  @override
  String get p2pPermissionCancel => 'Cancel';

  @override
  String get p2pNearbyDevicesPermissionTitle =>
      'Nearby Devices Permission Required';

  @override
  String get p2pNearbyDevicesPermissionExplanation =>
      'To discover nearby devices on modern Android versions, this app needs access to nearby WiFi devices. This permission allows the app to scan for WiFi networks without accessing your location.';

  @override
  String get sendData => 'Send Data';

  @override
  String get savedDevices => 'Saved Devices';

  @override
  String get p2lanTransfer => 'P2Lan Transfer';

  @override
  String get p2lanStatus => 'P2LAN Status';

  @override
  String get fileTransferStatus => 'File Transfer Status';

  @override
  String get pairWithDevice => 'Do you want to pair with this device?';

  @override
  String get deviceId => 'Device ID';

  @override
  String get discoveryTime => 'Discovery Time';

  @override
  String get saveConnection => 'Save Connection';

  @override
  String get autoReconnectDescription =>
      'Automatically reconnect when both devices are online';

  @override
  String get pairingNotificationInfo =>
      'The other user will receive a pairing request and needs to accept to complete the pairing.';

  @override
  String get sendRequest => 'Send Request';

  @override
  String get justNow => 'Just now';

  @override
  String minutesAgo(int minutes) {
    return '$minutes min ago';
  }

  @override
  String hoursAgo(int hours) {
    return '$hours hr ago';
  }

  @override
  String daysAgo(int days) {
    return '$days days ago';
  }

  @override
  String get noPairingRequests => 'No pairing requests';

  @override
  String get pairingRequestFrom => 'Pairing request from:';

  @override
  String get sentTime => 'Sent Time';

  @override
  String get trustThisUser => 'Trust this user';

  @override
  String get allowFileTransfersWithoutConfirmation =>
      'Allow file transfers without confirmation';

  @override
  String get onlyAcceptFromTrustedDevices =>
      'Only accept pairing from devices you trust.';

  @override
  String get previousRequest => 'Previous request';

  @override
  String get nextRequest => 'Next request';

  @override
  String get reject => 'Reject';

  @override
  String get accept => 'Accept';

  @override
  String get incomingFiles => 'Incoming Files';

  @override
  String wantsToSendYouFiles(int count) {
    return 'wants to send you $count file(s)';
  }

  @override
  String get filesToReceive => 'Files to receive:';

  @override
  String get totalSize => 'Total size:';

  @override
  String get localFiles => 'Local Files';

  @override
  String get manualDiscovery => 'Manual Discovery';

  @override
  String get transferSettings => 'Transfer Settings';

  @override
  String get savedDevicesCurrentlyAvailable =>
      'Saved devices currently available';

  @override
  String get recentlyDiscoveredDevices => 'Recently discovered devices';

  @override
  String get viewInfo => 'View Info';

  @override
  String get trust => 'Trust';

  @override
  String get removeTrust => 'Remove Trust';

  @override
  String get unpair => 'Unpair';

  @override
  String get thisDevice => 'This Device';

  @override
  String get fileCache => 'File Cache';

  @override
  String get reload => 'Reload';

  @override
  String get clear => 'Clear';

  @override
  String get debug => 'Debug';

  @override
  String failedToLoadSettings(String error) {
    return 'Failed to load settings: $error';
  }

  @override
  String removeTrustFrom(String deviceName) {
    return 'Remove trust from $deviceName?';
  }

  @override
  String get remove => 'Remove';

  @override
  String unpairFrom(String deviceName) {
    return 'Unpair from $deviceName';
  }

  @override
  String get unpairDescription =>
      'This will remove the pairing completely from both devices. You will need to pair again in the future.\n\nThe other device will also be notified and their connection will be removed.';

  @override
  String get holdToUnpair => 'Hold to Unpair';

  @override
  String get unpairing => 'Unpairing...';

  @override
  String get holdButtonToConfirmUnpair =>
      'Hold the button for 1 second to confirm unpair';

  @override
  String get taskAndFileDeletedSuccessfully =>
      'Task and file deleted successfully';

  @override
  String get sending => 'Sending...';

  @override
  String get sendFiles => 'Send files';

  @override
  String get addFiles => 'Add Files';

  @override
  String get noFilesSelected => 'No files selected';

  @override
  String get tapRightClickForOptions => 'Long tap or right-click for options';

  @override
  String get unlimited => 'Unlimited';

  @override
  String get udpDescription => 'Faster but less reliable, good for large files';

  @override
  String get createDateFolders => 'Create date folders';

  @override
  String get createSenderFolders => 'Create sender folders';

  @override
  String get immediate => 'Immediate';

  @override
  String get none => 'None';

  @override
  String get resetToDefaults => 'Reset to Defaults';

  @override
  String get storage => 'Storage';

  @override
  String get network => 'Network';

  @override
  String get userPreferences => 'User Preferences';

  @override
  String get enableNotifications => 'Enable Notifications';

  @override
  String get uiRefreshRate => 'UI Refresh Rate';

  @override
  String get currentConfiguration => 'Current Configuration';

  @override
  String get protocol => 'Protocol';

  @override
  String get maxFileSize => 'Max File Size';

  @override
  String get maxTotalSize => 'Maximum total size (per transfer batch)';

  @override
  String get concurrentTasks => 'Concurrent Tasks';

  @override
  String get chunkSize => 'Chunk Size';

  @override
  String get fileOrganization => 'File Organization';

  @override
  String get downloadPath => 'Download Path';

  @override
  String get totalSpace => 'Total Space';

  @override
  String get freeSpace => 'Free Space';

  @override
  String get usedSpace => 'Used Space';

  @override
  String get noDownloadPathSet => 'No Download Path Set';

  @override
  String get downloadLocation => 'Download Location';

  @override
  String get downloadFolder => 'Download Folder';

  @override
  String get androidStorageAccess => 'Android Storage Access';

  @override
  String get useAppFolder => 'Use App Folder';

  @override
  String get sizeLimits => 'Size Limits';

  @override
  String get performanceTuning => 'Performance Tuning';

  @override
  String get concurrentTransfersDescription =>
      ' = faster overall but higher CPU usage';

  @override
  String get transferChunkSizeDescription =>
      'Higher sizes = faster transfers but more memory usage';

  @override
  String get loadingDeviceInfo => 'Loading device information...';

  @override
  String get tempFilesDescription =>
      'Temporary files from P2Lan file transfers';

  @override
  String get networkDebugCompleted =>
      'Network debug completed. Check logs for details.';

  @override
  String lastRefresh(String time) {
    return 'Last refresh: $time';
  }

  @override
  String get p2pNetworkingPaused =>
      'P2P networking is paused due to internet connection loss. It will automatically resume when connection is restored.';

  @override
  String get internetRequiredToViewThisPage =>
      'Please connect to the internet to view this page';

  @override
  String get noInternetPleaseConnectAndTryAgain =>
      'No internet connection. Please connect and try again.';

  @override
  String get noInternetToFetchNewUpdate =>
      'No internet connection to fetch new update. Please connect and try again.';

  @override
  String get noDevicesInRange => 'No devices in range. Try refreshing.';

  @override
  String get initialDiscoveryInProgress => 'Initial discovery in progress...';

  @override
  String get refreshing => 'Refreshing...';

  @override
  String startedSending(int count, String name) {
    return 'Started sending $count files to $name';
  }

  @override
  String get disconnected => 'Disconnected';

  @override
  String get discoveringDevices => 'Discovering devices...';

  @override
  String get connected => 'Connected';

  @override
  String get pairing => 'Pairing...';

  @override
  String get checkingNetwork => 'Checking network...';

  @override
  String get pausedNoInternet => 'Paused (No Internet)';

  @override
  String get connectedViaMobileData => 'Connected via mobile data (secure)';

  @override
  String connectedToWifi(String name, String security) {
    return 'Connected to $name ($security)';
  }

  @override
  String get secure => 'secure';

  @override
  String get unsecure => 'unsecure';

  @override
  String get connectedViaEthernet => 'Connected via Ethernet (secure)';

  @override
  String get noNetworkConnection => 'No network connection';

  @override
  String get maxConcurrentTasks => 'Max Concurrent Tasks';

  @override
  String get customDisplayName => 'Custom Display Name';

  @override
  String get yourProfile => 'Your Profile';

  @override
  String get deviceName => 'Device Name';

  @override
  String get deviceNameDesc => 'Your device name to appear with other users';

  @override
  String get deviceNameEditDesc =>
      'Customize your device name to appear with other users';

  @override
  String get general => 'General';

  @override
  String get generalDesc => 'Device name, notifications & user preferences';

  @override
  String get receiverLocationSizeLimits => 'Receiver Location & Size Limits';

  @override
  String get receiverLocationSizeLimitsDesc =>
      'Download folder, file organization & size limits';

  @override
  String get networkSpeed => 'Network & Speed';

  @override
  String get networkSpeedDesc =>
      'Protocol settings, performance tuning & optimization';

  @override
  String get estimatedSpeed => 'Estimated Speed';

  @override
  String get advanced => 'Advanced';

  @override
  String get advancedDesc => 'Security, encryption & compression settings';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get secondsLabel => 'second';

  @override
  String get secondsPlural => 'seconds';

  @override
  String get onlineDevices => 'Online Devices';

  @override
  String get newDevices => 'New Devices';

  @override
  String get blockedDevices => 'Blocked Devices';

  @override
  String get blockedDevicesSubtitle =>
      'These devices are blocked and cannot contact you';

  @override
  String get addTrust => 'Add Trust';

  @override
  String get p2pTemporarilyDisabled =>
      'P2P temporarily disabled - waiting for internet connection';

  @override
  String get fileOrgNoneDescription => 'Files go directly to download folder';

  @override
  String get fileOrgDateDescription => 'Organize by date (YYYY-MM-DD)';

  @override
  String get fileOrgSenderDescription => 'Organize by sender display name';

  @override
  String get settingsTabGeneric => 'Generic';

  @override
  String get settingsTabStorage => 'Storage';

  @override
  String get settingsTabNetwork => 'Network';

  @override
  String get displayName => 'Display Name';

  @override
  String get displayNameDescription =>
      'Customize how your device appears to other users';

  @override
  String get enterDisplayName => 'Enter display name';

  @override
  String get deviceDisplayNameLabel => 'Device Display Name';

  @override
  String get deviceDisplayNameHint => 'Enter custom display name...';

  @override
  String defaultDisplayName(String name) {
    return 'Default: $name';
  }

  @override
  String get displayNameHasReset => 'Display name has been reset';

  @override
  String get notifications => 'Notifications';

  @override
  String get notSupportedOnWindows => 'Not supported on Windows';

  @override
  String get uiPerformance => 'User Interface Performance';

  @override
  String get uiRefreshRateDescription =>
      'Choose how often transfer progress updates in the UI. Higher frequencies work better on powerful devices.';

  @override
  String get previouslyPairedOffline => 'Previously paired devices (offline)';

  @override
  String get appInstallationId => 'App Installation ID';

  @override
  String get ipAddress => 'IP Address';

  @override
  String get port => 'Port';

  @override
  String get selectDownloadFolder => 'Select download folder';

  @override
  String get maxFileSizePerFile => 'Maximum file size (per file)';

  @override
  String get transferProtocol => 'Transfer Protocol';

  @override
  String get concurrentTransfers => 'Concurrent transfers';

  @override
  String get transferChunkSize => 'Transfer chunk size';

  @override
  String get defaultValue => '(Default)';

  @override
  String get androidStorageAccessDescription =>
      'For security, it\'s recommended to use the app-specific folder. You can select other folders, but this may require additional permissions.';

  @override
  String get storageInfo => 'Storage Information';

  @override
  String get noDownloadPathSetDescription =>
      'Please select a download folder in the Storage tab to see storage information.';

  @override
  String get enableNotificationsDescription =>
      'To receive notifications for pairing and file transfers, you need to enable them in the system settings.';

  @override
  String get maxFileSizePerFileDescription =>
      'Larger files will be automatically rejected';

  @override
  String get maxTotalSizeDescription =>
      'Total size limit for all files in a single transfer request';

  @override
  String get concurrentTransfersSubtitle =>
      'More transfers = faster overall but higher CPU usage';

  @override
  String get transferChunkSizeSubtitle =>
      'Higher sizes = faster transfers but more memory usage';

  @override
  String get protocolTcpReliable => 'TCP (Reliable)';

  @override
  String get protocolTcpDescription =>
      'More reliable, better for important files';

  @override
  String get protocolUdpFast => 'UDP (Fast)';

  @override
  String get fileOrgNone => 'None';

  @override
  String get fileOrgDate => 'By Date';

  @override
  String get fileOrgSender => 'By Sender Name';

  @override
  String get selectOperation => 'Select Operation';

  @override
  String get filterAndSort => 'Filter and Sort';

  @override
  String get tapToSelectAgain => 'Tap to select again';

  @override
  String get notSelected => 'Not selected';

  @override
  String get selectDestinationFolder => 'Select destination folder';

  @override
  String get openInApp => 'Open in App';

  @override
  String get openInExplorer => 'Open in Explorer';

  @override
  String get copyTo => 'Copy to';

  @override
  String get moveTo => 'Move to';

  @override
  String get moveOrCopyAndRename => 'Move or Copy and Rename';

  @override
  String get share => 'Share';

  @override
  String get confirmDelete => 'Confirm delete';

  @override
  String confirmDeleteFileNumber(int number) {
    return 'Are you sure you want to delete $number file(s)';
  }

  @override
  String confirmDeleteFolderNumber(int number) {
    return 'Are you sure you want to delete $number folder(s)';
  }

  @override
  String confirmDeleteFoldersAndFilesNumber(int numberFolder, int numberFile) {
    return 'Are you sure you want to delete $numberFolder folder(s) and $numberFile file(s)';
  }

  @override
  String get removeSelected => 'Remove selected content';

  @override
  String get noFilesFound => 'No files found';

  @override
  String get emptyFolder => 'Empty folder';

  @override
  String get file => 'file';

  @override
  String get folder => 'folder';

  @override
  String get fileInfo => 'File information';

  @override
  String get quickAccess => 'Quick Access';

  @override
  String get restore => 'Restore';

  @override
  String get clearAllBookmarks => 'Clear all bookmarks';

  @override
  String get clearAllBookmarksConfirm =>
      'Are you sure you want to permanently delete all history entries? This action cannot be undone.';

  @override
  String get path => 'Path';

  @override
  String get size => 'Size';

  @override
  String get type => 'Type';

  @override
  String get modified => 'Modified';

  @override
  String get securityAndEncryption => 'Security & Encryption';

  @override
  String get security => 'Security';

  @override
  String get p2lanOptionEncryptionNoneDesc =>
      'No encryption (fastest transfer)';

  @override
  String get p2lanOptionEncryptionAesGcmDesc =>
      'Strong encryption, best for high-end devices with hardware acceleration';

  @override
  String get p2lanOptionEncryptionChaCha20Desc =>
      'Optimized for mobile devices, better performance';

  @override
  String get p2lanOptionEncryptionNoneAbout =>
      'Data is transferred without encryption. This provides the fastest transfer speeds but offers no security protection. Only use this on trusted networks.';

  @override
  String get p2lanOptionEncryptionAesGcmAbout =>
      'AES-256-GCM is a widely used encryption standard that provides strong security. It is best suited for high-end devices with hardware acceleration, but may be slower on older or low-end Android devices.';

  @override
  String get p2lanOptionEncryptionChaCha20About =>
      'ChaCha20-Poly1305 is a modern encryption algorithm designed for both security and speed, especially on mobile devices.\nIt is recommended for most Android devices because it works efficiently even without hardware acceleration, providing strong protection with better performance than AES on many phones.';

  @override
  String get storagePermissionRequired =>
      'Storage permission is required to select custom folder';

  @override
  String get chat => 'Chat';

  @override
  String chatWith(String name) {
    return 'Chat with $name';
  }

  @override
  String get deleteChat => 'Delete Chat';

  @override
  String deleteChatWith(String name) {
    return 'Delete chat with $name?';
  }

  @override
  String get deleteChatDesc =>
      'This will permanently delete the chat history with this user. This action cannot be undone.';

  @override
  String get noChatExists => 'No chat yet.';

  @override
  String get noMessages => 'No messages yet. Start chatting!';

  @override
  String get fileLost => 'File is lost on the device';

  @override
  String get fileLostRequest => 'File lost request';

  @override
  String get fileLostRequestDesc =>
      'This file is lost or cannot be found. You can request the sender to resend it if they still keep their file on their device.';

  @override
  String get fileLostOnBothSides => 'File is lost on both sides';

  @override
  String get noPathToCopy => 'No path to copy';

  @override
  String get deleteMessage => 'Delete message';

  @override
  String get deleteMessageDesc =>
      'Are you sure you want to delete this message?';

  @override
  String get deleteMessageAndFile => 'Delete message and file';

  @override
  String get deleteMessageAndFileDesc =>
      'Are you sure you want to delete this message and the attached file?';

  @override
  String get errorOpeningFile => 'Error opening file';

  @override
  String errorOpeningFileDetails(String error) {
    return 'An error occurred while trying to open the file: $error';
  }

  @override
  String get attachFile => 'Attach files';

  @override
  String get attachMedia => 'Attach media';

  @override
  String get chatCustomization => 'Chat Customization';

  @override
  String get chatCustomizationSaved => 'Chat customization saved successfully';

  @override
  String get sendMessage => 'Send Message';

  @override
  String sendAt(String time) {
    return 'Send at $time';
  }

  @override
  String get loadingOldMessages => 'Loading old messages...';

  @override
  String get messageRetention => 'Message Retention';

  @override
  String get messageRetentionDesc =>
      'Set how long messages are kept in the chat before being automatically deleted.';

  @override
  String get p2pChatAutoCopyIncomingMessages => 'Synchronize clipboard';

  @override
  String get p2pChatAutoCopyIncomingMessagesDesc =>
      'When enabled, new messages, if they are images or text, will be automatically copied to the device\'s clipboard.';

  @override
  String get p2pChatDeleteAfterCopy => 'Delete message after copying';

  @override
  String get p2pChatDeleteAfterCopyDesc =>
      'When enabled, messages will be deleted after being copied to the clipboard.';

  @override
  String get p2pChatClipboardSharing => 'Clipboard sharing';

  @override
  String get p2pChatClipboardSharingDesc =>
      'When enabled, new content appearing in the clipboard, if it is text or images, will be automatically recognized and a message will be sent. This feature will register a process and consume resources, so it is recommended to enable it only when necessary.';

  @override
  String get p2pChatDeleteAfterShare => 'Delete message after sharing';

  @override
  String get p2pChatDeleteAfterShareDesc =>
      'When enabled, messages will be deleted after being shared from the clipboard.';

  @override
  String get p2pChatCustomizationAndroidCaution =>
      '## [warning, orange] Note for Android devices\n- Clipboard-related features may not work stably with images.\n- The clipboard sharing feature only works when the app is running in the foreground (meaning you must be actively using the app, or have it open in a floating window, mini window, or split-screen) and you must be in this chat conversation.\n- The clipboard sharing feature will register a monitoring task that may impact device performance, so enable it only when truly necessary and disable it when not in use.\n';

  @override
  String get clearTransferBatch => 'Clear Batch';

  @override
  String get clearTransferBatchDesc =>
      'Are you sure you want to clear this batch from the transfer list?';

  @override
  String get clearTransferBatchWithFiles => 'Clear Batch with Files';

  @override
  String get clearTransferBatchWithFilesDesc =>
      'Are you sure you want to clear this batch and delete all files associated with it?';

  @override
  String get performanceInfo => 'Performance Information';

  @override
  String get performanceInfoEncrypt => 'Encryption';

  @override
  String get performanceInfoSecuLevel => 'Security Level';

  @override
  String get performanceWarning => 'Performance Warning';

  @override
  String get performanceWarningInfo =>
      'Encryption may cause crashes on some Android devices, especially older or lower-end models. If you experience crashes, disable this feature for stable transfers.';

  @override
  String get resetToSafeDefaults => 'Reset to Safe Defaults';

  @override
  String get ddefault => 'Default';

  @override
  String get aggressive => 'Aggressive';

  @override
  String get conservative => 'Conservative';

  @override
  String get veryConservative => 'Very Conservative';

  @override
  String get onlyMajorGains => 'Only Major Gains';

  @override
  String get fastest => 'Fastest';

  @override
  String get strongest => 'Strongest';

  @override
  String get mobileOptimized => 'Mobile Optimized';

  @override
  String upToNumberXFaster(int number) {
    return 'Up to ${number}x Faster';
  }

  @override
  String get baseline => 'Baseline';

  @override
  String get high => 'High';

  @override
  String get notRecommended => 'Not Recommended';

  @override
  String get encrypted => 'Encrypted';

  @override
  String get disabled => 'Disabled';

  @override
  String get adaptive => 'Adaptive';

  @override
  String get enterAChatToStart => 'Enter a chat to start messaging';

  @override
  String get chatList => 'Chat List';

  @override
  String get chatDetails => 'Chat Details';

  @override
  String get addChat => 'Add Chat';

  @override
  String get addChatDesc => 'Add a new chat with a user to start messaging.';

  @override
  String get noUserOnline => 'No user is online at the moment.';

  @override
  String get clearAllTransfers => 'Clear All Transfers';

  @override
  String get clearAllTransfersDesc =>
      'Are you sure you want to clear all history transfers?';

  @override
  String get mobileLayout => 'Mobile Layout';

  @override
  String get useCompactLayout => 'Use Compact Layout';

  @override
  String get useCompactLayoutDesc =>
      'Hide icons on the navigation bar and use a more compact layout to save space.';

  @override
  String get userExperience => 'User Experience';

  @override
  String get showShortcutsInTooltips => 'Show shortcuts in tooltips';

  @override
  String get showShortcutsInTooltipsDesc =>
      'Display keyboard shortcuts when hovering over buttons';

  @override
  String numberFilesSendToUser(int count, String name) {
    return '$count file(s) sent to $name';
  }

  @override
  String numberFilesReceivedFromUser(int count, String name) {
    return '$count file(s) received from $name';
  }

  @override
  String sendToUser(String name) {
    return 'Send to $name';
  }

  @override
  String receiveFromUser(String name) {
    return 'Receive from $name';
  }

  @override
  String get allCompleted => 'All completed';

  @override
  String get completedWithErrors => 'Completed with errors';

  @override
  String get transfering => 'Transferring';

  @override
  String get waiting => 'Waiting';

  @override
  String completedTasksNumber(int count) {
    return '$count completed tasks';
  }

  @override
  String transferringTasksNumber(int count) {
    return '$count transferring tasks';
  }

  @override
  String failedTasksNumber(int count) {
    return '$count failed tasks';
  }

  @override
  String get clearTask => 'Clear Task';

  @override
  String get requesting => 'Requesting';

  @override
  String get waitingForApproval => 'Waiting for approval';

  @override
  String get beingRefused => 'Being refused';

  @override
  String get receiving => 'Receiving...';

  @override
  String get completed => 'Completed';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get clearNotification => 'Clear Notification';

  @override
  String get clearNotificationInfo1 =>
      'You are disabling notifications. There may be active notifications from this app.';

  @override
  String get clearNotificationInfo2 =>
      'Would you like to clear all existing notifications?';

  @override
  String get pickLanguage => 'Pick Language';

  @override
  String get pickTheme => 'Pick Theme';

  @override
  String get welcomeToApp => 'Welcome to P2Lan Transfer';

  @override
  String get privacyStatement => 'Privacy Statement';

  @override
  String get privacyStatementDesc =>
      'This application is a client-side app and does not collect any user data. The permissions requested by the app are solely for enabling its normal functions and are not used to collect personal information. All data remains on your device and is only shared when you choose to transfer files with other devices on your network.';

  @override
  String get agreeToTerms => 'I agree to the Terms of Use';

  @override
  String get startUsingApp => 'Start Using App';

  @override
  String get termsOfUse => 'Terms of Use';

  @override
  String get termsOfUseView => 'View Terms of Use of this application';

  @override
  String get setupComplete => 'Setup Complete';

  @override
  String get languageSelection => 'Language Selection';

  @override
  String get themeSelection => 'Theme Selection';

  @override
  String get privacyAndTerms => 'Privacy & Terms';

  @override
  String get selectYourLanguage => 'Select your preferred language';

  @override
  String get selectYourTheme => 'Select your preferred theme';

  @override
  String get mustAgreeToTerms =>
      'You must agree to the Terms of Use to continue';

  @override
  String get next => 'Next';

  @override
  String get previous => 'Previous';

  @override
  String get skip => 'Skip';

  @override
  String get finish => 'Finish';

  @override
  String get noData => 'No Data Available';

  @override
  String get aboutToOpenUrlOutsideApp =>
      'You are about to open a URL outside the app!';

  @override
  String get ccontinue => 'Continue';

  @override
  String get retry => 'Retry';

  @override
  String get refresh => 'Refresh';

  @override
  String get thanksLibAuthor => 'Thank You, Library Authors!';

  @override
  String get thanksLibAuthorDesc =>
      'This app uses several open-source libraries that make it possible. We are grateful to all the authors for their hard work and dedication.';

  @override
  String get pressBackAgainToExit => 'Press back again to exit the app';

  @override
  String get canNotOpenFile => 'Cannot open file';

  @override
  String get canNotOpenUrl => 'Cannot open URL';

  @override
  String get errorOpeningUrl => 'Error opening URL';

  @override
  String get linkCopiedToClipboard => 'Link copied to clipboard';

  @override
  String get invalidFileName => 'Invalid file name';

  @override
  String get actionCancelled => 'Action cancelled';

  @override
  String get fileExists => 'File already exists';

  @override
  String get fileExistsDesc =>
      'A file with this name already exists in the destination folder. Do you want to overwrite it?';

  @override
  String get fileMovedSuccessfully => 'File đã được di chuyển thành công';

  @override
  String get fileCopiedSuccessfully => 'File đã được sao chép thành công';

  @override
  String get fileRenamedSuccessfully => 'File đã được đổi tên thành công';

  @override
  String get renameFile => 'Rename File';

  @override
  String get newFileName => 'New File Name';

  @override
  String get errorRenamingFile => 'Error renaming file';

  @override
  String get fileDeletedSuccessfully => 'File deleted successfully';

  @override
  String get errorDeletingFile => 'Error deleting file';

  @override
  String get name => 'Name';

  @override
  String get date => 'Date';

  @override
  String get localFolderInitializationError =>
      'Local folder initialization error';

  @override
  String get pleaseTryAgainLater => 'Please try again later';

  @override
  String get apkNotSupportedDesc =>
      'The current application does not (or does not yet) support APK installation. You can move the APK file to a public folder and install it from your device\'s file browser.';

  @override
  String get theseWillBeCleared => 'The following items will be cleared';

  @override
  String get paste => 'Paste';

  @override
  String get deviceNameAutoDetected => 'Device name is automatically detected';

  @override
  String get transferProgressAutoCleanup => 'Transfer Progress Auto-Cleanup';

  @override
  String get autoRemoveTransferMessages =>
      'Automatically remove transfer progress after completion or cancellation';

  @override
  String get removeProgressOnSuccess =>
      'Remove progress when transfers complete successfully';

  @override
  String get cancelledTransfers => 'Cancelled transfers';

  @override
  String get removeProgressOnCancel =>
      'Remove progress when transfers are cancelled';

  @override
  String get removeProgressOnFail => 'Remove progress when transfers fail';

  @override
  String get cleanupDelay => 'Cleanup delay';

  @override
  String get autoCheckUpdatesDaily => 'Auto check for updates';

  @override
  String get autoCheckUpdatesDailyDesc =>
      'Check for updates once a day and notify when a new version is available';

  @override
  String get clearTransfersAtStartup => 'Clear transfers at startup';

  @override
  String get clearTransfersAtStartupDesc =>
      'Automatically clear old transfer progress when the app starts';

  @override
  String get notificationRequestPermission => 'Request Notification Permission';

  @override
  String get notificationRequestPermissionDesc =>
      'The app needs to be granted notification permission in order to notify you. If you have pressed the \'Grant Permission\' button but the permission dialog still does not appear, please manually grant notification permission in the app\'s permission settings.';

  @override
  String get grantPermission => 'Grant Permission';

  @override
  String get checkingForUpdates => 'Checking for updates...';

  @override
  String get noNewUpdates => 'No new updates';

  @override
  String updateCheckError(String errorMessage) {
    return 'Error checking updates: $errorMessage';
  }

  @override
  String get usingLatestVersion => 'You are using the latest version';

  @override
  String get newVersionAvailable => 'New version available';

  @override
  String get latest => 'Latest';

  @override
  String currentVersion(String version) {
    return 'Current: $version';
  }

  @override
  String publishDate(String publishDate) {
    return 'Publish date: $publishDate';
  }

  @override
  String get releaseNotes => 'Release notes';

  @override
  String get noReleaseNotes => 'No release notes';

  @override
  String get alreadyLatestVersion => 'Already the latest version';

  @override
  String get download => 'Download';

  @override
  String get selectVersionToDownload => 'Select version to download';

  @override
  String filteredForPlatform(String getPlatformName) {
    return 'Filtered for $getPlatformName';
  }

  @override
  String sizeInMB(String sizeInMB) {
    return 'Size: $sizeInMB';
  }

  @override
  String uploadDate(String updatedAt) {
    return 'Upload date: $updatedAt';
  }

  @override
  String get confirmDownload => 'Confirm download';

  @override
  String confirmDownloadMessage(String name, String sizeInMB) {
    return 'Are you sure you want to download this version?\n\nFile name: $name\nSize: $sizeInMB';
  }

  @override
  String get currentPlatform => 'Current platform';

  @override
  String get eerror => 'Error';

  @override
  String get stopped => 'Stopped';

  @override
  String completedInTime(String duration) {
    return 'Completed in $duration';
  }

  @override
  String transferredInTime(String duration) {
    return 'Transferred in $duration';
  }

  @override
  String waitingInTime(String duration) {
    return 'Waiting for $duration';
  }

  @override
  String get transferStatusViewAll => 'View: All';

  @override
  String get transferStatusViewOutgoing => 'View: Only outgoing';

  @override
  String get transferStatusViewIncoming => 'View: Only incoming';

  @override
  String get authorProducts => 'Other Products';

  @override
  String get authorProductsDesc =>
      'View other products by the author, maybe you\'ll find something interesting!';

  @override
  String get authorProductsMessage =>
      'Hi there! Here are some of my other products. If you\'re interested, feel free to check them out! I hope you\'ll find something useful among them. Thank you for visiting!';

  @override
  String get noOtherProducts => 'No other products available';

  @override
  String get loadingProducts => 'Loading products...';

  @override
  String get failedToLoadProducts => 'Failed to load products';

  @override
  String get retryLoadProducts => 'Retry loading products';

  @override
  String get visitProduct => 'Visit Product';

  @override
  String productCount(int count) {
    return '$count product(s)';
  }

  @override
  String processingNumberOfTotal(int current, int total) {
    return 'Processing $current of $total file(s)';
  }

  @override
  String get waitingForFileSelection =>
      'Waiting for file selection and processing file resources';

  @override
  String get expand => 'Expand';

  @override
  String get collapse => 'Collapse';

  @override
  String get block => 'Block';

  @override
  String get blockTitle => 'Block this user';

  @override
  String get blockDesc =>
      'Are you sure you want to block this user?\nThis user will not be able to contact you until you unblock them.';

  @override
  String get unblock => 'Unblock';

  @override
  String get unblockTitle => 'Unblock this user';

  @override
  String get unblockDesc =>
      'Are you sure you want to unblock this user?\nThis user will be able to contact you.';

  @override
  String get connectToDevice => 'Connect to Device';

  @override
  String get enterDeviceIpAddress =>
      'Enter the IP address of the device you want to connect to:';

  @override
  String get connectToDeviceHint =>
      'Make sure the device is on the same network and P2P networking is enabled.';

  @override
  String get connecting => 'Connecting...';

  @override
  String get customStatusCards => 'Customize Status Cards';

  @override
  String get customStatusCardsDesc => 'Choose which status cards to display';

  @override
  String get endRemoteToCustomizeStatus =>
      'End the remote control session to customize status';

  @override
  String get noStatusCardsEnabled => 'No status cards enabled';

  @override
  String get useTheCustomizeButtonToEnableStatusCards =>
      'Use the customize button to enable status cards';

  @override
  String get thisDeviceDesc => 'Device information and settings';

  @override
  String get connectionStatusDesc => 'Network connection and debug info';

  @override
  String get statisticsDesc => 'Transfer and device statistics';

  @override
  String get remoteControlRequest => 'Remote Control Request';

  @override
  String remoteControlRequestMessage(String userName) {
    return '$userName wants to control your computer remotely.';
  }

  @override
  String get reason => 'Reason';

  @override
  String get securityWarning => 'Security Warning';

  @override
  String get securityWarningMessage =>
      'Granting remote control access allows the other user to:';

  @override
  String get controlMouseCursor => 'Control your mouse cursor';

  @override
  String get clickAnywhere => 'Click anywhere on your screen';

  @override
  String get scrollScreen => 'Scroll on your screen';

  @override
  String get trustWarning => 'Only accept requests from users you trust.';

  @override
  String get confirmRemoteControlAccess => 'Confirm Remote Control Access';

  @override
  String confirmRemoteControlMessage(String userName) {
    return 'Hold to confirm that you want to allow $userName to control your computer.';
  }

  @override
  String get holdToAllowControl => 'HOLD TO ALLOW CONTROL';

  @override
  String get allowing => 'Allowing...';

  @override
  String controlInstruction(String userName) {
    return 'This will give $userName control over your mouse and screen.';
  }

  @override
  String get requestRemoteControl => 'Request Remote Control';

  @override
  String sendRemoteControlRequest(String userName) {
    return 'Send a remote control request to $userName?';
  }

  @override
  String get reasonOptional => 'Reason (optional)';

  @override
  String get reasonHint => 'Why do you need remote control access?';

  @override
  String get remoteControlAccess => 'Remote Control Access';

  @override
  String get remoteControlAccessMessage => 'If accepted, you will be able to:';

  @override
  String get controlRemoteMouse => 'Control the remote mouse cursor';

  @override
  String get clickRemoteScreen => 'Click anywhere on the remote screen';

  @override
  String get scrollRemoteScreen => 'Scroll on the remote screen';

  @override
  String get requestExpiresIn60 => 'The request will expire in 60 seconds.';

  @override
  String get sendText => 'Send Text';

  @override
  String get sendTextHint => 'Enter text to send...';

  @override
  String get textSentSuccessfully => 'Text sent successfully';

  @override
  String textSendError(Object error) {
    return 'Error sending text: $error';
  }

  @override
  String get send => 'Send';
}
