# BlueMoon Apartment Management System

A comprehensive apartment management system built with Flutter (frontend) and Node.js/Express (backend), designed for property managers to efficiently manage apartments, households, residents, staff, and financial records.

## 🏗️ Project Structure

```
📦 quanlychungcu/
├── 📁 backend/              # Node.js/Express API server
│   ├── 📁 controllers/      # Business logic controllers
│   ├── 📁 routes/          # API route definitions
│   ├── 📁 middlewares/     # Authentication & validation
│   ├── 📄 database.js      # MySQL database connection
│   ├── 📄 server.js        # Main server entry point
│   └── 📄 package.json     # Backend dependencies
├── 📁 bluemoon/            # Flutter mobile application
│   ├── 📁 lib/            # Flutter source code
│   │   ├── 📁 models/     # Data models
│   │   ├── 📁 services/   # API communication services
│   │   ├── 📁 screens/    # UI screens/pages
│   │   └── 📁 widgets/    # Reusable UI components
│   ├── 📄 pubspec.yaml    # Flutter dependencies
│   └── 📁 android/        # Android build configuration
└── 📄 frontend/bluemoon_database.txt  # Database schema
```

## 🚀 Quick Start Guide

### Prerequisites

Before running the application, ensure you have the following installed:

- **Node.js** (v16.0 or higher) - [Download here](https://nodejs.org/)
- **MySQL** (v8.0 or higher) - [Download here](https://mysql.com/downloads/)
- **Flutter SDK** (v3.0 or higher) - [Install guide](https://flutter.dev/docs/get-started/install)
- **Android Studio** or **VS Code** with Flutter extensions

### 📊 Database Setup

1. **Create MySQL Database:**
   ```sql
   CREATE DATABASE bluemoon_apartment_db;
   ```

2. **Run Database Schema:**
   ```bash
   # Navigate to project root
   cd quanlychungcu
   
   # Execute the SQL schema file
   mysql -u your_username -p bluemoon_apartment_db < frontend/bluemoon_database.txt
   ```

3. **Insert Sample Data (Optional):**
   ```sql
   -- Create a test staff account
   INSERT INTO Staff (full_name, email, phone_number, password_hash, status) 
   VALUES ('Admin User', 'admin@bluemoon.com', '0123456789', '$2a$10$hashedpassword', 'active');
   ```

### 🔧 Backend Setup (Node.js/Express)

1. **Navigate to Backend Directory:**
   ```bash
   cd backend
   ```

2. **Install Dependencies:**
   ```bash
   npm install
   ```

3. **Configure Database Connection:**
   ```bash
   # Create config.js file
   cp config.example.js config.js
   
   # Edit config.js with your database credentials
   ```
   
   **config.js example:**
   ```javascript
   module.exports = {
     port: 3000,
     jwtSecret: 'your-super-secret-jwt-key',
     db: {
       host: 'localhost',
       user: 'your_mysql_username',
       password: 'your_mysql_password',
       name: 'bluemoon_apartment_db'
     }
   };
   ```

4. **Start Backend Server:**
   ```bash
   # Development mode with auto-restart
   npm run dev
   
   # Or production mode
   npm start
   ```

   ✅ **Server should start on:** `http://localhost:3000`

### 📱 Frontend Setup (Flutter)

1. **Navigate to Flutter Directory:**
   ```bash
   cd bluemoon
   ```

2. **Install Flutter Dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure API Endpoint:**
   ```bash
   # Edit lib/services/base_service.dart
   # Update the base URL to match your backend server
   ```
   
   **Example in base_service.dart:**
   ```dart
   static const String baseUrl = 'http://localhost:3000/api';
   // For Android emulator: 'http://10.0.2.2:3000/api'
   // For physical device: 'http://YOUR_COMPUTER_IP:3000/api'
   ```

4. **Run Flutter Application:**
   ```bash
   # Check connected devices
   flutter devices
   
   # Run on specific device
   flutter run -d chrome          # Web browser
   flutter run -d android         # Android device/emulator
   flutter run -d windows         # Windows desktop
   
   # Or simply run on default device
   flutter run
   ```

## 🔑 First Login

**Default Credentials:**
- **Email:** `admin@bluemoon.com`
- **Password:** `admin123`

*⚠️ Remember to change default password after first login!*

## 🛠️ Development Commands

### Backend Commands
```bash
cd backend

# Start development server (auto-restart)
npm run dev

# Start production server
npm start

# Install new package
npm install package-name

# Run tests (if available)
npm test
```

### Frontend Commands
```bash
cd bluemoon

# Get dependencies
flutter pub get

# Run app in debug mode
flutter run

# Build for production
flutter build apk          # Android APK
flutter build web          # Web deployment
flutter build windows      # Windows desktop

# Clean build cache
flutter clean

# Analyze code quality
flutter analyze

# Format code
flutter format lib/
```

## 🌟 Key Features

### 🏢 **Apartment Management**
- Add, edit, delete apartment records
- Track apartment status (occupied/vacant/maintenance)
- Monitor apartment area and specifications
- Responsive table with search and filtering

### 👨‍👩‍👧‍👦 **Household Management**
- Register new households to apartments
- Manage household members and head residents
- Track move-in dates and residency duration
- CCCD (Citizen ID) management

### 💰 **Financial Management**
- Create and track payment records
- Multiple payment types (service fees, parking, utilities)
- Payment status tracking (paid/unpaid/pending)
- Financial reporting and statistics
- Due date management with alerts

### 👥 **Staff Management**
- Staff account creation and management
- Role-based access control
- Password reset functionality
- Staff status management (active/inactive)

### 📊 **Dashboard & Analytics**
- Real-time statistics overview
- Revenue tracking and summaries
- Resident count monitoring
- Quick access navigation

## 🎨 UI Features

- **Modern Material Design 3** aesthetics
- **Responsive layout** for desktop and mobile
- **Dark/Light theme** support
- **Smooth animations** and transitions
- **Advanced filtering** and search capabilities
- **Data tables** with sorting functionality
- **Form validation** with user-friendly error messages

## 🔒 Security Features

- **JWT-based authentication**
- **Password hashing** with bcrypt
- **Protected API routes**
- **Input validation** and sanitization
- **SQL injection protection**

## 🐛 Troubleshooting

### Common Backend Issues:
```bash
# Database connection failed
- Check MySQL service is running
- Verify credentials in config.js
- Ensure database exists

# Port already in use
- Change port in config.js
- Or kill process: lsof -ti:3000 | xargs kill

# Dependencies issues
rm -rf node_modules package-lock.json
npm install
```

### Common Flutter Issues:
```bash
# Build failures
flutter clean
flutter pub get
flutter run

# Dependency conflicts
flutter pub deps
flutter pub upgrade

# Android build issues
cd android && ./gradlew clean && cd ..
flutter build apk
```

## 📱 Supported Platforms

- ✅ **Android** (API 21+)
- ✅ **Web** (Chrome, Firefox, Safari)
- ✅ **Windows** (Windows 10+)
- ✅ **macOS** (macOS 10.14+)
- ✅ **iOS** (iOS 11+)

## 🤝 Contributing

1. Fork the repository
2. Create feature branch: `git checkout -b feature/new-feature`
3. Commit changes: `git commit -am 'Add new feature'`
4. Push to branch: `git push origin feature/new-feature`
5. Submit Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support

For technical support or questions:
- 📧 **Email:** support@bluemoon.com
- 🐛 **Issues:** [GitHub Issues](https://github.com/your-repo/issues)
- 📖 **Documentation:** [Wiki Pages](https://github.com/your-repo/wiki)

---

**Made with ❤️ by the BlueMoon Development Team**
