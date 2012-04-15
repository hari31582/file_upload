#This will create job in delayed job which will be processed later

class FileProcessor
  
  def self.upload(file_name, mapping)
    Delayed::Job.enqueue FileUploadJob.new(file_name,mapping)
  end

end
