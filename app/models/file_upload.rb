# This class has responsibility to parse file and validate uploaded file

require 'roo'
class FileUpload

  attr_accessor :errors , :columns , :file , :new_filename

  def initialize(file)
    @file = file 
    @columns = []
    @errors = []
    @new_filename="tmpfile#{Time.now.strftime('%Y%m%d%I%M%S')}#{@file.original_filename}"
  end

  def parse

    if  valid?
      #Save file in Temporary folder
      f = File.open("#{RAILS_ROOT}/tmp/#{@new_filename}","wb")
      f.write File.open(@file.path, "rb").read
      f.close
      @file.close
    end
  end

  def valid?

    unless @file
      @errors << "File cannot be empty"
      return false
    end

    #check for extension
    unless ApplicationConfiguration.settings[:file_upload][:extentions].split.include?(@file.original_filename.split(".").last)
      @errors << "This file type is not supported"
      return false
    end

    #Check for size
    

    if (@file.size/(1024*1024)) > 5
      @errors << "File Size is greater than 5MB"
      return false
    end

    #Parse file
    parse_file

   
   
    @errors.empty?

  end

  private

  def parse_file
    file = Roo::Spreadsheet.custom_open(@file.original_filename,@file.path,nil,:ignore)
    file.default_sheet = file.sheets.first
    for cell_num in file.first_column..file.last_column
      @columns << file.cell(file.first_row,cell_num)
    end
  end


  
end
