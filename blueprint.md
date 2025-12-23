# Project Blueprint

## Overview

This application is a sophisticated financial analysis and reporting tool designed for property industry professionals, such as estate agents, developers, and surveyors. It provides deep insights into property financials, enabling users to model development scenarios, calculate Gross Development Value (GDV), and generate comprehensive reports. The core purpose is to facilitate data-driven decision-making for property investment and development, **not** to act as a consumer-facing platform for buying or selling property.

## Style, Design, and Features

### Implemented Features

*   **Authentication:** Secure user authentication handled via Supabase, with options for email/password and magic link sign-in.
*   **User & Company Profiles:** Professionals can manage their personal and company profiles.
*   **Property Data Aggregation:** The application aggregates key property data, including:
    *   Energy Performance Certificates (EPC), now including the number of habitable rooms.
    *   Price paid history.
*   **Postcode & Geolocation:** Includes postcode lookup with autocomplete and geolocation to find nearby properties.
*   **Financial Modeling Engine:**
    *   **Development Scenarios:** Users can select from a wide range of development scenarios (e.g., extensions, loft conversions) to model potential outcomes.
    *   **GDV Calculator:** A weighted calculator for determining the Gross Development Value based on sold, on-market, and area comparable data. Now includes a placeholder estimation method based on postcode and habitable rooms.
    *   **Financial Summary:** A high-level overview of key deal metrics, including GDV, Total Cost, Uplift (Profit), and ROI.
*   **Uplift & Risk Overview:** A compact, high-level panel displaying key contextual indicators for the selected development scenario:
    *   **Uplift %:** Profit as a percentage of total investment (ROI).
    *   **Area Growth %:** The percentage increase in internal floor area.
    *   **Risk Indicator:** A qualitative assessment (Low, Medium, Higher) of execution and market risk based on planning requirements and scale of works.
*   **Detailed Uplift Analysis:** A comprehensive table that breaks down the potential value-add for *all* possible development scenarios, detailing the added area (m²), the uplift rate (£/m²), and the total uplift (£) for each option.
*   **Image Integration:** Users can upload images of a property, which are included in generated reports. The image gallery is now a self-contained widget.
*   **Report Generation & Export:** Users can compile and send financial reports.

### Design

*   **Theme:** A clean and professional Material 3 theme with a color scheme generated from a seed color, suitable for a business application.
*   **Typography:** Clear and legible typography using the `google_fonts` package.
*   **Layout:** The application uses a standard `Scaffold` layout with a focus on clear data presentation through `Card`s, `Table`s, and custom data visualization widgets.

## Current Task

*   **Comprehensive Testing:**
    *   **PropertyHeader Widget Test:** Created `test/widgets/property_header_test.dart` to verify the UI behavior of the `PropertyHeader`. This test ensures that the price text is initially displayed correctly and that tapping the edit icon successfully switches the UI to an editable `TextFormField`.
    *   **PropertyHeaderController Unit Test:** Created `test/controllers/property_header_controller_test.dart` to test the business logic of the header's state management. This test verifies that the `isEditingPrice` flag is managed correctly and that the controller notifies its listeners upon state changes.
    *   **FinancialController Unit Test:** Created `test/controllers/financial_controller_test.dart` to validate the core financial logic. These tests confirm that the controller initializes correctly, `setCurrentPrice` triggers the appropriate recalculations, and the main `calculateFinancials` method produces accurate results for `totalCost`, `uplift`, `roi`, and `riskIndicator` across different development scenarios.
    *   **Iterative Correction:** The testing process involved identifying and fixing several bugs and inaccuracies in the test files themselves, leading to a robust and reliable test suite.
