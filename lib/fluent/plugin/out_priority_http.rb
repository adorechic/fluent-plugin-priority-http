module Fluent
  class PriorityHttpOutput < Fluent::Output
    Fluent::Plugin.register_output('priority_http', self)

    def configure(conf)
      super
    end

    def start
      @queue = {1 => [], 2 => [], 3 => []}
      @alive = true
      @mutex = Mutex.new
      @cond = ConditionVariable.new
      @thread = Thread.start do
        @mutex.lock
        while @alive || !@queue.values.all?(&:empty?)
          job_priority = (1..3).find {|i| !@queue[i].empty? }

          if job_priority
            job = @queue[job_priority].shift
            @mutex.unlock
            invoke(job)
            @mutex.lock
          else
            @cond.wait(@mutex)
          end
        end
        @mutex.unlock
      end
    end

    def invoke(data)
      uri = URI.parse("http://example.com/")
      req = Net::HTTP::Post.new(uri.path)
      res = Net::HTTP.start(uri.host, uri.port) do |http|
        http.request(req, data.to_json)
      end
    end

    def shutdown
      @alive = false
      @mutex.synchronize do
        @cond.signal
      end
      @thread.join
    end

    def emit(tag, es, chain)
      chain.next
      es.each {|time,record|
        priority = case record["job_priority"]
                   when "high"
                     1
                   when "normal"
                     2
                   when "low"
                     3
                   else
                     2
                   end

        @mutex.synchronize do
          @queue[priority].push(record)
          @cond.signal
        end
      }
    end
  end
end
