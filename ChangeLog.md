# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Data API support with dedicated `DataApi` class
  - `request()` method for single authenticated Data API requests
  - `request_iter()` method for iterating through paginated responses
  - `results_iter()` method for iterating through individual results across pages
  - Automatic routing metadata headers: `X-Learnosity-Consumer`, `X-Learnosity-Action`, `X-Learnosity-SDK`
- Data API demo added to Rails quickstart application
- Comprehensive unit and integration tests for Data API functionality
- Example usage in `examples/simple/data_api_example.rb`

### Fixed
- Ruby 2.6 compatibility in Rails quickstart (commented out `spring` gems that require Ruby 2.7+)
- Rails 6.1 compatibility with Ruby 2.6 (added `require 'logger'` to `config/boot.rb`)
- Bumped 3rd party libraries to fix known vulnerabilities in the quick start application
- Fixed seed data for the api-reports example in the quick start application

## [v0.3.0] - 2024-07-12
### Added
- Add support for api-authoraide.

## [v0.2.2] - 2023-06-29
### Security
- Upgraded signature to match the security standard.

### Added

- Improved Makefile and tests
- PR template

### Security
- Updated vendor libraries to fix security issues

## [v0.2.1] - 2019-01-08
### Added

- Updated version range of `sys-uname` to include versions `1.0` and above

## [v0.2.0] - 2019-08-12
### Added

- This ChangeLog!
- Telemetry data (basic information about the execution environment) is now added to the request objects being signed which is later read and logged internally by our APIs when the request is received. This allows us to better support our various SDKs and does not send any additional network requests. More information can be found in README.md.

## [v0.1.0] - 2017-05-10
Initial Release
