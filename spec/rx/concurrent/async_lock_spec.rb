require 'minitest/autorun'
require 'minitest/spec'


require 'rx/concurrency/async_lock'

module RX

  describe AsyncLock do
    
    describe '#wait' do
      
      describe 'with_1_thread' do

        let(:lock){ AsyncLock.new}

        it 'finishes' do

          called = false
          lock.wait{ called = true}
          assert called
        end

      end

      describe 'Parallel Wait' do

        let(:lock){ AsyncLock.new}
        
        it 'waits for both locks' do
          
          called1 = false
          called2 = false

          thread1 = Thread.new do
            lock.wait do
              sleep 0.01
              called1 = true
            end
            assert called1
            assert called2
          end

          thread2 = Thread.new do
            lock.wait do
              sleep 0.05
              called2 = true
            end

            assert !called1
            assert !called2

          end
          
          [thread1,thread2].each(&:join)

        end
        
      end

      describe "#clear" do

        let(:lock){ AsyncLock.new}
        
        it "won't run once it has been cleared" do
          
          lock.clear
          called = false
          lock.wait{ called = true}
          assert !called
        end

      end

      

      
    end
  end

end



