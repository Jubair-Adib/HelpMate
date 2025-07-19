<div align="center">
  <img src="assets/images/helpmate_logo.png" alt="HelpMate Logo" width="300"/>
</div>

# HelpMate 🏠

A comprehensive home service provider platform that connects customers with skilled workers for various home services, featuring real-time booking, secure payments, and seamless communication.

## 📑 Table of Contents

<details open>
  <summary><b>Expand Table of Contents</b></summary>
  <ul>
    <li><a href="#-project-overview">📱 Project Overview</a></li>
    <li><a href="#-features">✨ Features</a></li>
    <li><a href="#-prerequisites">📋 Prerequisites</a></li>
    <li><a href="#-installation--setup">🚀 Installation & Setup</a></li>
    <li><a href="#-download-apk">📦 Download APK</a></li>
    <li><a href="#-project-architecture">🏗️ Project Architecture</a></li>
    <li><a href="#-development">🔧 Development</a></li>
    <li><a href="#-security-features">🛡️ Security Features</a></li>
    <li><a href="#-contributing">🤝 Contributing</a></li>
    <li><a href="#-contributors">👥 Contributors</a></li>
    <li><a href="#-license">📄 License</a></li>
    <li><a href="#-support--documentation">🆘 Support & Documentation</a></li>
  </ul>
</details>

---

## 📱 Project Overview

HelpMate is a full-stack application consisting of:

- **Frontend**: Flutter mobile application with cross-platform support
- **Backend**: FastAPI REST API with modern Python stack
- **Database**: PostgreSQL with SQLite for development
- **Payment Integration**: SSLCommerz for secure payment processing
- **Real-time Communication**: WebSocket-based chat system
- **File Storage**: Local storage with image handling capabilities



## ✨ Features

### 👤 For Customers
- 🔐 **Secure Authentication** – JWT-based login/signup with password reset
- 🔍 **Service Discovery** – Browse service categories and find skilled workers
- 👷 **Worker Profiles** – View detailed worker information, reviews, and ratings
- 📅 **Booking System** – Easy service booking with scheduling
- 💳 **Secure Payments** – SSLCommerz integration for safe transactions
- 💬 **Real-Time Chat** – Communicate with workers during service
- ⭐ **Review System** – Rate and review completed services
- ❤️ **Favorites** – Save preferred workers for quick access
- 📱 **Profile Management** – Update personal information and preferences
- 🔔 **Notifications** – Real-time updates on bookings and messages

### 👷 For Workers
- 📊 **Service Management** – Track pending and completed services
- 💬 **Customer Communication** – Chat with customers in real-time
- 📈 **Earnings Tracking** – Monitor income and service history
- ⭐ **Rating System** – Build reputation through customer reviews
- 📱 **Profile Management** – Update skills, availability, and information

### 🏢 For Administrators
- 📊 **Dashboard Analytics** – Monitor platform performance and metrics
- 👥 **User Management** – Manage customers, workers, and admins
- 📋 **Order Management** – Oversee all service bookings
- 🛠️ **Service Categories** – Manage available service types
- 📈 **Reports** – Generate detailed reports and insights

### ⚙️ Technical Features
- 🎨 **Modern UI/UX** – Blue-themed Material Design 3 interface
- 🔄 **Real-Time Updates** – WebSocket-based live chat and notifications
- 🖼️ **Image Handling** – Profile picture upload and management
- 💳 **Payment Processing** – Secure SSLCommerz integration
- 📱 **Cross-Platform** – Flutter app for Android, iOS, and Web
- 🔍 **Search & Filter** – Advanced search capabilities
- 📊 **Admin Dashboard** – Comprehensive admin panel
- 🔐 **JWT Authentication** – Secure token-based authentication
- 📧 **Email Integration** – Password reset and notifications
- 🗄️ **Database Management** – PostgreSQL with SQLAlchemy ORM

## 📋 Prerequisites

### System Requirements

- **Flutter SDK** 3.7.2 or higher
- **Python** 3.9 or higher
- **PostgreSQL** 12 or higher (for production)
- **SQLite** (for development)
- **Android Studio** / **VS Code** for development
- **Git** version control

