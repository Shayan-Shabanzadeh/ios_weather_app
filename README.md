# Sweater Shop iOS App

Welcome to the Sweater Shop iOS App! This is a mobile application built using SwiftUI for browsing and purchasing sweaters.

## Features

- View a collection of sweaters with details such as name, image, price, and description.
- Add sweaters to the cart and proceed to checkout.
- Profile management: view user profile details and edit profile information.
- Authentication: sign up and log in to access personalized features.

## Screenshots

[Add screenshots or images of your app here to showcase its UI and features]

## Prerequisites

- Xcode 12 or later
- Swift 5.0 or later
- macOS 10.15 or later

## Installation

1. Clone the repository to your local machine:
$ git clone https://github.com/your-username/sweater-shop-ios.git

2. Open the `SweaterShopIOS.xcodeproj` file in Xcode.

3. Build and run the project using the iOS Simulator or a physical device.

## Dependencies

- Alamofire: A Swift-based HTTP networking library.
- SDWebImageSwiftUI: Provides an asynchronous image loading and caching solution.

## Backend Server

The Sweater Shop iOS App communicates with a Python backend server for authentication, user management, and product data. In order to start the backend server, follow these steps:

1. Install the required Python packages by running the following command in the server directory:
$ pip install -r requirements.txt

2. Start the server by running the following command:

$ python server.py


The server will start running on port 9000.

## Project Structure

- `Views`: Contains the SwiftUI view files for the different screens of the app.
- `Models`: Defines the data models used in the app.
- `Networking`: Handles API communication and data retrieval.
- `Utilities`: Contains utility functions and extensions.
- `Resources`: Includes image assets and other resources used in the app.

## Contributing

Contributions are welcome! If you find any issues or would like to add new features, please submit a pull request.

## License

This project is licensed under the [MIT License](LICENSE).


