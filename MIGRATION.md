# Migration Guide & Developer Notes

This document covers:
1. Migrating an existing SRCCON site to the 2026 template pattern
2. AWS OIDC implementation for secure, keyless deployments

---

## Part 1: Migrating SRCCON 2025 to 2026 Template Pattern

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
# Critical: Change site . root_url to page.root_url
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

#### 6. Configure Deployment Settings

**Update `_config.yml`** with your deployment configuration:

```yaml
deployment:
  bucket: srccon-2025                    # Your S3 bucket name (staging gets -staging suffix)
  cloudfront_distribution_id: E1234ABCD5678  # Your CloudFront distribution ID (optional)
```

**Verify organization-level secret exists** (should already be configured):
- `AWS_ROLE_ARN` - IAM role for OIDC authentication (see Part 2 of this migration guide below for setup instructions)

**Note:** S3 buckets and CloudFront distributions must be created in AWS before deployment. No repository-level secrets are needed - all deployment config is in `_config.yml`.

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

---

## Part 2: AWS OIDC Implementation (One-Time Setup)

**This setup is done ONCE at the organization level and shared across ALL SRCCON repositories.**

### Prerequisites

- AWS account with IAM permissions
- GitHub organization admin access
- AWS CLI installed (optional, for testing)

### Implementation Steps

### 1. Create OIDC Identity Provider in AWS

**Via AWS Console:**

1. Navigate to IAM → Identity providers
2. Click "Add provider"
3. Select "OpenID Connect"
4. Configure:
   - **Provider URL:** `https://token.actions.githubusercontent.com`
   - **Audience:** `sts.amazonaws.com`
5. Click "Add provider"

### 2. Create IAM Role for GitHub Actions

**Important:** This role will be **shared across all SRCCON event repositories**. The wildcard pattern `srccon-*` in both the trust policy and permissions allows this.

**Via AWS Console:**

1. Navigate to **IAM → Roles**
2. Click **"Create role"**
3. Select trusted entity:
   - **Trusted entity type:** Web identity
   - **Identity provider:** token.actions.githubusercontent.com
   - **Audience:** sts.amazonaws.com
4. Click **"Next"**
5. Skip adding permissions for now (we'll add them in step 3)
6. Click **"Next"**
7. Configure role:
   - **Role name:** `GitHubActions-SRCCON-Deploy`
   - **Description:** `Role for GitHub Actions to deploy SRCCON sites`
8. Click **"Create role"**

**Now edit the trust policy to add branch restrictions:**

1. Find and click on the newly created `GitHubActions-SRCCON-Deploy` role
2. Click the **"Trust relationships"** tab
3. Click **"Edit trust policy"**
4. Replace the entire JSON with:  
  **Security note:** This trust policy restricts deployments to only the `main` and `staging` branches. Other branches (like feature branches) can still run workflows but cannot assume the AWS role, preventing unauthorized deployments.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::YOUR_ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringLike": {
          "token.actions.githubusercontent.com:sub": [
            "repo:OpenNews/srccon-*:ref:refs/heads/main",
            "repo:OpenNews/srccon-*:ref:refs/heads/staging"
          ]
        },
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        }
      }
    }
  ]
}
```

5. **Replace `YOUR_ACCOUNT_ID`** with your actual 12-digit AWS account ID
6. Click **"Update policy"**
7. **Copy the role ARN** - you'll need it for GitHub secrets (find it at the top of the role summary page, format: `arn:aws:iam::123456789012:role/GitHubActions-SRCCON-Deploy`).

### 3. Create and Attach Permissions Policy

**Important:** The wildcard pattern `srccon-*` in the S3 resources allows this single role to deploy to **all SRCCON buckets** (srccon-2024, srccon-2025, srccon-2026, srccon-2024-staging, etc.).

**Via AWS Console:**

1. Navigate to **IAM → Policies**
2. Click **"Create policy"**
3. Click the **"JSON"** tab
4. Paste this policy:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "S3Deployment",
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::srccon-*",
        "arn:aws:s3:::srccon-*/*"
      ]
    },
    {
      "Sid": "CloudFrontInvalidation",
      "Effect": "Allow",
      "Action": "cloudfront:CreateInvalidation",
      "Resource": "*"
    }
  ]
}
```

5. Click **"Next"**
6. Configure policy:
   - **Policy name:** `GitHubActions-SRCCON-Permissions`
   - **Description:** `Permissions for deploying SRCCON sites to S3 and CloudFront`
7. Click **"Create policy"**

**Now attach the policy to the role:**

1. Navigate back to **IAM → Roles**
2. Click on the `GitHubActions-SRCCON-Deploy` role
3. Click **"Add permissions" → "Attach policies"**
4. Search for `GitHubActions-SRCCON-Permissions`
5. Check the box next to it
6. Click **"Attach policies"**

**Note:** This policy allows deployment to any S3 bucket starting with `srccon-`, including both production and staging buckets.

### 4. Configure GitHub Organization Secret

**This is the ONLY secret you need to configure** - it will be shared across all SRCCON event repositories.

1. Go to https://github.com/organizations/OpenNews/settings/secrets/actions
2. Click "New organization secret"
3. Configure:
   - **Name:** `AWS_ROLE_ARN`
   - **Value:** `arn:aws:iam::123456789012:role/GitHubActions-SRCCON-Deploy` (the ARN you copied in step 2)
   - **Repository access:** All repositories
4. Click **"Add secret"**

### 5. Verify the Setup

Test with any SRCCON repository:

1. Push to the `staging` branch
2. Check workflow run in GitHub Actions
3. Verify "Configure AWS credentials" step succeeds

### Troubleshooting

**"Not authorized to perform sts:AssumeRoleWithWebIdentity"**
- Verify OIDC provider exists in AWS IAM
- Check trust policy Federated ARN matches your OIDC provider
- Ensure repository name matches pattern (`srccon-*`)
- Verify branch is `main` or `staging` (others are blocked)

**"Access Denied" during S3 sync**
- Verify role has permissions policy attached
- Check S3 bucket names match pattern (`srccon-*`)
- Ensure buckets exist in AWS before deploying

**"Error: Credentials could not be loaded"**
- Verify `AWS_ROLE_ARN` secret is set at organization level
- Check workflow has `id-token: write` permission
- Ensure using `aws-actions/configure-aws-credentials@v4`

**Config extraction fails**
- Verify `_config.yml` has `deployment:` section
- Check YAML syntax is valid
- Ensure `bucket` key exists in deployment config
