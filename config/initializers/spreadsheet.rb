module Roo
  class Spreadsheet
  
    def self.custom_open(filename,filepath,start,meth)
      case File.extname(filename)
      when '.xls'
        Excel.new(filepath,start,meth)
      when '.xlsx'
        Excelx.new(filepath,start,meth)
      when '.ods'
        Openoffice.new(filepath,start,meth)
      when '.csv'
        Csv.new(filepath,start,meth)
        # when ''
      else
        Google.new(filepath,start,meth)
        # else
        # raise ArgumentError, "Don't know how to open file #{file}"
      end
    end
 
  end
end