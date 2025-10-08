# frozen_string_literal: true

module Arclight
  class YearRange
    attr_accessor :years

    def initialize(dates = nil)
      @years = []
      self << parse_ranges(dates) if dates.present?
    end

    def to_s
      return if years.empty?
      return to_s_for_streak(years) unless gaps?

      to_s_with_gaps
    end

    def <<(other)
      return self if other.blank?

      @years |= other # will remove duplicates
      @years.sort!
      self
    end

    def parse_range(dates)
      return if dates.blank?

      if dates.include?('/')
        start_year, end_year = dates.split('/').map { |date| to_year_from_iso8601(date) }
        return [start_year] if end_year.blank?
        raise ArgumentError, "Range is too large: #{dates}" if (end_year - start_year) > 1000
        raise ArgumentError, "Range is inverted: #{dates}" unless start_year <= end_year

        (start_year..end_year).to_a
      else
        [to_year_from_iso8601(dates)]
      end
    end

    def parse_ranges(dates)
      dates.map { |date| parse_range(date) }.flatten.sort.uniq
    end

    def to_year_from_iso8601(date)
      return if date.blank?

      date.split('-').first[0..3].to_i # Extracts the year part from ISO8601 formats
    end

    def gaps?
      return false if years.blank?

      (years.min..years.max).to_a != years
    end

    private

    def to_s_with_gaps
      raise ArgumentError if years.blank? || years.length < 2

      results = []
      streak = [years[0]]
      i = streak.first
      years[1..].each do |j|
        i += 1
        if i == j
          streak << j
        else
          results << (streak.length == 1 ? streak.first.to_s : to_s_for_streak(streak))
          streak = [j]
          i = j
        end
      end
      results << to_s_for_streak(streak)
      results.join(', ')
    end

    def to_s_for_streak(streak)
      return streak.min.to_s if streak.min == streak.max

      streak.minmax.map(&:to_s).join('-')
    end
  end
end
