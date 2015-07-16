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
    command = command.gsub("$folder","#{folder}")
    command = command.gsub("$filepath","#{folder}/#{hash}.sub")
    
    if submission.kind == "plaintext"
      command = command.gsub("$filename","#{hash}.sub")
      # Write file
      File.open("#{folder}/#{hash}.sub","w") { |f| f.write(submission.plaintext.gsub("\r\n","\n").gsub("\r","\n")) }
    elsif submission.kind == "zipfile"
      command = command.gsub("$filename", submission.zipfile_path.split("/").last)
      unzip(submission.zipfile_path, folder)
    end
    
    # Compile
    result = `timeout 3 #{command} 2>&1`
    
    comments += "#{result}"
    
    testresult = TestResult.create(submission_id: submission.id, result: comments)
    
    # Clean up files
    `rm -rf #{folder} 2>/dev/null`
  end
end