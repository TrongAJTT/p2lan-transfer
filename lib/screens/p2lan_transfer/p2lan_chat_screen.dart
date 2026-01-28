import 'dart:io';
import 'package:cross_file/cross_file.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:isar/isar.dart';
import 'package:p2lan/view_models/p2p_view_model.dart';
import 'package:p2lan/l10n/app_localizations.dart';
import 'package:p2lan/layouts/two_panels_layout.dart';
import 'package:p2lan/models/p2p_chat.dart';
import 'package:p2lan/models/p2p_models.dart';
import 'package:p2lan/screens/p2lan_transfer/p2p_chat_settings_layout.dart';
import 'package:p2lan/services/app_logger.dart';
import 'package:p2lan/services/p2p_services/p2p_settings_adapter.dart';
import 'package:p2lan/utils/async_utils.dart';
import 'package:p2lan/utils/clipboard_utils.dart';
import 'package:p2lan/utils/generic_dialog_utils.dart';
import 'package:p2lan/utils/localization_utils.dart';
import 'package:p2lan/utils/media_utils.dart';
import 'package:p2lan/utils/shortcut_tooltip_utils.dart';
import 'package:p2lan/utils/size_utils.dart';
import 'package:p2lan/utils/snackbar_utils.dart';
import 'package:p2lan/utils/url_utils.dart' hide FileType;
import 'package:p2lan/screens/p2lan_transfer/p2lan_local_files_screen.dart';
import 'package:p2lan/utils/variables_utils.dart';
import 'package:p2lan/variables.dart';
import 'package:p2lan/widgets/generic/generic_context_menu.dart';
import 'package:p2lan/widgets/generic/generic_dialog.dart';
import 'package:p2lan/widgets/generic/generic_settings_helper.dart';
import 'package:p2lan/widgets/generic/icon_button_list.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:clipboard/clipboard.dart';
import 'package:uuid/uuid.dart';

/// Section: Chat List Screen

class P2LanChatListScreen extends StatefulWidget {
  final P2PViewModel viewModel;
  final String? initialUserBId;
  const P2LanChatListScreen(
      {super.key, required this.viewModel, this.initialUserBId});

  @override
  State<P2LanChatListScreen> createState() => _P2LanChatListScreenState();
}

class _P2LanChatListScreenState extends State<P2LanChatListScreen> {
  late AppLocalizations _loc;
  P2PChat _chat = P2PChat.empty();
  bool isDesktop = false;
  String? _pendingOpenUserBId;
  List<P2PChat> _latestChats = [];

  @override
  void initState() {
    super.initState();
    // Add listener to P2PViewModel for status updates
    widget.viewModel.addListener(_onControllerChanged);
    _pendingOpenUserBId = widget.initialUserBId;
  }

  @override
  void dispose() {
    // Remove listener from P2PViewModel
    widget.viewModel.removeListener(_onControllerChanged);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loc = AppLocalizations.of(context);
  }

  /// Handle P2PViewModel state changes to update UI
  void _onControllerChanged() {
    if (mounted) {
      setState(() {
        // This will trigger a rebuild to update online status and other UI elements
      });
    }
  }

  // Nút tao tác bên lề
  Widget _buildActionButtons(BuildContext context, P2PChat chat) {
    final loc = AppLocalizations.of(context);
    final visibleCount = MediaQuery.of(context).size.width > 600 ? 3 : 0;
    return FutureBuilder<bool>(
      future: widget.viewModel.p2pChatService.isPinned(chat.userBId),
      builder: (context, snapshot) {
        final isPinned = snapshot.data == true;
        final pinIcon = isPinned ? Icons.push_pin : Icons.push_pin_outlined;
        final pinLabel = isPinned ? 'Unpin' : 'Pin';
        return IconButtonList(
          buttons: [
            IconButtonListItem(
              icon: pinIcon,
              label: pinLabel,
              onPressed: () async {
                final current = await widget.viewModel.p2pChatService
                    .isPinned(chat.userBId);
                if (current) {
                  await widget.viewModel.p2pChatService.unpinChat(chat.userBId);
                } else {
                  await widget.viewModel.p2pChatService.pinChat(chat.userBId);
                }
                if (mounted) setState(() {});
              },
            ),
            // TODO: Support sync chat with other users in the future
            // IconButtonListItem(
            //   icon: Icons.person,
            //   label: 'Sync this chat with other users',
            //   onPressed: () {
            //
            //   },
            // ),
            IconButtonListItem(
              icon: Icons.clear,
              label: loc.deleteChat,
              onPressed: () {
                GenericDialogUtils.showSimpleHoldClearDialog(
                    context: context,
                    title: loc.deleteChatWith(chat.displayName),
                    content: loc.deleteChatDesc,
                    duration: const Duration(seconds: 1),
                    onConfirm: () async {
                      await widget.viewModel.p2pChatService
                          .deleteChatAndNotify(chat);
                      if (mounted) {
                        setState(() {
                          _chat = P2PChat.empty();
                        });
                      }
                    });
              },
            ),
          ],
          visibleCount: visibleCount,
        );
      },
    );
  }

