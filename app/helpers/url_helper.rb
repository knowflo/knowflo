module UrlHelper
  def with_subdomain(subdomain)
    return request.host if request.domain == 'localhost'

    subdomain = (subdomain || '')
    subdomain = subdomain.url if subdomain.respond_to?(:url)
    subdomain += "." unless subdomain.blank?
    [subdomain, request.domain, request.port_string].join
  end

  def url_for(options = nil)
    if options.kind_of?(Hash) && options.has_key?(:subdomain)
      options[:host] = with_subdomain(options.delete(:subdomain))
    end

    super
  end

  def group_root_url(group)
    if request.domain == 'localhost'
      group_url(group)
    else
      root_url(:subdomain => group.url)
    end
  end
end
