module Grub
  class Gemfile

    GEM_LINE_REGEX = /\A\s*gem[\s(]+["'](?<name>[^'"]*)["']/.freeze

    attr_accessor :gemfile_path, :gem_lines, :source, :options

    def initialize(gemfile_path, options = {})
      @gemfile_path = gemfile_path
      @source = []
      @gem_lines = []
      @options = options
    end

    def parse
      self.source = File.readlines(gemfile_path)
      source.each_with_index do |line, i|
        if match = GEM_LINE_REGEX.match(line)
          prev_line = source[i - 1] if i > 0
          prev_line_comment = prev_line if is_line_a_comment?(prev_line)
          self.gem_lines << GemLine.new(
            name: match[:name],
            original_line: line,
            location: i,
            prev_line_comment: prev_line_comment,
            options: options
          )
        end
      end
    end

    def write_comments
      gem_lines.reverse.each do |gem_line|
        source.insert(gem_line.location, gem_line.comment) if gem_line.should_insert?
      end
      File.write(gemfile_path, source.join)
    end

    private

    def is_line_a_comment?(line)
      line && line.strip.start_with?("#")
    end

  end
end
