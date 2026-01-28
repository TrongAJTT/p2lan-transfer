import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:p2lan/l10n/app_localizations.dart';
import 'package:p2lan/models/p2p_models.dart';
import 'package:p2lan/services/app_logger.dart';
import 'package:p2lan/services/p2p_services/p2p_service_manager.dart';

/// Screen Sharing Viewer Screen
/// Displays the shared screen from another device
class ScreenSharingViewerScreen extends StatefulWidget {
  final ScreenSharingSession session;
  final WindowController? windowController;
  final P2PServiceManager? serviceManager;
  final bool isFloatingWindow;

  const ScreenSharingViewerScreen({
    super.key,
    required this.session,
    this.windowController,
    this.serviceManager,
    this.isFloatingWindow = false,
  });

  @override
  State<ScreenSharingViewerScreen> createState() =>
      _ScreenSharingViewerScreenState();
}

class _ScreenSharingViewerScreenState extends State<ScreenSharingViewerScreen> {
  late final P2PServiceManager _serviceManager;
  RTCVideoRenderer? _remoteRenderer;
  bool _isFullScreen = false;
  bool _isConnected = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Use provided serviceManager or fallback to singleton
    _serviceManager = widget.serviceManager ?? P2PServiceManager.instance;
    logInfo(
        'ScreenSharingViewerScreen: Using serviceManager: ${widget.serviceManager != null ? "provided" : "singleton"}');
    _initializeRenderer();
    _setupListeners();
  }

  @override
  void dispose() {
    _cleanupRenderer();
    super.dispose();
  }

  Future<void> _initializeRenderer() async {
    try {
      _remoteRenderer = RTCVideoRenderer();
      await _remoteRenderer!.initialize();
      logInfo('ScreenSharingViewerScreen: Renderer initialized successfully');

      // Get remote stream from screen sharing service
      final remoteStream = _serviceManager.remoteScreenStream;
      if (remoteStream != null) {
        logInfo(
            'ScreenSharingViewerScreen: Remote stream found with ${remoteStream.getVideoTracks().length} video tracks');
        _remoteRenderer!.srcObject = remoteStream;
        logInfo(
            'ScreenSharingViewerScreen: Remote stream connected to renderer');
        setState(() {
          _isLoading = false;
          _isConnected = true;
        });
      } else {
        logWarning(
            'ScreenSharingViewerScreen: No remote stream available yet, will wait for stream');
        setState(() {
          _isLoading = false;
          _isConnected = false;
        });
      }
    } catch (e) {
      logError('ScreenSharingViewerScreen: Failed to initialize renderer: $e');
      setState(() {
        _isLoading = false;
        _isConnected = false;
      });
    }
  }

  void _setupListeners() {
    // Listen for session changes
    _serviceManager.addListener(_onServiceManagerChange);
  }

  void _onServiceManagerChange() {
    logInfo(
        'ScreenSharingViewerScreen: Service manager changed - isScreenReceiving: ${_serviceManager.isScreenReceiving}');

    if (!_serviceManager.isScreenReceiving) {
      // Session ended, go back
      logInfo('ScreenSharingViewerScreen: Session ended, going back');
      if (mounted) {
        Navigator.of(context).pop();
      }
    } else {
      // Check if remote stream is now available
      final remoteStream = _serviceManager.remoteScreenStream;
      logInfo(
          'ScreenSharingViewerScreen: Remote stream check - stream: ${remoteStream != null}, renderer: ${_remoteRenderer != null}, srcObject: ${_remoteRenderer?.srcObject != null}');

      if (remoteStream != null &&
          _remoteRenderer != null &&
          _remoteRenderer!.srcObject == null) {
        logInfo(
            'ScreenSharingViewerScreen: Remote stream now available with ${remoteStream.getVideoTracks().length} video tracks, connecting to renderer');
        _remoteRenderer!.srcObject = remoteStream;
        setState(() {
          _isLoading = false;
          _isConnected = true;
        });
      } else if (remoteStream != null &&
          _remoteRenderer != null &&
          _remoteRenderer!.srcObject != null) {
        // Stream already connected, just update state
        setState(() {
          _isLoading = false;
          _isConnected = true;
        });
      }
    }
  }

  Future<void> _cleanupRenderer() async {
    try {
      await _remoteRenderer?.dispose();
    } catch (e) {
      logError('ScreenSharingViewerScreen: Error disposing renderer: $e');
    }
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });

    if (_isFullScreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: SystemUiOverlay.values);
    }
  }

  void _disconnect() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm'),
        content: const Text('Stop receiving screen share?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _performDisconnect();
            },
            child: const Text('Stop'),
          ),
        ],
      ),
    );
  }

  void _performDisconnect() async {
    try {
      await _serviceManager.stopScreenReceiving();
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      logError('ScreenSharingViewerScreen: Failed to disconnect: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error disconnecting')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // In floating window mode, don't use PopScope and AppBar (handled by FloatingWindow)
    if (widget.isFloatingWindow) {
      return Container(
        color: Colors.black,
        child: _buildContent(l10n),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _disconnect();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: _isFullScreen
            ? null
            : AppBar(
                title: const Text('Screen Sharing'),
                backgroundColor: Colors.black87,
                foregroundColor: Colors.white,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _disconnect,
                  tooltip: 'Back',
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.fullscreen),
                    onPressed: _toggleFullScreen,
                    tooltip: 'Full Screen',
                  ),
                  IconButton(
                    icon: const Icon(Icons.stop),
                    onPressed: _disconnect,
                    tooltip: 'Stop',
                  ),
                ],
              ),
        body: _buildContent(l10n),
        floatingActionButton: _isFullScreen
            ? FloatingActionButton(
                onPressed: _toggleFullScreen,
                backgroundColor: Colors.black54,
                child: const Icon(Icons.fullscreen_exit, color: Colors.white),
              )
            : null,
      ),
    );
  }

  Widget _buildContent(AppLocalizations l10n) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
            const SizedBox(height: 24),
            Text(
              'Waiting for screen share...',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Establishing connection with ${widget.session.senderUser.displayName}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 32),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white24),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.info_outline, color: Colors.white70, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Connection Steps:',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildConnectionStep('1. Establishing P2P connection', true),
                  _buildConnectionStep(
                      '2. Negotiating WebRTC session', !_isConnected),
                  _buildConnectionStep('3. Receiving video stream', false),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (!_isConnected) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to connect to screen share',
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        // Remote screen display
        Center(
          child: _remoteRenderer != null
              ? RTCVideoView(_remoteRenderer!)
              : Container(
                  color: Colors.grey[900],
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.screen_share,
                          size: 64,
                          color: Colors.white54,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Waiting for screen content...',
                          style: const TextStyle(color: Colors.white54),
                        ),
                      ],
                    ),
                  ),
                ),
        ),

        // Connection info overlay (top)
        if (!_isFullScreen)
          Positioned(
            top: 8,
            left: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.monitor, color: Colors.green, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Receiving from ${widget.session.senderUser.displayName}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                  Text(
                    _formatDuration(widget.session.duration),
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),

        // Quality info (bottom left)
        if (!_isFullScreen)
          Positioned(
            bottom: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${widget.session.quality.name.toUpperCase()} - ${widget.session.quality.width}x${widget.session.quality.height}',
                style: const TextStyle(color: Colors.white70, fontSize: 10),
              ),
            ),
          ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Widget _buildConnectionStep(String text, bool isActive) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? Icons.hourglass_empty : Icons.check_circle_outline,
            color: isActive ? Colors.orange : Colors.white38,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.white54,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
