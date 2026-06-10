# KV

[Cloudflare API](https://developers.cloudflare.com/api/resources/kv/) for KV data storage written in Crystal.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     kv:
       github: joseafga/kv
   ```

2. Run `shards install`

## Usage

```crystal
require "kv"

# Credentials
client = KV::Client.new("YOUR_CLOUDFLARE_ACCOUNT_ID", "YOUR_CLOUDFLARE_API_TOKEN")

# Create a namespace
namespace = client.create "My Namespace"

client.get namespace.id do |ns|
  ns.write("foo", "bar") # create a key-value
  ns.keys.each { |key| puts key.name } # list all the keys
end
```

### Error handling

```crystal
begin
  namespace.read "bad-key"
rescue ex : KV::ResponseError
  puts ex.message # => "Error 10009: get: 'key not found'."
  namespace.write("bad-key", "default value")
end
```

See `spec/kv_spec.cr` for more examples.

## Contributing

1. Fork it (<https://github.com/joseafga/kv/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [José Almeida](https://github.com/joseafga) - creator and maintainer
