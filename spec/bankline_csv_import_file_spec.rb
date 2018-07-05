require "bankline_csv_import_file"

describe BanklineCsvImportFile do
  it "can generate a file with domestic payments" do
    file = BanklineCsvImportFile.new

    file.add_domestic_payment(
      payer_sort_code: "151000",
      payer_account_number: "31806542",
      amount: "166.42",
      beneficiary_sort_code: "151000",
      beneficiary_account_number: "44298801",
      beneficiary_name: "Mr John Smith",
      beneficiary_reference: "Invoice 1234",
      payment_date: Date.new(2006, 10, 1),
    )

    output = file.generate

    # Taken from https://www.business.rbs.co.uk/content/dam/rbs_co_uk/Business_and_Content/PDFs/Bankline/Bankline-import-file-guide-CSV-RBS.pdf (section 4.2, page 46)
    # Except that their example has 80 fields instead of 85, which we assume to be a mistake.
    expect(output).to eq ",,,01,,,,,,,,,15100031806542,,,,166.42,,01102006,,,,,,151000,,,,,,44298801,,MR JOHN SMITH,,,,INVOICE 1234,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,\n"
  end

  it "can include multiple payments" do
    file = BanklineCsvImportFile.new

    file.add_domestic_payment(
      **domestic_payment_arguments,
      beneficiary_reference: "Invoice 123",
    )

    file.add_domestic_payment(
      **domestic_payment_arguments,
      beneficiary_reference: "Invoice 666",
    )

    output = file.generate

    expect(output).to include "INVOICE 123"
    expect(output).to include "INVOICE 666"
  end

  it "uses only allowed characters and limits fields to their max length" do
    file = BanklineCsvImportFile.new

    file.add_domestic_payment(
      **domestic_payment_arguments,
      beneficiary_reference: "Max !!!!!18.-/&!!!!!åäöhi ho foo bar",
    )

    output = file.generate

    expect(output).to include ",MAX 18.-/&HI HO FO,"
  end

  it "normalizes account numbers" do
    file = BanklineCsvImportFile.new

    file.add_domestic_payment(
      **domestic_payment_arguments,
      payer_sort_code: "15-10-01",
      payer_account_number: "123 456 789",
      beneficiary_sort_code: "15-10-02",
      beneficiary_account_number: "123 456 780",
    )

    output = file.generate

    expect(output).to include ",151001123456789,"
    expect(output).to include ",151002,"
    expect(output).to include ",123456780,"
  end

  it "defaults payment_date to Date.current if that method exists (e.g. with Ruby on Rails)" do
    # Can't use `allow(Date)` since RSpec won't allow us to stub a method that doesn't exist.
    stub_const "Date", double(current: Date.new(1983, 10, 15))

    file = BanklineCsvImportFile.new

    file.add_domestic_payment(**domestic_payment_arguments)

    output = file.generate

    expect(output).to include ",15101983,"
  end

  it "defaults payment_date to Date.today when Date.current is not available" do
    allow(Date).to receive(:today).and_return(Date.new(1983, 7, 26))

    file = BanklineCsvImportFile.new

    file.add_domestic_payment(**domestic_payment_arguments)

    output = file.generate

    expect(output).to include ",26071983,"
  end

  private

  def domestic_payment_arguments
    {
      payer_sort_code: "151000",
      payer_account_number: "31806542",
      amount: "123.45",
      beneficiary_sort_code: "151001",
      beneficiary_account_number: "44298801",
      beneficiary_name: "John Doe",
      beneficiary_reference: "Invoice 123",
    }
  end
end
