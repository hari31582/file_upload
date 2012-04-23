class UploadsController < ApplicationController
  before_filter :verify_actions , :except=>[:new,:parse,:create]

  def new

  end

  # validate the uploaded file and parse using Roo. Parse view to be refactored later to Read DB columns than hardcode columns
  def parse
    uploader = FileUpload.new(params[:contacts])
    uploader.parse
    
    unless uploader.errors.empty?
      @uploader = uploader
      render :action=>:new
      return
    end
   
    @columns = uploader.columns.map{|col| [(col+" (column #{uploader.columns.index(col)+1})").downcase,col.downcase]}
    @columns.unshift(["Select",nil])

    # Security reason this has been saved in Session. 
    session[:filename] =  uploader.new_filename

  end

  #Create job for background process once columns are matched
  def create
    if session[:filename] && params[:contacts]
       FileProcessor.upload(session[:filename],params[:contacts])
       flash[:notice]="File has been uploaded and processesing is in progress. We will email you after processing."
       session[:filename] = nil
       render :action=>:new
    end
  end

  private
  def verify_actions
    redirect_to :action=>:new
  end

end
