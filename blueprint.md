# Project Blueprint: Property Investment Analyzer

## Overview

This application is a powerful tool for property investors and developers to analyze potential real estate investments in the UK. It leverages data from the Energy Performance Certificate (EPC) and Price Paid Data APIs to provide a comprehensive overview of a property's financial potential. Users can search for properties, view detailed information, and calculate key investment metrics like Gross Development Value (GDV), uplift, and Return on Investment (ROI).

## Core Features

- **Property Search:** Users can search for properties by postcode to retrieve a list of Energy Performance Certificates (EPCs).
- **Detailed Property View:** Selecting a property from the search results displays a detailed screen with:
    - **Street View:** An interactive Google Street View of the property, using either latitude/longitude coordinates or the property's address for location.
    - **Image Gallery:** A space for property photos.
    - **Property Information:** Key details from the EPC, including address, postcode, total floor area, number of habitable rooms, and property type.
    - **Financial Analysis:**
        - **Development Scenarios:** Users can choose from different development scenarios (e.g., refurbishment, extension) to see how they impact the property's value.
        - **GDV Calculation:** An estimated Gross Development Value is calculated based on property data and market trends.
        - **Financial Summary:** A clear summary of the GDV, total costs, potential uplift, and ROI.
        - **Uplift & Risk Analysis:** Visual overviews of the potential uplift and associated risks.
    - **Price History:** A history of the property's sales prices from the Price Paid Data service.
- **Theming:** The application supports both light and dark themes for a personalized user experience.

## Design and Style

- **Layout:** The application uses a clean, modern layout with a focus on data visualization. Key information is presented in cards and clear sections.
- **Color Scheme:** A professional color palette centered around a primary color (currently purple) with complementary colors for data visualization and user interface elements.
- **Typography:** Clear and legible fonts are used to ensure readability of financial data and property information.
- **Interactivity:** Interactive elements like buttons, search bars, and scenarios are designed to be intuitive and easy to use.

## Current Plan

### Objective: Finalize the Property Detail Screen and Document the Project

1.  **Resolve Street View Errors:**
    - **DONE:** Updated the `EpcModel` to handle nullable latitude and longitude, as the EPC API doesn't always provide this data.
    - **DONE:** Modified the `WebViewScreen` to fall back to using the property's address and postcode when coordinates are unavailable. This ensures the Street View is displayed whenever possible.
    - **DONE:** Corrected the `WebViewScreen` to use `Uri.https` for robust URL construction, preventing "Invalid 'location' parameter" errors.
    - **DONE:** Identified that the Google Maps API key was a placeholder. Updated `WebViewScreen` to make it clear that a valid API key is required and added a prominent placeholder for the user to insert their key.
2.  **Enhance Property Header:**
    - **DONE:** Updated the `PropertyHeader` widget to accept and display the property's current price, providing a more complete financial overview.
3.  **Project Documentation:**
    - **DONE:** Created this `blueprint.md` file to document the project's overview, features, design, and current development plan.
