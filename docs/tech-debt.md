# Technical Debt — LAB_PUBLIC

Source-Exempt: operational-doc

_Last updated: 2026-03-07_

## Priority 1

- Move host-specific values and auth settings out of tracked files
- Keep compose reproducible by pinning image references

## Priority 2

- Keep public-safety rules inside the repository
- Add a lightweight automated check for obvious leaks and placeholders

## Priority 3

- Keep infra recovery steps close to the compose file
- Prefer relative references over machine-local absolute paths