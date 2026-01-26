require 'jekyll'

# Load test:* tasks from separate file
Dir.glob('tasks/*.rake').each { |r| load r }

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
  task :precheck => [:check, :build, :test] do
    puts "\n✅ All pre-deployment checks passed!"
    puts "Ready to deploy. Use 'rake deploy:staging' or 'rake deploy:production'"
  end
  
  desc "Deploy to S3 staging bucket (dry-run by default, set DRY_RUN=false to deploy)"
  task :staging do
    dry_run = ENV['DRY_RUN'] != 'false'
    bucket = ENV['AWS_S3_BUCKET_STAGING']
    
    abort "AWS_S3_BUCKET_STAGING environment variable not set" unless bucket
    
    puts "#{dry_run ? '[DRY RUN] ' : ''}Deploying to staging bucket: #{bucket}..."
    sh "aws s3 sync _site/ s3://#{bucket} " \
       "#{dry_run ? '--dryrun ' : ''}" \
       "--delete " \
       "--cache-control 'public, max-age=3600'"
  end

  desc "Deploy to S3 production bucket and invalidate CloudFront (dry-run by default, set DRY_RUN=false to deploy)"
  task :production do
    dry_run = ENV['DRY_RUN'] != 'false'
    bucket = ENV['AWS_S3_BUCKET']
    distribution = ENV['CLOUDFRONT_DISTRIBUTION_ID']
    
    abort "AWS_S3_BUCKET environment variable not set" unless bucket
    
    puts "#{dry_run ? '[DRY RUN] ' : ''}Deploying to production bucket: #{bucket}..."
    sh "aws s3 sync _site/ s3://#{bucket} " \
       "#{dry_run ? '--dryrun ' : ''}" \
       "--delete " \
       "--cache-control 'public, max-age=3600'"
    
    if !dry_run && distribution
      puts "Invalidating CloudFront distribution: #{distribution}..."
      sh "aws cloudfront create-invalidation " \
         "--distribution-id #{distribution} " \
         "--paths '/*'"
    elsif !dry_run
      puts "Skipping CloudFront invalidation (CLOUDFRONT_DISTRIBUTION_ID not set)"
    end
  end
end
