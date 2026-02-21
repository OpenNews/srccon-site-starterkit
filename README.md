## SRCCON [Site Starterkit](https://site-starterkit.srccon.org) (Template Repo)

**📋 Audience:** This README is for OpenNews maintainers who manage this template and create new SRCCON event sites.

**🎯 Purpose:** Provides a standardized, automated foundation for launching new SRCCON event websites as subdomain sites within the OpenNews organization.

**⚠️ Important:** After creating a new event repo from this template, run `bundle exec rake setup` to automatically swap README files and prepare for event customization.

## Table of Contents

- [Quick Start: Creating a New SRCCON Site](#quick-start-creating-a-new-srccon-site)
- [Recent Updates (2026)](#recent-updates-2026)
- [Template Contents](#template-contents)
- [Maintaining This Template](#maintaining-this-template)
  - [When to Update](#when-to-update)
  - [How to Update the Template](#how-to-update-the-template)
  - [Propagating Fixes to Event Sites](#propagating-fixes-to-event-sites)
  - [Testing Template Changes](#testing-template-changes)
  - [Version & Release Management](#version--release-management)
- [Key Maintenance Tasks](#key-maintenance-tasks)
  - [Dependency Management](#dependency-management)
  - [Code Quality & Formatting](#code-quality--formatting)
  - [Editor Integration](#editor-integration-vscode-cursor-antigravity-etc)
- [Supporting Documentation](#supporting-documentation)
- [Additional Resources](#additional-resources)
- [Troubleshooting](#troubleshooting)
- [License](#license)

## Quick Start: Creating a New SRCCON Site

1. **Click "Use this template"** in GitHub to create a new repository
1. **Name it** following the pattern: `srccon-<YYYY|name>`
1. **Clone locally:** `bundle install` then `bundle exec rake setup`

After setup completes, follow the workflow in the new repo's README.md for configuration, development, and deployment. See [SITE_README.md](SITE_README.md) for a preview of the event site documentation.

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

- YAML duplicate key detection (`bundle exec rake validate_yaml`)
- Configuration validation (`bundle exec rake check`)
- Lotta pre-built and built file testing (`bundle exec rake test`)
- Performance warnings
- Pre-commit git hook preventing bad YAML from being committed (`.githooks/pre-commit`)
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

**Documentation:**

- `README.md` - Template maintainer documentation (this file, deleted by `rake setup`)
- `SITE_README.md` - Event organizer documentation (becomes `README.md` after `rake setup`)
- `TROUBLESHOOTING.md` - Common issues and solutions (included in event repos)
- `AWS_authentication.md` - OIDC setup details (template-only, deleted by `rake setup`)

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

### How to Update the Template

When making changes to the template repository itself:

**Workflow:**

1. **Create a feature branch** following the pattern: `<year>-<initials>-<task>`

   ```bash
   git checkout -b 2026-tk-update-ruby
   ```

2. **Make your changes** and test thoroughly (see [Testing Template Changes](#testing-template-changes))

3. **Update documentation:**
   - Update this README.md if maintenance procedures change
   - Update SITE_README.md if event organizer workflow changes
   - Add entry to "Recent Updates" section if it's a significant change
   - Update TROUBLESHOOTING.md if addressing common issues

4. **Run validation:**

   ```bash
   bundle exec rake check
   bundle exec rake test
   bundle exec rake format
   ```

5. **Create PR to `main`:**
   - The template repo uses `main` branch only (no `staging` needed)
   - Document what changed and why in PR description
   - Note if changes affect existing event sites
   - Consider asking @Copilot or colleagues for review

6. **Merge and deploy:**
   - Once merged to `main`, GitHub Pages auto-deploys to `https://site-starterkit.srccon.org`
   - New event repos created after this point will include your changes

**Important Notes:**

- Template changes only affect NEW event sites created after the change
- Existing event sites don't automatically receive updates (see [Propagating Fixes](#propagating-fixes-to-event-sites))
- Breaking changes should be documented clearly and coordinated with event organizers

### Propagating Fixes to Event Sites

When you fix something in the template that affects live event sites:

**For Critical Fixes (security, broken functionality):**

1. **Document the fix** in the PR description with clear before/after behavior
2. **Create issues** in affected event repositories:
   - Link to the template PR/commit
   - Provide specific files that need updating
   - Include reproduction steps if it's a bug
3. **Consider direct PRs** to affected repos if time-critical
4. **Notify event organizers** via issue comments or direct communication

**For Non-Critical Improvements (features, cleanup):**

1. **Document in template PR** what changed and benefits
2. **Create tracking issue** in template repo listing affected sites
3. **Let event organizers decide** whether to adopt changes
4. **Provide migration guide** if the update requires configuration changes

**Helping Event Organizers Pull Updates:**

Event sites can selectively adopt template improvements:

```bash
# In the event repo, add template as a remote
git remote add template https://github.com/OpenNews/srccon-site-starterkit.git
git fetch template

# View specific file changes
git diff main template/main -- path/to/file.rb

# Cherry-pick specific commits
git cherry-pick <commit-hash>

# Or manually copy files/changes as needed
```

**What to Backport:**

- ✅ Security updates (Ruby/gem versions, GitHub Actions)
- ✅ Bug fixes that break functionality
- ✅ Deployment config improvements
- ⚠️ New features (event organizer decides)
- ❌ Documentation changes (each repo has its own)
- ❌ Event-specific content/configuration

### Testing Template Changes

Before pushing template changes that will affect future event sites:

**Option 1: Local Testing (Quick)**

```bash
bundle exec rake serve    # Preview at localhost:4000
bundle exec rake test     # Run validation tests
bundle exec rake check    # Verify configuration
```

**Option 2: Test Event Repo (Thorough)**

1. Create a test repository from the template ("Use this template" button)
2. Clone locally and run `bundle exec rake setup`
3. Test the complete event organizer workflow
4. Verify `SITE_README.md` becomes `README.md` correctly
5. Delete test repo when done

**What to Test:**

- Jekyll builds without errors (`bundle exec rake build`)
- All rake tasks work (`bundle exec rake -T` and try each)
- Documentation is clear and accurate
- `.vscode/settings.json` works with required extensions
- GitHub Actions workflows validate (check `.github/workflows/test.yml`)

### Version & Release Management

The template uses a **rolling release** model without formal version numbers:

**Why No Versions:**

- Event sites are typically one-time use (for a specific conference)
- Template changes are incremental improvements, not breaking releases
- Event organizers rarely need to "upgrade" an in-progress site
- Git history provides sufficient tracking of changes

**Tracking Template History:**

- Use Git commit SHAs to reference specific template states
- Significant updates documented in "Recent Updates" section
- GitHub's commit history shows all changes: `https://github.com/OpenNews/srccon-site-starterkit/commits/main`

**Maintaining "Recent Updates" Section:**

Add entries to the "Recent Updates (2026)" section when:

- ✅ Major feature additions (new rake tasks, workflows, automation)
- ✅ Significant architecture changes (auth, deployment, config structure)
- ✅ Tool changes that affect contributor workflow (new linters, formatters)
- ❌ Minor bug fixes (document in commit messages instead)
- ❌ Content updates (logo additions, sponsor changes)
- ❌ Documentation improvements (unless workflow changes)

**When to Archive Updates:**

- When the section becomes too long (>10 subsections), consider:
  - Moving older updates (2+ years) to a CHANGELOG.md file
  - Keeping only current year's major updates in README
  - Linking to CHANGELOG.md for historical context

**Communicating Breaking Changes:**

If a template change would break existing event sites:

1. Document clearly in PR description
2. Add to "Recent Updates" with ⚠️ warning
3. Create issues in all active event repositories
4. Provide migration path or rollback instructions
5. Consider delaying merge until after active events conclude

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

The template includes automated code formatting using **StandardRB** (Ruby) and **Prettier** (HTML, CSS, JS, YAML, Markdown). This ensures consistent code style across all SRCCON event sites.

**Why These Tools:**

- **Zero configuration** - StandardRB and Prettier work out-of-the-box with sensible defaults
- **Automatic fixing** - Most issues auto-correct on save (with editor integration) or via `bundle exec rake format`
- **Dual toolchain** - Ruby via StandardRB, everything else via Prettier with Node.js
- **Git-friendly** - Consistent formatting reduces noisy diffs and merge conflicts

**Quick Reference:**

```bash
bundle exec rake lint      # Check all formatting
bundle exec rake format    # Auto-fix all issues
```

**For Maintainers:**

- Configuration lives in `.standard.yml`, `.prettierrc`, and `.prettierignore`
- Formatting rules are intentionally minimal to reduce bikeshedding
- To modify rules, update config files and run `bundle exec rake format` across the template
- Consider CI integration in `.github/workflows/test.yml` if format drift becomes an issue

**For Event Organizers:**

See [SITE_README.md - Code Formatting & Linting](SITE_README.md#code-formatting--linting) for detailed usage instructions and commands.

### Editor Integration (VSCode, Cursor, Antigravity, etc.)

The template includes `.vscode/settings.json` that configures automatic formatting for VSCode and VSCode-based editors (Cursor, Antigravity, VSCodium, etc.).

**What It Does:**

- **Format on save** - All files auto-format when saved
- **Format on paste** - Pasted content auto-formats to match project style
- **Real-time linting** - Issues appear in Problems tab as you type
- **Consistent tooling** - Same behavior across all contributors' editors

**For Maintainers:**

- Settings are in `.vscode/settings.json` and committed to the repository
- Works with Prettier and StandardRB extensions
- Applies to template and all event repos created from it
- To modify: Edit `.vscode/settings.json` and test with the required extensions installed

**For Event Organizers:**

See [SITE_README.md - Editor Setup](SITE_README.md#editor-setup-vscode-cursor-antigravity-etc) for complete setup instructions, required extensions, and troubleshooting.

## Supporting Documentation

Event organizers working from this template will have access to:

- **[SITE_README.md](SITE_README.md)** - Complete setup and development guide (becomes `README.md` in event repos)
- **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** - Common issues and solutions for setup, build, deployment, and editor problems
- **[tasks/README.md](tasks/README.md)** - Rake task development documentation

Template maintainers should also reference:

- **[AWS_authentication.md](AWS_authentication.md)** - OIDC setup and configuration details

## Additional Resources

- **[SRCCON Event Site](https://srccon.org)** - Main SRCCON landing page
- **[Jekyll Documentation](https://jekyllrb.com/docs/)** - Static site generator
- **[GitHub Actions Docs](https://docs.github.com/en/actions)** - CI/CD documentation
- **[AWS S3 Documentation](https://docs.aws.amazon.com/s3/)** - Static hosting
- **[AWS CloudFront Documentation](https://docs.aws.amazon.com/cloudfront/)** - CDN configuration

## Troubleshooting

### Template Maintenance Issues

These issues are specific to maintaining the template repository itself. For event site development issues, see [TROUBLESHOOTING.md](TROUBLESHOOTING.md).

**Template changes not appearing in new sites:**

- Ensure you're using GitHub's "Use this template" button, not forking
- After creating from template, pull latest changes if updates were recent
- Template changes only affect NEW sites created after the change

**`rake setup` fails or behaves unexpectedly:**

- Check that you're running it on a NEW repo created from template, not the template itself
- Ensure `SITE_README.md` exists before running
- The task is idempotent but warns if files are already processed
- Test setup task on a disposable test repo, not the template repo

**Testing template changes:**

- Create a disposable test repo from template to verify changes
- Test with `bundle exec rake setup` to ensure event organizer experience works
- Don't run destructive setup tasks on the template repo itself
- Verify build works: `bundle exec rake clean && bundle exec rake build`

**Deployment workflow configuration (in template):**

- Verify `AWS_ROLE_ARN` secret exists at organization level
- Ensure workflow files in `.github/workflows/` have correct triggers
- Test workflow changes in a test repo before merging to template

### Event Site Development

For issues that event organizers encounter when building and deploying their sites, see **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)**, which covers:

- First-time setup and quick triage
- Environment and dependency issues
- Build and cache problems
- Jekyll and template errors
- YAML and data file issues
- Deployment problems
- Manual smoke testing

## License

The SRCCON site template is available as open source under the terms of the [MIT License](LICENSE).
