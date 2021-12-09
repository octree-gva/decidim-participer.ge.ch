safelist_ips = ENV.fetch('SAFELIST_IPS', '')
if safelist_ips.present?
    safelist_ips.split(',').each do |safelist_ip|
        white_ip = "#{safelist_ip}".strip
        Rack::Attack.safelist_ip(white_ip)
    end 
end

Rack::Attack.blocklist("block all access to system") do |request|
    # Requests are blocked if the return value is truthy
    if request.path.start_with?("/system")
        !(Decidim.system_accesslist_ips.any? && 
            Decidim.system_accesslist_ips.map { |ip_address| IPAddr.new(ip_address).include?(IPAddr.new(request.ip)) }.any?)
    end
end

Rack::Attack.blocklist('fail2ban pentesters') do |req|
  # `filter` returns truthy value if request fails, or if it's from a previously banned IP
  # so the request is blocked
  Rack::Attack::Fail2Ban.filter("pentesters-#{req.ip}", maxretry: 3, findtime: 10.minutes, bantime: 50.minutes) do
    # The count for the IP is incremented if the return value is truthy
    CGI.unescape(req.query_string) =~ %r{/etc/passwd} ||
    req.path.include?('/etc/passwd') ||
    req.path.include?('wp-admin') ||
    req.path.include?('wp-login')
  end
end
