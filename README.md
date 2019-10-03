# SpreePrzelewy24Integration

Spree integration with Przelewy24 payment service.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'spree_przelewy24_integration'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install spree_przelewy24_integration

## Usage

In spree admin panel add and then Przelewy24 as a new payment method.
Add your Przelewy24 account info in payment method configuration.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/przekogo/spree_przelewy24_integration. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## Testing

Bundle your dependencies and then create a dummy app for the specs to run against.

When testing your application's integration with this gem you may use it's factories.
Add this line to your spec_helper:

```ruby
require 'spree_przelewy24_integration/factories'
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the SpreePrzelewy24Integration project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/spree_przelewy24_integration/blob/master/CODE_OF_CONDUCT.md).
