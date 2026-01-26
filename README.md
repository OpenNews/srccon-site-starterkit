## SRCCON site starterkit

This repo provides a templated foundation for creating new SRCCON event sites. By default, pages use the "simple" SRCCON template. [Check the demo site](https://site-starterkit.srccon.org) to see what's included and what it looks like.

### 🎯 2026 Major Refactoring

This starterkit has been significantly enhanced in 2026 to automate and template features that previously required manual setup for each annual SRCCON event. Key improvements include:

**Now Fully Templated:**
- **Dynamic event information** - Dates, venues and locations are re-centralized in `_config.yml` and populate throughout the site
- **Ticket price checks** - The four price options are now centralized in `_config.yml` and populate throughout the site, ready to be set per year
- **Session program integration** - Program pages and session schedules now use YAML data files instead of hardcoded HTML
- **Conditional content rendering** - Page content automatically adjusts based on event timeline flags: `schedule_live` and `session_deadline_passed`
- **Prior events navigation** - Footer automatically generates links to previous SRCCON years based on the current event's URL
- **Social media metadata** - OpenGraph tags now use absolute URLs from config instead of relative paths
- **Comprehensive testing** - Automated validation for templates, layouts, configuration, accessibility, security, and performance

**Examples of What's Automated:**
- Event name, dates and location appear consistently across all Markdown pages
- Participation Form deadlines update throughout the site from a config values
- Program page visibility is controlled by one `schedule_live` flag
- Participation Form open/close language is better controlled by one `session_deadline_passed` flag
- CTA button variations are pre-seeded to the site's phases
- Repetitive sponsor data is saved year over year, with some smart defaults in the public list

This means **less manual find-and-replace work** when setting up a new SRCCON site and **fewer opportunities for inconsistencies** across pages.

## Repository Structure
* **Directories:**
	* `_data/` - YAML data files for sessions, sponsors and other structured content
	* `_includes/` - Partial templates (footers, navigation, metadata, session tables)
	* `_layouts/` - Page layouts: `simple_layout.html` (clean design; default choice) and `layout_with_header_image.html` (with photo headers)
	* `_site/` - this is the result of our `:build` commmand, it should not be commited to GitHub; it's what goes to AWS's bucket to become the static site (is deployed, but also .gitignored)
	* `.github/workflows/*` - GitHub Actions scripts that drive our site-building process on commits to `main`
	* `.jekyll-cache/` - local-only elements to `serve` local dev site (gitignored)
	* `media/` - Static CSS, JS, and image assets
	* `tasks/` - Rake task definitions for testing and validation
* **Core Pages:**
	* `homepage.md` - Event landing page
	* `welcome.md` - Attendee FAQ guide
	* `participation_form.md` - Session proposal guide
	* `program.md` - Session schedule (unlinked, until `schedule_live: true`)
	* `sponsors.md` - Sponsor list (no longer redirecting to `sponsos_about.md`)
	* `sponsors_about.md` - Sponsor solicitation
	* `scholarships.md` - Scholarship info
	* `volunteer.md` - Volunteer info
	* `conduct.md` - Code of conduct
* **Configuration:**
	* `_config.yml` - **Primary configuration file** - event details, feature flags and defaults
	* `Rakefile` - `build`, `serve` and `deploy` commands, for local dev and publishing (more on this below)
	* `tasks/*.rake` files - Beefed up test suite, covering many Jekyll and static-bake templating challenges or inconsistencies

# Working locally with live reload

`bundle exec rake default` - runs `:build`, `:check` and `:serve` commands on most file changes, so you can watch along with your config and file tweaks 

View at [http://localhost:4000](http://localhost:4000)

## Pre-Launch Checklist

**Validate your configuration:**
```bash
bundle exec rake check
```

## Available tests

```bash
# Quick HTML validation
bundle exec rake test:html_proofer      # Validate built HTML and links
bundle exec rake test:templates         # Check template syntax

# Content quality
bundle exec rake test:placeholders      # Find unconfigured or TODO content patterns
bundle exec rake test:page_config       # Validate args at top of Markdown files

# Best practices
bundle exec rake test:a11y               # Accessibility checks
bundle exec rake test:performance        # File-size and performance warnings

# Run 'em all
bundle exec rake test:all                # Comprehensive validation suite
```

# Pre-launch checklist
What to do after copying this repository to set up a new SRCCON site:

**🚀 Quick Start:** See [TEMPLATE_SETUP.md](TEMPLATE_SETUP.md) for a comprehensive setup checklist.

**Validate your configuration:**
```bash
bundle exec rake validate_config
```

This checklist will guide you though customizing `_config` values and smoke-testing your changes.

* settings
	- [ ] `CNAME`
		* delete this file! (It only exists to point to [the demo site for this repo](https://site-starterkit.srccon.org).) If you use GitHub's "Create repository from template" feature to set up your new site repository, you may need to `git rm` this file to get rid of it.
	- [ ] `_config.yml`
		- [ ] under `defaults:`, revise the placeholders for:
			 * `root_url`
			 * `event_name`
			 * `event_date`
			 * `event_place`
			 * `event_venue`
			 * `event_venue_link`
			 * `event_timezone`
			 * `event_timezone_offset` - daylight savings time
			 * `event_place_abbr` (only used by `layout_with_teader_image`)
			* `description`: This is written for a midyear SRCCON; if the site is a semi-colon event, change it accordingly	
		- [ ] `layout`: This is set to "simple_layout" for page designs that look like [SRCCON:2025](https://2025.srccon.org/). You can change the value to "layout_with_header_image" for a site with photo headers like [SRCCON 2019](https://2019.srccon.org). (More work may be necessary for the photo template.)
		- [ ] `google_analytics_id` - any custom tracking?
		- [ ] `cta_button_text` & `cta_button_link`: an orange "call to action" button and its text. Some common options are commented out
		- [ ] `schedule_live` - should users be able to see a link to the program (aka, is it ready to publish)
		- [ ] `session_deadline_passed` - should we indicate that the partiticpation form is closed
			- [ ] `session_deadline` - date & time when the form ends
			- [ ] `session_confirm` - date when applicants should hear a verdict
		- [ ] To make sure all uses match across our pages, prices are now `_config.yaml` values:
			* `price_base`
			* `price_med`
			* `price_full`
			* `price_stiped`
		* Additionally, we have some `scope` args after the `defaults:`; these can be ignored until we get into some challenges with schedule item renderings
	-[ ] `media/img/`
		- [ ] `srccon_logo.png` is the primary SRCCON logo (the one that says "SRCCON" set at an angle). If you're creating a site for a topical SRCCON instead, you'll want to create appropriate logo files (generally 800px tall, probably starting from [this Illustrator template](https://github.com/OpenNews/media-assets/blob/master/srccon/srccon_thematic_logo_template.ai).)
		- [ ] `srccon_logo_share.png` is the version of the logo used by social-media share cards. If you create a new logo for an event, also make a 1200x600 version of it and replace this file.
		- [ ] if you're using `layout_with_header_image`, there are some helpful images in `/media/img/backgrounds/`
	- [ ] `_data/sessions.yml` - this is the JSON that will drive the schedule "app", with a basic placeholder/CTA to start
	- [ ] `_inculdes/footer_sponsors.html` - any tweaks?
* VQA/smoke-testing
	- [ ] `_includes/`
		* in `simple_footer.html` or `footer.html` (dependeng on `layout`), double-check the list of linked pages/includes. "Previous events" _should_ add any missing years once you set the `root_url`
	- [ ] `homepage.md`
		* in the "When & Where" section, consider un-`{% comment %}`ing the Room-block text once a link is ready
    - [ ] `price_*` changes in `_config.yaml`
        * Double-check the use of the prices in `homepage.md`, `attendees.md` and `scholarships.md`  
	- [ ] `participation/form/` - make sure Airtable renders
    - [ ] Sponsors:
		-[ ] `sponsors/` - starts with two default sponsors, but typical sponsor names/logos are ready to be un-`{% comment %}`ed as decisions come in
		- [ ] `sponsors/about/` - may need a refresh for numbers and contact points; if so, please consider PRing the same change back to `srccon-site-template`, too
	- [ ] `welcome.md` - do we have stenographers this year? Are they newer people? If so, please update and consider PRing the same change back to `srccon-site-template`, too

## GitHub Actions Setup

This template uses GitHub Actions for automated deployment to S3 and CloudFront. Here's how to set it up:

### Required Secrets

Secrets can be configured at the **organization level** (shared across all SRCCON repos) or **repository level** (specific to each event site).

**Organization-Level Secrets** (Settings → Secrets and variables → Actions at https://github.com/organizations/OpenNews/settings/secrets/actions):

**⚠️ REQUIRED DEPENDENCIES:** These must be configured at the organization level before deployment workflows will function. They are shared across all SRCCON site repositories:

- `AWS_ACCESS_KEY_ID` - AWS access key with S3 and CloudFront permissions (IAM policy must include `s3:PutObject`, `s3:DeleteObject`, `s3:ListBucket`, `cloudfront:CreateInvalidation`)
- `AWS_SECRET_ACCESS_KEY` - AWS secret access key corresponding to the access key ID
- `SLACK_WEBHOOK_URL` - Slack webhook for deployment notifications (uses a shared channel for all SRCCON deployments)

**Repository-Level Secrets** (Settings → Secrets and variables → Actions in each repository):

These are unique to each event and must be configured for each new SRCCON site repository:

- `AWS_S3_BUCKET_STAGING` - S3 bucket name for this event's staging site (e.g., `srccon-2026-staging`)
- `AWS_S3_BUCKET` - S3 bucket name for this event's production site (e.g., `srccon-2026`)
- `CLOUDFRONT_DISTRIBUTION_ID` - CloudFront distribution ID for this event's production site (e.g., `E1234ABCD5678`)

**Note:** S3 buckets and CloudFront distributions must be created in AWS before setting these values. The CloudFront distribution ID is found in the AWS CloudFront console after creating a distribution that points to your S3 bucket.

**Optional Repository-Level Overrides:**

If a specific event needs different configuration, you can override organization secrets at the repository level:

- `SLACK_WEBHOOK_URL` - Override with event-specific Slack channel webhook
- `SLACK_WEBHOOK_URL` - Slack webhook URL for deployment notifications ([get one here](https://api.slack.com/messaging/webhooks))

### Deployment Workflow

The repository includes three GitHub Actions workflows:

**1. Deploy Workflow** (`.github/workflows/deploy.yml`)
- Triggers on push to `main` or `staging` branches
- Builds Jekyll site with Ruby 3.2
- Deploys to S3 using AWS CLI
- Invalidates CloudFront cache (production only)
- Sends Slack notifications on completion

**2. Test Workflow** (`.github/workflows/test.yml`)
- Runs on all PRs and non-deployment branches
- Validates Jekyll build succeeds
- Checks internal links with html-proofer
- Tests deployment commands with `--dryrun` flag
- No artifacts saved (test locally if needed)

**3. Health Check Workflow** (`.github/workflows/health-check.yml`)
- Runs weekly (Mondays at noon UTC)
- Validates template still builds successfully
- Reports outdated dependencies
- Creates GitHub issue on failure

### Branch Strategy

- `main` → Production deployment (S3 + CloudFront invalidation)
- `staging` → Staging deployment (S3 only)
- Other branches → Test builds only (no deployment)

### Local Development

**Prerequisites:**

This project requires Ruby and Bundler. Check if you have them installed:

```bash
ruby --version   # Should be 3.2 or higher (see .ruby-version)
bundle --version # Should be 2.0 or higher
```

If you need to install Ruby:
- **macOS/Linux**: Use [rbenv](https://github.com/rbenv/rbenv) or [rvm](https://rvm.io/)
- **macOS with Homebrew**: `brew install ruby`
- **Linux**: Check your package manager (e.g., `sudo apt install ruby-full`)
- **Windows**: Use [RubyInstaller](https://rubyinstaller.org/)

If you need to install Bundler:
```bash
gem install bundler
```

# Core Commands
```bash
bundle exec rake clean              # Clean the build directory
bundle exec rake build              # 'Bake' the site to `_site/`
bundle exec rake serve              # Render locally with live reload
bundle exec rake default			# runs :clean, :build, :serve in a loop
```

# Ruby/Rails updates
```bash
bundle exec rake outdated           # Check for outdated dependencies
bundle exec rake outdated:all       # Chained outdated dependencies (we can't address these, but they may be informative)
```

# Checks & tests
```bash
bundle exec rake check              # Validate _config.yml configuration
bundle exec rake test:all           # Run all tests
bundle exec rake test:html_proofer  # Test built HTML and links
bundle exec rake test:templates     # Validate Liquid syntax
bundle exec rake test:layouts       # Check layout configuration
bundle exec rake test:page_config   # Validate page front matter
bundle exec rake test:placeholders  # Find TODO/FIXME content
bundle exec rake test:a11y          # Accessibility checks
bundle exec rake test:performance   # Performance warnings
```

# Deployment (requires AWS credentials)
```bash
bundle exec rake deploy:precheck                   # Run all pre-deployment checks
bundle exec rake deploy:staging DRY_RUN=false      # Deploy to staging S3
bundle exec rake deploy:production DRY_RUN=false   # Deploy to production S3
```

### Dependency Management

- **`bundler`** manages Ruby gems (Jekyll and plugins)
- **`dependabot`** automatically creates PRs for dependency updates
- Weekly automated health checks catch breaking changes

### Migration from Travis CI-backed sites to 2026 latest

TODO!

### Enhancement: Advanced AWS Setup (OIDC)

For enhanced security, you can use AWS OIDC instead of long-lived credentials. This eliminates the need for `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`.

[See AWS documentation for setup instructions](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services)

### Troubleshooting

**Build fails with gem errors:**
- Delete `Gemfile.lock` and run `bundle install` locally
- Commit the new `Gemfile.lock`

**Deployment dry-run fails in PRs:**
- Check that AWS credentials are configured as repository secrets
- Ensure secrets are available to PR builds (may need to adjust workflow permissions)

**HTML validation reports false positives:**
- Adjust html-proofer flags in `.github/workflows/test.yml`
- Add `--ignore-urls` patterns for known false positives
