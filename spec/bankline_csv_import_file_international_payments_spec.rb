require "bankline_csv_import_file"

describe BanklineCsvImportFile, "international payments" do
  it "has the correct format" do
    file = BanklineCsvImportFile.new

    file.add_international_payment(
      payer_sort_code: "151000",
      payer_account_number: "31806542",
      amount: "1266.42",
      beneficiary_bic: "SPKHDE2HXXX",
      beneficiary_iban: "DE53250501800039370089",
      beneficiary_name: "MR JOHN SMITH",
      beneficiary_address: "BEN ADDR 1\nBEN ADDR 2\nBEN ADDR 3",
      beneficiary_reference: "INFO FOR BEN 1\nINFO FOR BEN 2\nINFO FOR BEN 3\nINFO FOR BEN 4",
      payment_date: Date.new(2006, 10, 1),
    )

    output = file.generate

    # Taken from https://www.business.rbs.co.uk/content/dam/rbs_co_uk/Business_and_Content/PDFs/Bankline/Bankline-import-file-guide-CSV-RBS.pdf (section 4.6, page 54) and modified a bit.
    expect(output).to eq ",,,04,,,,,,DE,N,,15100031806542,,,GBP,1266.42,01102006,,,,,,,SPKHDE2HXXX,,,,,,DE53250501800039370089,,MR JOHN SMITH,BEN ADDR 1,BEN ADDR 2,BEN ADDR 3,,,,INFO FOR BEN 1,INFO FOR BEN 2,INFO FOR BEN 3,INFO FOR BEN 4,,GBP,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,\n"
  end

  it "uses only allowed characters, skips blank lines, and limits fields to their max length" do
    file = BanklineCsvImportFile.new

    file.add_international_payment(
      **international_payment_arguments,
      beneficiary_reference: "Row 1\n\nRow 2\nRow 3\nRow 4!!! - 123456789x123456789x123456789x\nRow 5"
    )

    output = file.generate

    expect(output).to include ",Row 1,Row 2,Row 3,Row 4 - 123456789x123456789x1234567,,"
  end

  it "rounds the amount to two decimals" do
    file = BanklineCsvImportFile.new

    file.add_international_payment(
      **international_payment_arguments,
      amount: "12.349",
    )

    output = file.generate

    expect(output).to include ",12.35,"
  end

  it "normalizes the payer sort code and account number" do
    file = BanklineCsvImportFile.new

    file.add_international_payment(
      **international_payment_arguments,
      payer_sort_code: "15-10-01",
      payer_account_number: "123 456 789",
    )

    output = file.generate

    expect(output).to include ",151001123456789,"
  end

  it "normalizes the IBAN" do
    file = BanklineCsvImportFile.new

    file.add_international_payment(
      **international_payment_arguments,
      beneficiary_iban: "de 532505018000393700-89",
    )

    output = file.generate

    expect(output).to include ",DE53250501800039370089,"
  end

  it "normalizes the BIC" do
    file = BanklineCsvImportFile.new

    file.add_international_payment(
      **international_payment_arguments,
      beneficiary_bic: "spkHDE 2HXXX",
    )

    output = file.generate

    expect(output).to include ",SPKHDE2HXXX,"
  end

  it "fills out the BIC with Xes when needed" do
    file = BanklineCsvImportFile.new

    file.add_international_payment(
      **international_payment_arguments,
      beneficiary_bic: "SPKHDE2H",
    )

    output = file.generate

    expect(output).to include ",SPKHDE2HXXX,"
  end
end
