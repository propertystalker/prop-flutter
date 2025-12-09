
# Project Blueprint

## Overview

This project is a Flutter web application designed to interact with the PropertyData API. It allows users to fetch and display property listings based on a given postcode, number of bedrooms, and an API key.

## Features

*   **Property Search:** Users can input their API key, a postcode, and the desired number of bedrooms to search for properties.
*   **Property List:** The application displays the search results in a clear, scrollable list.
*   **Property Details:** Users can tap on any property in the list to view more detailed information on a separate screen.
*   **Web-Based:** The application is built for the web, ensuring it is accessible from any modern browser.
*   **Responsive Design:** The UI is designed to be responsive and work well on different screen sizes.

## Current Plan

### Objective: Create a Flutter web screen to load values from the PropertyData API.

1.  **Add Dependencies:**
    *   `http`: For making HTTP requests to the API.
    *   `go_router`: For declarative routing and navigation between screens.

2.  **Structure the Application:**
    *   `lib/main.dart`: The main entry point of the application, responsible for setting up the router and the overall theme.
    *   `lib/models/property.dart`: Contains the data models to represent the property data received from the API.
    *   `lib/screens/home_screen.dart`: The main screen containing the search form and the list of properties.
    *   `lib/screens/property_detail_screen.dart`: A screen to display detailed information about a single property.
    *   `lib/services/api_service.dart`: A service class to handle the logic of making API calls.

3.  **Implement the Home Screen:**
    *   Create a form with `TextFormField`s for the API key, postcode, and bedrooms.
    *   Implement a button to trigger the API call.
    *   Display a loading indicator while the data is being fetched.
    *   Parse the JSON response into a list of `Property` objects.
    *   Use a `ListView.builder` to display the properties.
    *   Each item in the list will be a `ListTile` showing key information (e.g., price, type).
    *   Add an `onTap` event to each `ListTile` to navigate to the detail screen, passing the selected property data.

4.  **Implement the Detail Screen:**
    *   This screen will receive a `Property` object.
    *   Display all available details of the property, such as price, type, distance, and the portal it was listed on.

5.  **Implement the API Service:**
    *   Create a method that takes the API key, postcode, and bedrooms as arguments.
    *   Construct the API URL and make a GET request using the `http` package.
    *   Handle potential errors, such as network issues or a non-successful status code from the API.
    *   Parse the JSON response and return a list of `Property` objects.
