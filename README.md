# Ghkv

`ghkv` is a gem (and corresponding CLI tool) to allow for quick and dirty
persistence when you really can't be bothered spining up a Redis instance.

## Gem

```ruby
require 'ghkv'

# token will be read from ENV['GHKV_TOKEN'] if not passed in
kv = Ghkv::Ghkv.new repo: 'glassechidna/sneaky-repo', token: '<some hex>'
kv['key'] = { "some" => "hash" }
kv['key'] # => { "some" => "hash" }
kv.keys # => ["some"]
# kv.delete 'key'
kv.save
```

If your repo is hosted on GitHub enterprise, you can pass in an `api_url`
parameter (e.g. `https://git.example.com/api/v3`) or put it in
`ENV['GHKV_API_URL']`.

## CLI

Tip: Put the following in your `~/.bash_profile` for quicker usage:

```
# ~/.bash_profile
export GHKV_TOKEN=somehexvalue
```

```
$ ghkv
Usage:
    ghkv [OPTIONS] SUBCOMMAND [ARG] ...

Parameters:
    SUBCOMMAND                    subcommand
    [ARG] ...                     subcommand arguments

Subcommands:
    get                           Get value from KV and print to stdout
    set                           Pass in value to store in KV by parameter or from stdin
    list                          List all keys in KV, one per line
    delete                        Delete key from KV

Options:
    --repo REPO                   Qualified (user/repo) repo name
    --token TOKEN                 GitHub API token (default: $GHKV_TOKEN)
    --api API                     Base URL for enterprise GitHub (default: $GHKV_API_URL)
    -h, --help                    print help
```
