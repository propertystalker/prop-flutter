# Project Blueprint

## Overview

This document outlines the architecture, features, and design of the Flutter application. It serves as a single source of truth for the project's structure and implementation details.

## Style, Design, and Features

### Implemented Features

*   **Authentication:** User authentication is handled via Supabase, with options for email/password and magic link sign-in.
*   **User Profiles:** Users can create and manage their profiles, including personal and company information.
*   **Property Information:** The application provides detailed information about properties, including Energy Performance Certificates (EPC) and price paid history.
*   **Postcode Lookup:** Users can search for postcodes and get autocomplete suggestions.
*   **Geolocation:** The app can use the device's location to find nearby postcodes.

### Design

*   **Theme:** The app uses a Material 3 theme with a color scheme generated from a seed color.
*   **Typography:** The app uses the `google_fonts` package for custom fonts.
*   **Layout:** The app uses a standard `Scaffold` layout for most screens, with `ListView`s and `Card`s for displaying data.

## Current Task: Create Reports Screen

### Plan

1.  **Create `lib/screens/reports_screen.dart`:** This file will contain the new `ReportsScreen` widget.
2.  **Implement the UI for `ReportsScreen`:**
    *   Use a `Scaffold` with an `AppBar`.
    *   Use a `ListView.builder` to display the 12 uplift options.
    *   Each option will be a `ListTile` with a title and a subtitle.
3.  **Create a data structure for the options:** A `List` of a simple class or `Map`s to hold the title and description of each uplift option.
4.  **Add navigation:**
    *   Modify `lib/router.dart` to add a new route for `/reports`.
    *   Modify `lib/screens/opening_screen.dart` to add a button that navigates to the `/reports` screen.
