📱 MenteCart Mobile App
A Flutter-based mobile application for browsing services, managing bookings, and handling appointment scheduling.
The app follows clean architecture principles using BLoC state management for scalable and maintainable development.

───

✨ Features
• 🔐 User Authentication
• 🛍 Browse & Search Services
• 🛒 Smart Cart Management
• 📅 Service Slot Selection
• ❌ Booking Cancellation
• ⚡ Real-time State Management
• 🌐 REST API Integration
• 🚨 Centralized Error Handling
• 📱 Responsive UI

───

🧱 Tech Stack

Technology
Usage

Flutter
Mobile Framework

Dart
Language

flutter_bloc
State Management

Dio
Networking

SharedPreferences
Local Storage

Clean Architecture
App Structure



───

📁 Project Structure
Overview
MenteCart Mobile is the Flutter client application for booking services, managing carts, and tracking bookings.
Built with:
• Flutter
• Dart
• BLoC State Management
• Dio HTTP Client
The application follows clean architecture principles with proper separation between presentation, domain, and data layers.

───

Features
Authentication
• User signup/login
• JWT session handling
• Persistent authentication
Service Browsing
• Paginated service listing
• Category filtering
• Search functionality
• Service detail screen
Cart Management
• Add services with selected slots
• Update/remove cart items
• Real-time total calculation
Booking System
• Checkout flow
• Booking history
• Booking cancellation
• Booking status tracking
Error Handling
• Centralized API error mapping
• Network failure handling
• Empty state handling

───

Tech Stack

Layer
Technology

Framework
Flutter

Language
Dart

State Management
flutter_bloc

Networking
Dio

Storage
SharedPreferences

Architecture
Clean Architecture



───

Project Structure
bash
mobile/
├── lib/
│   ├── core/
│   ├── features/
│   │   ├── auth/
│   │   ├── services/
│   │   ├── cart/
│   │   └── bookings/
│   ├── shared/
│   └── main.dart
├── assets/
├── pubspec.yaml
└── .env


───

Environment Setup
Run the app with environment variables:
bash
flutter run --dart-define=BASE_URL=http://localhost:5000/api


───

Installation
bash
cd mobile
flutter pub get


───

Running the Application
bash
flutter run


───

State Management
The application uses the BLoC pattern.
Each feature contains:
• Bloc
• Events
• States
• Repository
• Data source
• UI screens

───

Networking
Dio is configured with:
• Base URL
• JWT interceptor
• Error interceptor
• Timeout handling

───

Screens
Authentication
• Login Screen
• Signup Screen
Services
• Service List Screen
• Service Detail Screen
Cart
• Cart Screen
• Checkout Screen
Bookings
• Booking History Screen
• Booking Detail Screen

───

Packages Used
yaml
dependencies:
  flutter_bloc:
  dio:
  equatable:
  go_router:
  shared_preferences:


───

Testing
Suggested testing areas:
• Bloc unit tests
• API integration tests
• Widget tests
• Authentication flow
• Cart calculations
• Error states

───

Known Limitations
• Offline mode not implemented
• Push notifications not implemented
• Payment integration pending

───

Future Improvements
• Dark mode
• Offline caching
• Real-time booking updates
• Push notifications
• Calendar integrations

───