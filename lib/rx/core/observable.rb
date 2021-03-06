# Copyright (c) Microsoft Open Technologies, Inc. All rights reserved. See License.txt in the project root for license information.

require 'rx/concurrency/current_thread_scheduler'
require 'rx/concurrency/immediate_scheduler'
require 'rx/core/observer'
require 'rx/core/auto_detach_observer'
require 'rx/subscriptions/subscription'

module RX

  module Observable

    # Subscribes the given observer to the observable sequence.
    # @param [Observer] observer
    # @return [Subscription]
    def subscribe(observer = Observer.configure)

      auto_detach_observer = AutoDetachObserver.new observer

      if CurrentThreadScheduler.schedule_required?
        CurrentThreadScheduler.instance.schedule_with_state auto_detach_observer, method(:schedule_subscribe)
      else
        begin
          auto_detach_observer.subscription = subscribe_core auto_detach_observer
        rescue => e
          raise e unless auto_detach_observer.fail e
        end
      end

      auto_detach_observer
    end

    # Subscribes the given block to the on_next action of the observable sequence.
    # @param [Object] block
    # @return [Subscription]
    def subscribe_on_next(&block)
      raise ArgumentError.new 'Block is required' unless block_given?
      subscribe(Observer.configure {|o| o.on_next &block })
    end

    # Subscribes the given block to the on_error action of the observable sequence.
    def subscribe_on_error(&block)
      raise ArgumentError.new 'Block is required' unless block_given?
      subscribe(Observer.configure {|o| o.on_error &block })
    end

    # Subscribes the given block to the on_completed action of the observable sequence.
    def subscribe_on_completed(&block)
      raise ArgumentError.new 'Block is required' unless block_given?
      subscribe(Observer.configure {|o| o.on_completed &block })
    end

    private

    def schedule_subscribe(_, auto_detach_observer)
      begin
        auto_detach_observer.subscription = subscribe_core auto_detach_observer
      rescue => e
        raise e unless auto_detach_observer.fail e
      end

      Subscription.empty
    end

  end

  class AnonymousObservable

    include Observable

    def initialize(&subscribe)
      @subscribe = subscribe
    end

    protected

    def subscribe_core(obs)
      @subscribe.call(obs) || Subscription.empty
    end

  end

end