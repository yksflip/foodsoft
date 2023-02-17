$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "foodsoft_bnn_upload/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "foodsoft_bnn_upload"
  s.version     = FoodsoftBnnUpload::VERSION
  s.authors     = ["fgu, viehlieb"]
  s.email       = ["foodsoft@local-it.org"]
  s.summary     = "Manually choose file to send to supplier. BNN file for NaturkostNord supported."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["Rakefile", "README.md"]

  s.add_dependency "rails"
  s.add_dependency "deface", "~> 1.0"
end
