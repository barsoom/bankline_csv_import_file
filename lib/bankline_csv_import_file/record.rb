class BanklineCsvImportFile
  class Record
    def initialize
      # 85 columns, namely H001..H003 and T001..T082 per https://www.business.rbs.co.uk/content/dam/rbs_co_uk/Business_and_Content/PDFs/Bankline/Bankline-import-file-guide-CSV-RBS.pdf (section 3).
      @array = Array.new(85)
    end

    def []=(key, value)
      case key
      when "H001" then @array[0] = value
      when "H002" then @array[1] = value
      when "H003" then @array[2] = value
      when /\AT(\d\d\d)\z/
        i = $1.to_i
        raise "Out of range!" unless (1..82).cover?(i)
        @array[i + 2] = value
      else
        raise "Unknown field: #{key.inspect}"
      end
    end

    def to_csv
      @array
    end
  end
end
