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