  void _enterChat(P2PChat chat) {
    setState(() {
      _chat = chat;
    });
    if (!isDesktop) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => P2LanChatDetailScreen(
            chat: chat,
            viewModel: widget.viewModel,
          ),
        ),
      );
    }
  }

  Widget _buildChatList() {
    return FutureBuilder<List<P2PChat>>(
      future: widget.viewModel.p2pChatService.loadAllChats(),
      builder: (context, snapshot) {
        Widget chatListContent;

        if (snapshot.connectionState == ConnectionState.waiting) {
          chatListContent = const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          chatListContent = Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          chatListContent = Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.chat_bubble_outline,
                    size: 48, color: Colors.grey),
                const SizedBox(height: 16),
                Text(_loc.noChatExists),
              ],
            ),
          );
        } else {
          final chats = snapshot.data!;
          _latestChats = chats;

          // Auto-open chat by initial userBId once after data loads
          if (_pendingOpenUserBId != null) {
            final targetChat = chats.firstWhere(
                (c) => c.userBId == _pendingOpenUserBId,
                orElse: () => P2PChat.empty());
            if (!targetChat.isEmpty()) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _enterChat(targetChat);
                _pendingOpenUserBId = null;
              });
            } else {
              // Fallback: try service lookup (in case chats list not yet updated)
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                final fallback = await widget.viewModel.p2pChatService
                    .findChatByUsers(_pendingOpenUserBId!);
                if (fallback != null && mounted) {
                  _enterChat(fallback);
                }
                _pendingOpenUserBId = null;
              });
            }
          }

          chatListContent = Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.separated(
              itemCount: chats.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final chat = chats[index];
                final title = chat.displayName;
                final lastMessage = chat.messages.isNotEmpty
                    ? chat.messages.last
                    : P2PCMessage.createEmpty();
                final isOnline = widget.viewModel.isUserOnline(chat.userBId);

                return ListTile(
                  leading: Stack(
                    children: [
                      CircleAvatar(
                        backgroundColor:
                            Colors.primaries[index % Colors.primaries.length],
                        child: Text(title.isNotEmpty ? title[0] : '?'),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: isOnline ? Colors.green : Colors.grey,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(context).cardColor,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  title: Text(title),
                  subtitle: lastMessage.isEmpty()
                      ? Text(
                          _loc.noMessages,
                          overflow: TextOverflow.ellipsis,
                        )
                      : Text(
                          '${LocalizationUtils.formatDateTime(context: context, dateTime: lastMessage.sentAt, formatType: DateTimeFormatType.message)} ● ${lastMessage.content}',
                          overflow: TextOverflow.ellipsis,
                        ),
                  trailing: _buildActionButtons(context, chat),
                  onTap: () => _enterChat(chat),
                  // Highlight the selected chat
                  selected: _chat.id == chat.id,
                );
              },
            ),
          );
        }

        // Wrap content with Scaffold to add FloatingActionButton
        return Scaffold(
          body: chatListContent,
          floatingActionButton: FloatingActionButton(
            onPressed: _showAddChatDialog,
            tooltip: _loc.addChat,
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  // Show dialog to add new chat with online users
  void _showAddChatDialog() {
    showDialog(
      context: context,
      builder: (context) => GenericDialog(
          header: GenericDialogHeader(
            title: _loc.addChat,
            subtitle: _loc.addChatDesc,
          ),
          body: SizedBox(
            width: double.maxFinite,
            child: FutureBuilder<List<P2PUser>>(
              future: _getOnlineUsers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.person_off,
                          size: 48, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(_loc.noUserOnline,
                          style: const TextStyle(color: Colors.grey)),
                    ],
                  );
                } else {
                  final onlineUsers = snapshot.data!;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 300,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: onlineUsers.length,
                          itemBuilder: (context, index) {
                            final user = onlineUsers[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors
                                    .primaries[index % Colors.primaries.length],
                                child: Text(user.displayName.isNotEmpty
                                    ? user.displayName[0]
                                    : '?'),
                              ),
                              title: Text(user.displayName),
                              subtitle: Text('${user.ipAddress}:${user.port}'),
                              trailing: const Icon(Icons.add_comment),
                              onTap: () async {
                                Navigator.of(context).pop();
                                await _addUserToChat(user);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
          footer: GenericDialogFooter(
            child: TextButton(
              style: TextButton.styleFrom(
                foregroundColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: Text(_loc.cancel),
            ),
          ),
          decorator: GenericDialogDecorator(
              width: DynamicDimension.flexibilityMax(90, 600),
              displayTopDivider: true)),
    );
  }

  // Get list of online users that can be added to chat
  Future<List<P2PUser>> _getOnlineUsers() async {
    final allUsers = widget.viewModel.discoveredUsers;
    final existingChats = await widget.viewModel.p2pChatService.loadAllChats();
    final existingUserIds = existingChats.map((chat) => chat.userBId).toSet();

    // Filter users that are online, paired, and not already in chat
    return allUsers.where((user) {
      return user.isOnline &&
          user.isPaired &&
          !existingUserIds.contains(user.id);
    }).toList();
  }

  // Add user to chat
  Future<void> _addUserToChat(P2PUser user) async {
    try {
      final chatService = widget.viewModel.p2pChatService;
      final currentUserId = widget.viewModel.currentUser?.id;

      if (currentUserId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Current user not available'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Check if chat already exists
      final existingChat = await chatService.findChatByUsers(user.id);
      if (existingChat != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Chat with this user already exists'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Add new chat
      await chatService.addChat(user.id);

      if (mounted) {
        setState(() {
          // Refresh the chat list
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Chat with ${user.displayName} added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding chat: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildChatDetails() {
    return _chat.isEmpty()
        // ? Center(child: Text(_loc.selectChatToViewDetails))
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.chat_outlined, size: 48, color: Colors.grey),
                const SizedBox(height: 16),
                Text(_loc.enterAChatToStart),
              ],
            ),
          )
        : P2LanChatDetailScreen(
            chat: _chat,
            viewModel: widget.viewModel,
          );
  }

  Widget _buildDesktopWidget() {
    return TwoPanelsLayout(panelInfos: [
      PanelInfo(
          title: _loc.chatList,
          content: _buildChatList(),
          flex: 1,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip:
                  ShortcutTooltipUtils.I.build(_loc.reload, 'Ctrl+Shift+R'),
              onPressed: () {
                // Handle refresh action
                widget.viewModel.p2pChatService.loadAllChats();
                setState(() {});
              },
            ),
          ]),
      PanelInfo(title: _loc.chatDetails, content: _buildChatDetails(), flex: 2)
    ]);
  }

  Widget _buildMobileWidget() {
    return Scaffold(
      body: Center(
        child: _buildChatList(),
      ),
    );
  }

  // Handle escape key and mouse back button
  void _handleEscape() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    isDesktop = !isMobileLayoutContext(context);
    return PopScope(
      canPop: _chat.isEmpty(), // Allow pop only when not in a chat
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && !_chat.isEmpty()) {
          // If pop was prevented and we're in a chat, exit the chat
          setState(() {
            _chat = P2PChat.empty();
          });
        }
      },
      child: KeyboardListener(
        focusNode: FocusNode(),
        autofocus: isDesktop,
        onKeyEvent: (event) {
          if (!isDesktop) return; // Only handle global shortcuts on desktop
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.escape) {
              _handleEscape();
              return;
            }
            // Ctrl+Shift+R: reload chat list
            if (HardwareKeyboard.instance.isControlPressed &&
                HardwareKeyboard.instance.isShiftPressed &&
                event.logicalKey == LogicalKeyboardKey.keyR) {
              widget.viewModel.p2pChatService.loadAllChats();
              setState(() {});
              return;
            }
            if (HardwareKeyboard.instance.isControlPressed) {
              int? index;
              if (event.logicalKey == LogicalKeyboardKey.digit1) {
                index = 0;
              } else if (event.logicalKey == LogicalKeyboardKey.digit2) {
                index = 1;
              } else if (event.logicalKey == LogicalKeyboardKey.digit3) {
                index = 2;
              } else if (event.logicalKey == LogicalKeyboardKey.digit4) {
                index = 3;
              } else if (event.logicalKey == LogicalKeyboardKey.digit5) {
                index = 4;
              } else if (event.logicalKey == LogicalKeyboardKey.digit6) {
                index = 5;
              } else if (event.logicalKey == LogicalKeyboardKey.digit7) {
                index = 6;
              } else if (event.logicalKey == LogicalKeyboardKey.digit8) {
                index = 7;
              } else if (event.logicalKey == LogicalKeyboardKey.digit9) {
                index = 8;
              }
              if (index != null && index < _latestChats.length) {
                _enterChat(_latestChats[index]);
              }
            }
          }
        },
        child: Listener(
          onPointerDown: (event) {
            // Handle mouse back button (button 8)
            if (event.buttons == 8) {
              _handleEscape();
            }
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text(_loc.chat),
              leading: IconButton(
                tooltip: _loc.back,
                icon: const Icon(Icons.arrow_back),
                onPressed: _handleEscape,
              ),
              actions: [
                if (Platform.isAndroid) ...[
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      // Handle refresh action
                      widget.viewModel.p2pChatService.loadAllChats();
                      setState(() {});
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.folder),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const P2LanLocalFilesScreen(),
                        ),
                      );
                    },
                    tooltip: _loc.localFiles,
                  ),
                  if (kDebugMode)
                    // DEBUG notification button (only on Android)
                    IconButton(
                      icon: const Icon(Icons.notification_add),
                      onPressed: () async {
                        await widget.viewModel.p2pChatService
                            .testNotification();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Test notification sent'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        }
                      },
                      tooltip: 'Test Notification',
                    ),
                ],
                const SizedBox(width: 8), // Add some spacing
              ],
            ),
            body: Center(
              child: isDesktop ? _buildDesktopWidget() : _buildMobileWidget(),
            ),
          ),
        ),
      ),
    );
  }
}

/// SECTION: Chat Detail Screen

class P2LanChatDetailScreen extends StatefulWidget {
  final P2PChat chat;
  final P2PViewModel viewModel;
  const P2LanChatDetailScreen(
      {super.key, required this.chat, required this.viewModel});

  @override
  State<P2LanChatDetailScreen> createState() => _P2LanChatDetailScreenState();
}

