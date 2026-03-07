require "html-proofer"

namespace :review do
  desc "Check external/public URLs in the built site (slower, requires network access)"
  task :external_links do
    # if no _site/, remind user to run bundle exec rake build first
    unless Dir.exist?("./_site")
      abort "❌ No _site/ directory found. Please run 'bundle exec rake build' first."
    end

    # Suppress Ruby warnings from html-proofer dependencies
    original_verbose = $VERBOSE
    $VERBOSE = nil

    begin
      HTMLProofer.check_directory(
        "./_site",
        {
          disable_external: false,
          enforce_https: false,
          ignore_urls: [
            "http://localhost",
            "http://127.0.0.1",
            "https://use.typekit.net",
            %r{\Ahttps://opennews\.us5\.list-manage\.com/},
          ],
          allow_hash_href: false,
          check_external_hash: false, # Skip hash validation
          log_level: :info,
          # Add some reasonable defaults for external checking
          typhoeus: {
            followlocation: true,
            maxredirs: 5,
            connecttimeout: 10,
            timeout: 30,
          },
          hydra: {
            max_concurrency: 2, # Be gentle with external sites
          },
          # optional
          # cache: {
          #   timeframe: {
          #     external: "1d", # Cache external link checks for 1 day
          #   },
          # },
        },
      ).run
      puts "✅ External link validation passed!"
    rescue => e
      puts "❌ External link validation failed: #{e.message}"
      raise
    ensure
      $VERBOSE = original_verbose
    end
  end
end
