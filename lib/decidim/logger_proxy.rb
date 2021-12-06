module Decidim
  class LoggerProxy
    def initialize
      @loggers = Set.new
    end

    def add(logger)
      @loggers.add(logger)
    end

    def remove(logger)
      @loggers.delete(logger)
    end

    def method_missing(name, *args, &block)
      @loggers.each do |logger|
        logger.public_send(name, *args, &block)
      end
    end
  end
end