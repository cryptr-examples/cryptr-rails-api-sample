# Cryptr with Rails API

## 02 - Add your Cryptr credentials

🛠️️ Add your Cryptr environment variables that you obtained previously (you can retrieve them in your Cryptr application) to your application in `config/application.rb`. Don't forget to replace `YOUR_DOMAIN` with your own domain:

```ruby
module CryptrRailsApiSample
 class Application < Rails::Application
   # Initialize configuration defaults for originally generated Rails version.
   config.load_defaults 6.1
 
   # Add your Cryptr config:
   config.before_configuration do
     ENV['CRYPTR_BASE_URL'] = 'https://auth.cryptr.eu'
     ENV['TENANT_DOMAIN'] = 'YOUR_DOMAIN'
     ENV['CRYPTR_AUDIENCE'] = 'http://localhost:8081'
   end
   # Configuration for the application, engines, and railties goes here.
   #
   # These settings can be overridden in specific environments using the files
   # in config/environments, which are processed later.
   #
   # config.time_zone = "Central Time (US & Canada)"
   # config.eager_load_paths << Rails.root.join("extras")
 
   # Only loads a smaller set of middleware suitable for API only apps.
   # Middleware like session, flash, cookies can be added back manually.
   # Skip views, helpers and assets when generating a new resource.
   config.api_only = true
 end
end
```

Note: __If you are from the EU, you must add `https://auth.cryptr.eu/` in the `CRYPTR_BASE_URL` variable, and if you are from the US, you must add `https://auth.cryptr.us/` in the same variable.__

Tip 💡: __This part can be done differently depending on the developer’s preference, the goal here is to have access to Cryptr configuration from `ENV`__

[Next](https://github.com/cryptr-examples/cryptr-rails-api-sample/tree/03-validate-access-tokens)
