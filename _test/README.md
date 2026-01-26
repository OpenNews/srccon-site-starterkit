# Test Content Directory

This directory contains sample content used for testing the Jekyll build process in CI/CD workflows.

## Purpose

- Provides realistic content structure for build validation
- Tests markdown rendering and layout functionality (especially `layout_with_header_image`)
- Validates internal links and image references
- Ensures templates work with actual content, not just empty pages

## Usage

This directory is automatically included in CI builds to test:
- Build process with real content
- Link validation with complex markdown
- Template rendering with different layouts
- HTML structure with populated pages

The content in this directory is built and tested but **never deployed** to production.

## Adding Test Content

Add sample pages here to test new features or layouts before using them in production sites.
