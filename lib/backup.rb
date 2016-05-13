#!/usr/bin/env ruby

require 'optparse'
require 'ostruct'
require 'date'

require_relative 'directory_parser'

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
  'list' => OptionParser.new do |opts|
    opts.banner = 'Usage: list [OPTIONS]'

    opts.on('-d', '--directory [TEXT]', 'Directory to analyze') do |dir|
      options[:directory] = dir
    end
  end,
  'keep' => OptionParser.new do |opts|
    opts.banner = 'Usage: list [OPTIONS]'

    opts.on('-d', '--directory [TEXT]', 'Directory to analyze') do |dir|
      options[:directory] = dir
    end

    opts.on('-k', '--keep [TEXT]', 'Days to keep backups around') do |days|
      options[:keep_in_days] = days.to_i
    end
  end,
  'diff' => OptionParser.new do |opts|
    opts.banner = 'Usage: diff [OPTIONS]'

    opts.on('-d', '--directory [TEXT]', 'Directory to analyze') do |dir|
      options[:directory] = dir
    end

    opts.on('-k', '--keep [TEXT]', 'Days to keep backups around') do |days|
      options[:keep_in_days] = days.to_i
    end
  end,
  'remove' => OptionParser.new do |opts|
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
  when 'list'
    puts directory_parser.files.map {|file| file[:filename]}
  when 'keep'
    puts directory_parser.days_ago(options[:keep_in_days]).map {|file| file[:filename]}
  when 'diff'
    puts directory_parser.removable_files_when_keeping_in_days(options[:keep_in_days]).map {|file| file[:filename]}
  when 'remove'
    if options[:dryrun]
      puts directory_parser.removable_files_when_keeping_in_days(options[:keep_in_days]).map {|file| file[:filename]}
    else
      directory_parser.remove_and_keep_days_ago(options[:keep_in_days])
    end
end
