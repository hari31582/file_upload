# This class holds application level configurations. It will not reload in production mode

require 'fileutils'
class ApplicationConfiguration


  @@settings = nil

  def initialize(settings_data)
    require 'yaml'
    @@settings = YAML.load(File.read(settings_data))
  rescue
    @@settings = nil
  end

  def self.settings
    return @@settings
  end

  def self.settings=(settings)
    @@settings = settings
  end


end

 ApplicationConfiguration.new("#{RAILS_ROOT}/config/application.yml")
 