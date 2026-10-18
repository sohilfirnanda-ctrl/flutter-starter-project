# Flutter Starter Project Architecture

## Architecture
This project uses the MVVM architecture pattern.

## Folder Structure
- lib/app: Application setup and configuration.
- lib/data: Data models and data sources.
- lib/presentation: User interface and view models.
- lib/utils: Shared utilities and helper functions.
- docs/architecture.md: Architecture documentation.

## Data Flow
User interacts with the presentation layer.
The presentation layer calls the view model.
The view model accesses the data layer.
The data layer returns data to the view model.
The presentation layer displays the result to the user.

## Verification
Run the project using Flutter:
flutter pub get
flutter run -d chrome