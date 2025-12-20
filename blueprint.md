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

I have implemented a major enhancement to the financial modeling engine by making the uplift calculations fully dynamic.

*   **Dynamic Uplift Rates:**
    *   Previously, the "Uplift £/m²" values for development scenarios were hardcoded constants.
    *   I have refactored the `GdvController` to replace these fixed rates with **dynamic calculations**.
    *   The controller now uses "uplift factors" (e.g., `_rearExtensionUpliftFactor = 0.55`), which represent the uplift rate as a percentage of the property's base value per square meter.
    *   A new `updateUpliftRates` method recalculates all uplift rates whenever the property's price changes.
*   **Real-time Price Synchronization:**
    *   The `PropertyScreen` now listens for changes to the `currentPrice` in the `FinancialController`.
    *   When the user edits the price, this listener calls the `updateUpliftRates` method in the `GdvController`.
    *   As a result, the entire "Uplift Analysis by Scenario" table is **immediately recalculated and updated**, providing a much more interactive and realistic financial modeling experience.

*   **Made Uplift Analysis Dynamic (Area):**
    *   **Corrected a major flaw** where the "Uplift Analysis by Scenario" table used a hardcoded area for the "Full Refurbishment" scenario.
    *   The `GdvController` has been refactored to remove the fixed `_existingInternalArea` value.
    *   The `PropertyScreen` now passes the actual `totalFloorArea` from the EPC data to the controller.
    *   This ensures the refurbishment scenario is now **dynamically and accurately calculated** based on the specific property's size.
*   **Resolved critical errors and warnings:** 
    *   Fixed a crash caused by calling a non-existent `calculateGdv` method. I implemented this method in the `GdvController` with placeholder logic and updated the `PropertyScreen` to use it correctly.
    *   Corrected an error in the `FinancialController` by adding the `selectedScenario` property, ensuring that financial calculations are correctly performed when the GDV or other inputs change.
    *   Fixed a type mismatch in the `PropertyScreen` by correctly parsing the `totalFloorArea` string to a rounded integer before passing it to the `PropertyStats` widget.
    *   Addressed a `prefer_final_fields` lint warning in `GdvController` for better code quality.
*   **Simplified Data Models:**
    *   The `EpcModel` now includes the `numberHabitableRooms` field, making it a more complete data source.
    *   The `KnownFloorArea` model was removed, and the `PropertyScreen` now directly uses the `EpcModel`.
*   **Streamlined Navigation:** The `EpcScreen` now passes the `EpcModel` object directly to the `PropertyScreen`, eliminating unnecessary data transformation.
*   **Improved Code Structure:**
    *   The `AddressFinderController` has been deleted to simplify the controller structure.
    *   The `ImageGallery` widget has been refactored to be self-contained and manage its own state, improving reusability.
    *   **Refactored `PropertyHeader`:** Created a new `PropertyHeaderController` to manage the widget's state, removing its dependency on the now-deleted `PropertyFloorAreaFilterController`. This makes the `PropertyHeader` a self-contained and reusable component.
