module Fluent
  class PriorityHttpOutput < Fluent::Output
    Fluent::Plugin.register_output('priority_http', self)

    def configure(conf)
      super
    end

    def start
      super
    end

    def shutdown
      super
    end

    def emit(tag, es, chain)
      chain.next
      es.each {|time,record|
        $stderr.puts "OK!"
      }
    end
  end
end
