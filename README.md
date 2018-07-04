# Bankline CSV import file

Generate Bankline CSV import files per <https://www.business.rbs.co.uk/content/dam/rbs_co_uk/Business_and_Content/PDFs/Bankline/Bankline-import-file-guide-CSV-RBS.pdf>, used e.g. by NatWest.

Not intended to be a complete implementation. We have implemented what we need; feel free to make PRs for further behaviour.

USER BEWARE: At the time of writing, we have not yet verified that the produced file works.


## Usage

### Standard domestic payment

All these fields are required unless stated.

Currency will be assumed to be GBP.

    file = BanklineCsvImportFile.new
    file.add_domestic_payment(
      payer_sort_code: "151000",               # Any non-digits will be stripped automatically.
      payer_account_number: "31806542",        # Any non-digits will be stripped automatically.
      amount: "123.45",                        # Strings and BigDecimal are allowed. (Floats are not advisable for money.)
      beneficiary_sort_code: "151000",         # Any non-digits will be stripped automatically.
      beneficiary_account_number: "44298801",  # Any non-digits will be stripped automatically.
      beneficiary_name: "John Doe",
      beneficiary_reference: "Invoice 123",
      payment_date: Date.new(2018, 1, 1),      # Optional. Defaults to Date.current if available, otherwise Date.today.
    )
    file.generate  # => "foo,bar,…"

### Payment templates, CHAPS, international payments

Not currently supported. Pull requests welcome!


## Installation

Add this line to your application's Gemfile:

```ruby
gem "bankline_csv_import_file"
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install bankline_csv_import_file


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bundle exec rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
