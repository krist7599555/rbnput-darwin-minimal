# frozen_string_literal: true

require 'set'
require_relative './key_code'
require_relative './simple_mutex_thread'
require_relative './darwin_ffi'

module Rbnput
  # Base listener for keyboard events
  # คลาส Listener พื้นฐานสำหรับเหตุการณ์คีย์บอร์ด บน macOS
  class DarwinListener < Rbnput::SimpleMutexThread
    # Initializes the DarwinListener.
    # สร้าง instance ใหม่สำหรับดักจับคีย์บอร์ด
    #
    # @param on_press [Proc, nil] Callback when a key is pressed.
    # @param on_release [Proc, nil] Callback when a key is released.
    # @param kwargs [Hash] Additional options passed to SimpleMutexThread.
    def initialize(on_press: nil, on_release: nil, **kwargs)
      super(*kwargs)
      @on_press = on_press     # callback เมื่อกดปุ่ม
      @on_release = on_release # callback เมื่อปล่อยปุ่ม

      @loop = nil
      @tap = nil
      @callback_proc = nil # Keep reference to prevent GC (เก็บ reference ไว้เพื่อป้องกัน Garbage Collection)
    end
    attr_reader :on_press, :on_release

    # Sets the callback for key press events.
    # ตั้งค่า callback สำหรับการกดปุ่ม
    #
    # @yield [key]
    # @yieldparam key [KeyCode] The key that was pressed.
    def on_press(&proc)
      @on_press = proc
    end
    
    # Sets the callback for key release events.
    # ตั้งค่า callback สำหรับการปล่อยปุ่ม
    #
    # @yield [key]
    # @yieldparam key [KeyCode] The key that was released.
    def on_release(&proc)
      @on_release = proc
    end

    # The main run loop for the listener.
    # Internal method called by the thread.
    #
    # @api private
    def _run
      # ตรวจสอบว่า Process ได้รับสิทธิ์ Accessibility หรือไม่
      unless Rbnput::DarwinFFI.AXIsProcessTrusted()
        @log.warn("Process is not trusted! Input monitoring will not work until added to accessibility clients.")
        @log.warn("โปรแกรมนี้ยังไม่ได้รับสิทธิ์ Accessibility! การดักจับอินพุตจะไม่ทำงานจนกว่าจะได้รับอนุญาต")
      end

      # Create the callback
      # สร้าง callback function ที่จะถูกเรียกเมื่อมี event
      @callback_proc = FFI::Function.new(:pointer, [:pointer, :int, :pointer, :pointer]) do |proxy, type, event, refcon|
        # ดึงค่า key code จาก event และแปลงเป็น KeyCode object
        key_code = DarwinFFI
          .CGEventGetIntegerValueField(event, Rbnput::DarwinFFI::KCGKeyboardEventKeycode)
          .then { |vk| KeyCode.from_vk(vk) }
        
        case type
        when Rbnput::DarwinFFI::KCGEventKeyDown;      @on_press&.call(key_code)   # กดปุ่ม
        when Rbnput::DarwinFFI::KCGEventKeyUp;        @on_release&.call(key_code) # ปล่อยปุ่ม
        when Rbnput::DarwinFFI::KCGEventFlagsChanged; @on_press&.call(key_code)   # ปุ่ม Modifier เปลี่ยนแปลง (เช่น Shift, Ctrl)
        end
        event
      end

      # สร้าง Event Tap เพื่อดักจับ event ของระบบ
      @tap = Rbnput::DarwinFFI.CGEventTapCreate(
        Rbnput::DarwinFFI::KCGSessionEventTap,
        Rbnput::DarwinFFI::KCGHeadInsertEventTap,
        Rbnput::DarwinFFI::KCGEventTapOptionDefault,
        (1 << Rbnput::DarwinFFI::KCGEventKeyDown)  | (1 << Rbnput::DarwinFFI::KCGEventKeyUp) | (1 << Rbnput::DarwinFFI::KCGEventFlagsChanged), # ระบุประเภท event ที่ต้องการดักจับ
        @callback_proc,
        nil
      )

      if @tap.null?
        @log.error("Failed to create event tap")
        @log.error("ไม่สามารถสร้าง event tap ได้")
        return
      end

      # Create run loop source
      # สร้าง run loop source จาก tap
      source = Rbnput::DarwinFFI.CFMachPortCreateRunLoopSource(nil, @tap, 0)
      
      # Add to current run loop
      # เพิ่ม source เข้าไปใน run loop ปัจจุบัน
      @loop = Rbnput::DarwinFFI.CFRunLoopGetCurrent()
      Rbnput::DarwinFFI.CFRunLoopAddSource(@loop, source, Rbnput::DarwinFFI.kCFRunLoopDefaultMode)
      
      # Enable tap
      # เปิดใช้งาน tap
      Rbnput::DarwinFFI.CGEventTapEnable(@tap, true)
      
      # Run loop
      # เริ่มทำงาน loop เพื่อรอรับ event
      while @running
        _result = Rbnput::DarwinFFI.CFRunLoopRunInMode(Rbnput::DarwinFFI.kCFRunLoopDefaultMode, 0.1, false)
        
        # 0.1 second timeout allows us to check @running flag
        # timeout 0.1 วินาที เพื่อให้สามารถตรวจสอบ flag @running ได้ (เพื่อให้หยุด loop ได้อย่างนุ่มนวล)
      end
    ensure
      # Cleanup เมื่อจบการทำงาน
      Rbnput::DarwinFFI.CFRelease(@tap) if @tap && !@tap.null?
      Rbnput::DarwinFFI.CFRelease(source) if source && !source.null?
      @tap = nil
      @loop = nil
    end

    # Stops the listener and the run loop.
    # หยุดการทำงานของ listener
    #
    # @return [void]
    def stop
      super
      # หยุด run loop
      Rbnput::DarwinFFI.CFRunLoopStop(@loop) if @loop && !@loop.null?
    end

  end
end
