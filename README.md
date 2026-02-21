## SRCCON [Site Starterkit](https://site-starterkit.srccon.org) (Template Repo)

**📋 Audience:** This README is for OpenNews maintainers who manage this template and create new SRCCON event sites.

**🎯 Purpose:** Provides a standardized, automated foundation for launching new SRCCON event websites as subdomain sites within the OpenNews organization.

**⚠️ Important:** After creating a new event repo from this template, run `bundle exec rake setup` to automatically swap README files and prepare for event customization.

## Quick Start: Creating a New SRCCON Site

1. **Click "Use this template"** in GitHub to create a new repository
1. **Name it** following the existing pattern: `srccon-<YYYY|name>`
1. **Clone locally** and run `bundle install`
1. **Run the setup task:** `bundle exec rake setup`  
   This automatically cleans up some files that describe the role of the _template_ repo that are now in the way.
1. **Customize `_config.yml`** with your event details (dates, venue, prices, deployment buckets, etc.)
1. **Update `CNAME`** with your event's subdomain, e.g., `2026.srccon.org`, with no `https://`
1. **Validate your configuration changes:** `bundle exec rake check`
1. **Render and smoke-test locally:** `bundle exec rake serve`
1. **Commit and push** your changes to trigger deployment to GitHub Pages (the site-starterkit repo is a bit different than our other repos, in that regard).
   - We recommend starting with by creating a `<year>-<initials>-<task>`-patterned branch name and working in that branch to tweak the template repo logic
   - Create a PR for your branch compared to `main` (the starterkit has no functional `staging` need at this moment)
   - Use the `bundle exec rake -T` tasks to check your work for issues
   - Consider asking @Copilot or colleagues for a Review
   - Once you merge your branch into `main`, you should see GitHub Pages automatically kick off a deployment to `https://site-starterkit.srccon.org` and your changes will be live there

## Recent Updates (2026)

This template was significantly upgraded in 2026 to reduce repetitive work and migrate deployment continual integration/deployment (CI/CD) patterns to use GitHub Actions rather than Travis. It also upgrades authentication-security connections between AWS S3 and GitHub. Details:

### AWS Authentication via OpenID Connect (OIDC)

Previously we used long-lived AWS credentials like
`AWS_ACCESS_KEY_ID` or `AWS_SECRET_ACCESS_KEY` stored as individual repository secrets, requiring rotation and management. Which we did not do frequently.

