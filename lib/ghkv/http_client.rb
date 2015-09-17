module Ghkv
  class HttpClient
    attr_accessor :token
    attr_accessor :verbose
    attr_accessor :base

    def initialize(base:, token:)
      @base = URI.parse base
      @token = token
    end

    def http_request(method, uri)
      klass = Net::HTTP.const_get method.capitalize
      klass.new(uri).tap do |r|
        r.basic_auth token, 'x-oauth-basic'
      end
    end

    def http(uri)
      Net::HTTP.new(uri.host, uri.port).tap do |h|
        h.set_debug_output($stdout) if verbose
        h.use_ssl = uri.port == 443
      end
    end

    def request(method, url, body=nil)
      uri = base + url

      req = http_request method, uri
      req.body = body.to_json if body

      client = http uri
      resp = client.request req
      JSON.parse(resp.body) rescue nil
    end
  end
end
