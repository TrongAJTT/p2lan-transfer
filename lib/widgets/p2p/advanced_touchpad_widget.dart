import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:p2lan/l10n/app_localizations.dart';
import 'package:p2lan/models/p2p_models.dart';

/// Advanced touchpad widget that supports laptop-like gestures
class AdvancedTouchpadWidget extends StatefulWidget {
  final Function(RemoteControlEvent) onGestureEvent;
  final bool isEnabled;

  const AdvancedTouchpadWidget({
    super.key,
    required this.onGestureEvent,
    this.isEnabled = true,
  });

  @override
  State<AdvancedTouchpadWidget> createState() => _AdvancedTouchpadWidgetState();
}

class _AdvancedTouchpadWidgetState extends State<AdvancedTouchpadWidget> {
  // Touch tracking with proper multi-touch support
  final Map<int, Offset> _activePointers = {};
  final Map<int, Offset> _initialPointers = {};
  Timer? _tapTimer;
  Timer? _doubleTapTimer;
  Timer? _gestureProcessingTimer;

  // Track finger count for better gesture detection
  int _maxFingerCount = 0;

  bool _isScrolling = false;
  bool _isMultiFingerGesture = false;
  bool _isDragging = false;
  bool _waitingForDrag = false; // After double tap, wait for drag
  int _consecutiveTaps = 0;
  DateTime? _lastGestureTime;

