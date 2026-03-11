<!-- 
# glamore-ecommerce-flutter

Glamoré is a Flutter-based fashion e-commerce mobile app designed especially for women. The app simulates a complete shopping experience including authentication, product browsing, favorites, cart management, coupons, and order placement, powered by Riverpod and Supabase.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference. -->


# 🌺 Glamore  
*Stylish & Scalable Flutter E‑Commerce App for Fashion Lovers*

![Flutter](https://img.shields.io/badge/Flutter-3.13-blue.svg) ![Dart](https://img.shields.io/badge/Dart-3.4-blue.svg) ![Riverpod](https://img.shields.io/badge/Riverpod-2.6.1-orange) ![Supabase](https://img.shields.io/badge/Supabase-2.10.3-green) ![License](https://img.shields.io/badge/License-MIT-lightgrey)

---

## 📄 Professional Description  
Glamore is a full‑featuredFlutter-based mobile shopping application tailored for the fashion market.  
It demonstrates a clean architecture, robust state management with Riverpod, and real‑world backend connectivity using Supabase.  
Designed as a portfolio project, it simulates an end‑to‑end e‑commerce flow—from authentication and product browsing to checkout and order history.

---

## 💡 Problem Statement  
In building a strong mobile development portfolio, recruiters look for apps that combine UI polish, state management, backend integration, and offline resilience.  
Glamore solves this by offering a realistic e‑commerce experience with a modular codebase that’s easy to understand, extend, and maintain.

---

## ✅ Key Features

- **User Authentication**
  - Email/password sign‑up, login, password reset
  - Profile editing and secure session handling
- **Product Catalog**
  - Category-based browsing (dresses, shoes, watches, bags, jewellery)
  - Search and filtered results
  - Home screen showcases one product per category
- **Favorites**
  - Toggle favorite state for products
  - Managed via Riverpod state notifier
- **Shopping Cart**
  - Add, increment, decrement, remove items
  - Persistent cart tied to user session
  - Offline fallback with local cache
- **Checkout & Orders**
  - Order placement with shipping details
  - Order history view
  - Coupon code entry
- **Settings & Profile**
  - Change password, update profile, manage shipping address
- **State Management**
  - Riverpod providers & controllers with `AsyncValue`
  - Optimistic UI updates for cart actions
- **Backend Integration**
  - Supabase for authentication, product, cart, and order data
  - Environment configuration via .env
- **Offline Resilience**
  - Fallback data when backend tables are missing
  - Local in‑memory cache for cart

---

## 🖼 App Screenshots / UI Preview

| Welcome / Auth | Home / Categories |
|---------------|-------------------|
| !splash | !home |

| Product Details | Cart / Checkout |
|-----------------|-----------------|
| !product | !cart |

| Profile / Settings | Order History |
|--------------------|----------------|
| !profile | !orders |

---

## 🎬 Demo / GIF  
> _Placeholder for demo video or GIF demonstrating flows._

---

## 🛠 Tech Stack

- **Framework:** Flutter
- **Language:** Dart
- **State Management:** Riverpod
- **Backend / APIs:** Supabase (Auth, PostgREST)
- **Database:** Supabase Postgres
- **Local Storage:** shared_preferences
- **Configuration:** flutter_dotenv
- **Fonts & Icons:** google_fonts, cupertino_icons
- **Dev Tools:** flutter_lints, flutter_launcher_icons

---

## 🏗 Architecture Overview

The app follows a **feature‑based modular architecture**:

- **Core**: Shared utilities and Supabase configuration.
- **Features**: Each major capability (auth, catalog, cart, orders) has its own folder containing:
  - `data/` for repository classes
  - `presentation/` for Riverpod providers & controllers
  - Models are defined in a central `Model/` folder.
- **UI Layers**: 
  - `view/` contains screen widgets organized by domain.
  - `widgets/` holds reusable components.
- **Singletons** & **utils** for app-wide utilities.

This structure promotes separation of concerns and scalability.

---

## 📁 Folder Structure Explanation

```
lib/
├── auth/                     # UI for login, signup, forgot password
├── core/supabase/            # Env‑aware Supabase config
├── features/
│   ├── auth_core/            # Auth repo + providers
│   ├── catalog_core/         # Product repo/providers
│   ├── cart_core/            # Cart repo/providers
│   └── order_core/           # Order repo/providers
├── Model/                    # Data models (user, cart item, order)
├── Singleton/                # Global state (e.g. current user)
├── utils/                    # Colors, helpers
├── view/                     # Screens (home, profile, cart, settings)
└── widgets/                  # Shared UI components
```

Assets are stored under images with branding and product photos.

---

## 📥 Installation Guide

1. Clone the repository:

   ```bash
   git clone https://github.com/<your-username>/glamore.git
   cd glamore
   ```

2. Create a .env file in the root:

   ```env
   SUPABASE_URL=your_supabase_url
   SUPABASE_ANON_KEY=your_anon_key
   ```

3. Install dependencies:

   ```bash
   flutter pub get
   ```

4. (Optional) Generate launcher icons:

   ```bash
   flutter pub run flutter_launcher_icons:main
   ```

---

## ▶️ How to Run

```bash
flutter run
```

> Use `flutter build apk` / `flutter build ios` for production builds.  
> Ensure the .env file is present; config is loaded automatically in main.dart.

---

## 📦 Dependencies Used

- flutter_riverpod
- supabase_flutter
- shared_preferences
- google_fonts
- flutter_dotenv
- cupertino_icons

Dev:

- flutter_test
- flutter_lints
- flutter_launcher_icons

(Versions locked in pubspec.yaml)

---

## 🧩 Key Functional Modules

- **AuthRepository / AuthActionController**
- **CatalogRepository / CatalogProviders**
- **CartRepository / CartController** (with optimistic update logic)
- **OrderRepository** & order history handling
- **SupabaseConfig** for environment‑driven backend URL/keys
- **UserSingleton** for global user data

---

## 🚀 Performance & Scalability Considerations

- Async network calls handled with `AsyncValue` to avoid blocking UI
- Local fallbacks prevent crashes when backend tables are missing
- Optimistic updates in cart improve perceived speed
- Modular providers make it easy to introduce caching or pagination
- Supabase backend can scale with project needs

---

## 🔮 Future Improvements

- Add payment gateway (Stripe / Razorpay)
- Product reviews & ratings
- Push notifications (order updates, promotions)
- Multi‑currency & internationalization
- Full unit and widget test coverage
- Web & desktop responsive UI
- Real‑time cart sync across devices
- CI/CD pipeline for automated builds

---

## ✍️ Author

**Your Name**  
[GitHub Profile](https://github.com/your-username)  
[LinkedIn](https://linkedin.com/in/your-profile)  
[Portfolio](https://yourdomain.com)

---

## 📎 License

This project is released under the **MIT License**.  
See LICENSE for details.

---

> _Glamore showcases clean architecture, modern Flutter patterns, and real backend integration—making it a powerful portfolio artifact that tells a story to recruiters and technical leads alike._
