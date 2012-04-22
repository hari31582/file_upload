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
  end

  private

  def read_file
    begin
      excel = Roo::Spreadsheet.custom_open(@filename , "#{RAILS_ROOT}/tmp/#{@filename}",nil,:ignore)
      excel.default_sheet = excel.sheets.first
      headers = []
      for cell_num in excel.first_column..excel.last_column
        headers << excel.cell(excel.first_row,cell_num)
      end
      mapping =  @column_mapping.invert

      
      processed_items = 0
      for row in excel.first_row+1..excel.last_row
        contact = Contact.new
        company = Company.new
        tags = []
        for col in headers

          db_col =  mapping[col]||col
        
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
            for tg in excel.cell(row,headers.index(col)+1)
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
        if contact.save
          processed_items += 1
          for tg in tags
            if tg.new_record?
              tg.save
              ContactsTag.create({:tag_id=>tg.id})
            end
          end

        end

      end
      send_admin_notification(processed_items,excel.last_row-excel.first_row)
    rescue=>e
      puts e
      puts e.backtrace
    end
    
  end


  def send_admin_notification(succedded,total)
     puts "Items uploaded successfully"
     puts  succedded
     puts "Size:"
     puts total
  end

end
