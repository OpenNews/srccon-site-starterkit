# SRCCON [YEAR|name] Website

This is the website for SRCCON [YEAR|name], built with Jekyll and deployed via GitHub Actions to AWS S3.

## Quick Start

1. **Start Here:** Run `bundle exec rake setup` (one-time initialization - creates staging branch and swaps README files)
   - No `bundle?` Try the [Prerequisite steps](#local-development) below
1. **Configure:** Update `_config.yml` with your event details (see the [Setup Checklist](#setup-checklist) below) and customize the URL in the `CNAME` file
1. **Create AWS Buckets:** If you haven't already,  create the `staging.<event>.srccon.org` and `<event>.srccon.org` buckets [AWS S3](https://us-east-1.console.aws.amazon.com/s3/buckets?region=us-east-1). Use the "_Copy settings from existing bucket - optional_" feature and the prior year's config to speed things up.
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
- [ ] `_config.yml` - Update these values under `deployment:`:
	- [ ] `s3_bucket_staging` - name of the staging bucket, often `staging.<event>.srccon.org`
	- [ ] `s3_bucket_production` - name of the user-facing public bucket, `<event>.srccon.org`
- [ ] `_config.yml` - Update these values under `defaults:`:
	* `root_url` - The full URL of your site (e.g., `https://2050.srccon.org`)
	* `event_name` - Full event name (e.g., "SRCCON 2050")
	* `event_date` - Human-readable date (e.g., "August 12-13, 2050")
	* `event_place` - Full location (e.g., "Minneapolis, MN")
	* `event_venue` - Venue name
	* `event_venue_link` - Maps or the Venue's own public site
	* `event_timezone` - Timezone abbreviation (e.g., "CT")
	* `event_timezone_offset` - UTC offset (e.g., "-05:00"), helps drive the live-session logic
	* `event_place_abbr` - Short location (only for `layout_with_header_image`)
	* `description` - Meta description for SEO and various pages
- [ ] `layout` - Choose between "simple_layout" (default) or "layout_with_header_image" (requires a bit more work)
- [ ] `google_analytics_id` - Set if using custom tracking
- [ ] `cta_button_text` & `cta_button_link` - Configure the main call-to-action button, from the default or commented out options, or something new
- [ ] `schedule_live` - Set to `true` when ready to show the program page
- [ ] `session_deadline_passed` - Set to `true` when participation form closes
	* `session_deadline` - Form deadline (e.g., "11:59pm ET on May 15, 2026")
	* `session_confirm` - When applicants hear back (e.g., "June 1")
- [ ] Ticket prices in `_config.yml`:
	* `price_base` - Base ticket price
	* `price_med` - Mid-tier price
	* `price_full` - Full price
	* `price_stipend` - Stipend/scholarship price

### Media Assets
- [ ] `media/img/srccon_logo.png` - Main SRCCON logo (800px tall, angled "SRCCON" text)
	* For topical SRCCONs, create custom logo from [this Illustrator template](https://github.com/OpenNews/media-assets/blob/master/srccon/srccon_thematic_logo_template.ai)
- [ ] `media/img/srccon_logo_share.png` - Social media share card (1200x600px)
- [ ] `media/img/backgrounds/` - Background images (if using `layout_with_header_image`)

### Data Files
- [ ] `_data/sessions.yml` - Session data (starts with placeholder/CTA)
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

This project requires Ruby and Bundler. Check if you have them installed:

```bash
ruby --version   # Should be 3.* or higher (see .ruby-version)
bundle --version # Should be 2.0 or higher
```

If you need to install Ruby:
- **macOS/Linux**: Use [rbenv](https://github.com/rbenv/rbenv) or [rvm](https://rvm.io/)
- **macOS with Homebrew**: `brew install ruby`
- **Linux**: Check your package manager (e.g., `sudo apt install ruby-full`)
- **Windows**: Use [RubyInstaller](https://rubyinstaller.org/)

If you need to install Bundler: `gem install bundler` then `bundle install`

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

#### Deploy
```bash
bundle exec rake deploy:precheck                   # Run pre-deployment checks
bundle exec rake deploy:staging DRY_RUN=false      # Deploy to staging S3
bundle exec rake deploy:production DRY_RUN=false   # Deploy to production S3
```

**Note:** Pushing to GitHub is usually faster than local deployment.

## Repository Structure / Essential Files

* `welcome.md` - Attendee FAQ guide
* `participation_form.md` - Session proposal guide
* `program.md` - Session schedule (unlinked until `schedule_live: true`)
* `sponsors.md` - Sponsor list
* `sponsors_about.md` - Sponsor solicitation
* `scholarships.md` - Scholarship info
* `volunteer.md` - Volunteer info
* `conduct.md` - Code of conduct

### Data & Templates:
* `_data/` - YAML data for sessions and structured content
* `_includes/` - Partial templates (footers, navigation, metadata, session tables)
* `media/` - Static CSS, JS, and image assets

### Infrastructure (Rarely Modified)

* **Build System:**
	* `Rakefile` - `:build`, `:serve`, and `:deploy` commands used by humans and GitHub Actions
	* `tasks/*.rake` - Test and validation task definitions, used by humans and GitHub Actions
* **Deployment:**
	* `.github/workflows/` - GitHub Actions runs automated deployment on merges to specifically named branches
		- `deploy.yml` - Deploys static site to S3's staging or production buckets, depending on the branch
		- `test.yml` - Runs on all PRs and some automated commits, to validate they don't break things
		- `health-check.yml` - Weekly automated validation check
* **Generated/Ignored:**
	* `_site/` - Build output directory (git-ignored, deployed to AWS)
	* `.jekyll-cache/` - Local development cache (git-ignored)
* **Layout Templates:**
	* `_layouts/` - Page layouts:
		- `simple_layout.html` - Clean design with solid backgrounds (default and recommended)
		- `layout_with_header_image.html` - Large photo headers (requires custom background images and other cleanup)

## Troubleshooting

**Setup task fails (`bundle exec rake setup`):**
- Ensure you're in the root directory of the repository
- Check that `CNAME` and `_config.yml` exist
- If running on the template repository itself, setup will exit with a warning (this is expected)
- Try running with `--trace` flag: `bundle exec rake setup --trace`

**Staging branch not created:**
- The setup task creates the staging branch automatically if you're in a git repository
- If not in a git repo yet: initialize with `git init`, commit files, add remote, push to GitHub, then run `bundle exec rake setup` again
- To create manually: `git checkout -b staging && git push -u origin staging`

**CNAME conflicts with another site:**
- Each SRCCON site needs a unique subdomain (e.g., `2026.srccon.org`, `power.srccon.org`)
- Coordinate with OpenNews team to ensure no conflicts
- Update both `CNAME` file and `root_url` in `_config.yml`

**Build fails with gem errors:**
- Delete `Gemfile.lock` and run `bundle install`
- Commit the new `Gemfile.lock`
- Check that Ruby version matches `.ruby-version`

**Deployment succeeds but site shows old content:**
- CloudFront cache invalidation takes 5-10 minutes to propagate globally
- Check GitHub Actions logs to confirm invalidation was triggered
- For immediate testing, append `?cache-bust=timestamp` to URLs
- Staging environment bypasses CloudFront so updates appear immediately

**Deployment fails:**
- Check that `_config.yml` has correct S3 bucket configuration (`s3_bucket_staging` and `s3_bucket_production`)
- Verify AWS OIDC role has necessary permissions (CloudFront invalidation requires additional permissions beyond S3 write)
- Confirm repository has access to organization-level `AWS_ROLE_ARN` secret
- Review GitHub Actions logs for specific errors

**HTML validation reports false positives:**
- Adjust html-proofer flags in `tasks/test.rake`
- Add `--ignore-urls` patterns for known false positives

**Local server won't start:**
- Ensure Ruby version matches `.ruby-version`
- Run `bundle install` to update dependencies
- Check port 4000 isn't already in use: `lsof -i :4000`
- Try `bundle exec rake clean` then `bundle exec rake serve`

**rake check reports placeholder values:**
- This is expected for a new site - work through the [Setup Checklist](#setup-checklist)
- Update all placeholder values in `_config.yml`
- Run `bundle exec rake check` again to verify

---

## Additional Resources

- **Jekyll Documentation:** https://jekyllrb.com/docs/
- **GitHub Actions Workflows:** See `.github/workflows/` for deployment automation
- **Rake Tasks:** Run `bundle exec rake -T` to see all available tasks
