# frozen_string_literal: true

module ActiveAny
  class Configuration
    attr_accessor :logger, :log_level

    def logger
      @logger ||= begin
        logger = Logger.new($stdout)
        logger.level = "::Logger::#{log_level.to_s.upcase}".constantize
        logger
      end
    end

    def log_level
      @log_level ||= :debug
    end
  end
end
