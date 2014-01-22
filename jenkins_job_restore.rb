home_dir = Dir.pwd
jenkins_jobs = [ENV["JENKINS_JOBS"]]
dirs = Array.new
jenkins_jobs.each do |jenkins_job|
  Dir.foreach(jenkins_job) do |item|
    dir = item if File.directory? File.join(jenkins_job,item) and !(item =='.' || item == '..')
    next if dir.nil?
    dir = File.join(jenkins_job, dir)
    next unless File.exist?(File.join(dir,'config.xml'))
    dirs << dir
    if File.exist?(File.join(dir,'jobs'))
      jenkins_jobs << File.join(dir,'jobs')
    end
  end
end

dirs.each do |dir|
  new_xml = ""
  old_xml = ""
  File.open(File.join(dir,'config.xml'), 'r') do |f|
    print "Opening #{dir}/config.xml for reading.\n"
    while line = f.gets
      old_xml = old_xml + line
      rvm_launcher = false
      if line.strip.eql?("<launcher ruby-class=\"Jenkins::Launcher\" pluginid=\"rvm\">") || line.strip.eql?("<native ruby-class=\"Java::Hudson::LocalLauncher\" pluginid=\"rvm\"/>") || (line.strip.eql?("</launcher>") && rvm_launcher)
        rvm_launcher = !rvm_launcher
        line = ""
      end
      new_xml = new_xml + line
    end
  end
  File.open(File.join(dir,'config.xml'), 'w') do |f|
    print "Opening #{dir}/config.xml for writing.\n"
    f.write new_xml
    print "Saved altered XML\n"
  end
  File.open(File.join(dir,"config.xml.bak.#{Time.now.strftime("%Y%m%d%H%M%S")}"), 'w') do |f|
    print "Opening #{dir}/config.xml.bak.1 for writing.\n"
    f.write old_xml
    print "Saved old XML\n"
  end
end
Dir.chdir home_dir

print "[Completed]\n"