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