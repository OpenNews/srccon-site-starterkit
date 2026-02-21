require "yaml"
require "fileutils"

desc "Initialize a new SRCCON site from this template"
task :setup do
  puts "\nSetting up new SRCCON site from template..."

  # Check if this is the template repo itself
  config = YAML.load_file("_config.yml")
  defaults_values = config.dig("defaults", 0, "values") || {}
  root_url = defaults_values["root_url"]

  if root_url&.include?("site-starterkit.srccon.org")
    puts "\n⚠️  WARNING: This appears to be the template repository itself!"
    puts "This task should only be run on NEW sites created from the template."
    exit 0
  end

  # Remove template-only documentation
  template_docs = %w[AWS_authentication.md README.md]
  template_docs.each { |doc| File.delete(doc) if File.exist?(doc) }

  # rename SITE_README to main README
  if File.exist?("SITE_README.md")
    File.rename("SITE_README.md", "README.md")
  else
    puts "\n⚠️  SITE_README.md not found (may have already been renamed)"
    exit 0
  end

  # Create staging branch if it doesn't exist
  puts "\n📋 Setting up branches..."

  # Check if we're in a git repository
  if system("git rev-parse --git-dir > /dev/null 2>&1")
    # Check if staging branch exists (locally or remotely)
    staging_exists_local = system("git show-ref --verify --quiet refs/heads/staging")
    staging_exists_remote =
      system("git ls-remote --heads origin staging 2>/dev/null | grep -q staging")

    if staging_exists_local || staging_exists_remote
      puts "   ✓ Staging branch already exists"
      # Switch to staging if not already on it
      current_branch = `git branch --show-current`.strip
      if current_branch != "staging"
        system("git checkout staging 2>/dev/null")
        puts "   ✓ Switched to staging branch"
      end
    elsif system("git checkout -b staging 2>/dev/null")
      # Create and push staging branch
      if system("git push -u origin staging 2>/dev/null")
        puts "   ✓ Created and pushed staging branch"
      else
        puts "   ⚠️  Created staging branch locally, but push failed"
        puts "   💡 You may need to push manually: git push -u origin staging"
      end
    else
      puts "   ⚠️  Could not create staging branch"
      puts "   💡 You may need to create it manually: git checkout -b staging && git push -u origin staging"
    end
  else
    puts "   ⚠️  Not a git repository - skipping branch creation"
    puts "   💡 Initialize git and push to GitHub, then run setup again"
  end

  # Summary and next steps
  puts "\n✅ Setup complete! You're now on the staging branch."
  puts "If you prefer to work via feature branchs, go ahead and branch off `staging` (but you'll still need `staging`)"
end
