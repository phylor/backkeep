require 'minitest/autorun'
require 'securerandom'
require 'fileutils'

require_relative '../lib/directory_parser'
require_relative 'utils.rb'

class DirectoryParserTest < Minitest::Test
  def test_directory_not_existing
    assert_raises RuntimeError do
      DirectoryParser.new('/tmp/directory-which-does-not-exist')
    end
  end

  def test_directory_exists
    assert DirectoryParser.new('/tmp')
  end

  def test_empty_directory
    test_directory = TestUtils.create_directory
    parser = DirectoryParser.new(test_directory)

    assert_equal 0, parser.count

    TestUtils.cleanup_directory test_directory
  end

  def test_one_date_only
    test_directory = TestUtils.create_directory
    TestUtils.create_files(test_directory, ['phpmyadmin-02.05.2016'], [])
    parser = DirectoryParser.new(test_directory)

    assert_equal 1, parser.count
    assert_equal 'phpmyadmin-02.05.2016', parser.files.first[:filename]
  end

  def test_one_date_and_time_only
    test_directory = TestUtils.create_directory
    TestUtils.create_files(test_directory, ['phpmyadmin-02.05.2016_08:10:02'], [])
    parser = DirectoryParser.new(test_directory)

    assert_equal 1, parser.count
    assert_equal 'phpmyadmin-02.05.2016_08:10:02', parser.files.first[:filename]
  end

  def test_multiple_dates_only
    test_directory = TestUtils.create_directory
    TestUtils.create_files(test_directory, [
      'phpmyadmin-02.05.2016_08:10:02.tar.gz',
      'phpmyadmin-03.05.2016_18:00:05.tar.gz',
      'phpmyadmin-02.05.2016_09:59:02.tar.gz',
      'phpmyadmin-08.05.2016_13:10:02.tar.gz'
    ], [])
    parser = DirectoryParser.new(test_directory)

    assert_equal 4, parser.count
    assert_equal 'phpmyadmin-02.05.2016_08:10:02.tar.gz', parser.files.first[:filename]
  end

  def test_multiple_dates_only
    test_directory = TestUtils.create_directory
    TestUtils.create_files(test_directory, [
      'phpmyadmin-02.05.2016_08:10:02.tar.gz',
      'phpmyadmin-03.05.2016_18:00:05.tar.gz',
      'phpmyadmin-02.05.2016_09:59:02.tar.gz',
      'phpmyadmin-08.05.2016_13:10:02.tar.gz'
    ], [
      'phpmyadmin-README',
      'phpmyadmin-install'
    ])
    parser = DirectoryParser.new(test_directory)

    assert_equal 4, parser.count
    assert_equal 'phpmyadmin-02.05.2016_08:10:02.tar.gz', parser.files.first[:filename]
  end

  def test_days_ago
    test_directory = TestUtils.create_directory
    TestUtils.create_files(test_directory, [
      'phpmyadmin-02.05.2016_08:10:02.tar.gz',
      'phpmyadmin-03.05.2016_18:00:05.tar.gz',
      'phpmyadmin-02.05.2016_09:59:02.tar.gz',
      'phpmyadmin-08.05.2016_13:10:02.tar.gz'
    ], [
      'phpmyadmin-README',
      'phpmyadmin-install'
    ])
    parser = DirectoryParser.new(test_directory, Date.parse('10.05.2016'))

    files = parser.days_ago(3)

    assert_equal 1, files.count
    assert_equal 'phpmyadmin-08.05.2016_13:10:02.tar.gz', files.first[:filename]
  end

  def test_days_ago_no_matches
    test_directory = TestUtils.create_directory
    TestUtils.create_files(test_directory, [
      'phpmyadmin-02.05.2016_08:10:02.tar.gz',
      'phpmyadmin-03.05.2016_18:00:05.tar.gz',
      'phpmyadmin-02.05.2016_09:59:02.tar.gz',
      'phpmyadmin-08.05.2016_13:10:02.tar.gz'
    ], [
      'phpmyadmin-README',
      'phpmyadmin-install'
    ])
    parser = DirectoryParser.new(test_directory, Date.parse('10.05.2016'))

    files = parser.days_ago(1)

    assert_equal 0, files.count
  end

  def test_days_ago_all_matches
    test_directory = TestUtils.create_directory
    TestUtils.create_files(test_directory, [
      'phpmyadmin-02.05.2016_08:10:02.tar.gz',
      'phpmyadmin-03.05.2016_18:00:05.tar.gz',
      'phpmyadmin-02.05.2016_09:59:02.tar.gz',
      'phpmyadmin-08.05.2016_13:10:02.tar.gz'
    ], [
      'phpmyadmin-README',
      'phpmyadmin-install'
    ])
    parser = DirectoryParser.new(test_directory, Date.parse('10.05.2016'))

    files = parser.days_ago(10)

    assert_equal 4, files.count
  end

  def test_age_in_days
    test_directory = TestUtils.create_directory
    TestUtils.create_files(test_directory, [
      'phpmyadmin-02.05.2016_08:10:02.tar.gz',
      'phpmyadmin-03.05.2016_18:00:05.tar.gz',
      'phpmyadmin-02.05.2016_09:59:02.tar.gz',
      'phpmyadmin-08.05.2016_13:10:02.tar.gz'
    ], [
      'phpmyadmin-README',
      'phpmyadmin-install'
    ])
    parser = DirectoryParser.new(test_directory, Date.parse('10.05.2016'))

    files = parser.days_ago(10)

    assert_equal 4, files.count
    files.each do |file|
      assert_equal 8, file[:age_in_days] if file[:filename] == 'phpmyadmin-02.05.2016_08:10:02.tar.gz'
      assert_equal 7, file[:age_in_days] if file[:filename] == 'phpmyadmin-03.05.2016_18:00:05.tar.gz'
      assert_equal 8, file[:age_in_days] if file[:filename] == 'phpmyadmin-02.05.2016_09:59:02.tar.gz'
      assert_equal 2, file[:age_in_days] if file[:filename] == 'phpmyadmin-08.05.2016_13:10:02.tar.gz'
    end
  end

  def test_no_directories
    test_directory = TestUtils.create_directory
    Dir.mkdir(File.join(test_directory, "#{SecureRandom.hex}-02.05.2016"))
    parser = DirectoryParser.new(test_directory)

    assert_equal 0, parser.count
  end

  def test_days_ago_zero_days
    test_directory = TestUtils.create_directory
    TestUtils.create_files(test_directory, [
      'phpmyadmin-02.05.2016_08:10:02.tar.gz',
      'phpmyadmin-03.05.2016_18:00:05.tar.gz',
      'phpmyadmin-02.05.2016_09:59:02.tar.gz',
      'phpmyadmin-08.05.2016_13:10:02.tar.gz',
      'phpmyadmin-10.05.2016_13:10:02.tar.gz'
    ], [
      'phpmyadmin-README',
      'phpmyadmin-install'
    ])
    parser = DirectoryParser.new(test_directory, Date.parse('10.05.2016'))

    files = parser.days_ago(0)

    assert_equal 1, files.count
  end

  def test_remove_days_ago_all
    test_directory = TestUtils.create_directory
    TestUtils.create_files(test_directory, [
      'phpmyadmin-02.05.2016_08:10:02.tar.gz',
      'phpmyadmin-03.05.2016_18:00:05.tar.gz',
      'phpmyadmin-02.05.2016_09:59:02.tar.gz',
      'phpmyadmin-08.05.2016_13:10:02.tar.gz'
    ], [
      'phpmyadmin-README',
      'phpmyadmin-install'
    ])
    parser = DirectoryParser.new(test_directory, Date.parse('10.05.2016'))

    parser.remove_and_keep_days_ago(0)

    assert_equal 2, Dir[File.join(test_directory, '**', '*')].count {|file| File.file?(file) }
  end

  def test_remove_days_ago_all_but_today
    test_directory = TestUtils.create_directory
    TestUtils.create_files(test_directory, [
      'phpmyadmin-02.05.2016_08:10:02.tar.gz',
      'phpmyadmin-03.05.2016_18:00:05.tar.gz',
      'phpmyadmin-02.05.2016_09:59:02.tar.gz',
      'phpmyadmin-08.05.2016_13:10:02.tar.gz',
      'phpmyadmin-10.05.2016_13:10:02.tar.gz'
    ], [
      'phpmyadmin-README',
      'phpmyadmin-install'
    ])
    parser = DirectoryParser.new(test_directory, Date.parse('10.05.2016'))

    parser.remove_and_keep_days_ago(0)

    assert_equal 3, Dir[File.join(test_directory, '**', '*')].count {|file| File.file?(file) }
    assert File.exists?(File.join(test_directory, 'phpmyadmin-README'))
    assert File.exists?(File.join(test_directory, 'phpmyadmin-install'))
    assert File.exists?(File.join(test_directory, 'phpmyadmin-10.05.2016_13:10:02.tar.gz'))
  end

  def test_remove_days_ago_some_left
    test_directory = TestUtils.create_directory
    TestUtils.create_files(test_directory, [
      'phpmyadmin-02.05.2016_08:10:02.tar.gz',
      'phpmyadmin-03.05.2016_18:00:05.tar.gz',
      'phpmyadmin-02.05.2016_09:59:02.tar.gz',
      'phpmyadmin-08.05.2016_13:10:02.tar.gz',
      'phpmyadmin-10.05.2016_13:10:02.tar.gz'
    ], [
      'phpmyadmin-README',
      'phpmyadmin-install'
    ])
    parser = DirectoryParser.new(test_directory, Date.parse('10.05.2016'))

    parser.remove_and_keep_days_ago(3)

    assert_equal 4, Dir[File.join(test_directory, '**', '*')].count {|file| File.file?(file) }
    assert File.exists?(File.join(test_directory, 'phpmyadmin-README'))
    assert File.exists?(File.join(test_directory, 'phpmyadmin-install'))
    assert File.exists?(File.join(test_directory, 'phpmyadmin-08.05.2016_13:10:02.tar.gz'))
    assert File.exists?(File.join(test_directory, 'phpmyadmin-10.05.2016_13:10:02.tar.gz'))
  end

  def test_removed_files_days_ago_all
    test_directory = TestUtils.create_directory
    TestUtils.create_files(test_directory, [
      'phpmyadmin-02.05.2016_08:10:02.tar.gz',
      'phpmyadmin-03.05.2016_18:00:05.tar.gz',
      'phpmyadmin-02.05.2016_09:59:02.tar.gz',
      'phpmyadmin-08.05.2016_13:10:02.tar.gz'
    ], [
      'phpmyadmin-README',
      'phpmyadmin-install'
    ])
    parser = DirectoryParser.new(test_directory, Date.parse('10.05.2016'))

    files = parser.removable_files_when_keeping_in_days(0).map {|file| file[:filename] }

    assert_equal 4, files.count
    assert files.include? 'phpmyadmin-02.05.2016_08:10:02.tar.gz'
    assert files.include? 'phpmyadmin-03.05.2016_18:00:05.tar.gz'
    assert files.include? 'phpmyadmin-02.05.2016_09:59:02.tar.gz'
    assert files.include? 'phpmyadmin-08.05.2016_13:10:02.tar.gz'
  end

  def test_removed_files_days_ago_all_but_today
    test_directory = TestUtils.create_directory
    TestUtils.create_files(test_directory, [
      'phpmyadmin-02.05.2016_08:10:02.tar.gz',
      'phpmyadmin-03.05.2016_18:00:05.tar.gz',
      'phpmyadmin-02.05.2016_09:59:02.tar.gz',
      'phpmyadmin-08.05.2016_13:10:02.tar.gz',
      'phpmyadmin-10.05.2016_13:10:02.tar.gz'
    ], [
      'phpmyadmin-README',
      'phpmyadmin-install'
    ])
    parser = DirectoryParser.new(test_directory, Date.parse('10.05.2016'))

    files = parser.removable_files_when_keeping_in_days(0).map {|file| file[:filename] }

    assert_equal 4, files.count
    assert files.include? 'phpmyadmin-02.05.2016_08:10:02.tar.gz'
    assert files.include? 'phpmyadmin-03.05.2016_18:00:05.tar.gz'
    assert files.include? 'phpmyadmin-02.05.2016_09:59:02.tar.gz'
    assert files.include? 'phpmyadmin-08.05.2016_13:10:02.tar.gz'
  end

  def test_removed_files_days_ago_some_left
    test_directory = TestUtils.create_directory
    TestUtils.create_files(test_directory, [
      'phpmyadmin-02.05.2016_08:10:02.tar.gz',
      'phpmyadmin-03.05.2016_18:00:05.tar.gz',
      'phpmyadmin-02.05.2016_09:59:02.tar.gz',
      'phpmyadmin-08.05.2016_13:10:02.tar.gz',
      'phpmyadmin-10.05.2016_13:10:02.tar.gz'
    ], [
      'phpmyadmin-README',
      'phpmyadmin-install'
    ])
    parser = DirectoryParser.new(test_directory, Date.parse('10.05.2016'))

    files = parser.removable_files_when_keeping_in_days(3).map {|file| file[:filename] }

    assert_equal 3, files.count
    assert files.include? 'phpmyadmin-02.05.2016_08:10:02.tar.gz'
    assert files.include? 'phpmyadmin-03.05.2016_18:00:05.tar.gz'
    assert files.include? 'phpmyadmin-02.05.2016_09:59:02.tar.gz'
  end

  def test_age_in_days_other_date_format
    test_directory = TestUtils.create_directory
    TestUtils.create_files(test_directory, [
      'mysql-2016-05-12_15:34:45.gz',
      'mysql-2016-05-04_17:34:34.gz',
      'mysql-2016-05-01_22:17:36.gz',
      'mysql-2016-05-09_13:46:36.gz',
      'mysql-2016-05-03_13:25:21.gz',
      'mysql-2016-04-30_22:28:15.gz',
      'mysql-2016-05-06_00:41:49.gz'
    ], [
      'phpmyadmin-README',
      'phpmyadmin-install'
    ])
    parser = DirectoryParser.new(test_directory, Date.parse('12.05.2016'))

    files = parser.files

    assert_equal 7, files.count
    files.each do |file|
      assert_equal 0, file[:age_in_days] if file[:filename] == 'mysql-2016-05-12_15:34:45.gz'
      assert_equal 8, file[:age_in_days] if file[:filename] == 'mysql-2016-05-04_17:34:34.gz'
      assert_equal 11, file[:age_in_days] if file[:filename] == 'mysql-2016-05-01_22:17:36.gz'
      assert_equal 3, file[:age_in_days] if file[:filename] == 'mysql-2016-05-09_13:46:36.gz'
      assert_equal 9, file[:age_in_days] if file[:filename] == 'mysql-2016-05-03_13:25:21.gz'
      assert_equal 12, file[:age_in_days] if file[:filename] == 'mysql-2016-04-30_22:28:15.gz'
      assert_equal 6, file[:age_in_days] if file[:filename] == 'mysql-2016-05-06_00:41:49.gz'
    end
  end

  def test_missing_age
    parser = DirectoryParser.new('/tmp', Date.parse('10.05.2016'))

    filenames = File.open('test/bug-age-missing').read
    filenames.each_line do |filename|
      age = parser.age_in_days(parser.date_of_filename(filename))
      assert (8..11).include? age
    end
  end

  def test_missing_age_all_items
    filenames = []

    filenames_as_text = File.open('test/bug-age-missing-all-items').read
    filenames_as_text.each_line do |filename|
      filenames.push(filename)
    end

    parser = DirectoryParser.new(filenames, Date.parse('10.05.2016'))

    assert_equal 1261, parser.files.count
  end

  def test_missing_age_all_items_removable
    filenames = []

    filenames_as_text = File.open('test/bug-age-missing-all-items').read
    filenames_as_text.each_line do |filename|
      filenames.push(filename)
    end

    parser = DirectoryParser.new(filenames, Date.parse('14.05.2016'))

    assert_equal 699, parser.removable_files_when_keeping_in_days(6).count
  end
end
