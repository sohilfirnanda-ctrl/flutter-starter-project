# AI Agent Instructions

## Project Overview

This project is a Flutter starter project using the MVVM architecture.

## Required Architecture

* `lib/app/`: application setup and configuration.
* `lib/data/`: data models, data sources, and repositories.
* `lib/presentation/`: screens, widgets, and ViewModels.
* `lib/utils/`: shared utilities and helpers.

## Rules

* Follow the existing project structure.
* Keep UI code separate from data and business logic.
* Do not add unnecessary dependencies.
* Do not expose secrets, passwords, API keys, or `.env` files.
* Do not delete or overwrite existing files without checking first.
* Keep changes small and explain the purpose of each change.
* Run appropriate Flutter checks after modifying code.

## Git Safety

* Never use `git push --force` on shared branches.
* Use feature branches for new work.
* Changes to `main` must go through a reviewed Pull Request.
* Explain risky changes before applying them.