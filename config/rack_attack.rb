safelist_ips = ENV.fetch('SAFELIST_IPS', '')
safelist_ips.split(',').each do |safelist_ip|
    white_ip = "#{safelist_ip}".strip
    Rack::Attack.safelist_ip(white_ip)
end if safelist_ips.present?
