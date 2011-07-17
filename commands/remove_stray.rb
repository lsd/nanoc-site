# encoding: utf-8

usage       'remove_stray'
summary     'remove stray files from output directory'
description <<-EOS
Removes all stray files, i.e. all files not managed by nanoc, from the output directory. This is useful if you also remove remote files when deploying (e.g. with rsync’s --delete-after).

This command should be safe to run if you do not put any files in the output directory manually.
EOS

run do |opts, args, cmd|
  # Get compiled files
  site = Nanoc3::Site.new('.')
  compiled_files = site.items.map do |item|
    item.reps.map do |rep|
      rep.raw_path
    end
  end.flatten.compact.select { |f| File.file?(f) }

  # Get present files
  present_files = Dir['output/**/*'].select { |f| File.file?(f) }

  # Remove stray files
  stray_files = present_files - compiled_files
  stray_files.each { |f| FileUtils.rm(f) }

  # Remove empty directories
  loop do
    changed = false
    Dir['output/**/*'].select { |f| File.directory?(f) }.each do |dir|
      is_empty = !Dir.foreach(dir) { |n| break true if n !~ /\A\.\.?\z/ }
      next if !is_empty

      puts "Deleting empty directory #{dir}"
      Dir.rmdir(dir)
      changed = true
    end
    break if !changed
  end
end
