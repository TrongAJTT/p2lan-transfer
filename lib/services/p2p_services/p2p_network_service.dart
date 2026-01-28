import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:p2lan/models/app_installation.dart';
import 'package:p2lan/models/p2p_models.dart';
import 'package:p2lan/models/p2p_chat.dart';
import 'package:p2lan/services/isar_service.dart';
import 'package:p2lan/services/app_logger.dart';
import 'package:p2lan/services/network_security_service.dart';
import 'package:p2lan/services/settings_models_service.dart';
import 'package:p2lan/services/p2p_services/p2p_notification_service.dart';
import 'package:p2lan/utils/platform_detection_utils.dart';
import 'package:p2lan/variables.dart';
import 'package:workmanager/workmanager.dart';

/// P2P Network Service - Manages network connections, servers, and basic networking
/// Extracted from monolithic P2PService for better modularity
class P2PNetworkService extends ChangeNotifier {
  // Network components
  ServerSocket? _serverSocket;
  RawDatagramSocket? _udpServerSocket;
  RawDatagramSocket? _udpListenerSocket; // Dedicated listener on port 8082

  // State management
  bool _isEnabled = false;
  ConnectionStatus _connectionStatus = ConnectionStatus.disconnected;
  NetworkInfo? _currentNetworkInfo;
  P2PUser? _currentUser;

  // Connected sockets management
  final Map<String, Socket> _connectedSockets = {};

  // Timers for network maintenance
  Timer? _heartbeatTimer;
  Timer? _cleanupTimer;
  Timer? _memoryCleanupTimer;

  // Message handling callback
  Function(Socket, Uint8List)? _onMessageReceived;

  /// Constructor
  P2PNetworkService() {
    // Initialize network service
    logInfo('P2PNetworkService: Initializing...');
  }

  // Chat message handler (for demo, should be moved to service)
  Future<void> handleIncomingChatMessage(
      Map<String, dynamic> messageData) async {
    logDebug('>>>>>>>>>>>>>>>>>>>>>>>>>>');

    final msg = P2PCMessage.fromJson(messageData);
    final isar = IsarService.isar;

    final myId =
        (await isar.appInstallations.where().findFirst())!.installationId!;
    P2PChat? chat =
        await isar.p2PChats.filter().userBIdEqualTo(msg.senderId).findFirst();
    final displayName =
        (await isar.p2PUsers.filter().idEqualTo(msg.senderId).findFirst())
                ?.displayName ??
            'User ${msg.senderId}';

    if (chat == null) {
      final newChat = P2PChat()
        ..userAId = myId
        ..userBId = msg.senderId
        ..displayName = displayName
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now()
        ..retention = MessageRetention.days30;
      await isar.writeTxn(() async {
        await isar.p2PChats.put(newChat);
      });
      chat = newChat;
    }
    // Add message
    // Gọi đến hàm addMessage của Chat Service
    try {
      final chatService = IsarService.chatService;
      msg.id = await chatService.addMessage(msg, chat);

      // Trigger notification for incoming chat message
      logDebug(
          'P2PNetworkService: Triggering notification for incoming chat message from ${msg.senderId}');
      try {
        await P2PNotificationService.instance.showNewMessage(
          chatId: chat.id.toString(),
          senderName: displayName,
          message: msg.content,
          userId: msg.senderId,
        );
        logInfo('P2PNetworkService: Chat notification sent successfully');
      } catch (notificationError) {
        logError(
            'P2PNetworkService: Failed to send chat notification: $notificationError');
      }
    } catch (e) {
      logError('Failed to access IsarService.chatService: $e');
      // Optionally, queue message for later or handle gracefully
      return;
    }
    notifyListeners();
  }

  Function(Uint8List, InternetAddress, int)? _onUdpMessageReceived;

  // Constants
  static const int _basePort = p2pBasePort;
  static const int _maxPort = p2pMaxPort;
  static const Duration _heartbeatInterval = Duration(seconds: 60);

  // Getters
  bool get isEnabled => _isEnabled;
  ConnectionStatus get connectionStatus => _connectionStatus;
  NetworkInfo? get currentNetworkInfo => _currentNetworkInfo;
  P2PUser? get currentUser => _currentUser;
  Map<String, Socket> get connectedSockets =>
      Map.unmodifiable(_connectedSockets);

