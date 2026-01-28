import 'dart:io';
import 'dart:async';
import 'package:p2lan/services/app_logger.dart';

/// Performance optimizer for P2P data transfer
/// Implements adaptive algorithms for optimal transfer speed
class PerformanceOptimizerService {
  // Network performance metrics
  static double _averageRtt = 50.0; // milliseconds
  static double _bandwidthEstimate = 10.0; // MB/s
  static const double _packetLossRate = 0.0; // 0.0 to 1.0
  static const int _optimalChunkSize = 512 * 1024; // 512KB default
  static const int _optimalConcurrency = 3;

  // Performance history for adaptive learning
  static final List<TransferMetrics> _transferHistory = [];
  static const int _maxHistorySize = 50;

  /// Calculate optimal chunk size based on network conditions
  static int calculateOptimalChunkSize({
    required double bandwidth, // MB/s
    required double rtt, // milliseconds
    required double packetLoss, // 0.0 to 1.0
  }) {
    // Base chunk size based on bandwidth-delay product
    final bdp = (bandwidth * 1024 * 1024) * (rtt / 1000); // bytes

    // Adjust for packet loss
    final lossAdjustment = 1.0 - (packetLoss * 2); // Reduce size if high loss

    // Calculate optimal chunk size
    int chunkSize = (bdp * 0.5 * lossAdjustment).round();

    // Clamp to reasonable bounds
    chunkSize = chunkSize.clamp(64 * 1024, 4 * 1024 * 1024); // 64KB to 4MB

    logInfo(
        'PerformanceOptimizer: Optimal chunk size: ${chunkSize ~/ 1024}KB (BW: ${bandwidth}MB/s, RTT: ${rtt}ms, Loss: ${(packetLoss * 100).toStringAsFixed(1)}%)');

    return chunkSize;
  }

  /// Calculate optimal concurrency level
  static int calculateOptimalConcurrency({
    required double bandwidth, // MB/s
    required int chunkSize, // bytes
    required double rtt, // milliseconds
  }) {
    // Estimate transfer time per chunk
    final chunkTransferTime =
        (chunkSize / (bandwidth * 1024 * 1024)) * 1000; // ms

    // Calculate parallel streams needed to keep network busy
    final optimalStreams = (rtt / chunkTransferTime).ceil();

    // Consider system resources
    final maxConcurrency = Platform.numberOfProcessors * 2;

    // Clamp to reasonable bounds
    final concurrency = optimalStreams.clamp(1, maxConcurrency);

    logInfo(
        'PerformanceOptimizer: Optimal concurrency: $concurrency (Transfer time: ${chunkTransferTime.toStringAsFixed(1)}ms)');

    return concurrency;
  }

  /// Adaptive chunk size algorithm based on transfer performance
  static int adaptiveChunkSize({
    required int currentChunkSize,
    required double currentSpeed, // bytes/sec
    required double targetSpeed, // bytes/sec
    required int consecutiveSuccess,
    required bool hadError,
  }) {
    if (hadError) {
      // Reduce chunk size on error
      final newSize = (currentChunkSize * 0.7).round();
      return newSize.clamp(64 * 1024, currentChunkSize);
    }

    if (consecutiveSuccess >= 5 && currentSpeed >= targetSpeed * 0.9) {
      // Increase chunk size if performing well
      final newSize = (currentChunkSize * 1.3).round();
      return newSize.clamp(currentChunkSize, 4 * 1024 * 1024);
    }

    if (currentSpeed < targetSpeed * 0.5) {
      // Decrease chunk size if underperforming
      final newSize = (currentChunkSize * 0.8).round();
      return newSize.clamp(64 * 1024, currentChunkSize);
    }

    return currentChunkSize;
  }

  /// Estimate network RTT using ping
  static Future<double> estimateRTT(String targetIP) async {
    final startTime = DateTime.now();

    try {
      final socket = await Socket.connect(
        targetIP,
        80, // Use port 80 for quick connection test
        timeout: const Duration(seconds: 3),
      );

      final rtt =
          DateTime.now().difference(startTime).inMilliseconds.toDouble();
      await socket.close();

      _averageRtt = (_averageRtt * 0.8) + (rtt * 0.2); // Exponential smoothing

      logInfo(
          'PerformanceOptimizer: RTT to $targetIP: ${rtt.toStringAsFixed(1)}ms');
      return rtt;
    } catch (e) {
      logWarning(
          'PerformanceOptimizer: Failed to measure RTT to $targetIP: $e');
      return _averageRtt; // Return cached value
    }
  }

