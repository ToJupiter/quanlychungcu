# Hệ thống Phòng khám Thú cưng - Giao diện Frontend React

Giao diện frontend hiện đại cho hệ thống quản lý phòng khám thú cưng, được xây dựng bằng React + TypeScript, tích hợp Material-UI và tối ưu hóa cho trình duyệt web.

## 🚀 Tính năng nổi bật

### Kiến trúc
- **React 18** cùng **TypeScript** đảm bảo an toàn kiểu dữ liệu
- **Material-UI (MUI)** - hệ thống thiết kế theo phong cách Apple
- **Zustand** - quản lý trạng thái ứng dụng
- **React Router** - điều hướng phía client
- **Axios** - thư viện HTTP hỗ trợ cookie JSESSIONID
- **Vite** - công cụ phát triển và build nhanh chóng

### Xác thực & Phân quyền
- **Phân quyền người dùng** (OWNER, STAFF, DOCTOR, ADMIN)
- **Xác thực phiên làm việc** thông qua cookie JSESSIONID
- **Route bảo vệ** dựa trên vai trò người dùng
- **Tự động khôi phục phiên** khi khởi động ứng dụng

### Giao diện người dùng
- Thiết kế **theo phong cách Material Design của Apple** với góc bo tròn và hiệu ứng mượt mà
- **Responsive design** tối ưu cho trình duyệt web (không phải mobile-first)
- **Bố cục ngang** tận dụng không gian màn hình
- Trang **đăng nhập/đăng ký** đẹp mắt, có tài khoản test nhanh
- **Thanh điều hướng bên trái** tùy biến theo vai trò người dùng
- **Màu sắc chuyên nghiệp** đi kèm huy hiệu phân biệt theo vai trò

### Tích hợp Backend
- **Tích hợp API đầy đủ** với backend Spring Boot
- **Tự động xử lý cookie** để quản lý phiên làm việc
- **Xử lý lỗi chi tiết** với thông báo thân thiện
- **Tải dữ liệu thời gian thực** với trạng thái loading
- **Cấu hình CORS và proxy** trong quá trình phát triển

## 🎨 Hệ thống thiết kế

### Màu sắc
- **Xanh dương chính**: #007AFF (màu xanh iOS)
- **Cam phụ**: #FF9500 (màu cam iOS)
- **Xanh lá thành công**: #34C759 (màu xanh iOS)
- **Đỏ lỗi**: #FF3B30 (màu đỏ iOS)
- **Cam cảnh báo**: #FF9500
- **Xanh nhạt thông tin**: #5AC8FA

### Màu sắc theo vai trò
- **Admin**: Huy hiệu màu đỏ
- **Bác sĩ thú y**: Huy hiệu màu xanh lá
- **Nhân viên**: Huy hiệu màu cam
- **Chủ thú cưng**: Huy hiệu màu xanh dương

## 📂 Cấu trúc dự án

```
js_fe/
├── src/
│   ├── components/           # Các component UI tái sử dụng
│   │   ├── Layout/          # Component bố cục (Sidebar, MainLayout)
│   │   └── ProtectedRoute.tsx
│   ├── pages/               # Component các trang
│   │   ├── auth/           # Trang đăng nhập/đăng ký
│   │   ├── dashboard/      # Trang tổng quan
│   │   ├── admin/          # Trang dành riêng Admin
│   │   ├── owner/          # Trang dành riêng Chủ thú cưng
│   │   └── common/         # Trang chung
│   ├── services/           # Lớp gọi API
│   ├── stores/             # Lưu trữ Zustand
│   ├── types/              # Định nghĩa kiểu TypeScript
│   ├── theme/              # Cấu hình theme MUI
│   ├── App.tsx             # Component chính với điều hướng
│   └── main.tsx            # Điểm vào của ứng dụng
├── package.json
├── vite.config.ts          # Cấu hình Vite với proxy
└── README.md
```

## 🔧 Cài đặt & Cấu hình

### Yêu cầu hệ thống
- **Node.js** 18+ và npm
- **Backend Spring Boot** đang chạy ở cổng 8080

