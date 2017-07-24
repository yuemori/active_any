# frozen_string_literal: true

module ActiveAny
  class Subscriber < ActiveSupport::LogSubscriber
    attach_to :active_any

    def exec_query(event)
      class_name = event.payload[:class_name]
      clauses = event.payload[:clauses]

      debug "#{class_name} exec_query(clauses: #{clauses})"
    end

    private

    def logger
      @logger ||= Logger.new($stdout)
    end
  end
end