  /// Set callback for handling received messages
  void setMessageHandler(Function(Socket, Uint8List) handler) {
    _onMessageReceived = handler;
  }

  /// Set callback for handling UDP messages
  void setUdpMessageHandler(Function(Uint8List, InternetAddress, int) handler) {
    _onUdpMessageReceived = handler;
  }

  /// Enable network service
  Future<bool> enable() async {
    if (_isEnabled) return true;

    try {
      // Check network security
      _currentNetworkInfo = await NetworkSecurityService.checkNetworkSecurity();

      logInfo(
          'P2PNetworkService: Network Info: WiFi=${_currentNetworkInfo!.isWiFi}, '
          'Mobile=${_currentNetworkInfo!.isMobile}, '
          'SecurityType=${_currentNetworkInfo!.securityType}');

      // Validate network connection
      final hasValidConnection = _currentNetworkInfo!.isWiFi ||
          _currentNetworkInfo!.isMobile ||
          (_currentNetworkInfo!.securityType == 'ETHERNET');

      if (!hasValidConnection) {
        throw Exception('No suitable network connection available');
      }

      // Create current user profile
      await _createCurrentUser(_currentNetworkInfo!);

      // Start TCP and UDP servers
      await _startServers();

      // Start maintenance timers
      _startTimers();

      // Register background task for mobile platforms
      await _registerBackgroundTask();

      _isEnabled = true;
      _connectionStatus = ConnectionStatus.discovering;

      logInfo('P2PNetworkService: Network service enabled successfully');
      notifyListeners();
      return true;
    } catch (e) {
      logError('P2PNetworkService: Failed to enable network service: $e');
      return false;
    }
  }

  /// Disable network service
  Future<void> disable() async {
    if (!_isEnabled) return;

    // Cancel background task
    await _cancelBackgroundTask();

    // Stop servers
    await _stopServers();

    // Stop timers
    _stopTimers();

    // Close all connections
    await _closeAllConnections();

    // Reset state
    _isEnabled = false;
    _connectionStatus = ConnectionStatus.disconnected;
    _currentUser = null;

    logInfo('P2PNetworkService: Network service disabled');
    notifyListeners();
  }

  /// Send message to specific socket with proper framing
  Future<bool> sendMessageToSocket(
      Socket socket, Map<String, dynamic> messageData) async {
    try {
      final messageBytes = utf8.encode(jsonEncode(messageData));
      final lengthHeader = ByteData(4)
        ..setUint32(0, messageBytes.length, Endian.big);

      // Send the length header first, then the message
      socket.add(lengthHeader.buffer.asUint8List());
      socket.add(messageBytes);
      await socket.flush();
      return true;
    } catch (e) {
      logError('P2PNetworkService: Failed to send message to socket: $e');
      return false;
    }
  }

  /// Send message to user by creating new connection
  Future<bool> sendMessageToUser(
      P2PUser targetUser, Map<String, dynamic> messageData) async {
    try {
      final socket = await Socket.connect(
        targetUser.ipAddress,
        targetUser.port,
        timeout: const Duration(seconds: 5),
      );

      // logInfo(
      //     'P2PNetworkService: Send chat message to ${targetUser.displayName} with data: $messageData');

      final success = await sendMessageToSocket(socket, messageData);

      // Add small delay to ensure message is sent before closing
      await Future.delayed(const Duration(milliseconds: 100));
      await socket.close();

      return success;
    } catch (e) {
      logError(
          'P2PNetworkService: Failed to send message to ${targetUser.displayName}: $e');
      // Clean up any stale socket references
      _connectedSockets.remove(targetUser.id);
      return false;
    }
  }

  /// Send UDP message to address
  Future<bool> sendUdpMessage(Map<String, dynamic> messageData,
      InternetAddress address, int port) async {
    try {
      final data = utf8.encode(jsonEncode(messageData));
      final tempSocket =
          await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      tempSocket.send(data, address, port);
      tempSocket.close();
      return true;
    } catch (e) {
      logError('P2PNetworkService: Failed to send UDP message: $e');
      return false;
    }
  }

