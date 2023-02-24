class QuantityUnit
  def initialize(quantity, unit)
    @quantity = quantity
    @unit = unit
  end

  def self.parse(number_with_unit)
    # remove whitespace
    number_with_unit = number_with_unit.gsub(/\s+/, '')
    # to lowercase
    number_with_unit = number_with_unit.downcase
    # remove numerical part
    number = number_with_unit.gsub(/[^0-9.,]/, '')
    # remove unit part
    unit = number_with_unit.gsub(/[^a-zA-Z]/, '')
    # convert comma to dot
    number = number.gsub(',', '.')
    # convert to float
    number = number.to_f

    return nil unless unit.in?(%w[g kg l ml])

    QuantityUnit.new(number, unit)
  end

  def scale_price_to_base_unit(price)
    return nil unless price.is_a?(Numeric)

    factor = if @unit == 'kg' || @unit == 'l'
      1
    elsif @unit == 'g' || @unit == 'ml'
      1000
    end

    scaled_price = price / @quantity * factor
    scaled_price.round(2)

    base_unit = if @unit == 'kg' || @unit == 'g'
      'kg'
    elsif @unit == 'l' || @unit == 'ml'
      'L'
    end

    [scaled_price, base_unit]
  end


  def to_s
    "#{@quantity} #{@unit}"
  end

  def quantity
    @quantity
  end

  def unit
    @unit
  end
end