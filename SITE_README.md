# SRCCON [YEAR|name] Website

This is the website for SRCCON [YEAR|name], built with Jekyll and deployed via GitHub Actions to AWS S3.

## Table of Contents

- [Quick Start](#quick-start)
- [Setup Checklist](#setup-checklist)
- [Local Development](#local-development)
  - [Prerequisites](#prerequisites)
  - [Core Commands](#core-commands)
  - [Testing & Validation](#testing--validation)
  - [Code Formatting & Linting](#code-formatting--linting)
  - [Editor Setup (VSCode, Cursor, Antigravity, etc.)](#editor-setup-vscode-cursor-antigravity-etc)
  - [Deployment](#deployment)
- [Repository Structure / Essential Files](#repository-structure--essential-files)
- [Troubleshooting](#troubleshooting)
- [Additional Resources](#additional-resources)

## Quick Start

1. **Start Here:** Run `bundle exec rake setup` (one-time initialization - creates staging branch and swaps README files)
   - No `bundle?` Try the [Prerequisite steps](#local-development) below
1. **Configure:** Update `_config.yml` with your event details (see the [Setup Checklist](#setup-checklist) below) and customize the URL in the `CNAME` file
1. **Create AWS Buckets:** If you haven't already, create the `staging.<event>.srccon.org` and `<event>.srccon.org` buckets [AWS S3](https://us-east-1.console.aws.amazon.com/s3/buckets?region=us-east-1). Use the "_Copy settings from existing bucket - optional_" feature and the prior year's config to speed things up.
1. **Develop:** Run `bundle exec rake serve` to preview locally at [http://localhost:4000](http://localhost:4000)
1. **Workflow:**
   1. Use `staging` or your own feature branch off `staging`
   1. Make changes and test locally as much as you like
   1. When you're ready, push or create a PR to merge your work into `staging`
   1. A successful push to `staging` will start a GitHub Action that will try to auto-deploy your work to `staging.<event>.srccon.org`
   1. Smoke test and validate things on the staging URL
   1. When staging is ready, create a PR from `staging` to `main` for your production deployment
1. **Validate:** Run `bundle exec rake check` and `bundle exec rake test` before merging to `main`
   - some work on `staging` will require this earlier, but it's worth checking again
1. **Deploy to `main`:** When staging is exactly what you want to see live, merge `staging` to `main` via PR or direct merge. This will kick off an auto-deployment to the production AWS S3 bucket which will render as `<event>.srccon.org`
1. **Your first production deploy will fail!** There's no good way to fix this ahead of time. You need to go into AWS Console and generate a `cloudfront_distribution_id` for `_config.yml`:
   1. In [AWS CloudFront](https://us-east-1.console.aws.amazon.com/cloudfront/v4/home?region=us-east-1#/distributions), create a new distribution
   1. Set origin to your production S3 bucket website endpoint
   1. Configure appropriate cache behaviors and SSL certificate (copy prior events)
   1. Copy the distribution ID (looks like `E1234ABCDEFG`)
   1. Add to `_config.yml` under `deployment`: `cloudfront_distribution_id: E1234ABCDEFG`
   1. Push changes and re-run deployment
   1. Future deploys will automatically invalidate the CloudFront cache

## Setup Checklist

### Settings

- [ ] `CNAME` - Set to your event's public URL (no `https://`)
- [ ] `_config.yml` - Update these values under `deployment:`
  - [ ] `s3_bucket_staging` - name of the staging bucket, often `staging.<event>.srccon.org`
  - [ ] `s3_bucket_production` - name of the user-facing public bucket, `<event>.srccon.org`
- [ ] `_config.yml` - Update these values under `defaults:`
  - `root_url` - The full URL of your site
  - `event_name` - Full event name
  - `event_date` - Human-readable date
  - `event_place` - Full location
  - `event_venue` - Venue name
  - `event_venue_link` - Maps or the Venue's own public site
  - `event_timezone` - Timezone abbreviation
  - `event_timezone_offset` - UTC offset
  - `event_place_abbr` - Short location
  - `description` - Meta description for SEO and various pages
- [ ] `layout` - Which layout to use
- [ ] `google_analytics_id` - Set if using custom tracking
- [ ] `cta_button_text` & `cta_button_link` - Configure the main call-to-action button, from the default or commented out options, or something new
- [ ] `schedule_live` - Set to `true` when ready to show the program page
- [ ] `session_deadline_passed` - Set to `true` when participation form closes
  - `session_deadline` - Participation form deadline
  - `session_confirm` - When applicants hear back
- [ ] Ticket prices in `_config.yml`:
  - `price_base` - Base ticket price
  - `price_med` - Mid-tier price
  - `price_full` - Full price
  - `price_stipend` - Stipend/scholarship price

### Media Assets

- [ ] `media/img/srccon_logo.png` - Main SRCCON logo
  - For topical SRCCONs, create custom logo from [this Illustrator template](https://github.com/OpenNews/media-assets/blob/master/srccon/srccon_thematic_logo_template.ai)
- [ ] `media/img/srccon_logo_share.png` - Social media share card
- [ ] `media/img/backgrounds/` - Background images (if using `layout_with_header_image`)

### Data Files

- [ ] `_data/sessions.yml` - Session data (seeded with placeholder/CTA)
- [ ] `_includes/footer_sponsors.html` - Customize sponsor footer if needed

### Content Verification & Page Reviews

- [ ] `_includes/` - Check `simple_footer.html` or `footer.html` for correct linked pages
- [ ] `homepage.md` - Uncomment hotel/room-block text when ready
- [ ] Verify price usage in `homepage.md`, `attendees.md`, and `scholarships.md`
- [ ] `participation/form/` - Ensure AirTable form renders and is set to allow third-party embeds
- [ ] `sponsors/` - Uncomment sponsors as they're confirmed, or add new entries
- [ ] `sponsors/about/` - Update numbers and contact info
- [ ] `welcome.md` - Update stenographer information if applicable

## Local Development

### Prerequisites

This project requires Ruby, Bundler, and Node.js. Check if you have them installed:

```bash
ruby --version   # Should match .ruby-version
bundle --version # Should be 2.0 or higher
node --version   # Should be 14.0 or higher (for Prettier)
npm --version    # Should be 6.0 or higher
```

| Tool        | macOS/Linux                                                       | macOS (Homebrew)      | Linux                                           | Windows                                     |
| ----------- | ----------------------------------------------------------------- | --------------------- | ----------------------------------------------- | ------------------------------------------- |
| **Ruby**    | [rbenv](https://github.com/rbenv/rbenv) or [rvm](https://rvm.io/) | `brew install ruby`   | Package manager (`sudo apt install ruby-full`)  | [RubyInstaller](https://rubyinstaller.org/) |
| **Bundler** | `gem install bundler`                                             | `gem install bundler` | `gem install bundler`                           | `gem install bundler`                       |
| **Node.js** | [rbenv](https://github.com/rbenv/rbenv) or [rvm](https://rvm.io/) | `brew install node`   | Package manager (`sudo apt install nodejs npm`) | [Node.js installer](https://nodejs.org/)    |

After installing Ruby and Node.js:

```bash
bundle install  # Install Ruby dependencies
npm install     # Install Node.js dependencies (Prettier)
```

### Core Commands

```bash
bundle exec rake clean              # Clean the build directory
bundle exec rake build              # Build the site to _site/
bundle exec rake serve              # Serve locally with live reload at http://localhost:4000
bundle exec rake                    # Run clean, build, check, and serve in a loop
```

### Testing & Validation

```bash
bundle exec rake check              # Validate _config.yml configuration
bundle exec rake test               # Run all tests (recommended)
bundle exec rake test:html_proofer  # Test built HTML and links
bundle exec rake test:templates     # Validate Liquid syntax
bundle exec rake test:page_config   # Validate page setup
bundle exec rake test:placeholders  # Find untouched defaults
bundle exec rake test:a11y          # Very basic accessibility checks
bundle exec rake test:performance   # Performance warnings
bundle exec rake outdated           # Check for outdated _direct_ dependencies
```

### Code Formatting & Linting

It is very helpful to maintain consistent code style across Ruby and non-Ruby files and keep change- and diff-histories easier to read in git/GitHub.
`bundle install` and `npm install` will enable our code-formatting support, available
in your IDE (depending on its features) and also via these `bundle exec rake *` commands:

```bash
bundle exec rake lint               # Check all code formatting (Ruby + web/YAML/Markdown)
bundle exec rake format             # Auto-fix all formatting issues

# Check only (no changes)
bundle exec rake format:ruby        # Ruby files with StandardRB
bundle exec rake format:prettier    # HTML/CSS/JS/YAML/Markdown with Prettier

# Auto-fix specific file types
bundle exec rake format:ruby_fix      # Fix Ruby formatting
bundle exec rake format:prettier_fix  # Fix non-Ruby formatting
```

**Configuration Files:**

The formatting behavior is controlled by:

- `.editorconfig` - Editor settings (most editors support this automatically)
- `.prettierrc` - Prettier formatting rules
- `.prettierignore` - Files excluded from Prettier
- `.standard.yml` - StandardRB configuration for Ruby files
- `.vscode/settings.json` - Editor workspace settings (see below)

### Editor Setup (VSCode, Cursor, Antigravity, etc.)

If you're using VSCode or a VSCode-based editor (like Cursor or Antigravity), the repository includes pre-configured settings for automatic code formatting and problem detection. These editors share the same open-source foundation and all read `.vscode/settings.json` files.

**Expected Behaviors:**

Once configured, your editor will automatically:

- **Format files on save** - No need to run `bundle exec rake format` manually
- **Format pasted content** - Pasted code auto-adjusts to project style
- **Show problems in real-time** - Linting issues appear in the Problems tab (Cmd/Ctrl+Shift+M)
- **Highlight syntax errors** - Ruby, HTML, CSS, JS, YAML, and Markdown errors surface immediately

**Setup Steps:**

1. **Install Required Extensions:**

   ```bash
   # Prettier - formats HTML, CSS, JS, JSON, YAML, Markdown
   code --install-extension esbenp.prettier-vscode

   # StandardRB - Ruby linting and formatting
   code --install-extension testdouble.vscode-standard-ruby
   # OR use Ruby LSP (includes StandardRB plus autocomplete, go-to-definition)
   code --install-extension shopify.ruby-lsp
   ```

   _Note: The `code` command works with VSCode and most VSCode-based editors. Alternatively, install extensions through your editor's Extensions panel._

1. **Reload Your Editor:**
   - Run "Developer: Reload Window" from Command Palette (Cmd/Ctrl+Shift+P)
   - Or restart your editor

1. **Verify It's Working:**
   - Open any file and save it - it should auto-format
   - Check status bar (bottom-right) - should show "Prettier" or "StandardRB"
   - Make a formatting mistake and save - it should auto-correct

**Editor Compatibility:**

These settings work with VSCode and any editor built on the same open-source codebase (like Cursor, Antigravity, VSCodium, etc.), as they all read `.vscode/` configuration files.

**Manual Formatting (Alternative):**

If you prefer not to use a VSCode-based editor or want to format all files at once:

```bash
bundle exec rake format    # Format all files
bundle exec rake lint      # Check formatting without changing files
```

### Deployment

#### Automatic Deployment (Recommended):

Deployment happens automatically via GitHub Actions:

- Merge PR to `staging` → Staging environment (S3 only)
- Merge PR to `main` → Production (S3 + CloudFront invalidation once `cloudfront_distribution_id` is set)

#### AWS S3 + GitHub Notes:

- AWS access is configured automatically via GitHub Actions using OpenID Connect (OIDC)
- Your repository needs access to the organization-level `AWS_ROLE_ARN` secret
- No additional AWS credentials needed for automated deployments off `staging` or `main`
- For `main`, CloudFront cache invalidation takes 5-10 minutes to propagate before the public site reflects your work

#### Manual Deployment:

Manual deployment is rarely needed since GitHub Actions handles deployment automatically. Use manual deployment only for emergency hotfixes or if GitHub Actions is unavailable.

#### Local AWS Setup:

The organization-level `AWS_ROLE_ARN` secret (OIDC) only works in GitHub Actions. For local deployment, configure traditional AWS credentials:

```bash
# Get AWS Access Key ID and Secret from OpenNews AWS administrator
aws configure
# Region: us-east-1
# Output format: json

# Verify access
aws s3 ls
```

## Repository Structure / Essential Files

- `welcome.md` - Attendee FAQ guide
- `participation_form.md` - Session proposal guide
- `program.md` - Session schedule (unlinked until `schedule_live: true`)
- `sponsors.md` - Sponsor list
- `sponsors_about.md` - Sponsor solicitation
- `scholarships.md` - Scholarship info
- `volunteer.md` - Volunteer info
- `conduct.md` - Code of conduct

### Data & Templates:

- `_data/` - YAML data for sessions and structured content
- `_includes/` - Partial templates (footers, navigation, metadata, session tables)
- `media/` - Static CSS, JS, and image assets

### Configuration Files:

- **Jekyll & Dependencies:**
  - `_config.yml` - Primary site configuration (event details, feature flags, deployment settings)
  - `Gemfile` / `Gemfile.lock` - Ruby dependencies (Jekyll, plugins, testing tools)
  - `package.json` / `package-lock.json` - Node.js dependencies (Prettier)
  - `.ruby-version` - Ruby version specification
- **Editor & Code Quality:**
  - `.vscode/settings.json` - VSCode/Cursor/Antigravity workspace settings (format-on-save, linting)
  - `.editorconfig` - Cross-editor formatting rules (indentation, line endings, etc.)
  - `.prettierrc` / `.prettierignore` - Prettier formatter configuration
  - `.standard.yml` - StandardRB Ruby linter configuration
- **Version Control:**
  - `.gitignore` - Git ignore patterns
  - `CNAME` - GitHub Pages custom domain configuration

### Infrastructure (Rarely Modified)

- **Build System:**
  - `Rakefile` - `:build`, `:serve`, and `:deploy` commands used by humans and GitHub Actions
  - `tasks/*.rake` - Test and validation task definitions, used by humans and GitHub Actions
- **Deployment:**
  - `.github/workflows/` - GitHub Actions runs automated deployment on merges to specifically named branches
    - `deploy.yml` - Deploys static site to S3's staging or production buckets, depending on the branch
    - `test.yml` - Runs on all PRs and some automated commits, to validate they don't break things
    - `health-check.yml` - Weekly automated validation check
- **Generated/Ignored:**
  - `_site/` - Build output directory (git-ignored, deployed to AWS)
  - `.jekyll-cache/` - Local development cache (git-ignored)
- **Layout Templates:**
  - `_layouts/` - Page layouts:
    - `simple_layout.html` - Clean design with solid backgrounds (default and recommended)
    - `layout_with_header_image.html` - Large photo headers (requires custom background images and other cleanup)

## Troubleshooting

For common issues and solutions, see **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)**, which covers:

- **First-time setup** - Steps for getting started after cloning
- **Quick triage** - Identify your issue quickly (won't build, looks wrong, changes not showing)
- **Environment issues** - Ruby version, gems, Node.js
- **Build problems** - Cache issues, server won't start
- **Jekyll errors** - Liquid syntax, includes, layouts, variables
- **YAML issues** - Config and data file syntax
- **Deployment** - CloudFront cache, AWS configuration
- **Manual testing** - Pre-commit smoke testing checklist

## Additional Resources

- **Jekyll Documentation:** https://jekyllrb.com/docs/
- **GitHub Actions Workflows:** See `.github/workflows/` for deployment automation
- **Rake Tasks:** Run `bundle exec rake -T` to see all available tasks
