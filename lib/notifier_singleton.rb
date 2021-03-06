require 'thread'

class NotifierSingleton
  
  def self.process_notifications
    job_queue = NotifyQueue.new
    jobs = job_queue.dequeue(1)
    
    jobs.each do |job|
      encoding = job[:video]
      begin
        if encoding.time_to_send_notification?
          encoding.send_notification
        end
      rescue Exception => e
        Merb.logger.error "ERROR (#{$!.to_s}) sending notification for #{encoding.key}. Waiting #{encoding.notification_wait_period}s before trying again."
      ensure
        Video.delete_notification_job(job[:receipt])
      end
    end
  end
  
end