### Cài đặt
```bash
# Di chuyển đến thư mục frontend
cd js_fe

# Cài đặt các gói phụ thuộc
npm install

# Khởi động máy chủ dev
npm run dev
```

Ứng dụng sẽ có tại `http://localhost:3000`

### Kết nối Backend
Frontend được cấu hình kết nối với backend Spring Boot tại `http://localhost:8080` thông qua proxy trong Vite.

## 🔐 Tài khoản Test

Trang đăng nhập có nút truy cập nhanh:

| Vai trò | Email | Mật khẩu | Quyền truy cập |
|--------|-------|----------|----------------|
| **Admin** | admin@example.com | admin123 | Toàn quyền |
| **Doctor** | doctor@example.com | doctor123 | Quản lý hồ sơ y tế, thú cưng, lịch hẹn |
| **Staff** | staff@example.com | staff123 | Quản lý lịch hẹn, chuồng, dịch vụ |
| **Owner** | owner@example.com | owner123 | Quản lý thú cưng và lịch hẹn cá nhân |

## 📱 Tính năng theo vai trò

### Chủ thú cưng (OWNER)
- ✅ Bảng điều khiển với thống kê cá nhân
- ✅ Quản lý thú cưng của tôi
- ✅ Quản lý lịch hẹn của tôi
- ✅ Xem hồ sơ y tế
- ✅ Quản lý hồ sơ cá nhân

### Nhân viên (STAFF)
- ✅ Bảng điều khiển với thống kê hệ thống
- ✅ Quản lý tất cả thú cưng
- ✅ Quản lý tất cả lịch hẹn
- ✅ Quản lý hồ sơ y tế
- ✅ Quản lý dịch vụ
- ✅ Quản lý chuồng

### Bác sĩ thú y (DOCTOR)
- ✅ Bảng điều khiển với thống kê y tế
- ✅ Xem tất cả thú cưng
- ✅ Xem tất cả lịch hẹn
- ✅ Quản lý hồ sơ y tế
- ✅ Lập kế hoạch điều trị

### Quản trị viên (ADMIN)
- ✅ Bảng điều khiển với thống kê đầy đủ
- ✅ Quản lý người dùng (phân quyền)
- ✅ Quản lý tất cả thú cưng
- ✅ Quản lý tất cả lịch hẹn
- ✅ Quản lý hồ sơ y tế
- ✅ Quản lý dịch vụ
- ✅ Cấu hình hệ thống

## 🔧 Cấu hình

### Vite (`vite.config.ts`)
```typescript
export default defineConfig({
  plugins: [react()],
  server: {
    port: 3000,
    proxy: {
      '/api': {
        target: 'http://localhost:8080',
        changeOrigin: true,
        secure: false,
      }
    }
  }
});
```

### Dịch vụ API
Dịch vụ API tự động xử lý:
- **Cookie JSESSIONID** cho xác thực
- **Header CORS** cho yêu cầu đa nguồn gốc
- **Xử lý lỗi** với thông báo dễ hiểu
- **Ghi log request/response** để debug

## 🚧 Trạng thái hiện tại

### ✅ Hoàn thành
- [x] Hệ thống xác thực (login/register)
- [x] Điều hướng và phân quyền theo vai trò
- [x] Theme MUI và hệ thống thiết kế
- [x] Thanh điều hướng tùy biến theo vai trò
- [x] Bảng điều khiển với thống kê theo vai trò
- [x] Trang lịch hẹn với API
- [x] Trang từ chối truy cập
- [x] Quản lý phiên làm việc

### 🔄 Đang phát triển
- [ ] Quản lý người dùng (Admin)
- [ ] Quản lý thú cưng (tất cả vai trò)
- [ ] Hồ sơ y tế (CRUD)
- [ ] Quản lý dịch vụ (Admin/Staff)
- [ ] Quản lý chuồng (Admin/Staff)

### 📋 Tính năng sắp triển khai
- [ ] Thông báo thời gian thực
- [ ] Bộ lọc nâng cao
- [ ] Xuất dữ liệu
- [ ] In hồ sơ y tế
- [ ] Lịch hẹn
- [ ] Upload ảnh thú cưng

