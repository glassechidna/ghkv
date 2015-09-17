module Ghkv
  class Ghkv
    attr_accessor :http, :cache, :dirty, :deleted, :namespace

    def initialize(repo:, api_url: nil, token: ENV['GHKV_TOKEN'])
      api_url ||= ENV['GHKV_API_URL'] || 'https://api.github.com/'
      @http = HttpClient.new base: "#{api_url}/repos/#{repo}/", token: token

      @cache = {}
      @dirty = Set.new
      @deleted = Set.new
      @namespace = 'ghkv'
    end

    def [](key)
      cache[key] ||= get key
    end

    def []=(key, value)
      dirty << key
      deleted.delete key

      cache[key] = value
    end

    def delete(key)
      deleted << key
      cache.delete key
    end

    def keys
      prefix_len = "refs/#{namespace}/".length

      url = refs_url namespace
      resp = http.request :get, url

      saved_keys = resp.map { |ref| ref['ref'][prefix_len..-1] }
      (saved_keys + cache.keys).uniq - deleted.to_a
    end

    def save
      deleted.each do |key|
        delete_ref key
      end

      dirty.each do |key|
        set key, cache[key]
      end

      true
    end

    private

    def get(key)
      url = refs_url("#{namespace}/#{key}")
      resp = http.request(:get, url)
      object = resp['object']
      return nil if object.nil?

      blob = http.request :get, object['url']
      decoded = Base64.decode64 blob['content']
      Marshal.load decoded
    end

    def set(key, value)
      sha = post_blob value

      if get(key).nil?
        create_ref sha, key
      else
        update_ref sha, key
      end
    end

    def delete_ref(key)
      http.request :delete, refs_url("#{namespace}/#{key}")
    end

    def create_ref(sha, key)
      http.request(
        :post,
        refs_url,
        ref: "refs/#{namespace}/#{key}",
        sha: sha
      )
    end

    def update_ref(sha, key)
      http.request(
        :patch,
        refs_url("#{namespace}/#{key}"),
        force: true,
        sha: sha
      )
    end

    def post_blob(value)
      encoded = Base64.encode64 Marshal.dump value
      payload = { encoding: 'base64', content: encoded }
      blob = http.request :post, 'git/blobs', payload
      blob['sha']
    end

    def refs_url(key=nil)
      "git/refs/#{key}".chomp('/')
    end
  end
end

