require "bankline_csv_import_file"

describe BanklineCsvImportFile do
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

    file.add_international_payment(
      **international_payment_arguments,
      beneficiary_reference: "Invoice 999",
    )

    output = file.generate

    expect(output).to include "INVOICE 123"
    expect(output).to include "INVOICE 666"
    expect(output).to include "Invoice 999"
  end
end