  // Gesture detection parameters
  static const double _scrollThreshold = 8.0; // Reduced for easier scrolling
  static const double _scrollSensitivity = 0.02;
  static const double _mouseSensitivity = 0.004;
  static const int _gestureDebounceMs = 40; // Lower for less delay

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _tapTimer?.cancel();
    _doubleTapTimer?.cancel();
    _gestureProcessingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[700]!, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Main touchpad area - Use only Listener for proper multi-touch
              Listener(
                onPointerDown: _handlePointerDown,
                onPointerMove: _handlePointerMove,
                onPointerUp: _handlePointerUp,
                onPointerCancel: _handlePointerCancel,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.transparent,
                ),
              ),

              // Visual feedback and instructions
              if (!widget.isEnabled)
                Container(
                  color: Colors.black.withValues(alpha: 0.5),
                  child: const Center(
                    child: Icon(
                      Icons.block,
                      size: 64,
                      color: Colors.red,
                    ),
                  ),
                ),

              // Instructions overlay
              if (widget.isEnabled)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.touch_app,
                            size: 48,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            loc.touchpadArea,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            loc.moveFingerToControlMouse,
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (!widget.isEnabled) return;

    _activePointers[event.pointer] = event.localPosition;
    _initialPointers[event.pointer] = event.localPosition;

    // Update max finger count
    _maxFingerCount = _activePointers.length;

    // Cancel any ongoing timers
    _tapTimer?.cancel();

    // If this is the first pointer, start tap detection for single finger
    if (_activePointers.length == 1) {
      _tapTimer = Timer(const Duration(milliseconds: 500), () {
        // If still only one pointer and hasn't moved much, it might be a long press
        if (_activePointers.length == 1) {
          final currentPos = _activePointers.values.first;
          final initialPos = _initialPointers.values.first;
          final distance = (currentPos - initialPos).distance;

          if (distance < 10) {
            // Long press = right click (fallback for single finger)
            _sendGestureWithDebounce(() {
              widget.onGestureEvent(RemoteControlEvent.rightClick());
              HapticFeedback.mediumImpact();
            });
          }
        }
      });
    }
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (!widget.isEnabled) return;

    final previousPosition = _activePointers[event.pointer];
    if (previousPosition == null) return;

    _activePointers[event.pointer] = event.localPosition;
    final delta = event.localPosition - previousPosition;

    // Determine gesture based on number of active pointers
    if (_activePointers.length == 1) {
      // Single finger = mouse movement or drag selection
      if (!_isScrolling && !_isMultiFingerGesture) {
        if (_waitingForDrag) {
          // Start drag selection after double tap
          if (!_isDragging) {
            _isDragging = true;
            // Start text selection by holding left mouse button
            widget.onGestureEvent(RemoteControlEvent.startLeftLongClick());
          }
          // Continue with mouse movement while dragging
          final mouseDelta = Offset(
            delta.dx * _mouseSensitivity,
            delta.dy * _mouseSensitivity,
          );
          widget.onGestureEvent(RemoteControlEvent.mouseMove(
            mouseDelta.dx,
            mouseDelta.dy,
          ));
        } else {
          // Normal mouse movement
          final mouseDelta = Offset(
            delta.dx * _mouseSensitivity,
            delta.dy * _mouseSensitivity,
          );
          widget.onGestureEvent(RemoteControlEvent.mouseMove(
            mouseDelta.dx,
            mouseDelta.dy,
          ));
        }
      }
    } else if (_activePointers.length == 2) {
      // Two fingers = scrolling (only if significant movement)
      if (delta.dy.abs() > _scrollThreshold && !_isScrolling) {
        _isScrolling = true;
        _isMultiFingerGesture = true;
      }

      if (_isScrolling) {
        // Fix scroll direction - remove negative sign to match physical touchpad
        final scrollDelta = delta.dy * _scrollSensitivity;
        widget
            .onGestureEvent(RemoteControlEvent.twoFingerScroll(0, scrollDelta));
      }
    }
    // Handle 3+ finger gestures during movement
    else if (_activePointers.length >= 3) {
      _isMultiFingerGesture = true;
      // Note: 3-finger gestures are processed in _processGestureEnd for better accuracy
    }
  }

  void _handlePointerUp(PointerUpEvent event) {
    if (!widget.isEnabled) return;

    final initialPosition = _initialPointers[event.pointer];
    final finalPosition = _activePointers[event.pointer];

    _activePointers.remove(event.pointer);
    _initialPointers.remove(event.pointer);

    // If this was the last pointer, process gestures
    if (_activePointers.isEmpty) {
      // End drag selection if was dragging
      if (_isDragging) {
        // End text selection by releasing left mouse button
        widget.onGestureEvent(RemoteControlEvent.stopLeftLongClick());
        _isDragging = false;
        _waitingForDrag = false;
      }

      // Lower latency: process immediately (remove 50ms delay)
      _processGestureEnd(_maxFingerCount, initialPosition, finalPosition);
      _resetGestureState();
    }
  }

  void _handlePointerCancel(PointerCancelEvent event) {
    if (!widget.isEnabled) return;

    _activePointers.remove(event.pointer);
    _initialPointers.remove(event.pointer);

    if (_activePointers.isEmpty) {
      _resetGestureState();
    }
  }

  void _processGestureEnd(
      int pointerCount, Offset? initialPos, Offset? finalPos) {
    _tapTimer?.cancel();

    if (initialPos == null || finalPos == null) return;

    final distance = (finalPos - initialPos).distance;
    final delta = finalPos - initialPos;

    if (pointerCount == 1) {
      if (distance < 10) {
        // Small movement = tap
        _handleTap();
      }
    } else if (pointerCount == 2) {
      // Two finger tap = right click
      // Only trigger if distance is small and no scrolling was detected
      if (distance < 20 && !_isScrolling) {
        _sendGestureWithDebounce(() {
          widget.onGestureEvent(RemoteControlEvent.rightClick());
          HapticFeedback.lightImpact();
        });
      }
    } else if (pointerCount == 3) {
      // Three finger gestures
      if (distance > 30) {
        // Reduced threshold for easier triggering
        String direction;
        if (delta.dy.abs() > delta.dx.abs()) {
          // Vertical movement - window switching
          direction = delta.dy < 0 ? 'up' : 'down';
        } else {
          // Horizontal movement - app switching
          direction = delta.dx < 0 ? 'left' : 'right';
        }

        _sendGestureWithDebounce(() {
          widget.onGestureEvent(RemoteControlEvent.threeFingerSwipe(direction));
          HapticFeedback.heavyImpact();
        });
      } else {
        // Three finger tap = Action Center
        _sendGestureWithDebounce(() {
          widget.onGestureEvent(RemoteControlEvent.threeFingerTap());
          HapticFeedback.mediumImpact();
        });
      }
    } else if (pointerCount >= 4) {
      if (distance < 15) {
        // Four finger tap = Virtual Desktop
        _sendGestureWithDebounce(() {
          widget.onGestureEvent(RemoteControlEvent.fourFingerTap());
          HapticFeedback.heavyImpact();
        });
      }
    }
  }

  void _handleTap() {
    _consecutiveTaps++;

    // Start double tap timer
    _doubleTapTimer?.cancel();
    _doubleTapTimer = Timer(const Duration(milliseconds: 300), () {
      if (_consecutiveTaps == 1) {
        // Single tap = left click
        widget.onGestureEvent(RemoteControlEvent.leftClick());
        HapticFeedback.lightImpact();
      } else if (_consecutiveTaps == 2) {
        // Double tap = double click (normal behavior first)
        widget.onGestureEvent(RemoteControlEvent.leftClick());
        Future.delayed(const Duration(milliseconds: 50), () {
          widget.onGestureEvent(RemoteControlEvent.leftClick());
        });
        HapticFeedback.mediumImpact();

        // Then prepare for drag selection
        _waitingForDrag = true;

        // Auto-cancel waiting for drag after 1.5 seconds
        Timer(const Duration(milliseconds: 1500), () {
          _waitingForDrag = false;
        });
      }
      _consecutiveTaps = 0;
    });
  }

  void _sendGestureWithDebounce(VoidCallback gesture) {
    final now = DateTime.now();
    if (_lastGestureTime != null &&
        now.difference(_lastGestureTime!).inMilliseconds < _gestureDebounceMs) {
      return; // Ignore rapid gestures
    }

    _lastGestureTime = now;
    gesture();
  }

  void _resetGestureState() {
    _isScrolling = false;
    _isMultiFingerGesture = false;
    _maxFingerCount = 0;
    // Don't reset _isDragging and _waitingForDrag here as they span multiple gestures
  }
}
