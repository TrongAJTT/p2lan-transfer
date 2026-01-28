# Về P2Lan Transfer
Chuyển dữ liệu nhanh chóng, an toàn qua mạng LAN giữa các thiết bị trong cùng mạng WiFi, hỗ trợ gửi/nhận file, thư mục, chat với nhau và nhiều tuỳ chọn bảo mật, tối ưu hoá hiệu suất.

## [lan, blue] Tính năng nổi bật
- [icon:devices] Kết nối nhiều thiết bị: Tự động phát hiện và kết nối các thiết bị trong cùng mạng LAN.
- [icon:send] Gửi & nhận file/thư mục: Hỗ trợ gửi nhiều file hoặc cả thư mục với tốc độ cao.
- [icon:chat] Chat trực tiếp: Nhắn tin văn bản, gửi hình ảnh và file qua chat với thiết bị khác.
- [icon:content_copy] Đồng bộ clipboard: Tự động chia sẻ nội dung clipboard giữa các thiết bị.
- [icon:security] Tuỳ chọn mã hoá: Bảo vệ dữ liệu với nhiều chế độ mã hoá (None, AES-GCM, ChaCha20-Poly1305).
- [icon:settings] Tuỳ chỉnh cài đặt: Đa dạng tuỳ chọn về vị trí lưu, giới hạn dung lượng, số luồng truyền, giao thức, giao diện, v.v.
- [icon:history] Quản lý lịch sử & batch: Theo dõi tiến trình, quản lý các batch truyền file, xoá hoặc làm sạch cache dễ dàng.
- [icon:notifications] Thông báo thông minh: Nhận thông báo khi có yêu cầu ghép đôi, nhận file, tin nhắn hoặc hoàn thành truyền dữ liệu.

## [play_circle, green] Hướng dẫn sử dụng nhanh
1. Bắt đầu: Mở chức năng P2Lan Data Transfer trên cả hai thiết bị cùng mạng WiFi.
2. Cấp quyền: Đảm bảo cấp quyền truy cập bộ nhớ, mạng, và thông báo (nếu cần).
3. Mở mạng: Thiết bị sẽ tự động quét và hiển thị các thiết bị khả dụng trong tab "Devices".
4. Ghép đôi: Chọn thiết bị muốn kết nối, nhấn vào menu 3 chấm và chọn "Pair" để ghép đôi.
5. Gửi file: Sau khi ghép đôi thành công, chọn file/thư mục trong tab "Send" để gửi.
6. Chat & nhắn tin: Sử dụng tab "Chat" để nhắn tin văn bản, gửi hình ảnh và chia sẻ clipboard.
7. Theo dõi tiến trình: Xem tiến trình truyền file ở tab "Transfers". Có thể huỷ, xoá, hoặc mở file sau khi truyền xong.

## [settings, indigo] Giải thích các cài đặt quan trọng

