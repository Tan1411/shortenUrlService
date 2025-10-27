class Rack::Attack
  cache.store = ActiveSupport::Cache::MemoryStore.new

  throttle('req/ip', limit: 200, period: 5.minutes) do |req|
    req.ip
  end

  blocklist('block_bad_ips') do |req|
    Rack::Attack::Allow2Ban.filter(req.ip, maxretry: 1000, findtime: 30.minutes, bantime: 12.hours) do
      req.ip
    end
  end

  self.throttled_responder = lambda do |request|
    retry_after = request.env['rack.attack.match_data'][:period]
    [
      429,
      {
        'Content-Type' => 'application/json',
        'X-RateLimit-Limit' => request.env['rack.attack.match_data'][:limit],
        'X-RateLimit-Remaining' => 0,
        'X-RateLimit-Reset' => (Time.now + retry_after).to_i,
        'Retry-After' => retry_after
      },
      [{
        error: 'Rate limit exceeded',
        message: 'Too many requests. Please try again later.',
        retry_after: retry_after
      }.to_json]
    ]
  end

  self.blocklisted_responder = lambda do |request|
    [
      403,
      {'Content-Type' => 'application/json'},
      [{ error: 'Forbidden', message: 'Your IP has been blocked' }.to_json]
    ]
  end
end

ActiveSupport::Notifications.subscribe('throttle.rack_attack') do |name, start, finish, request_id, payload|
  req = payload[:request]
  Rails.logger.warn "[RATE LIMIT] IP: #{req.ip}, Path: #{req.path}"
end

ActiveSupport::Notifications.subscribe('blocklist.rack_attack') do |name, start, finish, request_id, payload|
  req = payload[:request]
  Rails.logger.error "[BLOCKED] IP: #{req.ip}, Path: #{req.path}"
end

# disable in test environment
if Rails.env.test?
  Rack::Attack.enabled = false
end
