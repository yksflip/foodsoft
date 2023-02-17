require "deface"
require 'foodsoft_bnn_upload/engine'

module FoodsoftBnnUpload
  def self.enabled?
    FoodsoftConfig[:use_bnn_upload]
  end
end
