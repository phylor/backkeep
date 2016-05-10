require 'date'

class DirectoryParser
  def initialize(directory, now=DateTime.now)
    @directory = directory
    @now = now

    if not Dir.exists? @directory
      raise
    end
  end

  def files
    files = []
    Dir.foreach(@directory) do |item|
      next if item == '.' or item == '..' or item.start_with? '.'
  
      begin
        save_date = Date.parse(item)
        files.push({
          :filename => item,
          :date => save_date,
          :age_in_days => (@now - save_date).to_i
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
end

