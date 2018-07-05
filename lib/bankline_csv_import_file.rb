require "bankline_csv_import_file/version"
require "bankline_csv_import_file/record"

require "bigdecimal"
require "csv"

class BanklineCsvImportFile
  def initialize
    @records = []
  end

  def add_domestic_payment(payer_sort_code:, payer_account_number:, amount:, beneficiary_sort_code:, beneficiary_account_number:, beneficiary_name:, beneficiary_reference:, payment_date: nil)
    payment_date ||= today
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
    record["T030"] = domestic_normalize_string(beneficiary_name, max_length: 35)
    record["T034"] = domestic_normalize_string(beneficiary_reference, max_length: 18)

    @records << record
  end

  def add_international_payment(payer_sort_code:, payer_account_number:, amount:, beneficiary_bic:, beneficiary_iban:, beneficiary_name:, beneficiary_address: nil, beneficiary_reference:, payment_date: nil)
    # Use Ruby on Rails' `Date.current` when available, since it will be in the app time zone rather than the server time zone.
    payment_date ||= today
    formatted_payment_date = payment_date.strftime("%d%m%Y")

    payer_account_with_sort_code = normalize_account("#{payer_sort_code}#{payer_account_number}")

    normalized_iban = normalize_iban(beneficiary_iban)
    normalized_bic = normalize_bic(beneficiary_bic)

    beneficiary_country = normalized_iban[0, 2]

    beneficiary_address_line_1, beneficiary_address_line_2, beneficiary_address_line_3 =
      international_normalize_multiline_string(beneficiary_address, max_lines: 3, max_length_per_line: 35)

    beneficiary_reference_line_1, beneficiary_reference_line_2, beneficiary_reference_line_3, beneficiary_reference_line_4 =
      international_normalize_multiline_string(beneficiary_reference, max_lines: 4, max_length_per_line: 35)

    record = Record.new

    # https://www.business.rbs.co.uk/content/dam/rbs_co_uk/Business_and_Content/PDFs/Bankline/Bankline-import-file-guide-CSV-RBS.pdf
    # Section 4.6, page 54.
    record["T001"] = "04"  # 04 = International payment.
    record["T007"] = beneficiary_country
    record["T008"] = "N"  # Normal priority.
    record["T010"] = payer_account_with_sort_code
    record["T013"] = "GBP"  # Payment currency. (Presumably the target currency.)
    record["T014"] = sprintf("%.2f", BigDecimal(amount))
    record["T015"] = formatted_payment_date
    record["T022"] = normalized_bic
    record["T028"] = normalized_iban
    record["T030"] = international_normalize_string(beneficiary_name, max_length: 35)

    record["T031"] = beneficiary_address_line_1 if beneficiary_address_line_1
    record["T032"] = beneficiary_address_line_2 if beneficiary_address_line_2
    record["T033"] = beneficiary_address_line_3 if beneficiary_address_line_3

    record["T037"] = beneficiary_reference_line_1 if beneficiary_reference_line_1
    record["T038"] = beneficiary_reference_line_2 if beneficiary_reference_line_2
    record["T039"] = beneficiary_reference_line_3 if beneficiary_reference_line_3
    record["T040"] = beneficiary_reference_line_4 if beneficiary_reference_line_4

    record["T042"] = "GBP"  # Credit currency. (Presumably the source currency.)

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

  def today
    # Use Ruby on Rails' `Date.current` when available, since it will be in the app time zone rather than the server time zone.
    Date.respond_to?(:current) ? Date.current : Date.today
  end

  def normalize_bic(bic)
    normalized_bic = bic.to_s.upcase.gsub(/[^A-Z\d]/, "")

    # https://www.business.rbs.co.uk/content/dam/rbs_co_uk/Business_and_Content/PDFs/Bankline/Bankline-import-file-guide-CSV-RBS.pdf section 2.5, page 6:
    # "For any 8 character BIC, please append this with XXX i.e., for ULSBIE2D populate as ULSBIE2DXXX."
    normalized_bic << "XXX" if normalized_bic.length == 8

    normalized_bic
  end

  def normalize_iban(iban)
    iban.to_s.upcase.gsub(/[^A-Z\d]/, "")
  end

  def normalize_account(string)
    string.upcase.gsub(/\D/, "")
  end

  def domestic_normalize_string(string, max_length:)
    output = string.to_s.upcase
    output = output.gsub(%r{[^A-Z0-9./& -]}, "")
    output[0, max_length]
  end

  def international_normalize_multiline_string(string, max_lines:, max_length_per_line:)
    string.to_s.split("\n").reject(&:empty?)[0, max_lines].map { |line|
      international_normalize_string(line, max_length: max_length_per_line)
    }
  end

  def international_normalize_string(string, max_length:)
    output = string.to_s
    output = output.gsub(%r{[^a-zA-Z0-9./?:(),+' -]}, "")
    output[0, max_length]
  end
end
