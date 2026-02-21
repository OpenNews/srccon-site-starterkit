require "jekyll"
require "yaml"
require "fileutils"

# Load test:* tasks from separate file
Dir.glob("tasks/*.rake").each { |r| load r }

# Load deployment vars from _config.yml
def deployment_config
  return @deployment_config if @deployment_config

  unless File.exist?("_config.yml")
    abort "❌ _config.yml not found. Are you in the project root directory?"
  end

  begin
    config = YAML.load_file("_config.yml")
    @deployment_config = config["deployment"] || {}
  rescue => e
    abort "❌ Error loading _config.yml: #{e.message}"
  end
end

# Default task
task default: [:build, :check, :serve]

desc "Validate configuration has been updated from template defaults"
task :check do
  puts "\n" + "=" * 60
  puts "🔍 Validating SRCCON site configuration"
  puts "=" * 60

  unless File.exist?("_config.yml")
    abort "\n❌ _config.yml not found. Are you in the project root directory?"
  end

  begin
    config = YAML.load_file("_config.yml")
  rescue => e
    abort "\n❌ Error parsing _config.yml: #{e.message}"
  end

  unless config["defaults"].is_a?(Array)
    abort "\n❌ _config.yml is missing 'defaults' array"
  end

  default_scope = config["defaults"].find { |d| d["scope"] && d["scope"]["path"] == "" }
  unless default_scope && default_scope["values"]
    abort "\n❌ _config.yml is missing default scope with empty path"
  end

  defaults = default_scope["values"]
  deployments = config["deployment"]

  errors = []
  warnings = []

  # Check for required deployment configuration
  errors << "AWS buckets are still set to demo site in deployment config" if deployments["bucket"].to_s.include?("site-starterkit") || deployments["staging_bucket"].to_s.include?("site-starterkit")
  if deployments["cloudfront_distribution_id"].to_s.include?("E1234ABCD5678")
    errors << "AWS cloudfront_distribution_id is still set to demo site in deployment config, set to site's prd distribution ID (see README)"
  end

  # Check for placeholder values that need updating
  placeholder_checks = [
    ["root_url", "https://site-starterkit.srccon.org", "root_url is still set to 'https://site-starterkit.srccon.org'"],
    ["event_name", "SRCCON YYYY", "event_name is still set to 'SRCCON YYYY'"],
    ["event_date", "DATES", "event_date is still 'DATES' placeholder"],
    ["event_place", "PLACE", "event_place is still 'PLACE' placeholder"],
    ["form_link", "pagJcROoTohbsBLFw", "form_link is still set to the demo Airtable URL", :include?],
    ["session_deadline", "April 1", "session_deadline is still set to April Fools placeholder", :include?],
    ["session_confirm", "April 15", "session_confirm is still set to Tax Day placeholder", :include?]
  ]

  placeholder_checks.each do |key, value, message, method = :==|
    check_value = defaults[key].to_s
    errors << message if check_value.send(method, value)
  end

  cname_content = File.read("CNAME").strip
  errors << "CNAME file still set to demo site URL" if cname_content.include?("site-starterkit")

  warnings << "event_timezone_offset is empty (needed for live sessions feature)" if defaults["event_timezone_offset"].nil? || defaults["event_timezone_offset"].empty?
  warnings << "google_analytics_id is empty (no tracking will be enabled)" if defaults["google_analytics_id"].nil? || defaults["google_analytics_id"].empty?

  # verify prices are in $XXX format
  [
    defaults["price_base"],
    defaults["price_med"],
    defaults["price_full"],
    defaults["price_stipend"]
  ].each do |price|
    cost = price.to_s.gsub(/^\$(\d{3})$/) { |m| $1 } # extract digits
    warnings << "Ticket price #{price} has no dollar-sign prefix" unless price.to_s.start_with?("$")
    warnings << "Ticket price #{price} is not three digits" if cost && (cost.to_i < 100 || cost.to_i > 999)
  end

  if errors.any?
    puts "\n❌ Configuration Errors (MUST FIX):"
    errors.each { |e| puts "  - #{e}" }
  end

  if warnings.any?
    puts "\n⚠️  Configuration Warnings:"
    warnings.each { |w| puts "  - #{w}" }
  end

  if errors.empty?
    puts "✅ Configuration looks good!"
  end
end

desc "Build the Jekyll site"
task :build do
  puts "Building Jekyll site..."
  options = {
    "source" => ".",
    "destination" => "./_site"
  }
  Jekyll::Site.new(Jekyll.configuration(options)).process
end

