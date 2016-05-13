# Backkeep

Backkeep cleans backups from a directory so that:

  - at least a specified amount of backups are kept
  - kept backups are not older than a specified amount of days

Backkeep requires your backups to include a date and an optional time in their filename.

## Installation

## Usage

- `backkeep list`: lists all backups having a valid date in their filename
- `backkeep keep`: lists all backups which are not to be deleted
- `backkeep diff`: lists all backups which are deleted by `backkeep remove`
- `backkeep remove`: removes all outdated backups

## Development

Run tests:

    ruby test/*_test.rb
