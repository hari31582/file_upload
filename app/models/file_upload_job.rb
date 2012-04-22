#This job is created to upload file

require 'roo'
class FileUploadJob
  attr_accessor :filename , :column_mapping
  def initialize(file,mapping)
    @filename = file
    @column_mapping = mapping
  end

  def perform
    read_file
    return true
  end

  private

  def read_file
    
    excel = Roo::Spreadsheet.custom_open(@filename , "#{RAILS_ROOT}/tmp/#{@filename}",nil,:ignore)
    excel.default_sheet = excel.sheets.first
    headers = []
    for cell_num in excel.first_column..excel.last_column
      headers << excel.cell(excel.first_row,cell_num)
    end
    mapping =  @column_mapping.invert
    row_size = 2
    
    @processed_items=0
    if (excel.last_row - excel.first_row) > 50
    pool = Threading::ThreadPoolContainer.get_threaddpool # up to 10 threads
    actual_row = row = 2 
    while row <= excel.last_row
       
      pool.process {
        
        actual_row +=row_size
        process_row(excel,actual_row-row_size,actual_row,headers,mapping)
        
      }
      row += row_size
    end
    pool.join
    else
      process_row(excel,excel.first_row+1,excel.last_row+1,headers,mapping)
    end
    send_admin_notification(@processed_items,excel.last_row-excel.first_row)
    
    
  end

  def process_row(excel,start_row ,end_row,headers,mapping)
    begin
      
      for row in start_row...end_row
        
        next if row > excel.last_row
        contact=nil
        company=nil
        Mutex.new.synchronize {
         
          contact = Contact.new
          company = Company.new
        }

        tags = []
        for col in headers

          db_col =  mapping[col]||col

          next if ApplicationConfiguration.settings[:file_upload][:not_supported_columns].split.include?(db_col.to_s)
          
          if contact.respond_to?(db_col.to_sym) || db_col=="first_name" || db_col=="last_name"
           
            contact.send((db_col+"=").to_sym, excel.cell(row,headers.index(col)+1))

          elsif db_col=="first_name" || db_col=="last_name"
            name = contact.name||""

            if name.empty?
              name  = excel.cell(row,headers.index(col)+1)
            else
              if db_col=="first_name"
                name  = excel.cell(row,headers.index(col)+1)+" "+name
              else
                name = name + " " +excel.cell(row,headers.index(col)+1)
              end
            end
            contact.send("name=".to_sym,name)
          elsif company.respond_to?(db_col.to_sym)
            company.send((db_col+"=").to_sym, excel.cell(row,headers.index(col)+1))
          elsif db_col =~/company_/
            if company.respond_to?(db_col.sub('company_','').to_sym)
              company.send((db_col.sub('company_','')+"=").to_sym, excel.cell(row,headers.index(col)+1))
            end
          elsif db_col == "tags"
            for tg in excel.cell(row,headers.index(col)+1).split(";")
              if tag = Tag.find_by_name(tg)
                tags << tag
              else
                tags << Tag.new(:name=>tg)
              end
            end

          end


        end
        
        company.save
        contact.company_id  = company.id
        if contact.valid?
          contact.save
        else
          attributes = contact.attributes
          if contact = Contact.find_by_email(contact.email)
            contact.update_attributes(attributes)
          end
        end
        unless contact.new_record?
          @processed_items += 1
          for tg in tags
            if tg.new_record?
              tg.save
              ContactsTag.create({:tag_id=>tg.id})
            end
          end

        end
        
      end
    rescue=>e
      
    end
    
  end

  def send_admin_notification(succedded,total)
    Notifier.deliver_upload_status(succedded,total)
  end

end
