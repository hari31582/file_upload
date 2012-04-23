
module Threading
  class ThreadPoolContainer
    @@threadpool = ThreadPool.new(ApplicationConfiguration.settings[:threads][:size])
    def self.get_threaddpool
      @@threadpool  
    end

  end
end
