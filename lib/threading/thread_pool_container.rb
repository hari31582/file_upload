# To change this template, choose Tools | Templates
# and open the template in the editor.
module Threading
  class ThreadPoolContainer
    @@threadpool = ThreadPool.new(5)
    def self.get_threaddpool
      @@threadpool  
    end

  end
end
