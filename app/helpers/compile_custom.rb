module CompileCustom
  # Custom compilation module
  # Compiles using a custom command
  
  module_function
  def run(submission, tests)
    comments = ""
    hash = Digest::SHA1.hexdigest("#{rand(10000)}#{Time.now}")
    folder = "#{Rails.root}/tmp/compilations/#{hash}"
    `mkdir -p #{folder}`
    
    command = submission.assignment.custom_command
    command = command.gsub("$filename","#{hash}.sub")
    command = command.gsub("$folder","#{folder}")
    command = command.gsub("$filepath","#{folder}/#{hash}.sub")
    
    if submission.kind == "plaintext"
      # Write file
      File.open("#{folder}/#{hash}.sub","w") { |f| f.write(submission.plaintext.gsub("\r\n","\n").gsub("\r","\n")) }
    elsif submission.kind == "zipfile"
      unzip(submission.zipfile_path, folder)
    end
    
    # Compile
    result = `timeout 3 #{command} 2>&1`
    
    comments += "#{result}"
    
    testresult = TestResult.create(submission_id: submission.id, result: comments)
    
    # Clean up files
    `rm -rf #{folder} 2>/dev/null`
  end
  
  def unzip (file, dest)
    Zip::File.open(file) do |zip_file|
     zip_file.each do |f|
       path = File.join(dest, f.name)
       FileUtils.mkdir_p(File.dirname(path))
       zip_file.extract(f, path) unless File.exist?(path)
     end
   end
   
  end
end