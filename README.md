# Property Stalker

## Overview

Property Stalker is a Flutter-based application designed for property investors and developers to analyze potential property deals. The application allows users to search for properties, calculate key financial metrics, and generate detailed PDF reports. It also integrates with external APIs to provide valuable data, such as local planning applications.

## Features

- **Property Search:** Search for properties by postcode and address.
- **Financial Analysis:** Automatically calculates metrics like Gross Development Value (GDV), total project cost, and potential uplift.
- **Scenario Selection:** Allows users to select different investment scenarios to model various outcomes.
- **PDF Report Generation:** Generates comprehensive PDF reports that include financial breakdowns, pie charts, and a list of nearby planning applications.
- **Planning Data:** Fetches and displays recent planning applications in the property's vicinity from the PlanIt API.
- **Cloudinary Integration:** Uploads generated reports to Cloudinary for easy sharing and storage.
- **Supabase Integration:** Utilizes Supabase for backend services and data storage.

## Getting Started

### Prerequisites

- Flutter SDK: Make sure you have the Flutter SDK installed. For this project, a version compatible with Flutter 3.x is recommended.
- Firebase Account: A Firebase project is required for analytics and other Firebase services.
- Supabase Account: A Supabase project is needed for the database and backend services.
- Cloudinary Account: Required for storing generated PDF reports.
- PlanIt API Key: An API key for the PlanIt API is necessary to fetch planning application data.

### Installation

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd <repository-folder>
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure environment variables:**
   Create a file `lib/utils/constants.dart` and add the following constants with your own keys:
   ```dart
   const String superbaseUrl = 'YOUR_SUPERBASE_URL';
   const String superbaseAnonKey = 'YOUR_SUPERBASE_ANON_KEY';
   const String cloudinaryCloudName = 'YOUR_CLOUDINARY_CLOUD_NAME';
   const String cloudinaryUploadPreset = 'YOUR_CLOUDINARY_UPLOAD_PRESET';
   const String planitApiKey = 'YOUR_PLANIT_API_KEY';
   ```

4. **Run the app:**
   ```bash
   flutter run
   ```

## Key Dependencies

- **`flutter`:** The core framework for building the application.
- **`go_router`:** For declarative routing and navigation.
- **`provider`:** For state management and dependency injection.
- **`firebase_core`**, **`firebase_analytics`:** For Firebase integration and analytics.
- **`supabase_flutter`:** For interacting with the Supabase backend.
- **`pdf`**, **`printing`:** For generating and displaying PDF reports.
- **`fl_chart`:** For creating charts in the PDF reports.
- **`cloudinary_public`:** For uploading files to Cloudinary.
- **`searchfield`:** For providing autocomplete suggestions in search fields.

## Project Structure

The project follows a standard Flutter project structure, with the core application code located in the `lib` directory. Key subdirectories include:

- **`lib/screens`:** Contains the UI for different screens of the application.
- **`lib/controllers`:** Contains the business logic and state management for different features.
- **`lib/services`:** Contains services for interacting with external APIs (Supabase, Cloudinary, PlanIt).
- **`lib/models`:** Contains the data models used throughout the application.
- **`lib/utils`:** Contains utility classes and constants.
- **`lib/widgets`:** Contains reusable UI components.

## Logging and Error Handling

The application uses the `dart:developer` library for structured logging. This allows for effective debugging and monitoring of the application's behavior. Errors are handled gracefully, with informative messages displayed to the user.
