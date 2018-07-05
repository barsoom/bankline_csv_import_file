require "bankline_csv_import_file/version"
require "bankline_csv_import_file/record"

require "bigdecimal"
require "csv"

class BanklineCsvImportFile
  def initialize
    @records = []
  end

  def add_domestic_payment(payer_sort_code:, payer_account_number:, amount:, beneficiary_sort_code:, beneficiary_account_number:, beneficiary_name:, beneficiary_reference:, payment_date: nil)
    # Use Ruby on Rails' `Date.current` when available, since it will be in the app time zone rather than the server time zone.
    payment_date ||= Date.respond_to?(:current) ? Date.current : Date.today
    formatted_payment_date = payment_date.strftime("%d%m%Y")

    payer_account_with_sort_code = normalize_account("#{payer_sort_code}#{payer_account_number}")

    record = Record.new

    # https://www.business.rbs.co.uk/content/dam/rbs_co_uk/Business_and_Content/PDFs/Bankline/Bankline-import-file-guide-CSV-RBS.pdf
    # Section 4.2, page 46.
    record["T001"] = "01"  # 01 = Standard domestic payment.
    record["T010"] = payer_account_with_sort_code
    record["T014"] = sprintf("%.2f", BigDecimal(amount))
    record["T016"] = formatted_payment_date
    record["T022"] = normalize_account(beneficiary_sort_code)
    record["T028"] = normalize_account(beneficiary_account_number)
    record["T030"] = normalize_string(beneficiary_name, max_length: 35)
    record["T034"] = normalize_string(beneficiary_reference, max_length: 18)

    @records << record
  end

  def generate
    CSV.generate do |csv|
      @records.each do |record|
        csv << record.to_csv
      end
    end
  end

  private

  def normalize_account(string)
    string.gsub(/\D/, "")
  end

  def normalize_string(string, max_length:)
    output = string.to_s.upcase
    output = output.gsub(%r{[^A-Z0-9./& -]}, "")
    output[0, max_length]
  end
end
