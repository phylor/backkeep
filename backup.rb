#!/usr/bin/env ruby

require 'optparse'
require 'ostruct'
require 'date'

class DirectoryParser
  def initialize(directory)
    @directory = directory
  end

  def files
    files = []
    Dir.foreach(@directory) do |item|
      next if item == '.' or item == '..' or item.start_with? '.'
  
      begin
        save_date = Date.parse(item)
        files.push({
          :name => item,
          :date => save_date,
          :age_in_days => (DateTime.now - save_date).to_i
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
end

options = OpenStruct.new
options.days_to_keep = 30
options.command = 'count'

global = OptionParser.new do |opts|
  opts.banner = 'Usage: backup [command] [options]'

  opts.on('-v', '--verbose', 'Run verbosely') do |v|
    options[:verbose] = v
  end

  opts.on_tail('-h', '--help', 'Show this message') do
    puts opts
    exit
  end
end

commands = {
  'count' => OptionParser.new do |opts|
    opts.banner = 'Usage: count [OPTIONS]'

    opts.on('-d', '--directory [TEXT]', 'Directory to analyze') do |dir|
      options[:directory] = dir
    end
  end,
  'ls' => OptionParser.new do |opts|
    opts.banner = 'Usage: ls [OPTIONS]'

    opts.on('-d', '--directory [TEXT]', 'Directory to analyze') do |dir|
      options[:directory] = dir
    end
  end,
  'delete' => OptionParser.new do |opts|
    opts.banner = 'Usage: delete [OPTIONS]'

    opts.on('-x', '--dry-run', 'Show what would be deleted, but do not delete anything') do |dr|
      options[:dryrun] = dr
    end

    opts.on('-d', '--directory [TEXT]', 'Directory to analyze') do |dir|
      options[:directory] = dir
    end

    opts.on('-k', '--keep [TEXT]', 'Days to keep backups around') do |days|
      options[:keep_in_days] = days.to_i
    end
  end
}

global.order!
command = ARGV.shift
commands[command].order!

directory = options[:directory] || '.'
directory_parser = DirectoryParser.new(directory)

case command
  when 'count' 
    puts "#{directory_parser.count} backups found in #{directory}."
  when 'ls'
    puts "Analyzing directory #{directory}"

    puts directory_parser.files.map {|file| file[:name]}
  when 'delete'
    if options[:dryrun]
      directory_parser.files.each do |file|
        puts file[:name] if file[:age_in_days] > options[:keep_in_days]
      end
    else

    end
end
