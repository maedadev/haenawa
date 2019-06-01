require 'digest/sha1'

class HaenawaUtils

  def self.version_info
    if Dir.exist?('.git')
      info = `git describe`.strip.split('-')
      ret = info[0] ? "#{info[0]}-#{info[1]}" : '0.0.0-0'
      ret << "-p#{info[2]}" if info[2].to_i > 0
    else
      ret = '0.0.0-0'
    end

    ret
  end

  def self.hashed_filename(file)
    "#{Digest::SHA1.file(file.path).hexdigest}#{File.extname(file.path)}"
  end

  def self.absolute_url(string)
    string.to_s.start_with?('https://') || string.to_s.start_with?('http://')
  end

end