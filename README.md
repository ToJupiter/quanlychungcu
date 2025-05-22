# Apartment Management Application Setup Guide

This guide will walk you through setting up the MySQL database, Node.js backend, and Flutter frontend for the apartment management application.

## Prerequisites

*   **MySQL:** Ensure MySQL server is installed and running. You'll need a MySQL client (like MySQL Workbench, DBeaver, or the command-line client) to execute SQL commands.
*   **Node.js & npm:** Install Node.js (which includes npm) from [nodejs.org](https://nodejs.org/).
*   **Flutter SDK:** Install the Flutter SDK from [flutter.dev](https://flutter.dev/). Ensure the `flutter` command is in your system's PATH.
*   **Git (Optional):** If you cloned the repository, Git is already installed.

## 1. Database Setup (MySQL)

The application uses a MySQL database. You need to create the database and then create the necessary tables using the provided schema.

### a. Create the Database

1.  Open your MySQL client and connect to your MySQL server.
2.  Execute the following SQL command to create the database. The default database name used in `backend/config.js` and `backend/database.js` is `apartment_management_db`. If you wish to use a different name, you must update these files accordingly.

    ```sql
    CREATE DATABASE apartment_management_db;
    ```

    If you see an error like `Database 'your_db_name' does not exist` when starting the backend later, it means this step was missed or the database name in `backend/config.js` doesn't match the one you created.

### b. Create Tables

1.  Select the database you just created (e.g., `apartment_management_db`):

    ```sql
    USE apartment_management_db;
    ```

2.  Execute the following SQL DDL statements to create the tables. This schema is taken from `frontend/bluemoon_database.txt`.

    ```sql
    -- Staff
    CREATE TABLE Staff (
        staff_id INT PRIMARY KEY AUTO_INCREMENT,
        full_name VARCHAR(255) NOT NULL,
        email VARCHAR(255) UNIQUE NOT NULL,
        phone_number VARCHAR(20),
        password_hash VARCHAR(255) NOT NULL,
        status VARCHAR(50),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

    -- Apartments
    CREATE TABLE Apartments (
        apartment_id INT PRIMARY KEY AUTO_INCREMENT,
        apartment_number VARCHAR(50) UNIQUE NOT NULL,
        area DECIMAL(10, 2),
        status VARCHAR(50)
    );

    -- Households
    CREATE TABLE Households (
        household_id INT PRIMARY KEY AUTO_INCREMENT,
        apartment_id INT UNIQUE,
        head_of_household_resident_id INT, -- Note: Foreign key to Residents is commented out in source, can be added later if needed
        move_in_date DATE,
        FOREIGN KEY (apartment_id) REFERENCES Apartments(apartment_id)
    );

    -- Residents
    CREATE TABLE Residents (
        resident_id INT PRIMARY KEY AUTO_INCREMENT,
        household_id INT,
        full_name VARCHAR(255) NOT NULL,
        date_of_birth DATE,
        cccd_number VARCHAR(20) UNIQUE,
        role_in_household VARCHAR(50),
        FOREIGN KEY (household_id) REFERENCES Households(household_id)
    );

    -- Vehicles
    CREATE TABLE Vehicles (
        vehicle_id INT PRIMARY KEY AUTO_INCREMENT,
        household_id INT,
        plate_number VARCHAR(50) UNIQUE NOT NULL,
        vehicle_type VARCHAR(50),
        registration_date DATE,
        FOREIGN KEY (household_id) REFERENCES Households(household_id)
    );

    -- Payments
    CREATE TABLE Payments (
        payment_id INT PRIMARY KEY AUTO_INCREMENT,
        household_id INT,
        payment_type VARCHAR(100),
        amount DECIMAL(10, 2),
        due_date DATE,
        payment_date DATE,
        status VARCHAR(50),
        FOREIGN KEY (household_id) REFERENCES Households(household_id)
    );
    ```

### c. Configure Database Connection (Backend)

The backend needs to know how to connect to your MySQL database.
1.  Navigate to the `backend` folder.
2.  Open the `config.js` file.
3.  Update the `db` object with your MySQL connection details:

    ```javascript
    // backend/config.js
    module.exports = {
      port: process.env.PORT || 3000,
      jwtSecret: process.env.JWT_SECRET || 'your_very_secret_key_for_jwt', // Change this for production!
      db: {
        host: process.env.DB_HOST || 'localhost', // Or your MySQL server IP/hostname
        user: process.env.DB_USER || 'your_mysql_user', // e.g., 'root' or a dedicated user
        password: process.env.DB_PASSWORD || 'your_mysql_password',
        name: process.env.DB_NAME || 'apartment_management_db' // Must match the database created in step 1a
      }
    };
    ```
    *   Replace `'your_mysql_user'` and `'your_mysql_password'` with your actual MySQL username and password.
    *   Ensure `host` is correct (usually `'localhost'` if MySQL is on the same machine).
    *   Ensure `name` matches the database name created earlier.

    The `backend/database.js` file uses these credentials to establish a connection. If you encounter errors like `ECONNREFUSED` or `ER_ACCESS_DENIED_ERROR` when starting the backend, double-check these credentials and that your MySQL server is running and accessible.

## 2. Backend Setup (Node.js)

The backend is a Node.js application using Express.js.

### a. Navigate to Backend Directory

Open your terminal or command prompt and change to the `backend` directory of your project:

```bash
cd path/to/your/project/backend
```

### b. Install Dependencies

Install the necessary Node.js packages defined in `package.json`:

```bash
npm install
```

This command will download and install all dependencies into a `node_modules` folder within the `backend` directory.

### c. Start the Backend Server

Once dependencies are installed, you can start the backend server using the script defined in `package.json`:

```bash
npm start
```

This typically runs `node server.js` or a similar command.
If successful, you should see a message like:
`Server listening on port 3000`
`MySQL Connected successfully!`

If you see database connection errors, revisit section **1c. Configure Database Connection**.

The backend API will now be running, usually at `http://localhost:3000`.

## 3. Frontend Setup (Flutter - "bluemoon")

The frontend is a Flutter application.

### a. Navigate to Frontend Directory

Open a **new** terminal or command prompt (keep the backend server running in its terminal). Change to the `bluemoon` (frontend) directory of your project:

```bash
cd path/to/your/project/bluemoon
```

### b. Get Flutter Packages

Install the Flutter packages defined in `pubspec.yaml`:

```bash
flutter pub get
```

This command downloads and links all the Flutter dependencies.

### c. Configure API Endpoint (Frontend)

The Flutter app needs to know where the backend API is running. This is typically configured in a constants file or directly in service files.
Search for `http://localhost:3000` or similar base URLs in the Flutter project's `lib` directory (e.g., in files like `api_config.dart`, `*_service.dart`) and ensure it matches where your backend is running. If you changed the backend port in `backend/config.js`, update it here as well.

For example, if your services use a base URL like:
`String _baseUrl = 'http://localhost:3000/api';`
Ensure this matches your backend setup.

### d. Run the Flutter Application

1.  **Ensure an emulator is running or a device is connected.**
    *   You can list available devices with `flutter devices`.
    *   If no devices are listed, either start an Android emulator, iOS simulator, or connect a physical device.

2.  **Run the app:**
    Execute the following command in the `bluemoon` directory:

    ```bash
    flutter run
    ```

    This will build and run the Flutter application on the selected device/emulator.
    The first build might take some time.

    If you have multiple devices/emulators, you can target a specific one:
    ```bash
    flutter run -d <deviceId>
    ```
    (Replace `<deviceId>` with the ID from `flutter devices`).

## Troubleshooting Tips

*   **Backend `npm start` fails:**
    *   **Missing dependencies:** Run `npm install` again in the `backend` folder.
    *   **Port already in use:** If port 3000 is used by another application, either stop that application or change the `port` in `backend/config.js` and update the frontend accordingly.
    *   **Database connection errors:**
        *   `ECONNREFUSED`: MySQL server not running or not accessible at the configured host/port.
        *   `ER_ACCESS_DENIED_ERROR`: Incorrect MySQL username/password in `backend/config.js`.
        *   `ER_BAD_DB_ERROR`: The database specified in `backend/config.js` does not exist. Ensure you ran `CREATE DATABASE ...;` (Step 1a).
*   **Frontend `flutter run` fails:**
    *   **Flutter SDK issues:** Run `flutter doctor` and resolve any reported issues.
    *   **Missing dependencies:** Run `flutter pub get` again in the `bluemoon` folder.
    *   **No device/emulator:** Ensure a device is connected or an emulator is running.
*   **"DOCTYPE html" or HTML error in app instead of data:**
    *   This usually means a backend API call failed and returned an HTML error page (e.g., 404 Not Found, 500 Internal Server Error) instead of JSON.
    *   Check the backend terminal for error messages related to the failing API route.
    *   Verify the API endpoint URL in the Flutter service is correct and matches a defined route in `backend/routes/`.
*   **CORS errors in browser console (if running Flutter web):**
    *   The backend might need the `cors` middleware configured in `server.js` or `middlewares.js` if you are making requests from a web browser (Flutter web).
      Example `server.js` modification:
      ```javascript
      const cors = require('cors');
      // ...
      app.use(cors()); // Allow all origins - for development
      // For production, configure specific origins:
      // app.use(cors({ origin: 'http://your-flutter-web-app-domain.com' }));
      ```
      Then run `npm install cors` in the backend directory.

By following these steps, you should be able to get your apartment management application up and running.