### Development Tools

- Git version control
- Postman/FastAPI Swagger Docs (for API testing)
- Android/iOS emulators or physical devices

## 🚀 Installation & Setup

### 1. Clone the Repository

```bash
git clone https://github.com/mastermind-fa/TeamMechaBytes.git
cd HelpMate
```

### 2. Backend Setup

#### Navigate to backend directory

```bash
cd backend
```

#### Create and activate virtual environment

```bash
python -m venv venv
# On Windows
venv\Scripts\activate
# On macOS/Linux
source venv/bin/activate
```

#### Install dependencies

```bash
pip install -r requirements.txt
```

#### Environment Configuration

Create a `.env` file in the backend directory:

```env
# Database Configuration
DATABASE_URL=postgresql://username:password@localhost:5432/helpmate
# For development (SQLite)
DATABASE_URL=sqlite:///./helpmate.db

# JWT Configuration
JWT_SECRET_KEY=your-super-secret-jwt-key-here
JWT_ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30

# Email Configuration
GMAIL_USER=your-email@gmail.com
GMAIL_PASSWORD=your-app-password

# SSLCommerz Configuration
SSLCOMMERZ_STORE_ID=your-store-id
SSLCOMMERZ_STORE_PASSWORD=your-store-password
SSLCOMMERZ_SANDBOX=true

# Environment
ENVIRONMENT=development
```

#### Database Setup

```bash
# For PostgreSQL
createdb helpmate

# Run migrations
python migrate_db.py

# Initialize database with sample data
python init_db.py
```

#### Start the backend server

```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

### 3. Frontend Setup

#### Navigate to project root

```bash
cd ..
```

#### Install Flutter dependencies

```bash
flutter pub get
```

#### Configure API endpoints

Update `lib/services/api_service.dart` with your backend URL:

```dart
const String baseUrl = "http://localhost:8000/api/v1";
```

#### Run the Flutter app

```bash
# For development
flutter run

# For specific platforms
flutter run -d chrome      # Web
flutter run -d android     # Android
flutter run -d ios         # iOS
```

## 📦 Download APK

You can download the latest HelpMate Android APK from the following Google Drive link:

[👉 Download HelpMate APK](https://drive.google.com/file/d/1bA_7Cc5rmsa--bhDB-CaUDA9av-vfsaZ/view?usp=sharing)

**Supported Platforms:**
- ✅ **Android** - Full support with native features
- ✅ **iOS** - Full support with native features  
- ✅ **Web** - Full support with responsive design

---

## 🏗️ Project Architecture

### Backend Architecture

```
backend/
├── app/
│   ├── core/              # Core configuration
│   │   ├── config.py      # App configuration
│   │   ├── database.py    # Database connection
│   │   └── security.py    # Security utilities
│   ├── models/            # Database models
│   │   ├── user.py        # User model
│   │   ├── worker.py      # Worker model
│   │   ├── order.py       # Order model
│   │   └── chat.py        # Chat model
│   ├── routers/           # API routes
│   │   ├── auth.py        # Authentication endpoints
│   │   ├── workers.py     # Worker management
│   │   ├── orders.py      # Order management
│   │   ├── chat.py        # Chat endpoints
│   │   └── admin.py       # Admin endpoints
│   ├── schemas/           # Pydantic schemas
│   ├── services/          # Business logic
│   └── main.py           # FastAPI app initialization
├── static/               # Static files
├── requirements.txt     # Python dependencies
└── main.py             # Entry point
```

### Frontend Architecture

```
lib/
├── main.dart                    # App entry point
├── constants/                   # App constants
│   └── theme.dart              # App theme configuration
├── models/                      # Data models
│   ├── user.dart
│   ├── worker.dart
│   ├── order.dart
│   └── chat.dart
├── services/                    # API services
│   ├── api_service.dart
│   ├── auth_service.dart
│   └── sslcommerz_service.dart
├── providers/                   # State management
│   ├── auth_provider.dart
│   └── notification_provider.dart
├── screens/                     # UI screens
│   ├── auth/                    # Authentication screens
│   ├── home_tabs/              # Main app tabs
│   ├── worker/                 # Worker-related screens
│   ├── orders/                 # Order management
│   ├── chat/                   # Chat screens
│   └── admin/                  # Admin screens
└── assets/                     # Static assets
    ├── images/                 # App images & logos
    ├── icons/                  # App icons
    └── fonts/                  # Custom fonts
