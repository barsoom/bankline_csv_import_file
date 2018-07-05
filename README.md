# Bankline CSV import file

Generate Bankline CSV import files per <https://www.business.rbs.co.uk/content/dam/rbs_co_uk/Business_and_Content/PDFs/Bankline/Bankline-import-file-guide-CSV-RBS.pdf>, used e.g. by NatWest.

Not intended to be a complete implementation. We have implemented what we need; feel free to make PRs for further behaviour.

USER BEWARE: At the time of writing, we have not yet verified that the produced file works.


## Usage

Add any number of payments as described below, then generate the CSV content:

``` ruby
file = BanklineCsvImportFile.new

file.add_domestic_payment(…)
file.add_domestic_payment(…)
file.add_international_payment(…)

file.generate  # => "foo,bar,…"
```

### Domestic payment

All these fields are required unless stated otherwise.

``` ruby
file = BanklineCsvImportFile.new

file.add_domestic_payment(
  payer_sort_code: "151000",
  payer_account_number: "31806542",
  amount: "123.45",                        # Strings and BigDecimal are allowed. (Floats are not advisable for money.) Rounded to 2 decimals.
  beneficiary_sort_code: "151000",
  beneficiary_account_number: "44298801",
  beneficiary_name: "John Doe",            # Truncated to a max length of 35.
  beneficiary_reference: "Invoice 123",    # Truncated to a max length of 18.
  payment_date: Date.new(2018, 1, 1),      # Optional. Defaults to Date.current if available, otherwise Date.today. See note below.
)

file.generate  # => "foo,bar,…"
```

Currency is assumed to be GBP.

Texts are converted to UPPERCASE and characters other than A-Z, 0-9, space and .-/& are automatically removed from free-text fields.

Sort codes and account numbers are automatically normalised to the expected format.

Bankline says this about the payment date:

> Date payment to arrive (credit date)
>
> Identifies the date on which the funds are to be received by the beneficiary bank. Although not guaranteed this will normally be the same date on which the funds will be made available to the beneficiary.


### International payment

All these fields are required unless stated otherwise.

``` ruby
file = BanklineCsvImportFile.new

file.add_international_payment(
  payer_sort_code: "151000",             # Any non-digits will be stripped automatically.
  payer_account_number: "31806542",      # Any non-digits will be stripped automatically.
  amount: "123.45",                      # Strings and BigDecimal are allowed. (Floats are not advisable for money.)
  payment_date: Date.new(2018, 1, 1),    # Optional. Defaults to Date.current if available, otherwise Date.today. See note below.
  beneficiary_bic: "SPKHDE2H",
  beneficiary_iban: "DE53250501800039370089",
  beneficiary_name: "John Doe",

  # Optional but recommended, see below. Truncated to 35 chars per line and max 3 lines.
  beneficiary_address: "10 Foo Street\nBartown, Baz County\nABC 123"

  beneficiary_reference: "Invoice 123",  # Optional. Truncated to 35 chars per line and max 4 lines.
)

file.generate  # => "foo,bar,…"
```

Currency is assumed to be GBP.

Characters other than a-z, A-Z, 0-9, space and .-/?:(),+' are automatically removed from free-text fields.

Sort codes, account numbers, IBAN and BIC are automatically normalised to the expected format.

Bankline says this about the payment date:

> Execution date
>
> Identifies the date on which the payment is to be initiated.

Bankline says this about the beneficiary address:

> We strongly recommend providing a beneficiary address as this is mandatory for certain destination countries and failure to populate this may cause the payment to be delayed or even rejected by the receiving bank.


### Payment templates, CHAPS

Not currently supported. Pull requests welcome! [The documentation](https://www.business.rbs.co.uk/content/dam/rbs_co_uk/Business_and_Content/PDFs/Bankline/Bankline-import-file-guide-CSV-RBS.pdf) is great and this codebase is tiny – you can do it! 💪


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

## Also see

* [Banktools::GB](https://github.com/barsoom/banktools-gb)


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
