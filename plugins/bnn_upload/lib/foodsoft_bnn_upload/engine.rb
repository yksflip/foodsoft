module FoodsoftBnnUpload
  class Engine < ::Rails::Engine
    def default_foodsoft_config(cfg)
      cfg[:use_bnn_upload] = true
    end
  end
end
