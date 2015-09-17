module Ghkv
  class CLI < Clamp::Command
    option '--repo', 'REPO', 'Qualified (user/repo) repo name'
    option '--token', 'TOKEN', 'GitHub API token', environment_variable: 'GHKV_TOKEN'
    option '--api', 'API', 'Base URL for enterprise GitHub', environment_variable: 'GHKV_API_URL'

    subcommand 'get', 'Get value from KV and print to stdout' do
      parameter 'KEY', 'key'

      def execute
        puts ghkv[key].to_json
      end
    end

    subcommand 'set', 'Pass in value to store in KV by parameter or from stdin' do
      parameter 'KEY', 'key'
      parameter '[VALUE]', 'value'

      def execute
        ghkv[key] = JSON.parse input
        ghkv.save
      end

      def input
        value || $stdin.read
      end
    end

    subcommand 'list', 'List all keys in KV, one per line' do
      def execute
        puts ghkv.keys
      end
    end

    subcommand 'delete', 'Delete key from KV' do
      parameter 'KEY', 'key'

      def execute
        ghkv.delete key
        ghkv.save
      end
    end

    def ghkv
      @ghkv ||= Ghkv.new repo: repo, api_url: api, token: token
    end
  end
end
