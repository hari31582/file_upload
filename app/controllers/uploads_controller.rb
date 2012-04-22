class UploadsController < ApplicationController
  def new
  end

  def parse
    uploader = FileUpload.new(params[:contacts])
    uploader.parse
    
    unless uploader.errors.empty?
      @uploader = uploader
      render :action=>:new
      return
    end
   
    @columns = uploader.columns.map{|col| [col+" (column #{uploader.columns.index(col)+1})",col]}
    @columns.unshift(["Select",nil])

    # Security reason this has been saved in Session. 
    session[:filename] =  uploader.new_filename

  end

  def create
    if session[:filename] && params[:contacts]
       FileProcessor.upload(session[:filename],params[:contacts])
       flash[:notice]="File has been uploaded successfully."
       session[:filename] = nil
       render :action=>:new
    end
  end

end
