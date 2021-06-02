# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]
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
