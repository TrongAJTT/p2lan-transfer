import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:p2lan/services/app_logger.dart';

class TaskQueueManager {
  final ValueNotifier<bool> _isBusy = ValueNotifier<bool>(false);
  ValueNotifier<bool> get isBusy => _isBusy;

  // StreamController để quản lý hàng đợi các tác vụ
  final StreamController<Future<void> Function()> _taskQueue =
      StreamController<Future<void> Function()>();

  TaskQueueManager() {
    _processQueue(); // Bắt đầu lắng nghe và xử lý hàng đợi
  }

  /// Một hàm tiện ích để quan sát sự thay đổi của một ValueNotifier chỉ một lần.
  ///
  /// [notifier]: ValueNotifier mà bạn muốn quan sát.
  /// [callback]: Hàm sẽ được gọi khi giá trị của notifier thay đổi lần đầu tiên.
  ///
  /// Trả về một Future hoàn thành khi callback được gọi.
  Future<void> observeValueOnce<T>({
    required ValueNotifier<T> notifier,
    required void Function(T newValue) callback,
  }) {
    final completer = Completer<void>();
    late VoidCallback listener; // Sử dụng `late` vì nó sẽ được gán trong hàm

    listener = () {
      // Đảm bảo callback chỉ được gọi một lần và completer chỉ hoàn thành một lần
      if (!completer.isCompleted) {
        callback(notifier.value); // Gọi hàm callback với giá trị mới
        notifier.removeListener(listener); // Gỡ bỏ listener ngay lập tức
        completer.complete(); // Hoàn thành Future
      }
    };

    notifier.addListener(listener); // Thêm listener vào notifier

    // Trả về Future. Bạn có thể await Future này để biết khi nào sự thay đổi xảy ra.
    return completer.future;
  }

  // Thêm một tác vụ vào hàng đợi
  void addTask(Future<void> Function() task) {
    _taskQueue.sink.add(task);
    logDebug(
        'Task added to queue. Current queue size: ${_taskQueue.sink.hashCode}'); // Hash code để giả lập kích thước
  }

  // Hàm xử lý hàng đợi
  Future<void> _processQueue() async {
    await for (final task in _taskQueue.stream) {
      if (_isBusy.value) {
        // Nếu đang bận, đợi cho đến khi rảnh
        await observeValueOnce(
            notifier: _isBusy,
            callback: (newValue) {
              // Callback này sẽ được gọi khi _isBusy thay đổi thành false
              // (hoặc bất kỳ giá trị nào khác, nhưng chúng ta mong đợi false để tiếp tục)
            });
      }

      _isBusy.value = true; // Đặt cờ là đang bận để thực hiện tác vụ
      try {
        await task(); // Thực hiện tác vụ
      } catch (e) {
        logError('Error executing task: $e');
      } finally {
        _isBusy.value = false; // Đặt cờ là rảnh sau khi hoàn thành
        logInfo('Task completed. Manager is free.');
      }
    }
  }

  void dispose() {
    _isBusy.dispose();
    _taskQueue.close();
  }

  /// Chạy một tác vụ sau một khoảng thời gian nhất định.
  /// [delay]: Khoảng thời gian chờ trước khi chạy tác vụ.
  /// [task]: Tác vụ sẽ được thực hiện sau khoảng thời gian chờ.
  static Future<void> runTaskAfter({
    required Duration delay,
    required Future<void> Function() task,
  }) async {
    await Future.delayed(delay);
    await task();
  }

  static Future<void> runTaskAfterAndRepeatMax({
    required Duration delay,
    required Future<bool> Function() task,
    required int maxRepeats,
  }) async {
    for (int i = 0; i < maxRepeats; i++) {
      await Future.delayed(delay);
      if (await task()) {
        break;
      }
    }
  }
}
