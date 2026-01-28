require 'jekyll'
require 'yaml'

# Load test:* tasks from separate file
Dir.glob('tasks/*.rake').each { |r| load r }

# Load deployment vars from _config.yml
def deployment_config
  @deployment_config ||= YAML.load_file('_config.yml')['deployment'] || {}
end

# Default task
task default: [:build, :check, :serve]

desc "Validate configuration has been updated from template defaults"
task :check do
  puts "Validating _config.yml configuration..."
  config = YAML.load_file('_config.yml')
  defaults = config['defaults'].find { |d| d['scope']['path'] == '' }['values']
  
  errors = []
  warnings = []
  
  # Check for placeholder values that need updating
  errors << "root_url is still set to 'https://2025.srccon.org'" if defaults['root_url'] == 'https://2025.srccon.org'
  errors << "event_name is still set to 'SRCCON YYYY'" if defaults['event_name'] == 'SRCCON YYYY'
  errors << "event_date is still 'DATES' placeholder" if defaults['event_date'] == 'DATES'
  errors << "event_place is still 'PLACE' placeholder" if defaults['event_place'] == 'PLACE'
  errors << "form_link is still set to the demo Airtable URL" if defaults['form_link'].to_s.include?('pagJcROoTohbsBLFw')
  errors << "session_deadline is still set to April Fools placeholder" if defaults['session_deadline'].to_s.include?('April 1')
  errors << "session_confirm is still set to Tax Day placeholder" if defaults['session_confirm'].to_s.include?('April 15')
  
  # Check for CNAME file (should be deleted or customized)
  if File.exist?('CNAME')
    cname_content = File.read('CNAME').strip
    errors << "CNAME file exists with demo site URL (#{cname_content}). Delete or update for your event." if cname_content.include?('srccon.org')
  end
  
  warnings << "event_timezone_offset is empty (needed for live sessions feature)" if defaults['event_timezone_offset'].nil? || defaults['event_timezone_offset'].empty?
  warnings << "google_analytics_id is empty (no tracking will be enabled)" if defaults['google_analytics_id'].nil? || defaults['google_analytics_id'].empty?
  
  # verify prices are in $XXX format
  [
    defaults['price_base'], 
    defaults['price_med'], 
    defaults['price_full'], 
    defaults['price_stipend']
  ].each do |price|
    cost = price.to_s.gsub(/^\$(\d{3})$/) { |m| $1 } # extract digits
    warnings << "Ticket price #{price} has no dollar-sign prefix" unless price.to_s.start_with?('$')
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
  sh "rm -rf _site .jekyll-cache .jekyll-metadata"
end

desc "Build and serve the site locally"
task :serve do
  puts "Starting Jekyll server..."
  sh "bundle exec jekyll serve"
end

namespace :deploy do
  desc "Run all pre-deployment checks"
  task :precheck => [:check, :build, 'test:all'] do
    puts "\n✅ All pre-deployment checks passed!"
    puts "\nDeploy with:"
    puts "  rake deploy:staging          # Dry-run to staging"
    puts "  rake deploy:staging:real     # Actually deploy to staging"
    puts "  rake deploy:production       # Dry-run to production"
    puts "  rake deploy:production:real  # Actually deploy to production"
  end
  
  # Common S3 sync arguments
  S3_ARGS = "--delete --cache-control 'public, max-age=3600'"

  desc "Deploy to staging (dry-run by default)"
  namespace :staging do
    # Load bucket config once at namespace level
    staging_bucket = "#{deployment_config['bucket']}-staging"
    abort "❌ Staging bucket not configured in _config.yml" unless staging_bucket
    
    task :default => :dryrun
    
    desc "Dry-run staging deploy"
    task :dryrun => :build do
      puts "[DRY RUN] Deploying to staging bucket: #{staging_bucket}..."
      sh "aws s3 sync _site/ s3://#{staging_bucket} --dryrun #{S3_ARGS}"
      puts "\n✅ Dry-run complete. To deploy for real, run: rake deploy:staging:real"
    end

    desc "Real staging deploy (with confirmation)"
    task :real => :precheck do
      puts "\n⚠️  Deploying to STAGING: #{staging_bucket}"
      print "Continue? (y/N) "

      response = STDIN.gets.chomp
      abort "Deployment cancelled" unless response.downcase == 'y'
      
      puts "Deploying to staging bucket: #{staging_bucket}..."
      sh "aws s3 sync _site/ s3://#{staging_bucket} #{S3_ARGS}"
      puts "\n✅ Successfully deployed to staging!"
    end
  end

  desc "Deploy to production (dry-run by default)"
  namespace :production do
    # Load bucket config once at namespace level
    prod_bucket = deployment_config['bucket']
    cloudfront_dist = deployment_config['cloudfront_distribution_id']
    abort "❌ Production bucket not configured in _config.yml" unless prod_bucket
    
    task :default => :dryrun

    desc "Dry-run production deploy"
    task :dryrun => :build do
      puts "[DRY RUN] Deploying to production bucket: #{prod_bucket}..."
      sh "aws s3 sync _site/ s3://#{prod_bucket} --dryrun #{S3_ARGS}"
      
      if cloudfront_dist
        puts "[DRY RUN] Would invalidate CloudFront: #{cloudfront_dist}"
      else
        puts "⚠️ No CloudFront distribution configured (cache won't be invalidated)"
      end
      
      puts "\n✅ Dry-run complete. To deploy for real, run: rake deploy:production:real"
    end

    desc "Real production deploy (with confirmation)"
    task :real => :precheck do
      puts "\n🚨 DEPLOYING TO PRODUCTION: #{prod_bucket}"
      print "Are you absolutely sure? (yes/N) "
      response = STDIN.gets.chomp
      abort "Deployment cancelled" unless response == 'yes'
      
      puts "Deploying to production bucket: #{prod_bucket}..."
      sh "aws s3 sync _site/ s3://#{prod_bucket} #{S3_ARGS}"
      
      if cloudfront_dist
        puts "\nInvalidating CloudFront distribution: #{cloudfront_dist}..."
        sh "aws cloudfront create-invalidation --distribution-id #{cloudfront_dist} --paths '/*'"
        puts "✅ CloudFront cache invalidated"
      else
        puts "⚠️ Skipping CloudFront invalidation (not configured)"
      end
      
      puts "\n🎉 Successfully deployed to production!"
    end
  end
end
