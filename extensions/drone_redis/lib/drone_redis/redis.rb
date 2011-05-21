require 'drone'
require 'em-redis'
require 'fiber'

module Drone
  module Storage
    
    class Redis < Base
      
      class SharedNumber
        def initialize(key, store, initial_value = 0)
          @store = store
          @key = key
          @initial_value = initial_value
        end
        
        def init_if_required
          unless @init_done
            @init_done = true
            # initialize the key to 0 if it does not exists
            @store.setnx(@key, @initial_value)
            @initial_value = nil
          end
        end
        
        def inc(n = 1)
          init_if_required()
          @store.incr(@key, n)
        end
        
        def dec(n = 1)
          init_if_required()
          @store.decr(@key, n)
        end
        
        def set(n)
          @store.set(@key, n)
        end
        
        def get
          init_if_required()
          @store.get(@key).to_f
        end
        
        def get_and_set(n)
          init_if_required()
          @store.getset(@key, n).to_f
        end
        
        def compare_and_set(expected, new_value)
          @store.watch(@key)
          if @store.get == expected
            @store.multi
            set(new_value)
            @store.exec
            true
          else
            false
          end
        end
        
      end
      
      
      class SharedFixedSizeArray
        def initialize(key, size, store, initial_value = 0)
          @store = store
          @key = key
          @size = size
          @initial_value = initial_value
          @init_done = false
          raise "wtf"
        end
        
        def init_if_required
          unless @init_done
            @init_done = true
            # initialize the key to 0 if it does not exists
            @size.times do |n|
              self[n] = @initial_value
            end
            @initial_value = nil
          end
        end
        
        def [](index, to = nil)
          init_if_required()
          
          if to
            @store.lrange(@key, index, to)
          else
            @store.lindex(@key, index)
          end
        end
        
        def []=(index, val)
          init_if_required()
          
          @store.lset(@key, index, val)
        end
        
        def size
          init_if_required()
          # size is fixed so no need to ask redis
          # for it
          @size
        end
      end
      
      
      class SharedHash
        def initialize(key, store)
          @store = store
          @key = key
        end
        
        def [](k)
          @store.hget(@key, k)
        end
        
        def []=(k, val)
          @store.hset(@key, k, val)
        end
        
        def clear
          @store.del()
        end
        
        def size
          @store.hlen(@key)
        end
        
        def keys
          @store.hkeys(@key)
        end
        
        def values
          @store.hvals(@key)
        end
        
        def map(&block)
          # Hash[1, "v1", 2, "v2"] => {1 => "v1", 2 => "v2"}
          Hash[*@store.hgetall(@key)].map(&block)
        end
        
      end
      
      
      
      def initialize(address = '127.0.0.1', db = 1, port = nil)
        @address = address
        @db = db
        @port = port
      end
      
      def connect()
        @connection ||= EM::Protocols::Redis.connect(
            :host => @address,
            :port => @port,
            :db => @db
          )
        
        @connection
      end
      
      [
        # transactions
        :multi, :exec, :watch,
        
        # for SharedNumber
        :incr, :incrby, :decr, :decrby, :get, :set, :setnx, :getset,
        
        # SharedArray
        :lindex, :lset, :llen,
        
        # SharedHash
        :hget, :hset, :hlen, :hkeys, :hvals, :hgetall
        
      ].each do |m|
        define_method(m) do |*args|
          suspend_and_execute(m, *args)
        end
      end
      
      def suspend_and_execute(cmd, *args)
        connect()
        raise "No connection" unless @connection
        # raise(NoMethodError, "command not found: #{cmd}") unless @connection.respond_to?(cmd)
        
        fb = Fiber.current
        @connection.send(cmd, *args) do |response|
          fb.resume(response)
        end
        Fiber.yield
      end
      
      # def method_missing(method, *args)
      #   suspend_and_execute(method, *args)
      # end
      
      
      
    # external api
      def request_fixed_size_array(id, size)
        SharedFixedSizeArray.new(id, size, self)
      end
      
      def request_hash(id)
        SharedHash.new(id, self)
      end
      
      def request_number(id, initial_value = 0)
        SharedNumber.new(id, self, initial_value)
      end
    end
    
  end
end