[#:indigo] Giao diện người dùng
- [icon:palette] Chủ đề: Chọn giao diện sáng, tối hoặc theo hệ thống.
- [icon:language] Ngôn ngữ: Chuyển đổi giữa tiếng Việt và tiếng Anh.
- [icon:phone_android] Giao diện gọn (di động): Ẩn icon trên thanh điều hướng để tiết kiệm không gian.

[#:green] Thiết lập chung P2P
- [icon:person] Tên hiển thị: Đặt tên thiết bị để dễ nhận diện khi ghép đôi.
- [icon:notifications] Thông báo: Bật/tắt thông báo cho yêu cầu ghép đôi và chuyển file.

[#:orange] Vị trí lưu & giới hạn dung lượng
- [icon:folder] Thư mục tải xuống: Chọn thư mục lưu file nhận được.
- [icon:category] Tổ chức tập tin: Theo ngày, theo người gửi hoặc mặc định.
- [icon:cloud_upload] Giới hạn dung lượng file: Kích thước tối đa cho mỗi file nhận (10MB - 50GB).
- [icon:cloud_download] Giới hạn tổng dung lượng: Tổng dung lượng nhận trong một batch (100MB - 100GB).

[#:purple] Mạng & tốc độ
- [icon:bolt] Kích thước chunk: Kích thước gói dữ liệu truyền (tăng để tối ưu tốc độ trên mạng mạnh).
- [icon:layers] Số luồng đồng thời: Số luồng truyền song song (tăng để truyền nhiều file cùng lúc).
- [icon:network_wifi] Giao thức gửi: Chọn giao thức truyền (TCP/UDP).

[#:red] Bảo mật & mã hoá nâng cao
- [icon:lock] Loại mã hoá: Không  có, AES-GCM và ChaCha20-Poly1305.
  - Không có: Không mã hoá (nhanh nhất)
  - AES-GCM: Mã hoá mạnh, tốt cho thiết bị cao cấp
  - ChaCha20-Poly1305: Tối ưu cho thiết bị di động
- [icon:compress] Nén dữ liệu: Giảm thời gian truyền bằng cách nén file.

## [chat, teal] Tính năng Chat & Clipboard

[#:teal] Chat cơ bản
- [icon:message] Nhắn tin văn bản: Gửi tin nhắn văn bản trực tiếp giữa các thiết bị.
- [icon:image] Chia sẻ media: Gửi hình ảnh và video qua chat với xem trước.
- [icon:attach_file] Gửi file: Đính kèm và gửi file bất kỳ qua chat.
- [icon:timer] Quản lý thời gian: Hiển thị thời gian gửi cho tất cả tin nhắn.

[#:blue] Tuỳ chỉnh Chat
- [icon:person] Tên hiển thị chat: Đặt tên riêng cho từng cuộc chat.
- [icon:schedule] Thời gian lưu trữ: Chọn thời gian tự động xoá tin nhắn (7-365 ngày).
- [icon:content_copy] Đồng bộ clipboard: Tự động sao chép tin nhắn văn bản/hình ảnh vào clipboard.
- [icon:delete] Xoá sau khi sao chép: Tự động xoá tin nhắn sau khi sao chép.
- [icon:share] Chia sẻ clipboard: Tự động gửi nội dung clipboard mới dưới dạng tin nhắn.
- [icon:delete_forever] Xoá sau khi chia sẻ: Tự động xoá tin nhắn sau khi chia sẻ từ clipboard.

## [keyboard, cyan] Phím tắt
Truy cập nhanh các chức năng thường dùng với phím tắt để nâng cao hiệu suất làm việc.

## [build, purple] Mẹo sử dụng & tối ưu hoá
- Đặt tên thiết bị dễ nhớ để nhận diện nhanh khi ghép đôi.
- Sử dụng mã hoá ChaCha20-Poly1305 cho thiết bị di động hoặc AES-GCM cho máy tính mạnh.
- Bật giao diện gọn trên di động để tiết kiệm không gian màn hình.
- Sử dụng tính năng chat để liên lạc nhanh thay vì gửi file nhỏ.
- Bật đồng bộ clipboard khi cần chia sẻ văn bản/hình ảnh thường xuyên.
- Tăng chunk size và số luồng trên mạng nội bộ mạnh để đạt tốc độ tối đa.
- Dùng tính năng "Clear Cache" để giải phóng bộ nhớ khi cần.
- Bật thông báo để không bỏ lỡ các yêu cầu nhận file hoặc tin nhắn quan trọng.
- Có thể gửi nhiều file/thư mục cùng lúc bằng cách chọn batch gửi.

## [security, orange] Lưu ý bảo mật
- Chỉ ghép đôi và truyền file với thiết bị tin cậy trong cùng mạng LAN.
- Kiểm tra kỹ thông tin thiết bị trước khi xác nhận nhận file.
- Không chia sẻ mạng WiFi với người lạ khi sử dụng chức năng này.
- Sử dụng mã hoá để bảo vệ dữ liệu cá nhân.

## [help_outline, teal] Xử lý sự cố thường gặp
[#] Không thấy thiết bị khác: Kiểm tra kết nối WiFi, cấp quyền mạng, tắt VPN/chặn mạng.
[#] Không gửi/nhận được file: Kiểm tra quyền truy cập bộ nhớ, dung lượng còn trống, thử khởi động lại ứng dụng.
[#] Lỗi ghép đôi: Đảm bảo cả hai thiết bị đều mở chức năng P2Lan và trong cùng mạng.
[#] Chat không hoạt động: Kiểm tra kết nối mạng và đảm bảo thiết bị đích đang online.
[#] Clipboard không đồng bộ: Kiểm tra quyền truy cập clipboard và đảm bảo ứng dụng chạy foreground.
[#] Tốc độ chậm: Thử giảm chunk size, tắt mã hoá hoặc kiểm tra chất lượng mạng WiFi.

## [info_outline, red] Lưu ý quan trọng
- Chức năng chỉ hoạt động trong cùng mạng LAN/WiFi, không hỗ trợ qua Internet.
- Tốc độ truyền phụ thuộc vào chất lượng mạng nội bộ và cấu hình thiết bị.
- Tính năng clipboard sharing chỉ hoạt động khi ứng dụng chạy foreground.
- Mã hoá sẽ làm giảm tốc độ truyền nhưng tăng tính bảo mật.
- Không nên truyền file quá lớn trên thiết bị cấu hình yếu hoặc mạng không ổn định.
- Chat history sẽ được lưu cục bộ và tự động xoá theo cài đặt thời gian.

[#:cyan] Màn hình chính
- [icon:keyboard] Ctrl+1: Mở màn hình Chat
- [icon:keyboard] Ctrl+2: Mở Local Files (chỉ Android)
- [icon:keyboard] Ctrl+3: Hiển thị Yêu cầu ghép đôi (khi có)
- [icon:keyboard] Ctrl+4: Mở Cài đặt truyền dữ liệu
- [icon:keyboard] Ctrl+5: Hiển thị Tài liệu hướng dẫn
- [icon:keyboard] Ctrl+6: Hiển thị thông tin Về ứng dụng
- [icon:keyboard] Ctrl+O: Bật/Tắt mạng
- [icon:keyboard] Ctrl+R: Tìm thiết bị thủ công (khi mạng đang hoạt động)
- [icon:keyboard] Ctrl+Del: Xóa tất cả truyền dữ liệu (khi có transfers)
[#:yellow] Màn hình Trò chuyện
- [icon:keyboard] Ctrl+Shift+R: Tải lại các cuộc trò chuyện
- [icon:keyboard] Ctrl+R: Tải lại cuộc trò chuyện đang tham gia
- [icon:keyboard] Ctrl+O: Tùy chỉnh cuộc trò chuyện đang tham gia
- [icon:keyboard] Ctrl+I: Tiến hành soạn tin nhắn văn bản
- [icon:keyboard] Ctrl+,: Chọn 1 tệp phương tiện trong trò chuyện
- [icon:keyboard] Crtl+.: Chọn 1 tệp tin trong trò chuyện
- [icon:keyboard] Ctrl+Enter: Gửi tin nhắn
[#:blue] Màn hình Cài đặt, Trò chuyện và vài hộp thoại
- [icon:keyboard] Esc: Thoát và quay về màn hình trước
- [icon:keyboard] Ctrl+1...Ctrl+9: Chọn cuộc trò chuyện/ phần cài đặt tương ứng