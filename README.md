# Kigali City Services & Places Directory Mobile Application

A Flutter mobile application that helps Kigali residents locate and navigate to essential public services as well as leisure and lifestyle locations such as hospitals, police stations, public libraries, utility offices, restaurants, cafés, parks, and tourist attractions.

---

## Features

- **User Authentication** — Email/password sign-up and sign-in with Firebase Authentication.
- **Service Directory** — Browse all submitted listings with real-time updates. Filter by category and search by name, address, or description.
- **My Listings** — Authenticated users can create, edit, and delete their own listings.
- **Listing Detail** — View full listing information, including an embedded map, coordinates, contact details, and a "Get Directions" button that launches Google Maps externally.
- **Map View** — See all listings as tappable markers on a full-screen interactive map. Tapping a marker navigates to the listing's detail screen.
- **Cross-screen Tab Navigation** — The detail screen includes a shortcut button that switches directly to the Map tab from anywhere in the app.
- **Settings** — Displays the current user's profile (name, email, verification status) and a toggle for enabling/disabling location-based notification preferences (persisted locally via `SharedPreferences`).

---

## Project Structure

```
lib/
├── main.dart                         # App entry point with Firebase & MultiBlocProvider
├── firebase_options.dart              # Generated Firebase configuration
│
├── blocs/
│   ├── auth_management/
│   │   ├── auth_bloc.dart             # Handles auth events, calls AuthService
│   │   ├── auth_event.dart            # AuthCheckRequested, SignIn/Up/Out, etc.
│   │   └── auth_state.dart            # AuthInitial, Authenticated, Unauthenticated, etc.
│   └── listing_management/
│       ├── listing_bloc.dart          # Manages Firestore stream subscriptions + CRUD
│       ├── listing_event.dart         # ListenToAll/User, Create/Update/Delete/Stop
│       └── listing_state.dart         # ListingInitial, Loaded, OperationSuccess, Error
│
├── models/
│   └── listing.dart                  # Listing data model with toMap / fromFirestore
│
├── screens/
│   ├── auth/
│   │   ├── auth_wrapper.dart          # Redirects based on auth + verification state
│   │   ├── login_screen.dart
│   │   ├── signup_screen.dart
│   │   └── email_verification_screen.dart
│   ├── home/
│   │   └── home_screen.dart          # BottomNavigationBar host, tabNotifier
│   ├── directory/
│   │   ├── directory_screen.dart      # Searchable/filterable listing directory
│   │   └── listing_detail_screen.dart # Full detail view with embedded map + directions
│   ├── listings/
│   │   ├── my_listings_screen.dart    # Current user's listings with edit/delete
│   │   └── add_edit_listing_screen.dart # Create or edit a listing
│   ├── map/
│   │   └── map_view_screen.dart      # Full-screen map with all listing markers
│   └── settings/
│       └── settings_screen.dart      # Profile info, notification toggle, sign-out
│
├── services/
│   ├── auth_service.dart             # Firebase Auth + Firestore user profile operations
│   └── listing_service.dart          # Firestore CRUD and stream queries for listings
│
├── utils/
│   └── app_theme.dart                # Centralised theme, colours, and text styles
│
└── widgets/
    └── listing_card.dart             # Reusable card widget used in directory and my listings
```
---

