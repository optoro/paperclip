require 'active_support/core_ext/module/delegation'

module Paperclip
  class AbstractAdapter
    OS_RESTRICTED_CHARACTERS = %r{[/:]}

    attr_reader :content_type, :original_filename, :size
    delegate :binmode, :binmode?, :close, :close!, :closed?, :eof?, :path, :rewind, :unlink, :to => :@tempfile
    alias :length :size

    def fingerprint
      @fingerprint ||= Digest::MD5.file(path).to_s
    end

    def read(length = nil, buffer = nil)
      @tempfile.read(length, buffer)
    end

    def inspect
      "#{self.class}: #{self.original_filename}"
    end

    def original_filename=(new_filename)
      return unless new_filename
      @original_filename = new_filename.gsub(OS_RESTRICTED_CHARACTERS, "_")
    end

    def nil?
      false
    end

    def assignment?
      true
    end

    private

    def destination
      @destination ||= TempfileFactory.new.generate(@original_filename.to_s)
    end

    def copy_to_tempfile(src)
      Paperclip.log("source file (#{src.path}) directory")
      puts `ls -lah #{Pathname.new(src).dirname}`
      FileUtils.cp(src.path, destination.path)
      Paperclip.log("temp file (#{destination.path}) directory after copy")
      puts `ls -lah #{Pathname.new(destination).dirname}`
      destination
    end
  end
end
