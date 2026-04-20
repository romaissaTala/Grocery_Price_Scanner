# 🛒 Grocery Price Scanner

[![Flutter](https://img.shields.io/badge/Flutter-3.16.0-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.2.0-blue.svg)](https://dart.dev)
[![Supabase](https://img.shields.io/badge/Supabase-PostgreSQL-green.svg)](https://supabase.com)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

> Scan barcodes, compare prices, and save money on your grocery shopping!

## 📱 Screenshots

<div align="center">
  <img src="demo/screenshots/scanner.jpg" width="200" alt="Scanner"/>
  <img src="demo/screenshots/product.jpg" width="200" alt="Product Details"/>
  <img src="demo/screenshots/history.jpg" width="200" alt="Scan History"/>
  <img src="demo/screenshots/stores.jpg" width="200" alt="Stores"/>
</div>

## ✨ Features

- 🔍 **Barcode Scanner** - Fast and accurate barcode detection using ML Kit
- 💰 **Price Comparison** - Compare prices across multiple local stores
- 📊 **Price History** - Track price trends over time
- 🏷️ **Product Details** - Get detailed product information including nutrition facts
- 📜 **Scan History** - Keep track of all your scanned products
- 🏪 **Store Directory** - Browse and filter stores by location
- 📈 **Savings Calculator** - See how much you can save by shopping at the cheapest store
- 🌓 **Dark/Light Mode** - Full theme support
- 📱 **Responsive Design** - Works on all screen sizes

## 🛠️ Tech Stack

| Technology | Purpose |
|------------|---------|
| **Flutter** | Cross-platform UI framework |
| **Dart** | Programming language |
| **Supabase** | Backend (PostgreSQL, Auth, Storage) |
| **BLoC** | State management |
| **GetIt** | Dependency injection |
| **Hive** | Local database |
| **Mobile Scanner** | Barcode scanning |
| **fpdart** | Functional programming |

## 🏗️ Architecture

The project follows **Clean Architecture** with a **Feature-First** structure:
lib/
├── core/ # Core utilities, themes, constants
├── features/ # Feature modules
│ ├── product/ # Product search & display
│ ├── scanner/ # Barcode scanning
│ ├── history/ # Scan history
│ ├── stores/ # Store management
│ ├── onboarding/ # User onboarding
│ └── splash/ # Splash screen
└── main.dart # App entry point


## 🚀 Getting Started

### Prerequisites

- Flutter SDK (>=3.16.0)
- Dart SDK (>=3.2.0)
- Android Studio / VS Code
- Supabase account

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/romaissaTala/Grocery_Price_Scanner.git
cd Grocery_Price_Scanner
Install dependencies

bash
flutter pub get
Configure Supabase

Create a Supabase project

Run the SQL script from database/schema.sql

Update lib/core/constants/app_constants.dart with your credentials

Run the app

bash
flutter run
Building APK
bash
flutter build apk --release
Building App Bundle
bash
flutter build appbundle --release
📊 Database Schema
The app uses a PostgreSQL database with the following main tables:

products - Product information (barcode, name, brand, nutrition)

stores - Store information (name, location, contact)

prices - Current prices per store

price_history - Historical price data

scan_history - User scan records

tracked_products - User saved products

🔄 CI/CD Pipeline
The project uses GitHub Actions for:

✅ Automated testing

✅ Code formatting verification

✅ Static analysis

✅ APK and AAB builds

✅ Optional Firebase Distribution deployment

📁 Project Structure
text
Grocery_Price_Scanner/
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   ├── di/
│   │   ├── errors/
│   │   ├── network/
│   │   ├── router/
│   │   ├── themes/
│   │   ├── utils/
│   │   └── widgets/
│   └── features/
│       ├── product/
│       ├── scanner/
│       ├── history/
│       ├── stores/
│       ├── onboarding/
│       └── splash/
├── android/
├── ios/
├── test/
├── demo/
│   └── app.pdf
├── pubspec.yaml
└── README.md
🤝 Contributing
Fork the repository

Create your feature branch (git checkout -b feature/AmazingFeature)

Commit your changes (git commit -m 'Add some AmazingFeature')

Push to the branch (git push origin feature/AmazingFeature)

Open a Pull Request

📄 Demo
You can find the app demo PDF at demo/app.pdf

📝 License
This project is licensed under the MIT License - see the LICENSE file for details.

👩‍💻 Author
Romaissa Tala

GitHub: @romaissaTala

Project Link: https://github.com/romaissaTala/Grocery_Price_Scanner

🙏 Acknowledgments
Open Food Facts API for product data

Flutter community for amazing packages

Supabase for excellent backend services

<div align="center"> Made with ❤️ by Romaissa Tala </div>