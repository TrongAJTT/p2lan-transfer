# About P2Lan Transfer
Fast and secure data transfer over LAN between devices on the same WiFi network, supporting file and folder sending/receiving, direct chat messaging and various security options with optimized performance.

## [lan, blue] Key Features
- [icon:devices] Multi-device Connection: Automatically detects and connects devices on the same LAN.
- [icon:send] Send & Receive Files/Folders: Supports sending multiple files or entire folders at high speed.
- [icon:chat] Direct Chat: Send text messages, images and files via chat with other devices.
- [icon:content_copy] Clipboard Sync: Automatically share clipboard content between devices.
- [icon:security] Encryption Options: Protects data with various encryption modes (None, AES-GCM, ChaCha20-Poly1305).
- [icon:settings] Customizable Settings: Diverse options for save location, size limits, transfer streams, protocols, UI appearance, etc.
- [icon:history] History & Batch Management: Tracks progress, manages file transfer batches, easily deletes or clears cache.
- [icon:notifications] Smart Notifications: Receives notifications for pairing requests, file reception, messages or data transfer completion.

## [play_circle, green] Quick Start Guide
1. Start: Open the P2Lan Data Transfer function on both devices on the same WiFi network.
2. Grant Permissions: Ensure memory, network, and notification access permissions are granted (if required).
3. Network Discovery: The device will automatically scan and display available devices in the "Devices" tab.
4. Pair: Select the device you want to connect to, tap the 3-dot menu and choose "Pair" to pair devices.
5. Send Files: After successful pairing, select files/folders in the "Send" tab to send.
6. Chat & Messaging: Use the "Chat" tab to send text messages, share images and sync clipboard content.
7. Monitor Progress: Monitor file transfer progress in the "Transfers" tab. You can cancel, delete, or open files after transfer completion.

## [settings, indigo] Explanation of Important Settings

[#:indigo] User Interface
- [icon:palette] Theme: Choose light, dark or system theme appearance.
- [icon:language] Language: Switch between English and Vietnamese.
- [icon:phone_android] Compact Layout (Mobile): Hide icons on navigation bar to save screen space.

[#:green] General P2P Settings
- [icon:person] Display Name: Set device name for easy identification when pairing.
- [icon:notifications] Notifications: Enable/disable notifications for pairing requests and file transfers.

[#:orange] Download Location & Size Limits
- [icon:folder] Download Folder: Select the folder to save received files.
- [icon:category] File Organization: By date, by sender, or unorganized.
- [icon:cloud_upload] File Size Limit: Maximum size for each received file (10MB - 50GB).
- [icon:cloud_download] Total Size Limit: Total received size in a batch (100MB - 100GB).

[#:purple] Network & Speed
- [icon:bolt] Chunk Size: Size of data packets transferred (increase to optimize speed on strong networks).
- [icon:layers] Concurrent Tasks: Number of parallel transfer streams (increase to transfer multiple files simultaneously).
- [icon:network_wifi] Send Protocol: Select the transfer protocol (TCP/UDP).

[#:red] Advanced Security & Encryption
- [icon:lock] Encryption Type: None, AES-GCM and Chacha20-Poly1305
  - None: No encryption (fastest transfer)
  - AES-GCM: Strong encryption, best for high-end devices
  - ChaCha20-Poly1305: Optimized for mobile devices
- [icon:compress] Data Compression: Reduce transfer time by compressing files.

## [chat, teal] Chat & Clipboard Features

[#:teal] Basic Chat
- [icon:message] Text Messaging: Send text messages directly between devices.
- [icon:image] Media Sharing: Send images and videos through chat with preview.
- [icon:attach_file] File Sharing: Attach and send any files through chat.
- [icon:timer] Time Management: Display send time for all messages.

[#:blue] Chat Customization
- [icon:person] Chat Display Name: Set custom name for each chat conversation.
- [icon:schedule] Message Retention: Choose automatic message deletion time (7-365 days).
- [icon:content_copy] Synchronize Clipboard: Automatically copy text/image messages to clipboard.
- [icon:delete] Delete After Copy: Automatically delete messages after copying.
- [icon:share] Clipboard Sharing: Automatically send new clipboard content as messages.
- [icon:delete_forever] Delete After Share: Automatically delete messages after sharing from clipboard.

## [build, purple] Usage Tips & Optimization
- Use an easy-to-remember device name for quick identification when pairing.
- Use ChaCha20-Poly1305 encryption for mobile devices or AES-GCM for powerful computers.
- Enable compact layout on mobile to save screen space.
- Use chat features for quick communication instead of sending small files.
- Enable clipboard sync when frequently sharing text/images.
- Increase chunk size and number of streams on a strong local network for maximum speed.
- Use the "Clear Cache" feature to free up memory when needed.
- Enable notifications to avoid missing important file reception requests or messages.
- You can send multiple files/folders at once by selecting a send batch.

## [security, orange] Security Notes
- Only pair and transfer files with trusted devices on the same LAN.
- Carefully check device information before confirming file reception.
- Do not share your WiFi network with strangers when using this function.
- Use encryption to protect personal data.

## [help_outline, teal] Common Troubleshooting
[#] Cannot see other devices: Check WiFi connection, network permissions, disable VPN/network blocking.
[#] Cannot send/receive files: Check memory access permissions, available storage, or try restarting the application.
[#] Pairing error: Ensure both devices have the P2Lan function open and are on the same network.
[#] Chat not working: Check network connection and ensure target device is online.
[#] Clipboard not syncing: Check clipboard access permissions and ensure app is running in foreground.
[#] Slow transfer speed: Try reducing chunk size, disable encryption, or check WiFi network quality.

## [info_outline, red] Important Notes
- This function only works within the same LAN/WiFi network, not over the Internet.
- Transfer speed depends on the quality of the local network and device configuration.
- Clipboard sharing features only work when the app is running in foreground.
- Encryption will reduce transfer speed but increase security.
- Avoid transferring very large files on devices with weak configurations or unstable networks.
- Chat history is stored locally and automatically deleted according to time settings.

## [keyboard, cyan] Keyboard Shortcuts
Quickly access commonly used functions with keyboard shortcuts for enhanced productivity.
[#:cyan] Main Screen
- [icon:keyboard] Ctrl+1: Open Chat screen
- [icon:keyboard] Ctrl+2: Open Local Files (Android only)
- [icon:keyboard] Ctrl+3: Show Pairing Requests (when available)
- [icon:keyboard] Ctrl+4: Open Transfer Settings
- [icon:keyboard] Ctrl+5: Show Help documentation
- [icon:keyboard] Ctrl+6: Show About information
- [icon:keyboard] Ctrl+O: Start/Stop Networking
- [icon:keyboard] Ctrl+R: Manual Device Discovery (when networking is active)
- [icon:keyboard] Ctrl+Del: Clear All Transfers (when transfers exist)
[#:yellow] Chat Screen
- [icon:keyboard] Ctrl+Shift+R: Reload all chats
- [icon:keyboard] Ctrl+R: Reload the current chat
- [icon:keyboard] Ctrl+O: Customize the current chat
- [icon:keyboard] Ctrl+I: Start composing a text message
- [icon:keyboard] Ctrl+,: Select a media file in the chat
- [icon:keyboard] Ctrl+.: Select a file in the chat
- [icon:keyboard] Ctrl+Enter: Send message
[#:blue] Settings, Chat, and some dialogs
- [icon:keyboard] Esc: Exit and return to the previous screen
- [icon:keyboard] Ctrl+1...Ctrl+9: Select the corresponding chat or settings section