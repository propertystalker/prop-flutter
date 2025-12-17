
# Project Blueprint

## Overview

This project is a Flutter web application that provides property data insights. It features a robust user authentication system using Supabase for account creation and login. Once authenticated, users can access property information, including floor area, price history, and financial calculations for development scenarios. The application is designed to be a comprehensive tool for property analysis.

## Style and Design

*   **Theme:** The app uses a clean and modern design with a primary color scheme based on blue.
*   **Layout:** The layout is responsive and adapts to different screen sizes, ensuring a good user experience on both web and mobile.
*   **Interactivity:** The application uses interactive elements like buttons, text fields, and navigation components to create an intuitive user flow.

## Features Implemented

### User Authentication
*   **Supabase Integration:** The app is connected to a Supabase backend for user management and database storage.
*   **Registration:** New users can register with their email, password, and company name. User data is stored in the `auth.users` table, and a corresponding entry is created in the `public.profiles` table.
*   **Login:** Existing users can log in using their email and password.
*   **Dedicated Screens:** The authentication flow is handled through dedicated `EmailLoginScreen` and `RegisterScreen` for a clear user experience.

### Property Analysis
*   **Postcode Search:** The initial screen allows users to search for properties by postcode.
*   **Floor Area:** Displays a list of properties with their known floor areas and habitable rooms.
*   **Detailed Property View:** Tapping on a property opens a detailed screen with:
    *   Property images (placeholder and user-uploadable).
    *   Detailed address and stats.
    *   Price paid history.
    *   Development scenario analysis (GDV, Total Cost, Uplift).
    *   Financial summary (ROI).

### Backend & Database
*   **Supabase Backend:** Utilizes Supabase for authentication and database services.
*   **`profiles` Table:** A `profiles` table has been created to store user-specific data, such as their company name. The table is linked to the `auth.users` table.
*   **Row Level Security (RLS):** RLS policies are in place to ensure that users can only create and manage their own profiles, providing essential data security.

## Project Structure

*   **`lib/`**: Contains the main application code.
    *   **`controllers/`**: Manages the application's state and business logic (e.g., `UserController`, `FinancialController`).
    *   **`models/`**: Defines the data structures used throughout the app.
    *   **`screens/`**: Contains the UI for each page of the application.
    *   **`services/`**: Includes services for interacting with external APIs like Supabase and PropertyData.
    *   **`widgets/`**: Holds reusable UI components.
    *   **`main.dart`**: The main entry point of the application, responsible for initialization and routing.
*   **`blueprint.md`**: This file, providing an overview and documentation of the project.

