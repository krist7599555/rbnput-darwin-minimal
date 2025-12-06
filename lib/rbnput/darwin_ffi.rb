# frozen_string_literal: true

require 'ffi'

module Rbnput
  # FFI bindings for macOS ApplicationServices and CoreFoundation.
  # Provides low-level access to Quartz Event Services.
  #
  # @api private
  module DarwinFFI
    extend FFI::Library
    ffi_lib ['/System/Library/Frameworks/ApplicationServices.framework/ApplicationServices',
              '/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation']

    # CoreFoundation types
    typedef :pointer, :CFMachPortRef
    typedef :pointer, :CFRunLoopSourceRef
    typedef :pointer, :CFRunLoopRef
    typedef :pointer, :CFStringRef
    typedef :pointer, :CGEventTapProxy
    typedef :pointer, :CGEventRef
    
    # Constants
    KCGSessionEventTap = 0
    KCGHeadInsertEventTap = 0
    KCGEventTapOptionDefault = 0x00000000
    KCGEventTapOptionListenOnly = 0x00000001
    
    KCFRunLoopRunFinished = 1
    KCFRunLoopRunStopped = 2
    KCFRunLoopRunTimedOut = 3
    KCFRunLoopRunHandledSource = 4

    KCGEventSourceUnixProcessID = 1
    KCGKeyboardEventKeycode = 9

    KCGScrollWheelEventDeltaAxis1 = 11 # Y
    KCGScrollWheelEventDeltaAxis2 = 12 # X 

    KCGEventKeyDown = 10
    KCGEventKeyUp = 11
    KCGEventFlagsChanged = 12
    
    # We need to get the kCFRunLoopDefaultMode constant value
    # It's a CFStringRef. For simplicity in FFI, we can often pass NULL (0) for default mode in some APIs,
    # but CFRunLoopAddSource requires a mode.
    # A common workaround is to look it up or define it if we know the symbol name.
    # However, getting the actual pointer value of a constant exported by a dylib in FFI can be tricky.
    # We'll try to attach it.
    attach_variable :kCFRunLoopDefaultMode, :kCFRunLoopDefaultMode, :pointer

    # CGEventTapCallback function signature
    # @param proxy [CGEventTapProxy]
    # @param type [Integer] The event type
    # @param event [CGEventRef] The event reference
    # @param refcon [Pointer] User data
    # @return [CGEventRef] The event to pass through, or NULL to suppress
    callback :CGEventTapCallback, [:pointer, :int, :pointer, :pointer], :pointer

    # Functions

    # Creates an event tap.
    # @param tapLocation [Integer]
    # @param place [Integer]
    # @param options [Integer]
    # @param eventsOfInterest [Integer] Mask of events to listen for
    # @param callback [Proc] Block to be called
    # @param userInfo [Pointer]
    # @return [CFMachPortRef]
    attach_function :CGEventTapCreate, [:int, :int, :int, :uint64, :CGEventTapCallback, :pointer], :CFMachPortRef

    # Enables or disables an event tap.
    # @param tap [CFMachPortRef]
    # @param enable [Boolean]
    attach_function :CGEventTapEnable, [:CFMachPortRef, :bool], :void

    # Creates a run loop source for a Mach port.
    # @param allocator [Pointer]
    # @param port [CFMachPortRef]
    # @param order [Integer]
    # @return [CFRunLoopSourceRef]
    attach_function :CFMachPortCreateRunLoopSource, [:pointer, :CFMachPortRef, :long], :CFRunLoopSourceRef

    # Returns the current run loop.
    # @return [CFRunLoopRef]
    attach_function :CFRunLoopGetCurrent, [], :CFRunLoopRef

    # Adds a source to a run loop mode.
    # @param rl [CFRunLoopRef]
    # @param source [CFRunLoopSourceRef]
    # @param mode [CFStringRef]
    attach_function :CFRunLoopAddSource, [:CFRunLoopRef, :CFRunLoopSourceRef, :pointer], :void

    # Runs the current run loop in a specific mode.
    # @param mode [CFStringRef]
    # @param seconds [Float]
    # @param returnAfterSourceHandled [Boolean]
    # @return [Integer] Result code
    attach_function :CFRunLoopRunInMode, [:pointer, :double, :bool], :int

    # Stops a run loop.
    # @param rl [CFRunLoopRef]
    attach_function :CFRunLoopStop, [:CFRunLoopRef], :void

    # RE-DEFINED: Removes a value from a retain/release system.
    # This was defined twice in the original file, keeping one.
    # @param cf [Pointer]
    attach_function :CFRelease, [:pointer], :void

    # Checks if the current process is trusted for accessibility.
    # @return [Boolean]
    attach_function :AXIsProcessTrusted, [], :bool

    # Gets an integer value from an event field.
    # @param event [CGEventRef]
    # @param field [Integer]
    # @return [Integer]
    attach_function :CGEventGetIntegerValueField, [:pointer, :int], :int64

    # Gets the event type.
    # @param event [CGEventRef]
    # @return [Integer]
    attach_function :CGEventGetType, [:pointer], :int

    # Gets the event flags.
    # @param event [CGEventRef]
    # @return [Integer]
    attach_function :CGEventGetFlags, [:pointer], :uint64

    # Creates a keyboard event.
    # @param source [Pointer]
    # @param virtualKey [Integer]
    # @param keyDown [Boolean]
    # @return [CGEventRef]
    attach_function :CGEventCreateKeyboardEvent, [:pointer, :uint16, :bool], :pointer

    # Posts an event to the event stream.
    # @param tapLocation [Integer]
    # @param event [CGEventRef]
    attach_function :CGEventPost, [:int, :pointer], :void

    # Creates an event source.
    # @param stateID [Integer]
    # @return [Pointer]
    attach_function :CGEventSourceCreate, [:int], :pointer

    # Sets the event flags.
    # @param event [CGEventRef]
    # @param flags [Integer]
    attach_function :CGEventSetFlags, [:pointer, :uint64], :void
  end
end