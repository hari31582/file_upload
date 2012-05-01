=begin
  This is the job to process uploaded file and use multi threading if records are more. At the moment threading is not very effective as
  Activerecord is not enable for concurrency and execution has been put in Synchronized block
=end

require 'roo'
class FileUploadJob
  attr_accessor :filename , :column_mapping
  def initialize(file,mapping)
    @filename = file
    @column_mapping = mapping
    RAILS_DEFAULT_LOGGER.debug "message"
  end

  def perform
    read_file
    delete_file
    return true
  end

  private

  def delete_file
    if File.exist?("#{RAILS_ROOT}/tmp/#{@filename}")
      File.delete("#{RAILS_ROOT}/tmp/#{@filename}")
    end
  end

  def read_file
    
    excel = Roo::Spreadsheet.custom_open(@filename , "#{RAILS_ROOT}/tmp/#{@filename}",nil,:ignore)
    excel.default_sheet = excel.sheets.first
    headers = []
    for cell_num in excel.first_column..excel.last_column
      headers << excel.cell(excel.first_row,cell_num)
    end
    mapping =  @column_mapping.invert
    row_size = ApplicationConfiguration.settings[:threads][:rows_per_thread]
    @processed_items=0
    @mutex = Mutex.new

    time = Time.now
    if (excel.last_row - excel.first_row) > 50
      
      pool = Threading::ThreadPoolContainer.get_threaddpool
      actual_row = row = 2
      while row <= excel.last_row
       
        pool.process {    
          begin
            actual_row +=row_size
            process_row(excel,actual_row-row_size,actual_row,headers,mapping)
          rescue=>e
            RAILS_DEFAULT_LOGGER.info e.message
            RAILS_DEFAULT_LOGGER.info e.backtrace
            RAILS_DEFAULT_LOGGER.flush
          end
        }
        row += row_size
      end
      pool.join
    else
      process_row(excel,excel.first_row+1,excel.last_row+1,headers,mapping)
    end
    RAILS_DEFAULT_LOGGER.info "Total time for #{Time.now-time} seconds"
    send_admin_notification(@processed_items,excel.last_row-excel.first_row)

  end

  def process_row(excel,start_row ,end_row,headers,mapping)
    begin
      
      for row in start_row...end_row
        next if row > excel.last_row
        company = contact = nil
        @mutex.synchronize {
          contact = Contact.new
          company = Company.new
        }
        tags = []
        for col in headers    
          db_col =  (mapping[col.downcase]||col).downcase
          next if ApplicationConfiguration.settings[:file_upload][:not_supported_columns].split.include?(db_col.to_s)

          if contact.respond_to?(db_col.to_sym) && db_col != "tags"

            contact.send((db_col+"=").to_sym, excel.cell(row,headers.index(col)+1))

          elsif db_col=="full_name"
              
            name = (excel.cell(row,headers.index(col)+1)||"").split
            contact.first_name = name.first
            contact.last_name = name.last

          elsif company.respond_to?(db_col.to_sym)

            company.send((db_col+"=").to_sym, excel.cell(row,headers.index(col)+1))

          elsif db_col =~/company_/

            if company.respond_to?(db_col.sub('company_','').to_sym)
              company.send((db_col.sub('company_','')+"=").to_sym, excel.cell(row,headers.index(col)+1))
            end

          elsif db_col == "tags"

            tags = excel.cell(row,headers.index(col)+1).split(",").select{|tg| tg unless tg.blank?}

          end
        end

        @mutex.synchronize{
          company = company.valid? ? company.save : Company.find_by_name(company.name)
          contact.company_id  = company.id
          
          # if contact name us empty
          if contact.first_name.blank? && contact.last_name.blank?
            name = contact.email.split("@").first.split(".")
            contact.first_name = name.first
            contact.last_name = name.last
          end
          
          if contact.valid?
            contact.save
          else
            attributes = contact.attributes
            if contact = Contact.find_by_email(contact.email)
              contact.update_attributes(attributes)
            end
          end

          unless contact.new_record?
            for tg in tags
              ContactsTag.create({:tag_id=>Tag.find_or_create_by_name(tg).id,:contact_id=>contact.id})
            end
            @processed_items += 1
          end
        }
          
      end
      
    rescue=>e
      RAILS_DEFAULT_LOGGER.info e
      RAILS_DEFAULT_LOGGER.info e.backtrace
      RAILS_DEFAULT_LOGGER.flush
    end
    return
  end

  def send_admin_notification(succedded,total)
    RAILS_DEFAULT_LOGGER.info "#{succedded} Inserted from total #{total}"
    RAILS_DEFAULT_LOGGER.flush
    Notifier.deliver_upload_status(succedded,total)
  end

end