desc "Clean the build directory"
task :clean do
  puts "Cleaning _site directory..."
  FileUtils.rm_rf(["_site", ".jekyll-cache", ".jekyll-metadata"])
end

desc "Build and serve the site locally"
task :serve do
  puts "Starting Jekyll server..."
  sh "bundle exec jekyll serve"
end

# Common S3 sync arguments in :deploy steps
S3_ARGS = "--delete --cache-control 'public, max-age=3600'"

desc "MOSTLY used by GitHub Actions on push/merges to `main` and `staging` branches"
namespace :deploy do
  desc "Run all pre-deployment checks"
  task precheck: [:check, :build, "test:all"] do
    puts "\n✅ All pre-deployment checks passed!"
    puts "\nDeploy with:"
    puts "  rake deploy:staging          # Dry-run to staging"
    puts "  rake deploy:staging:real     # Actually deploy to staging"
    puts "  rake deploy:production       # Dry-run to production"
    puts "  rake deploy:production:real  # Actually deploy to production"
  end

  desc "Deploy to staging (dry-run by default)"
  namespace :staging do
    task default: :dryrun

    desc "Dry-run staging deploy"
    task dryrun: :build do
      config = deployment_config
      staging_bucket = config["staging_bucket"] || "staging.#{config["bucket"]}"
      abort "❌ Staging bucket not configured in _config.yml deployment section" unless staging_bucket

      puts "[DRY RUN] Deploying to staging bucket: #{staging_bucket}..."
      sh "aws s3 sync _site/ s3://#{staging_bucket} --dryrun #{S3_ARGS}"
      puts "\n✅ Dry-run complete. To deploy for real, run: rake deploy:staging:real"
    end

    desc "Real staging deploy (with confirmation)"
    task real: :precheck do
      config = deployment_config
      staging_bucket = config["staging_bucket"] || "staging.#{config["bucket"]}"
      abort "❌ Staging bucket not configured in _config.yml deployment section" unless staging_bucket

      puts "⚠️  Deploying to STAGING: #{staging_bucket}"
      print "Continue? (y/N) "

      response = $stdin.gets.chomp
      abort "Deployment cancelled" unless response.downcase == "y"

      puts "Deploying to staging bucket: #{staging_bucket}..."
      sh "aws s3 sync _site/ s3://#{staging_bucket} #{S3_ARGS}"
      puts "\n✅ Successfully deployed to staging!"
    end
  end

  desc "Deploy to production (dry-run by default)"
  namespace :production do
    task default: :dryrun

    desc "Dry-run production deploy"
    task dryrun: :build do
      config = deployment_config
      prod_bucket = config["bucket"]
      cloudfront_dist = config["cloudfront_distribution_id"]
      abort "❌ Production bucket not configured in _config.yml deployment section" unless prod_bucket

      puts "[DRY RUN] Deploying to production bucket: #{prod_bucket}..."
      sh "aws s3 sync _site/ s3://#{prod_bucket} --dryrun #{S3_ARGS}"

      if cloudfront_dist && !cloudfront_dist.empty?
        puts "\n[DRY RUN] Would invalidate CloudFront: #{cloudfront_dist}"
      else
        puts "\n⚠️  No CloudFront distribution configured (cache won't be invalidated)"
      end

      puts "\n✅ Dry-run complete. To deploy for real, run: rake deploy:production:real"
    end

    desc "Real production deploy (with confirmation)"
    task real: :precheck do
      config = deployment_config
      prod_bucket = config["bucket"]
      cloudfront_dist = config["cloudfront_distribution_id"]
      abort "❌ Production bucket not configured in _config.yml deployment section" unless prod_bucket

      puts "🚨 DEPLOYING TO PRODUCTION: #{prod_bucket}"
      print "Are you absolutely sure? (yes/N) "
      response = $stdin.gets.chomp
      abort "Deployment cancelled" unless response == "yes"

      puts "\nDeploying to production bucket: #{prod_bucket}..."
      sh "aws s3 sync _site/ s3://#{prod_bucket} #{S3_ARGS}"

      if cloudfront_dist && !cloudfront_dist.empty?
        puts "\nInvalidating CloudFront distribution: #{cloudfront_dist}..."
        sh "aws cloudfront create-invalidation --distribution-id #{cloudfront_dist} --paths '/*'"
        puts "\n✅ CloudFront cache invalidated"
      else
        puts "\n⚠️  Skipping CloudFront invalidation (not configured)"
      end

      puts "\n🎉 Successfully deployed to production!"
    end
  end
end
