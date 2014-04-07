# Copyright (c) Microsoft Open Technologies, Inc. All rights reserved. See License.txt in the project root for license information.

require 'thread'

module RX
  # Asynchronous lock.
  class AsyncLock

    def initialize
      @queue = []
      @is_acquired = false
      @has_faulted = false
      @gate = Mutex.new
    end

    # Queues the action for execution. If the caller acquire the lock and becomes
    # the owner, the queue is processed.  If the lock is already owned, the action
    # is queued and will get processed by the owner.    
    def wait(&action)
      @gate.synchronize do
        @queue.push action unless @has_faulted

        if @is_acquired or @has_faulted
          return
        else
          @is_acquired = true
        end


      end

      loop do
        work = nil

        @gate.synchronize do
          work = @queue.shift

          unless work
            @is_acquired = false
            return
          end
        end

        begin
          work.call
        rescue
          clear
          raise
        end
      end
    end

    # Clears the work items in the queue and drops further work being queued.
    def clear
      @gate.synchronize do
        @queue = []
        @has_faulted = true
      end
    end

  end
end