## 🐛 Vấn đề thường gặp & Giải pháp

### Kết nối Backend
Nếu bạn thấy lỗi "Không tải được dữ liệu":
1. Đảm bảo backend Spring Boot đang chạy trên cổng 8080
2. Kiểm tra tab Network trên DevTools nếu có lỗi CORS
3. Xác minh endpoint API khớp với backend

### Xác thực thất bại
Nếu đăng nhập thất bại:
1. Kiểm tra log backend về lỗi xác thực
2. Đảm bảo tài khoản test đã tồn tại ở backend
3. Xóa cookie trình duyệt nếu phiên bị lỗi

## 🤝 Đóng góp

### Hướng dẫn phát triển
1. **An toàn kiểu dữ liệu**: Tất cả component phải dùng TypeScript
2. **Material-UI**: Dùng component MUI với theme tùy chỉnh
3. **Xử lý lỗi**: Triển khai boundary lỗi và phản hồi rõ ràng
4. **Thiết kế web**: Tối ưu cho web nhưng hỗ trợ cơ bản trên mobile
5. **Phân quyền**: Luôn kiểm tra vai trò trước khi kích hoạt tính năng

### Thêm trang mới
1. Tạo component trang phù hợp (`pages/admin/`, `pages/owner/`, v.v.)
2. Thêm route vào `App.tsx` với bảo vệ phân quyền
3. Thêm mục menu vào `Sidebar.tsx` với giới hạn vai trò
4. Viết logic API ở lớp service
5. Thêm interface TypeScript vào `types/`

## 📚 Tài liệu API

Frontend tích hợp với các endpoint chính sau:

### Xác thực
- `POST /api/auth/login` - Đăng nhập
- `POST /api/auth/register` - Đăng ký
- `POST /api/auth/logout` - Đăng xuất
- `GET /api/auth/me` - Lấy thông tin người dùng

### Lịch hẹn
- `GET /api/bookings` - Lấy tất cả lịch hẹn (Staff/Admin/Doctor)
- `GET /api/bookings/my` - Lấy lịch hẹn cá nhân (Owner)
- `POST /api/bookings` - Tạo lịch hẹn
- `PUT /api/bookings/{id}` - Sửa lịch hẹn
- `DELETE /api/bookings/{id}` - Xóa lịch hẹn

### Thú cưng
- `GET /api/pets` - Lấy tất cả thú cưng (Staff/Admin/Doctor)
- `GET /api/pets/my` - Lấy thú cưng cá nhân (Owner)
- `POST /api/pets` - Tạo thú cưng
- `PUT /api/pets/{id}` - Sửa thú cưng
- `DELETE /api/pets/{id}` - Xóa thú cưng

### Hồ sơ y tế
- `GET /api/medical-records` - Lấy tất cả hồ sơ (Staff/Admin/Doctor)
- `GET /api/medical-records/my` - Lấy hồ sơ cá nhân (Owner)
- `POST /api/medical-records` - Tạo hồ sơ (Doctor/Admin)
- `PUT /api/medical-records/{id}` - Sửa hồ sơ (Doctor/Admin)

### Người dùng (dành riêng Admin)
- `GET /api/users` - Lấy tất cả người dùng
- `POST /api/users` - Tạo người dùng
- `PUT /api/users/{id}` - Sửa người dùng
- `DELETE /api/users/{id}` - Xóa người dùng

## 🎯 Tối ưu hiệu suất

### Chia nhỏ mã
- Route được lazy load để tăng tốc độ
- Component được memo hóa nơi cần thiết

### Quản lý trạng thái
- Zustand giúp quản lý trạng thái nhẹ nhàng
- Cache API để giảm tải server

### Tối ưu bundle
- Vite tự động chia nhỏ mã
- Tree shaking loại bỏ mã không dùng
- Build production tối ưu dung lượng

---

**Phát triển với ❤️ bằng React, TypeScript và Material-UI**
