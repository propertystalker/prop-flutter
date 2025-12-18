# Project Blueprint: Property Data Application

## Overview

This document outlines the design, features, and implementation plan for a property data application built with Flutter. The app will provide users with a platform to access and manage property information, including pricing, EPC ratings, and other relevant data.

## Core Features

- **User Authentication:** A registration and login system for users to access the application.
- **Property Data Visualization:** Display property data, including price paid, EPC ratings, and floor area.
- **Data Fetching:** Fetch property data from various external APIs.
- **Database Integration:** Use Supabase to store and manage user and property data.

## Design and Aesthetics

- **Color Palette:** A clean and professional color scheme with a primary color of blue.
- **Typography:** A clear and readable typography scheme.
- **Layout:** A responsive layout that works on both mobile and web.

## Implementation Plan

1.  **Project Setup:**
    *   Add necessary dependencies to `pubspec.yaml`: `supabase_flutter`, `go_router`, `provider`, `http`.

2.  **Authentication:**
    *   Implement user registration and login functionality.

3.  **Data Layer:**
    *   Create models for `Person`, `Company`, and other data structures.
    *   Create services to interact with Supabase and external APIs.

4.  **Routing:**
    *   Configure `go_router` with routes for different screens in the application.

5.  **Screens and Widgets:**
    *   **Opening Screen:** The initial screen with options to register or log in.
    *   **Profile Screen:** A screen to display and manage user profile information.
    *   **Admin Screen:** A screen for administrative tasks.
    *   **Property Data Screens:** Screens to display various property data, such as EPC ratings and price paid information.

