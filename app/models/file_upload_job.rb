#This job is created to upload file
require 'fastercsv'
class FileUploadJob
  attr_accessor :filename , :column_mapping
  def initialize(file,mapping)
    @filename = file
    @column_mapping = mapping
  end

  def perform
    if @filename =~/csv/
      read_csv
    elsif @filename =~/xls/
      read_xls
    end
  end

  private

  def read_csv

   
    rows = FasterCSV.parse(File.open("#{RAILS_ROOT}/tmp/#{@filename}").read,{:force_quotes => true, :headers => true,:encoding=>"UTF-8"})
    headers = rows.first.headers
   
    #This part should be handled using multithreading later
    processed_items = 0
    for row in rows
      next if row.header_row?

      mapping =  @column_mapping.invert
     
      #save contacts
      contact = Contact.new
      company = Company.new
      tags = []
      for col in headers
        
        db_col =  mapping[col]
        next unless db_col
        puts "DB COL"
        puts db_col
        if contact.respond_to?(db_col.to_sym) || db_col=="first_name" || db_col=="last_name"

          contact.send((db_col+"=").to_sym, row[headers.index(col)])

        elsif db_col=="first_name" || db_col=="last_name"
          name = contact.name||""

          if name.empty?
            name  = row[headers.index(col)]
          else
            if db_col=="first_name"
              name  = row[headers.index(col)]+" "+name
            else
              name = name + " " +row[headers.index(col)]
            end
          end
          contact.send("name=".to_sym,name)
        elsif company.respond_to?(db_col.to_sym)
          company.send((db_col+"=").to_sym, row[headers.index(col)])
        elsif db_col == "tags"
          for tg in row[headers.index(col)].split(",")
            if tag = Tag.find_by_name(tg)
              tags << tag
            else
              tags << Tag.new(tg)
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
            ContactsTag.create({:tag_id=>tg.id,:company_id=>company.id})
          end
        end

      end

    end
   
    send_admin_notification(processed_items,rows.size)

  end

  def read_xls

  end


  def send_admin_notification(succedded,total)

  end

end
