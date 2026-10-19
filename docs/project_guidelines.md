# Flutter Project Guidelines

## Architecture

The project uses MVVM principles.

* `lib/app/`: app configuration and setup.
* `lib/data/`: models, data sources, and repositories.
* `lib/presentation/`: UI screens, widgets, and ViewModels.
* `lib/utils/`: reusable helper functions.

## Coding Guidelines

* Keep UI and business logic separate.
* Use clear, descriptive file and class names.
* Avoid duplicating code.
* Add dependencies only when necessary.
* Keep changes focused and easy to review.

## Testing and Verification

* Run `flutter pub get` after dependency changes.
* Run `flutter analyze` after code changes.
* Verify that the application still starts.

## Git Workflow

* Develop new features on `feature/*` branches.
* Merge changes into `dev` through Pull Requests when possible.
* Merge into `main` only through a reviewed Pull Request.
* Never use `git push --force` on shared branches.

## Security

* Never commit `.env` files, passwords, API keys, or other secrets.
* Keep `.env.example` free of real credentials.