class _P2LanChatDetailScreenState extends State<P2LanChatDetailScreen>
    with ClipboardWatcherMixin {
  // Controllers for scroll and text input
  final _scrollController = ScrollController();
  final _textController = TextEditingController();
  final _textFocusNode = FocusNode();
  final FocusNode _shortcutFocusNode = FocusNode();
  late AppLocalizations _loc;

  // File picker state
  final List<PlatformFile> _selectedFiles = [];
  final List<PlatformFile> _selectedMedia = [];

  // State management for scroll position and visibility
  bool _isFocusNewest = true;
  bool _showScrollToBottom = false;
  final _flagPushClipboard = ValueNotifier<bool>(true);
  final _flagPopClipboard = ValueNotifier<bool>(true);

  List<P2PCMessage> _visibleMessages = [];
  int _currentPage = 0;
  static const int _pageSize = 30;
  bool _isLoadingMore = false;

  // Drag and drop state
  bool _isDragging = false;
  bool _isDragOverInput = false;
  bool _isDragHandled = false; // Flag to prevent double handling

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    _textController.dispose();
    _textFocusNode.dispose();
    _shortcutFocusNode.dispose();
    _removeClipboardListener();

    // Remove listener from P2PViewModel
    widget.viewModel.removeListener(_onControllerChanged);

    // Clear current visible chat for notification management
    widget.viewModel.p2pChatService.setCurrentVisibleChat(null);
  }

  @override
  void initState() {
    super.initState();
    // Initialize the clipboard listener
    _scrollController.addListener(_handleScroll);
    // Scroll to bottom on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initLoadMessages();
    });
    // Add listener to text controller to update UI on text change
    _textController.addListener(() {
      setState(() {});
    });
    // Set up clipboard listener if clipboard sharing is enabled
    if (widget.chat.clipboardSharing) {
      _setClipboardListener();
    }
    // Add listener to scroll controller to load more messages on scroll
    _scrollController.addListener(_handleLoadMoreScroll);

    // Add listener to P2PViewModel for status updates
    widget.viewModel.addListener(_onControllerChanged);

    // Set current visible chat for notification management
    widget.viewModel.p2pChatService
        .setCurrentVisibleChat(widget.chat.id.toString());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loc = AppLocalizations.of(context);
  }

  /// Handle P2PViewModel state changes to update UI
  void _onControllerChanged() {
    if (mounted) {
      setState(() {
        // This will trigger a rebuild to update online status and other UI elements
      });
    }
  }

  void _initLoadMessages() {
    final chatService = widget.viewModel.p2pChatService;
    final chatId = widget.chat.id.toString();
    final chat = chatService.chatIdExists(chatId)
        ? chatService.getChatById(chatId) ?? widget.chat
        : widget.chat;
    setState(() {
      _currentPage = 0;
      _visibleMessages = widget.viewModel.p2pChatService
          .getMessagesPage(chat, page: _currentPage, pageSize: _pageSize);
    });
    // Only scroll to bottom if there are messages and controller is attached
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_visibleMessages.isNotEmpty && _scrollController.hasClients) {
        _scrollToBottom(force: true);
      }
    });
  }

  // Media filters
  static const List<String> _imageExtensions = [
    'jpg',
    'jpeg',
    'png',
    'gif',
    'bmp',
    'webp',
  ];

  // Video extensions, but not available at the moment
  static const List<String> _videoExtensions = [
    'mp4',
    'mov',
    'avi',
    'mkv',
    'webm',
    'flv',
    'wmv',
    '3gp',
    'mpeg',
    'mpg'
  ];

  void _handleLoadMoreScroll() async {
    if (_scrollController.hasClients && !_isLoadingMore) {
      if (_scrollController.position.pixels <=
          _scrollController.position.minScrollExtent + 20) {
        setState(() {
          _isLoadingMore = true;
        });
        final start = DateTime.now();
        final moreMessages = await _loadMoreMessages();
        final elapsed = DateTime.now().difference(start);
        if (elapsed < const Duration(seconds: 1)) {
          await Future.delayed(const Duration(seconds: 1) - elapsed);
        }
        bool shouldScroll = false;
        setState(() {
          if (moreMessages != null && moreMessages.isNotEmpty) {
            _visibleMessages = [...moreMessages, ..._visibleMessages];
            _currentPage += 1;
            shouldScroll = true;
          }
          _isLoadingMore = false;
        });
        // print('>>>>>>>>>> visible messages: ${_visibleMessages.length}');
        // Chỉ scroll nếu vừa load thêm tin nhắn cũ
        if (shouldScroll) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              double offset = _scrollController.offset + 500;
              double maxOffset = _scrollController.position.maxScrollExtent;
              if (offset > maxOffset) offset = maxOffset;
              _scrollController.animateTo(
                offset,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });
        }
      }
    }
  }

  Future<List<P2PCMessage>?> _loadMoreMessages() async {
    final chatService = widget.viewModel.p2pChatService;
    final chatId = widget.chat.id.toString();
    final chat = chatService.chatIdExists(chatId)
        ? chatService.getChatById(chatId) ?? widget.chat
        : widget.chat;
    final nextPage = _currentPage + 1;
    final moreMessages = widget.viewModel.p2pChatService
        .getMessagesPage(chat, page: nextPage, pageSize: _pageSize);
    if (moreMessages.isEmpty) return null;
    return moreMessages;
  }

  Future<void> _handlePopClipboardAndSendMessage(
      ClipboardContent clipboard) async {
    // Set push flag to false to prevent multiple pushes
    _flagPushClipboard.value = false;
    // Handle clipboard content based on type
    String setSyncId = const Uuid().v4();
    if (clipboard.isText) {
      _textController.text = clipboard.asText;
      await _sendChatMessage(setSyncId: setSyncId);
    } else {
      final imageBytes = clipboard.asImage;
      String tempFileName =
          'clipboard_image_${DateTime.now().millisecondsSinceEpoch}.png';
      // Get p2lan directory
      final p2pLanDir = (await P2PSettingsAdapter.getSettings()).downloadPath;
      UriUtils.createImageFileFromUint8List(
          data: imageBytes, fileName: tempFileName, directory: p2pLanDir);
      // Get file path
      final filePath = p2pLanDir + Platform.pathSeparator + tempFileName;
      // Select media file
      setState(() {
        _selectedMedia.add(PlatformFile(
          path: filePath,
          name: tempFileName,
          size: imageBytes.length,
        ));
      });
      // Send message
      await _sendChatMessage(setSyncId: setSyncId);
      // Await for the message to be sent to the other user
      await Future.delayed(
          const Duration(seconds: p2pChatMediaWaitTimeBeforeDelete));
    }
    // Clear selected media if settings deleteAfterShare is true
    if (widget.chat.deleteAfterShare) {
      final message = await widget.viewModel.p2pChatService
          .getMessageBaseOnSyncId(chat: widget.chat, syncId: setSyncId);
      if (message != null) {
        await widget.viewModel.p2pChatService.removeMessageAndNotify(
            chat: widget.chat, message: message, deleteFileIfExist: true);
      } else {
        logError(
            'Message with syncId $setSyncId not found in chat ${widget.chat.id}');
      }
    }
    // Set push flag to true
    _flagPushClipboard.value = true;
  }

  @override
  onClipboardChanged(ClipboardChangeEvent event) async {
    if (_flagPopClipboard.value &&
        widget.viewModel.isUserOnline(widget.chat.userBId)) {
      final content = event.newContent;
      if (content.isText || content.isImage) {
        _handlePopClipboardAndSendMessage(content);
      }
    }
  }

  Future<void> _removeClipboardListener() async {
    logInfo('Removing clipboard listener');
    // Stop monitoring
    stopListeningClipboard();
  }

  Future<void> _setClipboardListener() async {
    logInfo('Setting clipboard listener');
    // Start monitoring clipboard changes
    startListeningClipboard(pollingInterval: const Duration(seconds: 3));
  }

  Future<void> _pushIntoClipboard(P2PCMessage msg) async {
    // Disable pop clipboard to prevent multiple copies
    _flagPopClipboard.value = false;
    // Process the message based on its type
    late bool copyResult;
    logDebug('Pushing message to clipboard: ${msg.content}');
    if (msg.type == P2PCMessageType.text) {
      // If the message is text, copy it directly
      FlutterClipboard.copy(msg.content);
      copyResult = true;
      logDebug('Text copied to clipboard: ${msg.content}');
    } else {
      // If the message is a file, check if the file exists, then copy its content
      await TaskQueueManager.runTaskAfterAndRepeatMax(
          delay: const Duration(seconds: 2),
          task: () async {
            // Update the message to ensure it has the latest syncId
            msg = widget.chat.messages
                    .filter()
                    .syncIdEqualTo(msg.syncId)
                    .findFirstSync() ??
                msg;
            // Check if the message has a valid file path
            if (msg.filePath != null && msg.filePath!.isNotEmpty) {
              final file = File(msg.filePath!);
              try {
                if (await file.exists()) {
                  final bytes = await file.readAsBytes();
                  await Pasteboard.writeImage(bytes);
                  logDebug('Image copied to clipboard successfully.');
                  copyResult = true;
                  return true;
                } else {
                  logError('File does not exist: ${msg.filePath}');
                  copyResult = false;
                  return false;
                }
              } catch (e) {
                logError('Error copying image to clipboard: $e');
                copyResult = false;
                return false;
              }
            } else {
              logError(
                  'Message does not have a valid file path: ${msg.filePath}');
              copyResult = false;
              return false;
            }
          },
          maxRepeats: 3);
    }
    // If deleteAfterCopy is true, remove the message after copying
    if (widget.chat.deleteAfterCopy && copyResult) {
      await widget.viewModel.p2pChatService.removeMessageAndNotify(
          chat: widget.chat, message: msg, deleteFileIfExist: false);
    }
    // Set the flag to true after copying
    TaskQueueManager.runTaskAfter(
        delay: const Duration(seconds: p2pChatClipboardPollingInterval),
        task: () async {
          _flagPopClipboard.value = true;
        });
  }

  Future<void> _handleClipboardPushed(P2PCMessage msg) async {
    if (widget.viewModel
            .isUserOnline(widget.chat.userBId) && // Other user must be online
        widget.chat
            .autoCopyIncomingMessages && // Chat must have auto copy enabled
        msg.isCopiable() && // Message must be copiable
        msg.senderId == widget.chat.userBId &&
        msg.sentAt.isAfter(// Only push if the message is recent
            DateTime.now().subtract(const Duration(seconds: 7)))) {
      if (_flagPushClipboard.value) {
        _pushIntoClipboard(msg);
      } else {
        TaskQueueManager().observeValueOnce<bool>(
            notifier: _flagPushClipboard,
            callback: (val) => _pushIntoClipboard(msg));
      }
    }
  }

  bool _isImageFile(PlatformFile file) {
    final ext = file.extension?.toLowerCase() ?? '';
    return _imageExtensions.contains(ext);
  }

  bool _isVideoFile(PlatformFile file) {
    final ext = file.extension?.toLowerCase() ?? '';
    return _videoExtensions.contains(ext);
  }

  // Drag and drop helper methods
  Future<void> _handleDroppedFiles(
      List<XFile> files, bool sendImmediately) async {
    if (files.isEmpty) return;

    final List<PlatformFile> imageFiles = [];
    final List<PlatformFile> otherFiles = [];

    // Categorize files: images first, then others
    for (final file in files) {
      final platformFile = PlatformFile(
        path: file.path,
        name: file.name,
        size: await file.length(),
      );

      if (_isImageFile(platformFile)) {
        imageFiles.add(platformFile);
      } else if (!_isVideoFile(platformFile)) {
        // Skip video files as not supported
        otherFiles.add(platformFile);
      }
    }

    // Add files to selection in priority order (images first, then files)
    setState(() {
      _selectedMedia.addAll(imageFiles);
      _selectedFiles.addAll(otherFiles);
    });

    // If sendImmediately is true and user is online, send the message right away
    if (sendImmediately) {
      final isOnline = widget.viewModel.isUserOnline(widget.chat.userBId);
      if (isOnline) {
        await _sendChatMessage();
      }
    }
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    // Check if the current scroll position is close to the bottom
    final isAtBottom = (maxScroll - currentScroll).abs() < 50;
    if (isAtBottom && !_isFocusNewest) {
      setState(() {
        _isFocusNewest = true;
        _showScrollToBottom = false;
      });
    } else if (!isAtBottom && _isFocusNewest) {
      setState(() {
        _isFocusNewest = false;
        _showScrollToBottom = true;
      });
    } else if (!isAtBottom && !_showScrollToBottom) {
      setState(() {
        _showScrollToBottom = true;
      });
    } else if (isAtBottom && _showScrollToBottom) {
      setState(() {
        _showScrollToBottom = false;
      });
    }
  }

  void _scrollToBottom({bool force = false}) {
    if (!_scrollController.hasClients) return;
    if (_visibleMessages.isEmpty && !force) return;
    logDebug('Scrolling to bottom');
    // Scroll to the last message (not extentTotal, which may be inaccurate if not rendered)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
        setState(() {
          _isFocusNewest = true;
          _showScrollToBottom = false;
        });
      } catch (e) {
        logError('Scroll to bottom error: $e');
      }
    });
  }

  Future<void> _sendChatMessage({String setSyncId = 'random'}) async {
    final text = _textController.text;
    final chat = widget.chat;
    final controller = widget.viewModel;
    final myId = chat.userAId;
    final peerId = chat.userBId;

    // Send media (images/videos) selected via Attach Media as media messages
    if (_selectedMedia.isNotEmpty) {
      for (final file in _selectedMedia) {
        P2PCMessage msg;
        if (_isImageFile(file)) {
          msg = P2PCMessage.createMediaImageMessage(
            senderId: myId,
            filePath: file.path ?? '',
            chat: chat,
            syncId: setSyncId,
          );
        } else if (_isVideoFile(file)) {
          msg = P2PCMessage.createMediaVideoMessage(
            senderId: myId,
            filePath: file.path ?? '',
            chat: chat,
            syncId: setSyncId,
          );
        } else {
          // Fallback to file message if not image/video
          msg = P2PCMessage.createFileMessage(
            senderId: myId,
            filePath: file.path ?? '',
            chat: chat,
            fileName: file.name,
            syncId: setSyncId,
          );
        }
        final peerUser = controller.getUserById(peerId);
        if (peerUser == null) continue;
        final messageData = P2PMessage(
            type: P2PMessageTypes.sendChatMessage,
            fromUserId: myId,
            toUserId: chat.userBId,
            data: msg.toJson());
        final sendResult = await controller.p2pService.networkService
            .sendMessageToUser(peerUser, messageData.toJson());
        if (sendResult) {
          logDebug('Sent media to peer and reset result');
          final chatService = widget.viewModel.p2pChatService;
          await chatService.addMessageAndNotify(
              msg, chat, P2PCMessageStatus.onDevice);
          await controller.p2pService.sendMultipleFiles(
              filePaths: [file.path ?? ''],
              targetUser: peerUser,
              transferOnly: false);
        }
      }
    }

    // Send files selected via Attach Files strictly as file messages
    if (_selectedFiles.isNotEmpty) {
      for (final file in _selectedFiles) {
        final msg = P2PCMessage.createFileMessage(
          senderId: myId,
          filePath: file.path ?? '',
          chat: chat,
          fileName: file.name,
          syncId: setSyncId,
        );
        final peerUser = controller.getUserById(peerId);
        if (peerUser == null) continue;
        final messageData = P2PMessage(
            type: P2PMessageTypes.sendChatMessage,
            fromUserId: myId,
            toUserId: chat.userBId,
            data: msg.toJson());
        final sendResult = await controller.p2pService.networkService
            .sendMessageToUser(peerUser, messageData.toJson());
        if (sendResult) {
          logDebug('Sent file to peer and reset result');
          final chatService = widget.viewModel.p2pChatService;
          await chatService.addMessageAndNotify(
              msg, chat, P2PCMessageStatus.onDevice);
          await controller.p2pService.sendMultipleFiles(
              filePaths: [file.path ?? ''],
              targetUser: peerUser,
              transferOnly: false);
        }
      }
    }

    if (_selectedFiles.isNotEmpty || _selectedMedia.isNotEmpty) {
      setState(() {
        _selectedFiles.clear();
        _selectedMedia.clear();
      });
    }

    // Gửi text nếu có
    if (text.trim().isNotEmpty) {
      // if (text.length > 2048) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(
      //       content: Text('Tin nhắn quá dài (tối đa 2048 ký tự)!'),
      //       backgroundColor: Colors.red,
      //     ),
      //   );
      //   return;
      // }
      final msg = P2PCMessage.createTextMessage(
          senderId: myId, content: text, chat: chat, syncId: setSyncId);
      _textController.clear();
      final peerUser = controller.getUserById(peerId);
      if (peerUser == null) return;
      final messageData = P2PMessage(
          type: P2PMessageTypes.sendChatMessage,
          fromUserId: myId,
          toUserId: chat.userBId,
          data: msg.toJson());
      final sendResult = await controller.p2pService.networkService
          .sendMessageToUser(peerUser, messageData.toJson());
      if (sendResult) {
        logDebug('Sent message to peer and reset result');
        final chatService = widget.viewModel.p2pChatService;
        await chatService.addMessageAndNotify(
            msg, chat, P2PCMessageStatus.onDevice);
        if (mounted) setState(() {});
      }
    }
  }

  Future<void> _showFileLostDialog(P2PCMessage msg) async {
    await showDialog(
      context: context,
      builder: (ctx) => GenericDialog(
        header: GenericDialogHeader(title: _loc.fileLostRequest),
        body: Text(_loc.fileLostRequestDesc),
        footer: GenericDialogFooter.twoCustomButtons(
          context: context,
          leftButton: TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(_loc.close),
          ),
          rightButton: TextButton(
            onPressed: () {
              _requestFile(msg.syncId);
              Navigator.of(ctx).pop();
            },
            child: Text(_loc.fileLostRequest),
          ),
        ),
        decorator: GenericDialogDecorator(
            width: DynamicDimension.flexibilityMax(90, 500),
            displayTopDivider: true),
      ),
    );
  }

  Future<void> _requestFile(String syncId) async {
    // Send a request to the peer to resend the file
    final peerUser = widget.viewModel.getUserById(widget.chat.userBId)!;

    final messageData = P2PMessage(
        type: P2PMessageTypes.chatRequestFileBackward,
        fromUserId: widget.chat.userAId,
        toUserId: widget.chat.userBId,
        data: {
          'syncId': syncId,
        });
    final sendResult = await widget.viewModel.p2pService.networkService
        .sendMessageToUser(peerUser, messageData.toJson());
    if (sendResult) {
      logDebug('Sent file request backward to peer and get result');
    }

    return Future.value();
  }

  Widget _buildMessageWidget(P2PCMessage msg, bool isMe) {
    switch (msg.type) {
      case P2PCMessageType.text:
        return _buildTextMessageWidget(msg, isMe);
      case P2PCMessageType.mediaImage:
      case P2PCMessageType.mediaVideo:
        return _buildMediaMessageWidget(msg, isMe);
      case P2PCMessageType.file:
        return _buildFileMessageWidget(msg, isMe);
    }
  }

  Future<void> _copyMessage(P2PCMessage msg) async {
    // Disable pop clipboard to prevent multiple copies
    _flagPopClipboard.value = false;
    // Process based on message type
    if (msg.type == P2PCMessageType.text) {
      FlutterClipboard.copy(msg.content);
    } else {
      if (msg.filePath != null && msg.filePath!.isNotEmpty) {
        final file = File(msg.filePath!);
        if (file.existsSync()) {
          // If the file exists, copy its content to clipboard
          Pasteboard.writeImage(await file.readAsBytes());
        } else {
          widget.viewModel.p2pChatService
              .updateMessageStatus(msg, widget.chat, P2PCMessageStatus.lost);
          // If the file does not exist, show an error
          SnackbarUtils.showTyped(context, _loc.fileLost, SnackBarType.error);
        }
      } else {
        widget.viewModel.p2pChatService
            .updateMessageStatus(msg, widget.chat, P2PCMessageStatus.lost);
        SnackbarUtils.showTyped(context, _loc.noPathToCopy, SnackBarType.error);
      }
    }
    // Re-enable pop clipboard after copying
    TaskQueueManager.runTaskAfter(
        delay: const Duration(seconds: p2pChatClipboardPollingInterval),
        task: () async => _flagPopClipboard.value = true);
  }

  void _showMessagesContextMenu(P2PCMessage msg, Offset? position) {
    final options = [
      if (msg.isCopiable() && msg.isNotLost())
        OptionItem(
            label: _loc.copy, icon: Icons.copy, onTap: () => _copyMessage(msg)),
      if (Platform.isAndroid && msg.containsFileAndNotLost()) ...[
        OptionItem(
            label: _loc.share,
            icon: Icons.share,
            onTap: () async => UriUtils.shareFile(msg.filePath!)),
        OptionItem(
          label: '${_loc.copyTo}...',
          icon: Icons.copy,
          onTap: () async => UriUtils.simpleExternalOperation(
              context: context, sourcePath: msg.filePath!, isMove: false),
        ),
      ],
      if (msg.containsFileAndNotLost() && Platform.isWindows)
        OptionItem(
            label: _loc.openInExplorer,
            icon: Icons.folder_open,
            onTap: () => UriUtils.openInFileExplorer(msg.filePath!)),
      OptionItem(
          label: _loc.deleteMessage,
          icon: Icons.delete,
          onTap: () {
            GenericDialogUtils.showSimpleGenericClearDialog(
              context: context,
              title: _loc.deleteMessage,
              description: _loc.deleteMessageDesc,
              onConfirm: () async {
                await widget.viewModel.p2pChatService.removeMessageAndNotify(
                    chat: widget.chat, message: msg, deleteFileIfExist: false);
                // Refresh the message list after deletion
                if (mounted) {
                  setState(() {
                    _initLoadMessages();
                  });
                }
              },
            );
          }),
      if (msg.containsFileAndNotLost())
        OptionItem(
            label: _loc.deleteMessageAndFile,
            icon: Icons.delete_forever,
            onTap: () {
              GenericDialogUtils.showSimpleGenericClearDialog(
                context: context,
                title: _loc.deleteMessageAndFile,
                description: _loc.deleteMessageAndFileDesc,
                onConfirm: () async {
                  await widget.viewModel.p2pChatService.removeMessageAndNotify(
                      chat: widget.chat, message: msg, deleteFileIfExist: true);
                  // Refresh the message list after deletion
                  if (mounted) {
                    setState(() {
                      _initLoadMessages();
                    });
                  }
                },
              );
            }),
      if (msg.containsFileAndNotLost())
        OptionItem(
          label: _loc.viewDetails,
          icon: Icons.info_rounded,
          onTap: () => UriUtils.showDetailDialog(
              context: context, filePath: msg.filePath!),
        ),
    ];
    GenericContextMenu.show(
        context: context,
        actions: options,
        position: position,
        topWidget: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(_loc.sendAt(LocalizationUtils.formatDateTime(
              context: context, dateTime: msg.sentAt))),
        ),
        onInit: () {
          // Only unfocus on desktop to prevent keyboard hiding on mobile
          if (!Platform.isAndroid && !Platform.isIOS) {
            _textFocusNode.unfocus();
          }
        },
        desktopDialogWidth: 240);
  }

  Widget _buildTextMessageWidget(P2PCMessage msg, bool isMe) {
    final theme = Theme.of(context);
    final faded = msg.status == P2PCMessageStatus.waiting;
    final content = msg.content.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    final urlRegex = RegExp(r'(https?:\/\/[^\s]+)');
    final urls = urlRegex
        .allMatches(content)
        .map((m) => m.group(0))
        .whereType<String>()
        .toList();

    // Professional color scheme based on theme
    final backgroundColor = isMe
        ? theme.colorScheme.primary.withValues(alpha: .1)
        : theme.colorScheme.surfaceContainerHighest;
    final textColor = isMe
        ? theme.colorScheme.onPrimaryContainer
        : theme.colorScheme.onSurfaceVariant;
    final borderColor = isMe
        ? theme.colorScheme.primary.withValues(alpha: 0.3)
        : theme.colorScheme.outline.withValues(alpha: 0.3);

    return GestureDetector(
      onLongPressStart: (detail) =>
          _showMessagesContextMenu(msg, detail.globalPosition),
      onSecondaryTapDown: (detail) =>
          _showMessagesContextMenu(msg, detail.globalPosition),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Align(
            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
                minWidth: 80,
              ),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: Radius.circular(isMe ? 18 : 4),
                    bottomRight: Radius.circular(isMe ? 4 : 18),
                  ),
                  border: Border.all(
                    color: borderColor,
                    width: 0.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.shadowColor.withValues(alpha: 0.1),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Opacity(
                  opacity: faded ? 0.6 : 1.0,
                  child: MarkdownBody(
                    data: content,
                    styleSheet: MarkdownStyleSheet(
                      p: TextStyle(
                        color: textColor,
                        fontSize: 15,
                        height: 1.4,
                      ),
                      code: TextStyle(
                        color: textColor,
                        backgroundColor:
                            theme.colorScheme.surface.withValues(alpha: .5),
                        fontSize: 14,
                      ),
                      codeblockDecoration: BoxDecoration(
                        color: theme.colorScheme.surface.withValues(alpha: .5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    softLineBreak: true,
                  ),
                ),
              ),
            ),
          ),
          if (urls.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 16, right: 16),
              child: Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: urls
                    .map((url) => MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () {
                              UriUtils.launchInBrowser(url, context);
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 2),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: theme.colorScheme.primary
                                      .withValues(alpha: .3),
                                  width: 0.5,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.link,
                                    color: theme.colorScheme.primary,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      url,
                                      style: TextStyle(
                                        color: theme.colorScheme.primary,
                                        decoration: TextDecoration.underline,
                                        fontSize: 14,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
          // Timestamp (subtle)
          if (!faded)
            Padding(
              padding: EdgeInsets.only(
                top: 2,
                left: isMe ? 0 : 16,
                right: isMe ? 16 : 0,
              ),
              child: Text(
                _formatMessageTime(msg.sentAt),
                style: TextStyle(
                  color:
                      theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                  fontSize: 11,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatMessageTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${dateTime.day}/${dateTime.month} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  Widget _buildMediaMessageWidget(P2PCMessage msg, bool isMe) {
    final theme = Theme.of(context);
    P2PCMessageStatus status = msg.status;
    bool fileExists = true;
    if (msg.status == P2PCMessageStatus.lost ||
        msg.status == P2PCMessageStatus.lostBoth) {
      fileExists = false;
    } else if (msg.status == P2PCMessageStatus.onDevice) {
      fileExists =
          msg.filePath == null ? false : File(msg.filePath!).existsSync();
      if (!fileExists) {
        status = P2PCMessageStatus.lost;
        widget.viewModel.p2pChatService
            .updateMessageStatus(msg, widget.chat, status);
      }
    }

    final backgroundColor = isMe
        ? theme.colorScheme.primary.withValues(alpha: .1)
        : theme.colorScheme.surfaceContainerHighest;
    final borderColor = isMe
        ? theme.colorScheme.primary.withValues(alpha: .3)
        : theme.colorScheme.outline.withValues(alpha: .3);

    if (!fileExists) {
      return GestureDetector(
        onLongPressStart: (details) =>
            _showMessagesContextMenu(msg, details.globalPosition),
        onSecondaryTapDown: (details) =>
            _showMessagesContextMenu(msg, details.globalPosition),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Align(
              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isMe ? 18 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 18),
                    ),
                    border: Border.all(
                      color: theme.colorScheme.error.withValues(alpha: 0.3),
                      width: 0.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.shadowColor.withValues(alpha: 0.1),
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: Icon(
                        msg.type == P2PCMessageType.mediaImage
                            ? Icons.image
                            : Icons.video_call,
                        color: theme.colorScheme.error),
                    title: Text(
                      msg.content,
                      style: TextStyle(
                        color: theme.colorScheme.onErrorContainer,
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    onTap: () async {
                      if (status == P2PCMessageStatus.lost) {
                        _showFileLostDialog(msg);
                      }
                    },
                    subtitle: Text(
                      status == P2PCMessageStatus.lost
                          ? _loc.fileLost
                          : _loc.fileLostOnBothSides,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.error,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    visualDensity: VisualDensity.compact,
                    minVerticalPadding: 0,
                    dense: true,
                  ),
                ),
              ),
            ),
            // Timestamp
            Padding(
              padding: EdgeInsets.only(
                top: 2,
                left: isMe ? 0 : 16,
                right: isMe ? 16 : 0,
              ),
              child: Text(
                _formatMessageTime(msg.sentAt),
                style: TextStyle(
                  color:
                      theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onLongPressStart: (details) =>
          _showMessagesContextMenu(msg, details.globalPosition),
      onSecondaryTapDown: (details) =>
          _showMessagesContextMenu(msg, details.globalPosition),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Align(
            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isMe ? 18 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 18),
                ),
                border: Border.all(
                  color: borderColor,
                  width: 0.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withValues(alpha: 0.1),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(17.5),
                  topRight: const Radius.circular(17.5),
                  bottomLeft: Radius.circular(isMe ? 17.5 : 3.5),
                  bottomRight: Radius.circular(isMe ? 3.5 : 17.5),
                ),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      if (msg.type == P2PCMessageType.mediaImage) {
                        // Open image in full screen
                        MediaUtils.openImageInFullscreen(
                          context: context,
                          filePath: msg.filePath!,
                        );
                      }
                    },
                    child: msg.type == P2PCMessageType.mediaImage
                        ? Image.file(
                            File(msg.filePath!),
                            width: 200,
                            height: 200,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            width: 200,
                            height: 200,
                            color: theme.colorScheme.surface,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.play_circle_outline,
                                  size: 48,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Video',
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurface,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  'Not supported yet',
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.7),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
          // Timestamp
          Padding(
            padding: EdgeInsets.only(
              top: 2,
              left: isMe ? 0 : 16,
              right: isMe ? 16 : 0,
            ),
            child: Text(
              _formatMessageTime(msg.sentAt),
              style: TextStyle(
                color:
                    theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileMessageWidget(P2PCMessage msg, bool isMe) {
    final theme = Theme.of(context);
    P2PCMessageStatus status = msg.status;
    bool fileExists = true;
    if (msg.status == P2PCMessageStatus.lost ||
        msg.status == P2PCMessageStatus.lostBoth) {
      fileExists = false;
    } else if (msg.status == P2PCMessageStatus.onDevice) {
      fileExists =
          msg.filePath == null ? false : File(msg.filePath!).existsSync();
      if (!fileExists) {
        status = P2PCMessageStatus.lost;
        widget.viewModel.p2pChatService
            .updateMessageStatus(msg, widget.chat, status);
      }
    }
    final fileSize = fileExists ? File(msg.filePath!).lengthSync() : 0;
    final icon = fileExists ? Icons.insert_drive_file : Icons.error;

    final backgroundColor = fileExists
        ? (isMe
            ? theme.colorScheme.primary.withValues(alpha: 0.1)
            : theme.colorScheme.surfaceContainerHighest)
        : theme.colorScheme.errorContainer;

    final borderColor = fileExists
        ? (isMe
            ? theme.colorScheme.primary.withValues(alpha: 0.3)
            : theme.colorScheme.outline.withValues(alpha: 0.3))
        : theme.colorScheme.error.withValues(alpha: 0.3);

    final iconColor =
        fileExists ? theme.colorScheme.primary : theme.colorScheme.error;

    final textColor = fileExists
        ? (isMe
            ? theme.colorScheme.onPrimaryContainer
            : theme.colorScheme.onSurfaceVariant)
        : theme.colorScheme.onErrorContainer;

    return GestureDetector(
      onLongPressStart: (details) =>
          _showMessagesContextMenu(msg, details.globalPosition),
      onSecondaryTapDown: (details) =>
          _showMessagesContextMenu(msg, details.globalPosition),
      onTap: () async {
        if (msg.status == P2PCMessageStatus.lost) {
          await _showFileLostDialog(msg);
        } else if (fileExists &&
            msg.filePath != null &&
            msg.filePath!.isNotEmpty) {
          // Mở file bằng app hệ điều hành
          try {
            await UriUtils.openFile(filePath: msg.filePath!, context: context);
          } catch (e) {
            if (mounted) {
              await showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(_loc.errorOpeningFile),
                  content: Text(_loc.errorOpeningFileDetails(e.toString())),
                  actions: [
                    TextButton(
                      onPressed: () {
                        widget.viewModel.p2pChatService.updateMessageStatus(
                            msg, widget.chat, P2PCMessageStatus.lost);
                        Navigator.of(ctx).pop();
                      },
                      child: Text(_loc.close),
                    ),
                  ],
                ),
              );
            }
          }
        }
      },
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Align(
            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
                minWidth: 200,
              ),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: Radius.circular(isMe ? 18 : 4),
                    bottomRight: Radius.circular(isMe ? 4 : 18),
                  ),
                  border: Border.all(
                    color: borderColor,
                    width: 0.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.shadowColor.withValues(alpha: 0.1),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: iconColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          icon,
                          color: iconColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              msg.content,
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              status == P2PCMessageStatus.onDevice
                                  ? '${(fileSize / 1024).toStringAsFixed(1)} KB'
                                  : (status == P2PCMessageStatus.lost
                                      ? _loc.fileLost
                                      : _loc.fileLostOnBothSides),
                              style: TextStyle(
                                fontSize: 12,
                                color: fileExists
                                    ? textColor.withValues(alpha: 0.7)
                                    : theme.colorScheme.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (fileExists)
                        Icon(
                          Icons.chevron_right,
                          color: iconColor.withValues(alpha: .5),
                          size: 20,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Timestamp
          Padding(
            padding: EdgeInsets.only(
              top: 2,
              left: isMe ? 0 : 16,
              right: isMe ? 16 : 0,
            ),
            child: Text(
              _formatMessageTime(msg.sentAt),
              style: TextStyle(
                color:
                    theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconButton _buildFilePickerButton(bool isEnable, AppLocalizations loc) {
    return IconButton(
      icon: const Icon(Icons.attach_file),
      tooltip: ShortcutTooltipUtils.I.build(_loc.attachFile, 'Ctrl+,'),
      onPressed: isEnable
          ? () async {
              await _pickFiles();
            }
          : null,
    );
  }

  IconButton _buildMediaPickerButton(bool isEnable, AppLocalizations loc) {
    return IconButton(
      icon: const Icon(Icons.photo),
      tooltip: ShortcutTooltipUtils.I.build(_loc.attachMedia, 'Ctrl+.'),
      onPressed: isEnable
          ? () async {
              await _pickMedia();
            }
          : null,
    );
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedFiles
            .addAll(result.files.where((f) => !_selectedFiles.contains(f)));
      });
    }
  }

  Future<void> _pickMedia() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: [
        ..._imageExtensions,
        // TODO: Support video files in the future
        // ..._videoExtensions
      ],
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedMedia
            .addAll(result.files.where((f) => !_selectedMedia.contains(f)));
      });
    }
  }

  Widget _buildPreviewBar(AppLocalizations loc) {
    if (_selectedFiles.isEmpty && _selectedMedia.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_selectedFiles.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _buildFilePickerButton(true, loc),
                ..._selectedFiles.map((file) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.insert_drive_file,
                              color: Colors.white, size: 18),
                          const SizedBox(width: 4),
                          SizedBox(
                            width: 120,
                            child: Text(
                              file.name,
                              style: const TextStyle(color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedFiles.remove(file);
                                });
                              },
                              child: const Icon(Icons.close,
                                  color: Colors.white, size: 16),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          if (_selectedMedia.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _buildMediaPickerButton(true, loc),
                ..._selectedMedia.map((file) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _isImageFile(file)
                              ? const Icon(Icons.image,
                                  color: Colors.white, size: 18)
                              : const Icon(Icons.videocam,
                                  color: Colors.white, size: 18),
                          const SizedBox(width: 4),
                          SizedBox(
                            width: 80,
                            child: Text(
                              file.name,
                              style: const TextStyle(color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          if (_isImageFile(file) && file.path != null)
                            Container(
                              width: 32,
                              height: 32,
                              margin: const EdgeInsets.only(right: 4),
                              child: Image.file(
                                File(file.path!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          if (_isVideoFile(file) && file.path != null)
                            Container(
                              width: 32,
                              height: 32,
                              margin: const EdgeInsets.only(right: 4),
                              child: const Center(
                                child: Icon(Icons.play_arrow,
                                    color: Colors.white, size: 20),
                              ),
                            ),
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedMedia.remove(file);
                                });
                              },
                              child: const Icon(Icons.close,
                                  color: Colors.white, size: 16),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ]
        ],
      ),
    );
  }

  Future<void> _saveSettings(P2PChat updatedChat) async {
    // Process background tasks
    if (updatedChat.clipboardSharing != widget.chat.clipboardSharing) {
      if (updatedChat.clipboardSharing) {
        // If clipboard sharing is enabled, set listener
        await _setClipboardListener();
      } else {
        // If clipboard sharing is disabled, remove listener
        await _removeClipboardListener();
      }
    }
    // Cập nhật đoạn chat
    widget.viewModel.p2pChatService
        .updateChatSettings(widget.chat, updatedChat);
    // Refresh current chat
    if (mounted) {
      setState(() {});
    }
    // Hiện thông báo thành công
    if (mounted) {
      SnackbarUtils.showTyped(
        context,
        _loc.chatCustomizationSaved,
        SnackBarType.info,
      );
    }
  }

  Future<void> _navigateToChatSettings() async {
    GenericSettingsHelper.showSettings(
        context,
        GenericSettingsConfig<P2PChat>(
            title: _loc.chatCustomization,
            settingsLayout: Padding(
              padding: const EdgeInsets.all(16),
              child: P2PChatSettingsLayout(
                chat: widget.chat,
                onSave: _saveSettings,
              ),
            ),
            onSettingsChanged: _saveSettings));
  }

  void _checkAndUpdateVisibleMessages(P2PChat chat) {
    bool needUpdate = false;
    for (var msg in _visibleMessages) {
      final updatedMsg =
          chat.messages.filter().idEqualTo(msg.id).findFirstSync();
      if (updatedMsg != null && updatedMsg.filePath != msg.filePath) {
        needUpdate = true;
        break;
      }
    }
    if (needUpdate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _visibleMessages = widget.viewModel.p2pChatService
                .getMessagesPage(chat, page: _currentPage, pageSize: _pageSize);
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatService = widget.viewModel.p2pChatService;
    final chatId = widget.chat.id.toString();
    final loc = AppLocalizations.of(context);

    return AnimatedBuilder(
      animation: chatService,
      builder: (context, _) {
        // Always get latest chat instance from service
        final chat = chatService.chatIdExists(chatId)
            ? chatService.getChatById(chatId) ?? widget.chat
            : widget.chat;
        _checkAndUpdateVisibleMessages(chat);

        final allMessages = chat.messages.toList();
        final isOnline = widget.viewModel.isUserOnline(chat.userBId);
        final myId = chat.userAId;
        // Get all messages for the chat
        // final allMessages = chat.messages.toList();
        if (_visibleMessages.isEmpty ||
            (allMessages.isNotEmpty &&
                _visibleMessages.isNotEmpty &&
                allMessages.last.id != _visibleMessages.last.id)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _initLoadMessages();
          });
          if (allMessages.isNotEmpty) {
            _handleClipboardPushed(allMessages.last);
          }
        }
        final isDesktop = MediaQuery.of(context).size.width > 800;

        final isDesktopShortcuts = !isMobileLayoutContext(context);
        final scaffold = Scaffold(
          appBar: AppBar(
            // Hide back button on desktop
            automaticallyImplyLeading: !isDesktop,
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    chat.displayName,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 12),
                CircleAvatar(
                  radius: 10,
                  backgroundColor: isOnline ? Colors.green : Colors.grey,
                ),
              ],
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(
                color: Theme.of(context).dividerColor,
                height: 1,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: ShortcutTooltipUtils.I.build(_loc.reload, 'Ctrl+R'),
                onPressed: () {
                  _initLoadMessages();
                  if (mounted) setState(() {});
                },
              ),
              IconButton(
                icon: const Icon(Icons.settings_applications),
                tooltip: ShortcutTooltipUtils.I
                    .build(_loc.chatCustomization, 'Ctrl+O'),
                onPressed: _navigateToChatSettings,
              ),
            ],
          ),
          body: DropTarget(
            onDragDone: (details) async {
              if (!_isDragHandled) {
                _isDragHandled = true;
                await _handleDroppedFiles(details.files,
                    false); // Only add to selection when dropped on chat area
                // Reset flag after a short delay
                Future.delayed(const Duration(milliseconds: 100), () {
                  _isDragHandled = false;
                });
              }
            },
            onDragEntered: (details) {
              setState(() {
                _isDragging = true;
                _isDragOverInput = false;
              });
            },
            onDragExited: (details) {
              setState(() {
                _isDragging = false;
                _isDragOverInput = false;
              });
            },
            child: Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          ListView.builder(
                            controller: _scrollController,
                            reverse: false,
                            padding: const EdgeInsets.all(16),
                            itemCount: _visibleMessages.length,
                            itemBuilder: (context, i) {
                              final msg = _visibleMessages[i];
                              final isMe = msg.senderId == myId;
                              return _buildMessageWidget(msg, isMe);
                            },
                          ),
                          if (_isLoadingMore)
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                color: Colors.white.withValues(alpha: .8),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Center(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        _loc.loadingOldMessages,
                                        style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black87),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    DropTarget(
                      onDragDone: (details) async {
                        if (!_isDragHandled) {
                          _isDragHandled = true;
                          await _handleDroppedFiles(details.files,
                              true); // Send immediately when dropped on input area
                          // Reset flag after a short delay
                          Future.delayed(const Duration(milliseconds: 100), () {
                            _isDragHandled = false;
                          });
                        }
                      },
                      onDragEntered: (details) {
                        setState(() {
                          _isDragOverInput = true;
                        });
                      },
                      onDragExited: (details) {
                        setState(() {
                          _isDragOverInput = false;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _isDragOverInput
                              ? Theme.of(context)
                                  .primaryColor
                                  .withValues(alpha: 0.1)
                              : Theme.of(context).colorScheme.onSecondary,
                          border: _isDragOverInput
                              ? Border.all(
                                  color: Theme.of(context).primaryColor,
                                  width: 2)
                              : null,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildPreviewBar(loc),
                            Row(
                              children: [
                                Expanded(
                                  child: KeyboardListener(
                                    focusNode: FocusNode(),
                                    onKeyEvent: (event) async {
                                      // Check for Ctrl+Enter combination (desktop only)
                                      if (!isDesktop) return;
                                      if (isOnline &&
                                          event is KeyDownEvent &&
                                          HardwareKeyboard
                                              .instance.isControlPressed &&
                                          event.logicalKey ==
                                              LogicalKeyboardKey.enter) {
                                        await _sendChatMessage();
                                        _textController.clear();
                                      }
                                    },
                                    child: TextField(
                                      controller: _textController,
                                      focusNode: _textFocusNode,
                                      enabled: isOnline,
                                      maxLength: 2048,
                                      maxLines: null,
                                      keyboardType: TextInputType.multiline,
                                      textInputAction: TextInputAction.newline,
                                      onSubmitted: isOnline
                                          ? (text) async {
                                              // Send on Enter (mobile) or when enabled
                                              if (text.trim().isNotEmpty) {
                                                await _sendChatMessage();
                                              }
                                            }
                                          : null,
                                      decoration: InputDecoration(
                                        fillColor: Theme.of(context)
                                            .colorScheme
                                            .surface,
                                        counterText: '',
                                        hintText: isOnline
                                            ? loc.sendMessage
                                            : "User is offline",
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(24),
                                          borderSide: BorderSide.none,
                                        ),
                                        filled: true,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                if (_selectedFiles.isEmpty)
                                  _buildFilePickerButton(isOnline, loc),
                                if (_selectedMedia.isEmpty)
                                  _buildMediaPickerButton(isOnline, loc),
                                if (_textController.text.isNotEmpty ||
                                    _selectedFiles.isNotEmpty ||
                                    _selectedMedia.isNotEmpty)
                                  IconButton(
                                    icon: const Icon(Icons.send),
                                    tooltip: ShortcutTooltipUtils.I
                                        .build(_loc.sendMessage, 'Ctrl+Enter'),
                                    onPressed:
                                        isOnline ? _sendChatMessage : null,
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                if (_showScrollToBottom)
                  Positioned(
                    bottom: 70,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          shape: const StadiumBorder(),
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 8),
                        ),
                        icon: const Icon(Icons.arrow_downward),
                        label: Text(_loc.scrollToBottom),
                        onPressed: _scrollToBottom,
                      ),
                    ),
                  ),
                // Drag and drop overlay
                if (_isDragging)
                  Positioned.fill(
                    child: Container(
                      color:
                          Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Theme.of(context).primaryColor,
                              width: 2,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.upload_file,
                                size: 48,
                                color: Theme.of(context).primaryColor,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _isDragOverInput
                                    ? 'Drop files here to send immediately'
                                    : 'Drop files here to add to selection',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: Theme.of(context).primaryColor,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
        if (isDesktopShortcuts) {
          return KeyboardListener(
            focusNode: _shortcutFocusNode,
            autofocus: true,
            onKeyEvent: (event) async {
              if (event is! KeyDownEvent) return;
              // Back/Escape: exit chat
              if (event.logicalKey == LogicalKeyboardKey.escape) {
                if (Navigator.canPop(context)) Navigator.pop(context);
                return;
              }
              if (HardwareKeyboard.instance.isControlPressed) {
                // Ctrl+I: focus input
                if (event.logicalKey == LogicalKeyboardKey.keyI) {
                  _textFocusNode.requestFocus();
                  return;
                }
                // Ctrl+, choose files
                if (event.logicalKey == LogicalKeyboardKey.comma) {
                  await _pickFiles();
                  return;
                }
                // Ctrl+. choose media
                if (event.logicalKey == LogicalKeyboardKey.period) {
                  await _pickMedia();
                  return;
                }
                // Ctrl+R: reload messages
                if (event.logicalKey == LogicalKeyboardKey.keyR) {
                  _initLoadMessages();
                  if (mounted) setState(() {});
                  return;
                }
                // Ctrl+O: open chat customization
                if (event.logicalKey == LogicalKeyboardKey.keyO) {
                  _navigateToChatSettings();
                  return;
                }
              }
            },
            child: Listener(
              onPointerDown: (evt) {
                if (evt.buttons == 8) {
                  if (Navigator.canPop(context)) Navigator.pop(context);
                }
              },
              child: scaffold,
            ),
          );
        }
        return scaffold;
      },
    );
  }
}
