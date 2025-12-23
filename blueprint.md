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

*   **Critical Bug Fix: Stack Overflow Error:**
    *   **Problem:** A severe "Stack Overflow" error was crashing the application, particularly when navigating between different properties. This was caused by an infinite loop in the state management logic. A change in the `FinancialController` would trigger an update in the `GdvController`, which in turn would trigger an update in the `FinancialController`, creating a circular dependency and an endless loop of calculations.
    *   **Solution:** The infinite loop was broken by adding a conditional check to the `_onGdvChanged` listener in the `PropertyScreen`. A new state variable, `_lastGdv`, was introduced to track the last known Gross Development Value. The listener now only proceeds to recalculate the financials if the new `finalGdv` is different from the last known value.
    *   **Result:** This change successfully breaks the circular dependency, resolving the Stack Overflow crash. The application is now stable, and the dynamic financial calculations continue to work as expected. The fix was validated by a full pass of the test suite.

*   **Critical Bug Fix: "Used After Disposed" Error:**
    *   **Problem:** After attempting to fix a memory leak, a more critical bug was introduced, causing the app to crash with a "A PricePaidController was used after being disposed" error. This happened because shared, app-wide controllers were being incorrectly destroyed by the `PropertyScreen` when the user navigated away.
    *   **Correction:** The fix involved reverting the incorrect change. The `dispose` method in `_PropertyScreenState` was corrected to **only remove its listeners** from the shared controllers (`removeListener`). The incorrect calls to `controller.dispose()` were removed.
    *   **Result:** This is the correct Flutter pattern for interacting with shared state from a `StatefulWidget`. It prevents the screen from trying to update after it's gone (fixing the original leak) without destroying the singleton controllers that the rest of the app relies on. The application is now stable, and the fix was verified by a full pass of the test suite.

*   **Comprehensive Testing:**
    *   **PropertyHeader Widget Test:** Created `test/widgets/property_header_test.dart` to verify the UI behavior of the `PropertyHeader`.
    *   **PropertyHeaderController Unit Test:** Created `test/controllers/property_header_controller_test.dart` to test the business logic of the header's state management.
    *   **FinancialController Unit Test:** Created `test/controllers/financial_controller_test.dart` to validate the core financial logic.