  /// Broadcast UDP message to multiple addresses
  Future<void> broadcastUdpMessage(Map<String, dynamic> messageData,
      List<String> addresses, int port) async {
    try {
      final data = utf8.encode(jsonEncode(messageData));
      final tempSocket =
          await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      tempSocket.broadcastEnabled = true;

      for (final address in addresses) {
        try {
          tempSocket.send(data, InternetAddress(address), port);
          logInfo('P2PNetworkService: Sent UDP broadcast to: $address:$port');
        } catch (e) {
          logWarning(
              'P2PNetworkService: Failed to send to broadcast $address: $e');
        }
      }

      tempSocket.close();
    } catch (e) {
      logError('P2PNetworkService: Failed to broadcast UDP message: $e');
    }
  }

  // Private methods

  Future<void> _createCurrentUser(NetworkInfo networkInfo) async {
    final appInstallationId =
        await NetworkSecurityService.getAppInstallationId();
    final deviceName = await NetworkSecurityService.getDeviceName();
    try {
      final general = await ExtensibleSettingsService.getGeneralSettings();
      if (general.displayName != null &&
          general.displayName!.trim().isNotEmpty) {
        // Prefer user-customized display name
      }
    } catch (_) {}

    _currentUser = P2PUser(
      id: appInstallationId,
      displayName: (await _resolveDisplayName(deviceName)),
      profileId: appInstallationId,
      ipAddress: networkInfo.ipAddress ?? '127.0.0.1',
      port: _basePort,
      isOnline: true,
      lastSeen: DateTime.now(),
      platform: PlatformDetectionUtils.getCurrentPlatform(),
    );
  }

  Future<String> _resolveDisplayName(String fallback) async {
    try {
      final general = await ExtensibleSettingsService.getGeneralSettings();
      if (general.displayName != null &&
          general.displayName!.trim().isNotEmpty) {
        return general.displayName!.trim();
      }
    } catch (_) {}
    return fallback;
  }

  Future<void> _startServers() async {
    for (int port = _basePort; port <= _maxPort; port++) {
      try {
        // Start TCP server
        _serverSocket = await ServerSocket.bind(InternetAddress.anyIPv4, port);
        _currentUser!.port = port;
        _serverSocket!.listen(_handleClientConnection);

        // Start UDP server on same port
        await _startUdpServer(port);

        // Start UDP listener on port 8082
        await _startUdpListener();

        logInfo('P2PNetworkService: TCP/UDP servers started on port $port');
        return;
      } catch (e) {
        if (port == _maxPort) {
          throw Exception(
              'Failed to bind to any port in range $_basePort-$_maxPort');
        }
      }
    }
  }

