# frozen_string_literal: true

module ActiveAny
  class HashAdapter < BasicAdapter
    def base_handler(record, key, value)
      record[key] == value
    end

    def regexp_handler(record, key, regexp)
      regexp.match? record[key]
    end

    def range_handler(record, key, range)
      range.include? record[key]
    end

    def array_handler(record, key, array)
      array.include? record[key]
    end

    def group_handler(records, group_values)
      return records if group_values.empty?

      records.uniq do |record|
        group_values.map { |key| record[key] }
      end
    end
  end
end
