# frozen_string_literal: true

require 'thread'

# A simple thread wrapper with mutex synchronization.
# Provides a base class for threaded listeners.
class Rbnput::SimpleMutexThread

  protected
  
  # Platform-specific run implementation.
  # Must be implemented by subclasses.
  #
  # @return [void]
  # @raise [NotImplementedError] If not implemented by subclass
  def _run; raise NotImplementedError, "Subclasses must implement _run" end

  public
  
  # @return [Boolean] true if the thread is running
  attr_reader :running
  
  # Initializes the SimpleMutexThread.
  def initialize
    @running = false
    @thread = nil
    @mutex = Mutex.new
  end

  # Starts the listener in a separate thread.
  # Check is running before start new thread.
  #
  # @return [self]
  def start
    @mutex.synchronize do
      return if @running
      @running = true
      @thread = Thread.new do
        begin; _run
        ensure; @running = false end
      end
    end
    self
  end

  # Stops the listener.
  # Sets running flag to false and waits for the thread to exit.
  #
  # @return [self]
  def stop
    @mutex.synchronize do; @running = false end
    @thread&.join(5) # Wait up to 5 seconds
    self
  end

  # Joins the thread.
  #
  # @return [Thread, nil]
  def join; @thread&.join end
  
  # Checks if the thread is alive.
  #
  # @return [Boolean]
  def alive?; @running && @thread&.alive? end


end
