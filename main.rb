require 'bundler'
Bundler.require
require "tmpdir"
require 'securerandom'
require "active_support/core_ext"

puts "environment variable 'TMPDIR' is #{ENV["TMPDIR"]}"

user = "Bamboo"
file_id = SecureRandom.hex(10)

file_hash = {
  theme: "home work",
  section1: {
    question1: 1,
    question2: "hoge"
  },
  section2: {
    question1: "fuga",
    question2: [1, 3, 6]
  }
}

# ref: https://docs.ruby-lang.org/ja/latest/class/Tempfile.html

# ref: https://docs.ruby-lang.org/ja/latest/method/Dir/s/mktmpdir.html
puts "--- the directory is removed after block ---"
Dir.mktmpdir([user, file_id], Bundler.root) do |dir|
  @tempdir = dir
  puts "#{user}'s file (#{file_id}) is at #{dir}"

  File.open("#{dir}/homework.xml", "w") do |fp|
    fp.puts file_hash.to_xml
  end
end

puts "Tempdir after use. Does it still exists?: #{FileTest.directory?(@tempdir)}"

puts "--- zip directory including xml file ---"
dir = Dir.mktmpdir([user, file_id], Bundler.root)
puts "the dir is at #{dir}"

file_name = "homework.xml"
homework_file = "#{dir}/#{file_name}"
zip_name = "#{Bundler.root}/submit.zip"

begin
  # create xml file
  File.open(homework_file, "w") do |fp|
    fp.puts(file_hash.to_xml)
    puts "File is #{fp}"
    puts file_hash.to_xml
  end

  # create zip
  Zip::File.open(zip_name, Zip::File::CREATE) do |zip|
    zip.add(file_name, homework_file)

    # The way2 as below seems more simple in this case
    zip.get_output_stream("another_way.xml") { |f| f.write file_hash.to_xml }
  end
ensure
  puts "The dir(#{dir}) is being removed"
  FileUtils.remove_entry_secure dir
end

puts "Tempdir after use. Does it still exists?: #{FileTest.directory?(dir)}"
