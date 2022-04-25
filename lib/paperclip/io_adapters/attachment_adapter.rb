module Paperclip
  class AttachmentAdapter < AbstractAdapter
    def initialize(target)
      @target, @style = case target
      when Paperclip::Attachment
        [target, :original]
      when Paperclip::Style
        [target.attachment, target.name]
      end

      cache_current_values
    end

    private

    def cache_current_values
      self.original_filename = @target.original_filename
      @content_type = @target.content_type
      @tempfile = copy_to_tempfile(@target)
      @size = @tempfile.size || @target.size
    end

    def copy_to_tempfile(source)
      Paperclip.log(source.queued_for_write)

      if source.staged?
        src = source.staged_path(@style)
        dst = destination.path

        Paperclip.log("tmp directory before copy, source file: #{src}")
        puts `ls -lah /tmp`
        FileUtils.cp(src, dst)
        Paperclip.log("tmp directory after copy, destination file: #{dst}")
        puts `ls -lah /tmp`
      else
        Paperclip.log("attachment is not staged")
        source.copy_to_local_file(@style, destination.path)
      end
      destination
    end
  end
end

Paperclip.io_adapters.register Paperclip::AttachmentAdapter do |target|
  Paperclip::Attachment === target || Paperclip::Style === target
end
