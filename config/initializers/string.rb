require 'UniversalDetector'
require 'iconv'
class String

  def to_utf_eight
    
    begin

      encoding= UniversalDetector::chardet(self.to_s)["encoding"]
      Iconv.conv("#{encoding.upcase}//IGNORE", 'UTF-8', self.to_s + ' ')[0..-2]
      
    rescue
      self
    end
    
  end

end