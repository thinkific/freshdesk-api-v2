# FreshdeskApiV2

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/freshdesk_api_v2`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'freshdesk_api_v2'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install freshdesk_api_v2

## Usage

Currently, the API bindings only expose the following endpoints:

1. [Contacts](https://developers.freshdesk.com/api/#contacts)
2. [Companies](https://developers.freshdesk.com/api/#companies)
3. [Contact Fields](https://developers.freshdesk.com/api/#list_all_contact_fields)
4. [Company Fields](https://developers.freshdesk.com/api/#list_all_company_fields)

Note that while search/filter works for both Companies and Contacts, the API is still not working perfectly.
For example, filtering Contacts by email fails - likely due to encosing issues on Freshdesk's side.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/freshdesk_api_v2. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the FreshdeskApiV2 project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/freshdesk_api_v2/blob/master/CODE_OF_CONDUCT.md).
