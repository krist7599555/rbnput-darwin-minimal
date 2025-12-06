#!/usr/bin/env ruby
# frozen_string_literal: true

MODE = ENV.fetch("APP_MODE", "local").to_sym

# Load Library
case MODE
when :local; require_relative '../lib/rbnput-darwin-minimal'
when :prod;  require 'rbnput-darwin-minimal'
else; raise "Unknown MODE #{MODE.inspect}"
end

# Example: Monitoring keyboard events
puts "=== Keyboard Listener Example (#{MODE}) ==="
puts "Press any keys. Press Ctrl+C to exit."
puts

# Create and start listener
listener = Rbnput::Listener.new
listener.on_press do |key|
  puts "\b ⬇️ up   : #{key}"
end
listener.on_release do |key|
  puts "\b ⬆️ down : #{key}"
end

begin
  listener.start # start thread
  listener.join # wait thread exit 
rescue Interrupt
  puts "\nStopping listener..."
  puts "Listener stopped."
end
