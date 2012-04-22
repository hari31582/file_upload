class Notifier < ActionMailer::Base
  
  def upload_status(items,total)
    subject    'Contacts uploaded successfully'
    recipients 'admin@localhost'
    from       'admin@localhost'
    sent_on    Time.now
    body       :stats => "Total #{total} rows processed , #{total-items} had an error. #{items} rows inserted"
  end

end