## Setup Instructions

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart SDK `^3.10.7`)
- [Firebase CLI](https://firebase.google.com/docs/cli) (`npm install -g firebase-tools`)
- [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/) (`dart pub global activate flutterfire_cli`)
- An Android or iOS device/emulator

### Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/hd77alu/mob_dev_individual_assignment-2
   cd mob_dev_individual_assignment-2
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase** — see the [Firebase Setup](#firebase-setup) section below. Make sure `lib/firebase_options.dart` exists before running the app.

4. **Run the app**
   ```bash
   flutter run
   ```

---

## Firebase Setup

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com).
2. Enable **Email/Password** under Authentication → Sign-in methods.
3. Add Android and/or iOS apps to the project and download the respective `google-services.json` / `GoogleService-Info.plist` files into the platform directories.
4. The `lib/firebase_options.dart` file is generated by the FlutterFire CLI (`flutterfire configure`) and must be present for the app to initialise Firebase.
5. Deploy the Firestore security rules from `firestore.rules` using the Firebase CLI:
   ```
   firebase deploy --only firestore
   ```

---

## Firestore Database Structure

The application uses two top-level Firestore collections.

```
classDiagram
    class users {
        +uid : String
        +name : String
        +email : String
        +emailVerified : Boolean
        +createdAt : Timestamp
    }

    class listings {
        +id : String
        +name : String
        +category : String
        +address : String
        +contactNumber : String
        +description : String
        +latitude : Number
        +longitude : Number
        +createdBy : String
        +timestamp : Timestamp
    }

    users "1" --> "0..*" listings: createdBy (uid)
```

### `users` collection
Each document is indexed by the Firebase Authentication UID and stores the user's name, email address, email verification status, and account creation timestamp.

### `listings` collection
Each document is auto-generated by Firestore and stores the business or service details. The `createdBy` field holds the UID of the user who submitted the listing, forming a logical one-to-many relationship: one user can own many listings, and every listing belongs to exactly one user.

---

## State Management

The app uses the **BLoC (Business Logic Component)** pattern via the `flutter_bloc` package. All BLoCs are provided at the app root in `main.dart` through `MultiBlocProvider`, making them available to every screen.

### `AuthBloc`
Manages the full authentication lifecycle.

| Event | Description |
|---|---|
| `AuthCheckRequested` | Checks persisted auth state on app launch |
| `SignUpRequested` | Creates a new account and sends a verification email |
| `SignInRequested` | Signs in and syncs email verification status with Firestore |
| `SignOutRequested` | Signs out the current user |
| `CheckVerificationStatusRequested` | Re-checks email verification status |
| `ResendVerificationEmailRequested` | Resends the verification email |

**States:** `AuthInitial` → `AuthLoading` → `AuthAuthenticated` / `AuthUnauthenticated` / `AuthError` / `AuthSuccess`

### `ListingBloc`
Manages all listing data via live Firestore stream subscriptions.

| Event | Description |
|---|---|
| `ListenToAllListings` | Subscribes to all listings (Directory + Map tabs) |
| `ListenToUserListings` | Subscribes to the current user's listings (My Listings tab) |
| `CreateListing` | Adds a new listing to Firestore |
| `UpdateListing` | Updates an existing listing |
| `DeleteListing` | Deletes a listing |
| `StopListeningToListings` | Cancels the active Firestore subscription (called before sign-out to prevent permission errors) |

**States:** `ListingInitial` → `ListingLoading` → `ListingLoaded` / `ListingOperationSuccess` / `ListingError`

The `HomeScreen` switches between `ListenToAllListings` and `ListenToUserListings` whenever the active tab changes.

---

## Navigation Structure

```
AuthWrapper
├── LoginScreen                  (unauthenticated)
│   └── SignUpScreen
├── EmailVerificationScreen      (authenticated, email unverified)
└── HomeScreen                   (authenticated, email verified)
    ├── [Tab 0] DirectoryScreen
    │   └── ListingDetailScreen
    │       └── (Map tab via HomeScreen.tabNotifier)
    ├── [Tab 1] MyListingsScreen
    │   └── AddEditListingScreen (create or edit)
    ├── [Tab 2] MapViewScreen
    │   └── ListingDetailScreen
    └── [Tab 3] SettingsScreen
```

- **`AuthWrapper`** listens to `AuthBloc` and renders the correct root screen based on auth state and email verification.
- **`HomeScreen`** uses a `BottomNavigationBar` with an `IndexedStack` to preserve tab state. It exposes a `static ValueNotifier<int> tabNotifier` that any screen can write to switch tabs programmatically (used by `ListingDetailScreen` to jump to the Map tab).
- All screens use `AutomaticKeepAliveClientMixin` where appropriate to prevent unnecessary rebuilds when switching tabs.

---

## Key Dependencies

| Package | Purpose |
|---|---|
| `flutter_bloc` | BLoC state management |
| `equatable` | Value equality for BLoC events and states |
| `firebase_core` | Firebase initialisation |
| `firebase_auth` | Email/password authentication |
| `cloud_firestore` | NoSQL real-time database |
| `flutter_map` | OpenStreetMap-based interactive maps (no API key required) |
| `latlong2` | `LatLng` coordinate type for flutter_map |
| `url_launcher` | Opens Google Maps directions in an external app |
| `shared_preferences` | Persists notification preference locally |
| `intl` | Date formatting |