  Future<void> _startUdpServer(int port) async {
    try {
      _udpServerSocket =
          await RawDatagramSocket.bind(InternetAddress.anyIPv4, port);
      _udpServerSocket!.listen((RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          final datagram = _udpServerSocket!.receive();
          if (datagram != null && _onUdpMessageReceived != null) {
            _onUdpMessageReceived!(
                datagram.data, datagram.address, datagram.port);
          }
        }
      });
      logInfo('P2PNetworkService: UDP server started on port $port');
    } catch (e) {
      logWarning(
          'P2PNetworkService: Failed to start UDP server on port $port: $e');
    }
  }

  Future<void> _startUdpListener() async {
    try {
      if (_udpListenerSocket != null) return;

      _udpListenerSocket =
          await RawDatagramSocket.bind(InternetAddress.anyIPv4, 8082);
      _udpListenerSocket!.listen((RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          final datagram = _udpListenerSocket!.receive();
          if (datagram != null && _onUdpMessageReceived != null) {
            _onUdpMessageReceived!(
                datagram.data, datagram.address, datagram.port);
          }
        }
      });

      logInfo('P2PNetworkService: UDP listener started on port 8082');
    } catch (e) {
      logError('P2PNetworkService: Failed to start UDP listener: $e');
    }
  }

  Future<void> _stopServers() async {
    await _serverSocket?.close();
    _serverSocket = null;

    _udpServerSocket?.close();
    _udpServerSocket = null;

    _udpListenerSocket?.close();
    _udpListenerSocket = null;

    logInfo('P2PNetworkService: All servers stopped');
  }

  void _handleClientConnection(Socket socket) {
    // logDebug(
    // 'P2PNetworkService: New client connected: ${socket.remoteAddress}');

    // Optimize socket for high throughput
    socket.setOption(SocketOption.tcpNoDelay, true);

    // Use a buffer for each connection to handle message framing
    final buffer = BytesBuilder();

    socket.listen(
      (data) {
        buffer.add(data);

        // Process all complete messages in the buffer
        while (true) {
          final currentBytes = buffer.toBytes();
          if (currentBytes.length < 4) {
            // Not enough data for the length header
            break;
          }

          final messageLength =
              ByteData.view(currentBytes.buffer).getUint32(0, Endian.big);

          if (currentBytes.length < messageLength + 4) {
            // The full message has not been received yet
            break;
          }

          // Extract the complete message
          final messageBytes = currentBytes.sublist(4, messageLength + 4);

          // Process the message
          if (_onMessageReceived != null) {
            _onMessageReceived!(socket, messageBytes);
          }

          // Remove the processed message from the buffer
          final remainingBytes = currentBytes.sublist(messageLength + 4);
          buffer.clear();
          buffer.add(remainingBytes);
        }
      },
      onError: (error) {
        logError(
            'P2PNetworkService: Socket error on ${socket.remoteAddress}: $error');
        _handleClientDisconnection(socket);
      },
      onDone: () => _handleClientDisconnection(socket),
      cancelOnError: true,
    );
  }

  void _handleClientDisconnection(Socket socket) {
    // @DebugLog
    // logDebug('P2PNetworkService: Client disconnected: ${socket.remoteAddress}');
    final userId = _connectedSockets.entries
        .firstWhere((entry) => entry.value == socket,
            orElse: () => MapEntry('', socket))
        .key;
    if (userId.isNotEmpty) {
      _connectedSockets.remove(userId);
      // logInfo('P2PNetworkService: Removed socket for user $userId');
    }
  }

  void _startTimers() {
    // Only start heartbeat timer for essential connectivity
    _heartbeatTimer =
        Timer.periodic(_heartbeatInterval, (_) => _performHeartbeat());

    // 🔥 REMOVED: Automatic cleanup and memory cleanup timers to save battery
    // These will only run on-demand via manual calls
  }

  void _stopTimers() {
    _heartbeatTimer?.cancel();
    _cleanupTimer?.cancel();
    _memoryCleanupTimer?.cancel();
  }

  void _performHeartbeat() {
    // This will be implemented by services that use this network service
    logInfo('P2PNetworkService: Heartbeat tick');
  }

  Future<void> _registerBackgroundTask() async {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      try {
        await Workmanager().registerPeriodicTask(
          "p2pKeepAliveUniqueName",
          "p2pKeepAliveTask",
          frequency: const Duration(minutes: 15),
          constraints: Constraints(networkType: NetworkType.connected),
          inputData: <String, dynamic>{
            'showNotification': false, // Explicitly disable notifications
            'silentMode': true, // Run in silent mode
          },
          // Note: Some Android versions may still show system notifications
          // for background tasks. This is controlled by the OS, not the app.
        );
        logInfo(
            'P2PNetworkService: Registered background task with notifications disabled');
      } catch (e) {
        logWarning('P2PNetworkService: Failed to register background task: $e');
      }
    }
  }

  Future<void> _cancelBackgroundTask() async {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      try {
        await Workmanager().cancelByUniqueName("p2pKeepAliveUniqueName");
        logInfo('P2PNetworkService: Cancelled background task');
      } catch (e) {
        logWarning('P2PNetworkService: Failed to cancel background task: $e');
      }
    }
  }

  Future<void> _closeAllConnections() async {
    for (final socket in _connectedSockets.values) {
      try {
        await socket.close();
      } catch (e) {
        logError('P2PNetworkService: Error closing socket: $e');
      }
    }
    _connectedSockets.clear();
  }

  /// Associate socket with user ID
  void associateSocketWithUser(String userId, Socket socket) {
    _connectedSockets[userId] = socket;
  }

  /// Get socket for user ID
  Socket? getSocketForUser(String userId) {
    return _connectedSockets[userId];
  }

  /// Called when discovery is complete
  void onDiscoveryComplete() {
    if (_connectionStatus == ConnectionStatus.discovering) {
      _connectionStatus = ConnectionStatus.connected;
      logInfo(
          'P2PNetworkService: Discovery complete, status changed to connected');
      notifyListeners();
    }
  }

  /// Set connection status (used by discovery service)
  void setConnectionStatus(ConnectionStatus status) {
    if (_connectionStatus != status) {
      _connectionStatus = status;
      logInfo('P2PNetworkService: Connection status changed to: $status');
      notifyListeners();
    }
  }

  @override
  void dispose() {
    logInfo('P2PNetworkService: Disposing...');
    disable();
    super.dispose();
  }
}
