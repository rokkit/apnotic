require 'apnotic/abstract_notification'

module Apnotic

  class Notification < AbstractNotification
    attr_accessor :alert, :badge, :sound, :content_available, :category, :custom_payload, :url_args, :mutable_content, :thread_id
    attr_accessor :target_content_id, :interruption_level, :relevance_score
    
    def background_notification?
      aps[:aps].count == 1 && aps[:aps].key?('content-available') && aps[:aps]['content-available'] == 1
    end

    private

    def aps
      r = {}
      r = r.merge(custom_payload) if custom_payload
      r[:aps] ||= {}
      r[:aps].tap do |result|
        result[:alert] = alert if alert
        result[:badge] = badge if badge
        result[:sound] = sound if sound
        result[:category] = category if category
        result['content-available'] = content_available if content_available
        result['url-args'] = url_args if url_args
        result['mutable-content'] = mutable_content if mutable_content
        result.merge!('thread-id' => thread_id) if thread_id
        result.merge!('target-content-id' => target_content_id) if target_content_id
        result.merge!('interruption-level' => interruption_level) if interruption_level
        result.merge!('relevance-score' => relevance_score) if relevance_score
      end
      r
    end

    def to_hash
      aps
    end
  end
end
