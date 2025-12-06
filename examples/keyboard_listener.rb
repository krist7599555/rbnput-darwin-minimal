#!/usr/bin/env ruby
# frozen_string_literal: true

MODE = ENV.fetch("APP_MODE", "local").to_sym

# กำหนดการโหลด Library หรือไฟล์
# Load Library
case MODE
when :local; require_relative '../lib/rbnput-darwin-minimal' # โหลดจากไฟล์ในเครื่อง (local)
when :prod;  require 'rbnput-darwin-minimal'             # โหลดจาก gem ที่ติดตั้งแล้ว (production)
else; raise "Unknown MODE #{MODE.inspect}"               # แสดงข้อผิดพลาดหากไม่รู้จักโหมด
end

# ตัวอย่าง: การดักจับเหตุการณ์คีย์บอร์ด
# Example: Monitoring keyboard events
puts "=== Keyboard Listener Example (#{MODE}) ==="
puts "Press any keys. Press Ctrl+C to exit."
puts "กดปุ่มใดๆ บนคีย์บอร์ด. กด Ctrl+C เพื่อออกจากโปรแกรม."
puts

# สร้างและเริ่มตัวดักจับ (Create and start listener)
listener = Rbnput::Listener.new
listener.on_press do |key|
  # ทำงานเมื่อมีการกดปุ่ม
  puts "\b ⬇️ up   : #{key} (กด)"
end
listener.on_release do |key|
  # ทำงานเมื่อมีการปล่อยปุ่ม
  puts "\b ⬆️ down : #{key} (ปล่อย)"
end

begin
  listener.start # เริ่ม thread การทำงาน (start thread)
  listener.join # รอให้ thread ทำงานจนจบ (wait thread exit)
rescue Interrupt
  puts "\nStopping listener..."
  puts "Listener stopped. (หยุดการทำงาน)"
end