```

## 🔧 Development

### Backend Development

- **API Documentation**: Available at `http://localhost:8000/docs` (Swagger UI)
- **Database Migrations**:
  ```bash
  python migrate_db.py
  ```

### Frontend Development

- **Hot Reload**: Enabled automatically in development mode
- **Build for Development**:
  ```bash
  flutter run
  ```
- **Build for Production**:
  ```bash
  flutter build apk --release           # Android APK
  flutter build ios --release           # iOS
  flutter build web --release           # Web
  ```

## 🛡️ Security Features

- **JWT Authentication** with secure token management
- **Password Hashing** using bcrypt
- **Input Validation** with Pydantic schemas
- **CORS Configuration** for web security
- **SQL Injection Protection** via SQLAlchemy ORM
- **File Upload Validation** for images
- **Environment Variables** for sensitive data
- **Secure Payment Processing** via SSLCommerz

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/amazing-feature`
3. **Make your changes** following our coding standards
4. **Write tests** for new functionality
5. **Commit your changes**: `git commit -m 'Add amazing feature'`
6. **Push to the branch**: `git push origin feature/amazing-feature`
7. **Open a Pull Request**

### Coding Standards

- Follow **Flutter/Dart** style guidelines
- Follow **PEP 8** for Python code
- Write **meaningful commit messages**
- Include **tests** for new features
- Update **documentation** as needed
- Use **conventional commits** format

## 👥 Contributors

<div align="center">

### 🚀 Project Team

<table>
  <tr>
    <td align="center">
      <img src="assets/images/farhana.png" width="100px;" height="100px;" alt="Farhana Alam" style="border-radius: 50%; object-fit: cover;"/>
      <br />
      <sub><b>Farhana Alam</b></sub>
      <br />
      <a href="https://github.com/mastermind-fa">🐛 💻 📖</a>
      <br />
      <small>Full-Stack Developer</small>
    </td>
    <td align="center">
      <img src="assets/images/jubair.png" width="100px;" height="100px;" alt="Jubair" style="border-radius: 50%; object-fit: cover;"/>
      <br />
      <sub><b>Jubair</b></sub>
      <br />
      <a href="https://github.com/Jubair-Adib">💻 🎨 📱</a>
      <br />
      <small>Frontend Developer</small>
    </td>
    <td align="center">
      <img src="assets/images/kabbo.png" width="100px;" height="100px;" alt="Kabbo" style="border-radius: 50%; object-fit: cover;"/>
      <br />
      <sub><b>Kabbo</b></sub>
      <br />
      <a href="https://github.com/shakinalamkabbo">💻 🗃️ ⚡</a>
      <br />
      <small>Backend Developer</small>
    </td>
    <td align="center">
      <img src="assets/images/masum.png" width="100px;" height="100px;" alt="Masum" style="border-radius: 50%; object-fit: cover;"/>
      <br />
      <sub><b>Masum</b></sub>
      <br />
      <a href="https://github.com/nmrmasum">💻 🧪 📊</a>
      <br />
      <small>UI/UX Designer</small>
    </td>
  </tr>
</table>

</div>

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

## 🆘 Support & Documentation

### Getting Help

- 📧 **Email Support**: support@helpmate.com
- 📖 **API Documentation**: Available at `/docs` when running the backend
- 🐛 **Issue Tracker**: Report bugs and feature requests on GitHub

### Useful Links
- [Flutter Documentation](https://docs.flutter.dev/)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [SSLCommerz Documentation](https://developer.sslcommerz.com/)

---

<div align="center">

**Made with ❤️ for the home service community**

*Connecting skilled workers with customers for quality home services*

[⬆ Back to Top](#helpmate-) | [📑 Table of Contents](#-table-of-contents)

</div>
