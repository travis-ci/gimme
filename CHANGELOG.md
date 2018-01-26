# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]

### Added

### Changed

### Deprecated

### Removed

### Fixed

### Security

## [1.3.0] - 2018-01-17

### Added

- Code of Conduct

### Changed

- `1.8` and `1.9` are now build-from-source bootstrapping candidates

### Fixed
- paginate bucket when fetching 'stable' alias
- account for future 1.1x releases in version regex

## [1.2.0] - 2017-07-09

### Added
- support for `stable` alias which auto-updates to point at latest release
- flag/command `-k|--known|known` to list known go versions

### Fixed
- always set `GOROOT` when installing official binaries

## [1.1.0] - 2016-12-07
### Added
- Windows binary downloads
- Custom download base via `${GIMME_DOWNLOAD_BASE}`, suitable for downloading
  from mirrors
- Default exclusion of `~/.gimme/versions` from time machine backups on macOS

### Changed
- Dumped env statements end with `;` for compat with quote-less `eval $(...)`
- Use existing source version if present

### Removed
- Support for binary go versions no longer available for download including
  `go1`, `1.0.1`, `1.0.2`, `1.0.3`, `1.1`, `1.1.1`, `1.1.2`

### Fixed
- Use `1.7` for bootstrapping on macOS Sierra

## [1.0.0] - 2016-06-29
### Added
- Automated construction of known binary versions
- `Dockerfile`
- Embedding of copyright and license URL strings/vars
- Mention of homebrew installation method in docs
- `GIMME_CGO_ENABLED` to enable build of cgo support
- `GIMME_CC_FOR_TARGET` to specify cross compiler for cgo support
- FreeBSD compatibility
- Better support for cross-compiling to arm/arm64
- Support for tee'ing build output when `GIMME_DEBUG > 1`

### Changed
- Bootstrapping via 1.4.3
- Removed embedded license text in favor of URL
- Parse flags/args in a while loop to catch 'em all

## [0.2.4] - 2015-07-15
### Added
- 1.4.2 to tested binary versions
- Mention of original project scope to docs

### Changed
- Repository location to travis-ci/gimme

## [0.2.3] - 2015-02-05
### Added
- Testing with `GIMME_OS` and `GIMME_ARCH` when possible

### Fixed
- Building with bootstrap go version if necessary
- Env sourcing example in docs
- Failing out via `-o pipefail`

## [0.2.2] - 2015-01-30
### Added
- Ability to silence env printing via `GIMME_SILENT_ENV`

### Changed
- Check version usability by compiling rather than `go version`

## [0.2.1] - 2015-01-30
### Added
- Show current version when listing versions

## [0.2.0] - 2015-01-30
### Added
- 1.4.1 to tested binary versions
- Handling of `-h`, `--help`, or `help` for usage
- Handling of `-V`, `--version`, or `version` for printing the version
- Automatic embedding of version string/var

### Changed
- "auto" install tries existing before binary, source, and git
- Assert a version is supplied before attempting an install

## [0.1.0] - 2016-01-27
### Added
- Initial release!

[Unreleased]: https://github.com/travis-ci/gimme/compare/v1.3.0...HEAD
[1.3.0]: https://github.com/travis-ci/gimme/compare/v1.2.0...v1.3.0
[1.2.0]: https://github.com/travis-ci/gimme/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/travis-ci/gimme/compare/v1.0.4...v1.1.0
[1.0.0]: https://github.com/travis-ci/gimme/compare/v0.2.4...v1.0.0
[0.2.4]: https://github.com/travis-ci/gimme/compare/v0.2.3...v0.2.4
[0.2.3]: https://github.com/travis-ci/gimme/compare/v0.2.2...v0.2.3
[0.2.2]: https://github.com/travis-ci/gimme/compare/v0.2.1...v0.2.2
[0.2.1]: https://github.com/travis-ci/gimme/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/travis-ci/gimme/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/travis-ci/gimme/compare/655fc2e...v0.1.0
