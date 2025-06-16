# Nhóm 30 - Quản lý chung cư BlueMoon

---

# 🌙 BlueMoon Project

Hệ thống quản lý toàn diện dành cho doanh nghiệp, tích hợp cả Backend (Spring Boot) và Frontend (ReactJS).

---

## 📋 Yêu Cầu Hệ Thống

Trước khi bắt đầu, hãy đảm bảo máy tính của bạn đã được cài đặt đầy đủ các công cụ sau:

- **Java Development Kit (JDK)**: Phiên bản 17 trở lên.
- **Maven**: Phiên bản 3.6 trở lên.
- **Node.js**: Phiên bản 18 trở lên (bao gồm cả `npm`).
- **Git**
- **MySQL Server**

---

## ⚙️ 1. Cài Đặt Backend (Spring Boot)

### Bước 1: Lấy Mã Nguồn
```bash
# Thay <repo-url> bằng đường dẫn repository của bạn
git clone <repo-url>
cd backend_springboot
```

### Bước 2: Cấu Hình Cơ Sở Dữ Liệu
Tạo database trong MySQL: `bluemoon_db`.

Chỉnh sửa file `src/main/resources/application.properties`:
```properties
spring.datasource.url=jdbc:mysql://localhost:3306/bluemoon_db?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true
spring.datasource.username=your_username
spring.datasource.password=your_password
spring.jpa.hibernate.ddl-auto=update
```

### Bước 3: Build và Chạy Ứng Dụng
```bash
mvn clean install
mvn spring-boot:run
```

Backend sẽ chạy tại: `http://localhost:3001`

---

## 🖥️ 2. Cài Đặt Frontend (ReactJS + Vite)

### Bước 1: Di chuyển vào thư mục frontend
```bash
cd js_fe
```

### Bước 2: Cài đặt dependencies
```bash
npm install
```

### Bước 3: Cấu hình kết nối backend
Tạo file `.env` trong thư mục `js_fe` với nội dung:
```env
VITE_API_BASE_URL=http://localhost:3001/api
```

### Bước 4: Chạy ứng dụng
```bash
npm run dev
```

Frontend sẽ chạy tại: `http://localhost:5173`

---

## 🔑 3. Tài Khoản Mẫu

- **Admin**  
  Email: `admin@bluemoon.com`  
  Password: `admin123`

- **Kế toán**  
  Email: `accountant@bluemoon.com`  
  Password: `accountant123`

---

## ⚠️ 4. Các Lỗi Thường Gặp

- **Lỗi CORS**: Kiểm tra cấu hình Cors trong Spring Boot.
- **Port đã bị sử dụng**: Đổi cổng hoặc đóng ứng dụng đang chiếm port.
- **Lỗi kết nối cơ sở dữ liệu**: Kiểm tra lại username, password, URL DB.

---

Chúc bạn cài đặt thành công và phát triển hiệu quả với **BlueMoon**! 🚀