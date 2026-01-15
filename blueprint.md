# Project Blueprint

## Overview

This document outlines the architecture and features of the Flutter property analysis application. The application allows users to analyze property deals, generate reports, and view planning application data.

## Features

### Core Features

- **Property Search:** Users can search for properties by address.
- **Deal Analysis:** The application calculates key financial metrics such as estimated profit and return on investment (ROI).
- **Report Generation:** Users can generate PDF reports summarizing the property analysis.

### Key Data Models

- **PropertyReport:** Represents a full property analysis report, including financial metrics, selected scenarios, and key constraints.
- **PlanningApplication:** Represents a single planning application, containing details such as the address, description, status, and received date.

### Services

- **PlanningService:** Fetches planning application data from the PlanIt API.
- **CloudinaryService:** Uploads generated PDF reports to Cloudinary.

## PDF Generation

The `PdfGenerator` class is responsible for creating PDF reports. The reports include:

- A summary of the deal, including a pie chart visualizing the GDV, uplift, and total cost.
- A dedicated page for planning applications, listing all relevant applications for the property's postcode.

## Error Handling and Logging

The application uses the `dart:developer` library for structured logging, allowing for effective debugging and monitoring. Errors are handled gracefully, with informative messages displayed to the user.

## Recent Changes

- **Added Planning Application to PDF:** The PDF report now includes a new page that displays a list of planning applications related to the property. This was achieved by:
    - Updating the `PropertyReport` model to include a list of `PlanningApplication` objects.
    - Modifying the `ReportController` to fetch planning applications using the `PlanningService`.
    - Updating the `PdfGenerator` to create a new page for planning applications.
- **Bug Fixes:** Addressed several bugs and warnings, including:
    - Corrected field names in the `PlanningApplication` model.
    - Fixed null-aware operators in the `PdfGenerator`.
    - Resolved unused variable and `use_build_context_synchronously` warnings.
    - Corrected a `not_enough_positional_arguments` error in the `ReportPanel`.
    - Addressed warnings in the `PlanAppWidget`.
- **Corrected PDF Generation Flow:** Fixed a bug where planning application data was not being included in the PDF generated from the "Send Report" button. The `ReportPanel` now fetches the planning applications before generating the PDF.
- **Refactored Data Flow for Planning Applications:** To improve efficiency and ensure data consistency, the planning application data is now fetched only once in the `PropertyScreen`. This data is then passed down to both the `PlanAppWidget` for display and the `ReportPanel` for PDF generation, eliminating redundant API calls.
- **Resolved Compilation Error:** Fixed a `missing_required_argument` error in the `ScenarioSelectionScreen` by providing the required `planningApplications` parameter to the `ReportPanel` widget.
- **Replaced Custom Autocomplete with `searchfield` Package:** The buggy custom autocomplete implementation in `opening_screen.dart` has been completely replaced with the `searchfield` package. This provides a robust and reliable solution for postcode suggestions, resolving the long-standing bug where tapping a suggestion did not update the input field.
- **Street View Fallback:** The PDF report generation will no longer fail if the Google Street View image is unavailable. A fallback image (`gemini.png`) is now used in its place.
- **Corrected "total floor area" Formatting:** Fixed a bug in the `BuildCostDetails` widget where the "total floor area" was being incorrectly formatted as a currency. It is now displayed as a numerical area with "m²".
- **Fixed Root Cause of Incorrect Floor Area:** Identified and fixed a critical data bug in the `FinancialController`. The `_existingInternalArea` was incorrectly initialized to `1.0`, causing the `BuildCostEngine` to calculate costs based on this placeholder. The value is now correctly initialized to `0.0`, ensuring that cost calculations are only performed when a valid property with a real floor area is selected.
- **Established Correct Data Flow:** Fixed the fundamental data flow issue where the `FinancialController` was not being updated with the property's floor area. The `PropertyScreen` now calls `financialController.updatePropertyData()` in `initState`, ensuring the `BuildCostEngine` has the correct data from the moment the screen loads. This resolves the persistent "total floor area 0" bug.
