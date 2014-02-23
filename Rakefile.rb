FILE = File.expand_path('/play/TV/ruby/links.txt')
DONE = File.expand_path('/play/TV/ruby/links_DONE.txt')
SAVE_TO = File.expand_path('/play/TV/ruby')

desc "Download files from: #{FILE} to #{SAVE_TO}. Uses ENV=wget"
task :download do

  Dir.chdir(SAVE_TO) {
    `touch #{DONE}`
    done  = File.read(DONE).split.uniq
    
    `touch #{FILE}`
    links = File.read(FILE).split.uniq - done

    links.each do |lk| 
      name = File.basename(lk).split('?').first
      begin
        sh "wget #{ENV['wget']} -O #{name} -c #{lk}"
        sh "echo #{lk} >> #{DONE}"
      rescue Interrupt => e
        puts "Stopped: #{name}"
      end
      
    end
  }

end

desc "Displays number of downloads that are still waiting."
task :download_count do
  c = (File.read(FILE).split.uniq - File.read(DONE).split.uniq).size
  puts c.to_s
end

desc "Extracts links from file and adds them to links list. Uses ENV=path"
task :download_from_file do
  raise "Lynx not installed." if `which lynx`.strip.empty?
  raise "No file given: ENV=path" unless ENV['path']
  raise "Not a file" unless File.exists?(ENV['path'])
  output = `lynx -dump -listonly -nonumbers "file://#{File.expand_path ENV['path']}" 2>&1`.strip
  raise output unless $?.exitstatus
  lines = output.split
  lines.pop
  o = File.read(FILE)
  n = lines.join("\n") + "\n" + o
  File.write(FILE, n)
  puts "Added: #{lines.size}"
end