  /// Estimate available bandwidth
  static Future<double> estimateBandwidth() async {
    // Simple bandwidth estimation based on recent transfer history
    if (_transferHistory.isEmpty) {
      return _bandwidthEstimate;
    }

    final recentTransfers = _transferHistory
        .where((m) => DateTime.now().difference(m.timestamp).inMinutes < 5)
        .toList();

    if (recentTransfers.isEmpty) {
      return _bandwidthEstimate;
    }

    final avgSpeed =
        recentTransfers.map((m) => m.speedMBps).reduce((a, b) => a + b) /
            recentTransfers.length;

    _bandwidthEstimate = (_bandwidthEstimate * 0.7) + (avgSpeed * 0.3);

    logInfo(
        'PerformanceOptimizer: Estimated bandwidth: ${_bandwidthEstimate.toStringAsFixed(1)} MB/s');
    return _bandwidthEstimate;
  }

  /// Record transfer metrics for learning
  static void recordTransferMetrics({
    required int chunkSize,
    required double speedMBps,
    required double rtt,
    required bool successful,
    required int concurrency,
  }) {
    final metrics = TransferMetrics(
      timestamp: DateTime.now(),
      chunkSize: chunkSize,
      speedMBps: speedMBps,
      rtt: rtt,
      successful: successful,
      concurrency: concurrency,
    );

    _transferHistory.add(metrics);

    // Keep history size manageable
    if (_transferHistory.length > _maxHistorySize) {
      _transferHistory.removeAt(0);
    }

    // Update global estimates
    if (successful) {
      _averageRtt = (_averageRtt * 0.9) + (rtt * 0.1);
      _bandwidthEstimate = (_bandwidthEstimate * 0.9) + (speedMBps * 0.1);
    }
  }

  /// Get optimized transfer parameters
  static Future<TransferParameters> getOptimizedParameters(
      String targetIP) async {
    final rtt = await estimateRTT(targetIP);
    final bandwidth = await estimateBandwidth();

    final chunkSize = calculateOptimalChunkSize(
      bandwidth: bandwidth,
      rtt: rtt,
      packetLoss: _packetLossRate,
    );

    final concurrency = calculateOptimalConcurrency(
      bandwidth: bandwidth,
      chunkSize: chunkSize,
      rtt: rtt,
    );

    return TransferParameters(
      chunkSize: chunkSize,
      concurrency: concurrency,
      bandwidth: bandwidth,
      rtt: rtt,
    );
  }

  /// TCP socket optimization
  static void optimizeTCPSocket(Socket socket) {
    try {
      // Disable Nagle's algorithm for low latency
      socket.setOption(SocketOption.tcpNoDelay, true);

      // Set large send/receive buffers
      if (Platform.isLinux || Platform.isMacOS) {
        socket.setRawOption(RawSocketOption.fromInt(
          RawSocketOption.levelSocket,
          SO_SNDBUF,
          1024 * 1024, // 1MB send buffer
        ));
        socket.setRawOption(RawSocketOption.fromInt(
          RawSocketOption.levelSocket,
          SO_RCVBUF,
          1024 * 1024, // 1MB receive buffer
        ));
      }

      logInfo('PerformanceOptimizer: TCP socket optimized');
    } catch (e) {
      logWarning('PerformanceOptimizer: Failed to optimize TCP socket: $e');
    }
  }

  /// UDP socket optimization
  static void optimizeUDPSocket(RawDatagramSocket socket) {
    try {
      // Set large send/receive buffers for UDP
      if (Platform.isLinux || Platform.isMacOS) {
        socket.setRawOption(RawSocketOption.fromInt(
          RawSocketOption.levelSocket,
          SO_SNDBUF,
          2 * 1024 * 1024, // 2MB send buffer
        ));
        socket.setRawOption(RawSocketOption.fromInt(
          RawSocketOption.levelSocket,
          SO_RCVBUF,
          2 * 1024 * 1024, // 2MB receive buffer
        ));
      }

      logInfo('PerformanceOptimizer: UDP socket optimized');
    } catch (e) {
      logWarning('PerformanceOptimizer: Failed to optimize UDP socket: $e');
    }
  }

  // Socket option constants
  static const int SO_SNDBUF = 7;
  static const int SO_RCVBUF = 8;
}

/// Transfer metrics for performance analysis
class TransferMetrics {
  final DateTime timestamp;
  final int chunkSize;
  final double speedMBps;
  final double rtt;
  final bool successful;
  final int concurrency;

  TransferMetrics({
    required this.timestamp,
    required this.chunkSize,
    required this.speedMBps,
    required this.rtt,
    required this.successful,
    required this.concurrency,
  });
}

/// Optimized transfer parameters
class TransferParameters {
  final int chunkSize;
  final int concurrency;
  final double bandwidth;
  final double rtt;

  TransferParameters({
    required this.chunkSize,
    required this.concurrency,
    required this.bandwidth,
    required this.rtt,
  });

  @override
  String toString() {
    return 'TransferParameters(chunkSize: ${chunkSize ~/ 1024}KB, '
        'concurrency: $concurrency, bandwidth: ${bandwidth.toStringAsFixed(1)}MB/s, '
        'rtt: ${rtt.toStringAsFixed(1)}ms)';
  }
}