**Now:** We use a single GitHub Organization-level `AWS_ROLE_ARN` secret using [OpenID Connect (OIDC)](https://docs.github.com/en/actions/concepts/security/openid-connect#overview-of-openid-connect-oidc):

- ✅ Short-lived credentials (auto-expire quickly)
- ✅ No secrets in cloud storage or on local machines
- ✅ Granular permission controls that do only what we need, not more
- ✅ One secret to manage across all OpenNews repos, via [OpenNews Organization-level secrets](https://github.com/organizations/OpenNews/settings/secrets/actions) in GitHub.

**Details:** [AWS_authentication.md](AWS_authentication.md)

### Centralized Configuration

Previously, event details were scattered across HTML and Markdown files requiring manual find-and-replace. And many full-event templates were missing from the baseline in this template repo. They needed to be copy-pasted into new event repos from prior years as pre-conference deadlines approached. This brought in inconsistencies in dates, locations and pricing details.

**Now:** Most event metadata is now centralized in `_config.yml`:

```yaml
[...snip...]
event_name: "SRCCON 2052"
event_date: "April 1-3, 2052"
event_venue: Nerd Church
price_base: $450
price_med: $750
price_full: $1050
price_stipend: $500
[...snip...]
```

Changes to these values propagate automatically throughout the site when it is rebuilt as a static site via `bundle exec rake build`. The built code is then deployed via GitHub PRs & merges into `staging` or `main` protected branches. GitHub Actions auto-deploys successful merges to `staging` and `main` to their respective public-facing buckets & URLs.

### Enhanced Templating

- **Dynamic content** - Dates, venues, prices populate from config
- **Conditional rendering** - Show/hide content based on timeline flags (`schedule_live`, `session_deadline_passed`)
- **Session YAML integration** - Program pages render from `_data/sessions.yml`
- **Auto-generated footer** - Previous SRCCON event links generated automatically

### Automated Validation

New capabilities:

- Configuration validation (`bundle exec rake check`)
- Lotta pre-built and built file testing (`bundle exec rake test`)
- Performance warnings
- A weekly healthcheck pattern that runs the tests
- Dependabot keeping an eye on direct dependencies, via GitHub

### Code Quality & Formatting

New automated formatting system maintains consistent code style:

- **StandardRB** - Zero-config Ruby linter and formatter
- **Prettier** - Opinionated formatter for HTML, CSS, JavaScript, YAML, and Markdown
- **Unified commands** - `bundle exec rake lint` checks all files, `bundle exec rake format` fixes all issues
- **Editor integration** - `.editorconfig` works with most editors automatically
- **Dual toolchain** - Ruby formatting via StandardRB, everything else via Prettier with Node.js

### Smart Deployment Config

Previously our S3 buckets and CloudFront caching-setup IDs were somewhat buried in environment-specific files or environment variables.

**Now:** All are consolidated and visible in `_config.yml`:

```yaml
deployment:
  bucket: site-starterkit.srccon.org
  staging_bucket: staging.site-starterkit.srccon.org
  cloudfront_distribution_id: E1234ABCD5678
```

### GitHub Actions Deployment

Previously, we used Travis CI with manual configuration per repository and stored (the same broad) secrets in every repo.

**Now:** Three automated workflows:

1. **Test** - Validate PRs and any branches not named `main` or `staging`
2. **Deploy** - Auto-deploys any pushes/merges to `main` (production) or `staging` branches to their respective public S3 buckets
3. **Health Check** - Weekly automated testing and outdated-dependency reports

## Template Contents

### File Structure

**Configuration & Build:**

- `_config.yml` - Primary configuration file (event details, feature flags, deployment)
- `Rakefile` - `:build`, `:serve`, `:test`, and `:deploy` tasks, plus more
- `tasks/*.rake` - Test suite and Outdated checks as tasks
- `.ruby-version` - Ruby version specification
- `Gemfile` / `Gemfile.lock` - Ruby dependencies
- `package.json` / `package-lock.json` - Node.js dependencies (Prettier)
- `.editorconfig` / `.prettierrc` / `.prettierignore` / `.standard.yml` - Code formatting configuration

**Content Pages:**

- `homepage.md` - Event landing page
- `welcome.md` - Attendee FAQ
- `participation_form.md` - Session proposal guide
- `program.md` - Session schedule
- `sponsors.md` / `sponsors_about.md` - Sponsor information
- `scholarships.md` / `volunteer.md` / `conduct.md` - Supporting pages

**Templates & Data:**

- `_layouts/` - Page layouts, defaults to `simple_layout.html`
- `_includes/` - Reusable components (navigation, footers, session tables)
- `_data/sessions.yml` - Session data for program schedule

**Assets:**

- `media/css/` - Styles
- `media/js/` - Client-side JavaScript
- `media/img/` - Images and sponsor logos (this repo is the library of more sponsors than a given event may need)

**Continuous Integration & Deployment (CI/CD):**

- `.github/workflows/deploy.yml` - Production/staging deployment
- `.github/workflows/test.yml` - PR validation
- `.github/workflows/health-check.yml` - Weekly monitoring of responsiveness and outdated dependencies

### GitHub Actions Workflows

**1. Deploy Workflow** (`.github/workflows/deploy.yml`)

- Triggers on push to `main` or `staging` branches
- Builds Jekyll site with Ruby (see `.ruby-version`)
- Deploys to S3 using AWS CLI
- Invalidates CloudFront cache (production only)

**2. Test Workflow** (`.github/workflows/test.yml`)

- Runs on all PRs and non-deployment branches
- Validates Jekyll build succeeds
- Checks internal links with html-proofer
- Tests deployment commands with `--dryrun` flag
- **No** artifacts copied to S3

**3. Health Check Workflow** (`.github/workflows/health-check.yml`)

- Runs weekly (Mondays at noon UTC)
- Validates template still builds successfully
- Reports outdated dependencies
- Creates GitHub issue on failure

## Maintaining This Template

### When to Update

Update this template when you discover:

- Out of date Gems and versions (so long as they aren't breaking changes)
- Bugs or issues affecting multiple SRCCON sites that you want to patch now before we generate the next event
- Improved CI/CD workflows or automation
- Security updates or best practices
- New features, logos and styles useful for all events
- Documentation improvements

### Propagating Fixes to Event Sites

When you fix something in the template that affects live event sites:

1. **Document the fix** in the PR description
2. **Create issues** in affected event repositories
3. **Consider backporting** critical security/bug fixes to every repo that need the fix (this can be painful)

## Key Maintenance Tasks

**Regular (when starting a new event):**

- Update sponsor logos in `media/img/partners/`
- Review and update prices if changed
- Check for outdated Ruby/gem versions (`bundle update`)
- Run `npm update` to update Prettier and formatting dependencies
- Consider merging in Dependabot recommendations on GitHub Action workflows version upgrades
- Run `bundle exec rake format` to maintain consistent code style
- Update Code of Conduct if OpenNews policy changes
- Improve accessibility based on audits
- Add new validation tests based on issues discovered

**Periodic (annually):**

- Consider upgrading Ruby version in `.ruby-version`
- Validate CloudFront distribution IDs
- Audit AWS IAM permissions
- Review and update documentation

### Dependency Management

**Automated:**

- **Dependabot** - Creates PRs for Ruby gem and npm package updates (configured in `.github/dependabot.yml`)
- **Weekly health checks** - Health check workflow reports outdated dependencies, too

**Manual checks:**

```bash
# Ruby dependencies
bundle exec rake outdated           # Check for outdated gems
bundle exec rake outdated:all       # Include child dependencies of our main dependencies (stuff we can't fix but should generally understand is falling behind)

# Node.js dependencies (Prettier)
npm outdated                        # Check for outdated npm packages
```

**Updating dependencies:**

```bash
# Ruby gems
bundle update                       # Update all gems
bundle update jekyll                # Update specific gem
bundle install                      # Install after Gemfile changes

# Node.js packages
npm update                          # Update all npm packages
npm update prettier                 # Update specific package
npm install                         # Install after package.json changes
```

### Code Quality & Formatting

This template includes automated code formatting and linting for maintaining consistent code style across Ruby and non-Ruby files.

**Formatting Tools:**

- **StandardRB** - Ruby code style linter and formatter (zero-config)
- **Prettier** - Opinionated formatter for HTML, CSS, JavaScript, YAML, and Markdown
- **@prettier/plugin-ruby** - Prettier plugin for Ruby syntax support

**Prerequisites:**

```bash
# Ruby dependencies (already installed with bundle install)
bundle install

# Node.js dependencies for Prettier
npm install
```

**Available Commands:**

```bash
# Check all code formatting (Ruby + HTML/CSS/JS/YAML/Markdown)
bundle exec rake lint

# Auto-fix all formatting issues
bundle exec rake format

# Ruby-only tasks
bundle exec rake format:ruby        # Check Ruby code style
bundle exec rake format:ruby_fix    # Auto-fix Ruby formatting

# Prettier-only tasks
bundle exec rake format:prettier      # Check non-Ruby files
bundle exec rake format:prettier_fix  # Auto-fix non-Ruby files
```

**When to Format:**

- Before committing changes to maintain consistency
- After making template modifications
- When reviewing PRs from contributors
- Periodically to catch drift from standards

**CI Integration:**

The Test workflow (`.github/workflows/test.yml`) can be extended to include formatting checks on PRs. Currently, it focuses on build and deployment validation.

**Configuration Files:**

- `.standard.yml` - StandardRB configuration (currently uses defaults)
- `.prettierrc` - Prettier configuration
- `.prettierignore` - Files to exclude from Prettier
- `.editorconfig` - Editor settings for consistent formatting

## Additional Resources

- **[SRCCON Event Site](https://srccon.org)** - Main SRCCON landing page
- **[Jekyll Documentation](https://jekyllrb.com/docs/)** - Static site generator
- **[GitHub Actions Docs](https://docs.github.com/en/actions)** - CI/CD documentation
- **[AWS S3 Documentation](https://docs.aws.amazon.com/s3/)** - Static hosting
- **[AWS CloudFront Documentation](https://docs.aws.amazon.com/cloudfront/)** - CDN configuration

## Troubleshooting

**Template changes not appearing in new sites:**

- Ensure you're using GitHub's "Use this template" button, not forking
- After creating from template, pull latest changes if updates were recent

**Deployment workflow fails:**

- Verify `AWS_ROLE_ARN` secret exists at organization level (no need to see its value)
- Check S3 bucket names in `_config.yml` match actual buckets
- Ensure CloudFront distribution ID is correct

**Tests failing locally but passing in CI:**

- Ensure Ruby version matches `.ruby-version`
- Delete and rebuild: `bundle exec rake clean && bundle exec rake build`

## License

The SRCCON site template is available as open source under the terms of the [MIT License](LICENSE).
