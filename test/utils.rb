require 'fileutils'

class TestUtils
  def self.create_directory
    test_directory = "/tmp/#{SecureRandom.hex}"
  
    Dir.mkdir test_directory
    test_directory
  end
  
  def self.cleanup_directory(path)
    if path.start_with? '/tmp'
      FileUtils.rm_rf path
    end
  end

  def self.create_files(directory, names_with_dates, names_without_dates)
    (names_with_dates + names_without_dates).each do |filename|
      FileUtils.touch(File.join(directory, filename))
    end
  end
end
