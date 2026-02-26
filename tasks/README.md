# Rake Tasks (Ruby)

This directory contains Rake tasks that are automatically loaded by the main `Rakefile`.

## Available Task Files

### `format.rake` - Code Formatting & Linting

Format and lint Ruby and non-Ruby files to maintain consistent code style.

- `rake lint` - Check all code formatting (Ruby with StandardRB + HTML/CSS/JS/YAML/Markdown with Prettier)
- `rake format` - Auto-fix all formatting issues
- `rake format:ruby` - Check Ruby code style with StandardRB
- `rake format:ruby_fix` - Auto-fix Ruby formatting
- `rake format:prettier` - Check non-Ruby files with Prettier npm via NodeJS
- `rake format:prettier_fix` - Auto-fix non-Ruby files

### `test.rake` - Site Validation Tests

Comprehensive testing suite for the built site.

- `rake test` - Run all tests
- `rake test:html_proofer` - Test built site with html-proofer (checks links, images, etc.)
- `rake test:templates` - Check for Liquid template issues
- `rake test:page_config` - Validate page frontmatter configuration
- `rake test:placeholders` - Check for placeholder content (TODO, YYYY, etc.)
- `rake test:a11y` - Test for common accessibility issues
- `rake test:performance` - Check for performance issues
- `rake test:sessions` - Validate session page structure

### `review.rake` - External Link Validation

Check external/public URLs in the built site.

- `rake review:external_links` - Check external/public URLs in the built site (slower, requires network access)

### `outdated.rake` - Dependency Updates

Check for outdated Ruby gems.

- `rake outdated` - Check directly used outdated dependencies
- `rake outdated:direct` - Check only direct dependencies from Gemfile
- `rake outdated:all` - Check all outdated dependencies (including transitive)

### `setup.rake` - Initial Site Setup

One-time setup task for new SRCCON sites created from the template.

- Checks if setup has already been run
- Removes some `site-starterkit`-only files
- Renames `SITE_README.md` to `README.md`
- Creates and pushes `staging` branch (if it doesn't exist)
- Switches to `staging` branch by default
