require 'date'

class DirectoryParser
  def initialize(directory, now=DateTime.now)
    @directory = directory if directory.kind_of? String
    @filenames = directory if directory.kind_of? Array
    @now = now

    if @directory and not Dir.exists? @directory
      raise
    end
  end

  def date_of_filename(filename)
    Date.parse(filename.gsub(/-(\d{4})/, '\1')) # Remove minus in front of years of american date formats
  end

  def age_in_days(date)
    (@now - date).to_i
  end

  def load_filenames_from_directory
    @filenames = []

    Dir.foreach(@directory) do |item|
      next if item == '.' or item == '..' or item.start_with? '.' or Dir.exists?(File.join(@directory, item))
  
      @filenames << item
    end
  end

  def files
    load_filenames_from_directory if @directory

    files = []

    @filenames.each do |item|
      begin
        save_date = date_of_filename(item)
        files.push({
          :filename => item,
          :date => save_date,
          :age_in_days => age_in_days(save_date)
        })
      rescue
        next
      end
    end
  
    files
  end

  def count
    files.count
  end

  def days_ago(days)
    days_ago_files = []

    files.each do |file|
      days_ago_files.push file if file[:age_in_days] <= days
    end

    days_ago_files
  end

  def remove_and_keep_days_ago(days)
    removable_files_when_keeping_in_days(days).map {|file| File.delete(File.join(@directory, file[:filename])) }
  end

  def removable_files_when_keeping_in_days(days)
    files - days_ago(days)
  end
end

