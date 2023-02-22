module FoodsoftBnnUpload
  class OrderBnn < RenderCsv
    def initialize(object, options = {})
      super
      @options[:col_sep] = ""
      @options[:row_sep] = "\n"
      @options[:encoding] = 'IBM850'
    end

    def header
      customer_id = "000001"
      delivery_date = Time.zone.now.strftime("%y%m%d")
      pickup = " "

      ["D##{customer_id}#{delivery_date}#{pickup}#{@object.id}"]
    end

    def data
      @object.order_articles.ordered.includes([:article, :article_price]).all.map do |oa|
        yield [
          pad_to_length(oa.article.order_number, 13),
          "+",
          pad_float_values(oa.units_to_order),
          pad_to_length(oa.article.name, 30),
          pad_float_values(oa.article.unit_quantity),
          pad_to_length(oa.article.unit, 14),
          pad_to_length(oa.article.manufacturer, 3),
          pad_to_length("", 26)
        ]
      end
    end

    def pad_float_values(number, digits_before=4, digits_after=3)
      format_string = "%0#{digits_before + digits_after}d"
      formatted_number = sprintf(format_string, (number * 10 ** digits_after).to_i)
    end

    def pad_to_length(string, length)
      string.to_s.rjust(length, " ")[0, length]
    end
  end
end