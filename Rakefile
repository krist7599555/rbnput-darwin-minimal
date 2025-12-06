require "rake"

EXAMPLE = File.expand_path("examples/keyboard_listener.rb", __dir__)

desc "Run example in local mode"
task :test_local do
  sh({ "APP_MODE" => "local" }, "ruby #{EXAMPLE}")
end

desc "Run example in prod mode"
task :test_prod do
  sh({ "APP_MODE" => "prod" }, "ruby #{EXAMPLE}")
end

desc "Run example in prod mode --rebuild --no-cache"
task :test_prod_latest do
  sh("rake build")
  sh("rake test_prod")
end

desc "Build Gem"
task :build do
  sh("rm rbnput-darwin-minimal-*.gem || true")
  sh("gem build ./rbnput-darwin-minimal.gemspec")
end

desc "Gem push"
task :push do
  sh("rake build")
  sh("gem push rbnput-darwin-minimal-*.gem")
end