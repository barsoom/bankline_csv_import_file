# coding: utf-8

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "bankline_csv_import_file/version"

Gem::Specification.new do |spec|
  spec.name          = "bankline_csv_import_file"
  spec.version       = BanklineCsvImportFile::VERSION
  spec.authors       = [ "Henrik Nyh" ]
  spec.email         = [ "henrik@nyh.se" ]

  spec.summary       = %q{Generate Bankline CSV import files.}
  spec.homepage      = "https://github.com/barsoom/bankline_csv_import_file"
  spec.license       = "MIT"
  spec.metadata      = { "rubygems_mfa_required" => "true" }

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.require_paths = [ "lib" ]
  spec.add_runtime_dependency "bigdecimal"
end
