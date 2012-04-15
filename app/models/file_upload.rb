# This class has responsibility to parse file and validate uploaded file
require 'fastercsv'
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
       f = File.open("#{RAILS_ROOT}/tmp/#{@new_filename}","w")
       f.write File.open(@file.path, "r").read
       f.close
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

    #Parse file
    if @file.original_filename =~/csv/
      parse_csv_file
    else
      parse_xls_file
    end

    #check valid columns
    for col in  (ApplicationConfiguration.settings[:file_upload][:not_supported_columns].split & @columns)
      @errors << "Column #{col} is not supported. Please remove this column"
    end
    @errors.empty?

  end

  private

  def parse_csv_file
    @columns = FasterCSV.parse(@file).first
    p "Columns"
    p @columns
   
  end

  def parse_xls_file
    @columns << 'id'
  end

end
