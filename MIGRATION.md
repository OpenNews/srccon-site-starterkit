# Migration 

## From Travis CI-backed sites to `srccon-site-starterkit` circa 2026

If you're upgrading an existing SRCCON site (like [srccon-2025](https://github.com/OpenNews/srccon-2025)) to use this 2026 template, follow these steps:

#### 1. Backup and Prepare
```bash
# Create a migration branch
git checkout -b migrate-to-2026-template

# Backup your current _config.yml
cp _config.yml _config.yml.backup
```

#### 2. Copy New Infrastructure

**GitHub Actions workflows:**
```bash
# Remove Travis CI configuration
rm .travis.yml

# Copy GitHub Actions workflows
mkdir -p .github/workflows
# Copy these files from this template:
# - .github/workflows/deploy.yml
# - .github/workflows/test.yml  
# - .github/workflows/health-check.yml
```

**Rake task structure:**
```bash
# Create tasks directory
mkdir -p tasks

# Copy modular test suite
# - tasks/test.rake from this template
# - Update your Rakefile to load tasks/*.rake
```

#### 3. Update Configuration

**Migrate `_config.yml` to new structure:**

The 2026 template centralizes all event-specific data under `defaults:` so it's available as `page.*` variables throughout the site.

```yaml
# OLD (scattered across files, or in top-level _config.yml):
# Values hardcoded in multiple .md files

# NEW (centralized in _config.yml defaults):
defaults:
  - scope:
      path: ""
    values:
      root_url: "https://2025.srccon.org"
      event_name: "SRCCON 2025"
      event_date: "August 14-15, 2025"
      event_place: "Minneapolis, MN"
      event_venue: "McNamara Alumni Center"
      event_venue_link: "https://mac-events.org/"
      event_timezone: "CT"
      event_timezone_offset: "-0500"
      
      # Time-based feature flags
      schedule_live: true
      session_deadline_passed: true
      session_deadline: "May 15, 2025 at 11:59pm ET"
      session_confirm: "June 15, 2025"
      
      # Centralized pricing
      price_base: "$225"
      price_med: "$375"
      price_full: "$450"
      price_stipend: "$0"
      
      # CTA button
      cta_button_text: "See the full schedule"
      cta_button_link: "/program"
```

#### 4. Migrate Content to Use Config Variables

**Find and replace hardcoded values across all `.md` files:**

```bash
# Example: Replace hardcoded dates with config variable
# OLD: August 14-15, 2025
# NEW: {{ page.event_date }}

# OLD: Minneapolis
# NEW: {{ page.event_place }}

# OLD: $225
# NEW: {{ page.price_base }}
```

**Update Liquid template patterns:**

```bash
# Critical: Change site.root_url to page.root_url
grep -r "site\.root_url" . --include="*.html" --include="*.md"
# Replace all instances with: page.root_url
```

**Update social metadata in `_includes/headmeta.html`:**

```liquid
<!-- OLD (relative URLs): -->
<meta property="og:url" content="{{ page.url }}" />
<meta property="og:image" content="/media/img/srccon_logo_share.png" />

<!-- NEW (absolute URLs): -->
<meta property="og:url" content="{{ page.root_url }}{{ page.url }}" />
<meta property="og:image" content="{{ page.root_url }}/media/img/srccon_logo_share.png" />
```

#### 5. Migrate Session Data

**Convert hardcoded HTML schedule to YAML:**

```bash
# Create data file structure
mkdir -p _data

# Move session information from program.md to _data/sessions.yml
# See _data/sessions.yml in this template for format
```

**Update `program.md` to use the session table include:**

```liquid
{% include live_sessions_table.html %}
```

#### 6. Set Up GitHub Secrets

**Repository-level secrets** (Settings → Secrets and variables → Actions):

- `AWS_S3_BUCKET_STAGING` - Your staging S3 bucket (e.g., `srccon-2025-staging`)
- `AWS_S3_BUCKET` - Your production S3 bucket (e.g., `srccon-2025`)
- `CLOUDFRONT_DISTRIBUTION_ID` - Your CloudFront distribution ID

**Verify organization-level secrets exist** (should already be configured):
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `SLACK_WEBHOOK_URL`

#### 7. Add Footer Automation

**Replace manual "previous events" list with automated include:**

In your footer template (`_includes/simple_footer.html` or `_includes/footer.html`):

```liquid
<!-- OLD: Manual list -->
<a href="https://2024.srccon.org">SRCCON 2024</a>
<a href="https://2023.srccon.org">SRCCON 2023</a>
<!-- ... -->

<!-- NEW: Automated generation -->
{% include prior_events.html %}
```

#### 8. Test Everything

```bash
# Install dependencies
bundle install

# Run comprehensive tests
bundle exec rake test:all

# Build and serve locally
bundle exec rake serve

# Visit http://localhost:4000 and verify:
# - All config variables populate correctly
# - Social share metadata uses absolute URLs
# - Previous events footer generates correctly
# - Session schedule renders from YAML data
```

#### 9. Deploy

```bash
# Test deployment (dry-run)
bundle exec rake deploy:staging

# Push to staging branch to trigger deployment
git push origin migrate-to-2026-template:staging

# After validation, merge to main for production
git checkout main
git merge migrate-to-2026-template
git push origin main
```

#### 10. Cleanup

```bash
# Remove backup files
rm _config.yml.backup

# Remove any Travis-related files
rm -f .travis.yml

# Remove old deployment scripts if any
# (check for legacy deploy.sh or similar)
```

#### Common Migration Gotchas

**Template variable scope:**
- Jekyll's `defaults` create `page.*` variables, not `site.*`
- Update all `{{ site.event_name }}` → `{{ page.event_name }}`

**Feature flag timing:**
- Set `schedule_live: false` initially if program isn't ready
- Set `session_deadline_passed: true` after proposal deadline

**Price variables:**
- Check all mentions in: `homepage.md`, `welcome.md`, `scholarships.md`
- Ensure consistency using `{{ page.price_* }}` variables

**Sponsor data:**
- Consider moving to `_data/sponsors.yml` for easier year-over-year updates
- See `sponsors.md` for examples of commented-out sponsor templates