# my_provider

Thư viện hỗ trợ các thành phần giúp xây dựng ứng dụng flutter nhanh chóng hơn.

## Một số ví dụ

Lưu trữ và sử dụng dữ liệu cơ bản

Lấy dữ liệu từ API với Fetch

Quản lý APIs với HttpFetch

Dùng Fetch để gởi 1 POST request

Tối ưu hiệu suất ứng dụng bằng lưu trữ cache

Tối ưu hiệu suất ứng dụng bằng việc chỉnh sửa cache

Phân trang và cuộn trang với Fetch

Làm mới dữ liệu danh sách sau khi thực hiện 1 hành động

Sử lý lỗi HTTP

Tự động thử lại sau khi gặp lỗi

Tải trước dữ liệu (Prefetching)

Tự động làm mới

## APIs

Store: Là nơi lưu trữ dữ dữ liệu dựa trên cấu trúc key-value-pair.

State: Một đơn vị tương ứng với 1 value trong Store.

Presenter: Thành phần kết nối giữa UI và State.

Fetch: Lấy dữ liệu từ kho lưu trữ bên ngoài ứng dụng để hiển thị lên UI.

HttpRemote: Hỗ trợ tạo http request với các thành phần như url, headers, authorization.

EventEmitter: Quản lý và kích hoạt hệ thống sự kiện.


## Setup

```bash
# Install packages
flutter pub get

# Generate mocks
flutter packages pub run build_runner build --delete-conflicting-outputs
```

