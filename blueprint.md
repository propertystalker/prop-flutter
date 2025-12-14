
# Project Blueprint

## Overview

This project is a Flutter web application designed to interact with the PropertyData API. It allows users to fetch and display property listings based on a given postcode, number of bedrooms, and an API key. It also provides a feature to convert latitude and longitude to a UK postcode.

## Features

*   **Property Search:** Users can input their API key, a postcode, and the desired number of bedrooms to search for properties.
*   **Property List:** The application displays the search results in a clear, scrollable list.
*   **Property Details:** Users can tap on any property in the list to view more detailed information on a separate screen.
*   **Postcode Conversion:** Users can manually enter latitude and longitude to get the corresponding UK postcode.
*   **Web-Based:** The application is built for the web, ensuring it is accessible from any modern browser.
*   **Responsive Design:** The UI is designed to be responsive and work well on different screen sizes.

## Current Plan

### Objective: Add limit and radius fields to the postcode converter.

1.  **Add Input Fields**: Add "Limit" and "Radius" text fields to the `OpeningScreen` below the longitude field.

### Previous Plan: Create an interactive latitude/longitude to postcode converter.

1.  **Add Input Fields**: Added "Latitude" and "Longitude" text fields to the `OpeningScreen`.
2.  **Update "Get Location" Button**: The "Get Location" button now populates these fields with the device's current coordinates.
3.  **Add "Get Postcode" Button**: Added a new button to trigger the postcode conversion.
4.  **Implement "Get Postcode" Logic**: This button takes the values from the text fields, uses the `PostcodeService` to get the postcode, and displays the result in a pop-up dialog.

