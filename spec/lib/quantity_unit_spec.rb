require_relative '../spec_helper'

describe QuantityUnit do
  it "parses a string correctly" do
    qu = QuantityUnit.parse("1.5 k g"); expect([qu.quantity, qu.unit]).to eq([1.5, "kg"])
    qu = QuantityUnit.parse("  1,5 kg"); expect([qu.quantity, qu.unit]).to eq([1.5, "kg"])
    qu = QuantityUnit.parse("1500   g"); expect([qu.quantity, qu.unit]).to eq([1500, "g"])
    qu = QuantityUnit.parse("1.5L   "); expect([qu.quantity, qu.unit]).to eq([1.5, "l"])
    qu = QuantityUnit.parse("2400mL"); expect([qu.quantity, qu.unit]).to eq([2400, "ml"])
  end

  it "scales prices correctly" do
    qu = QuantityUnit.new(1.5, "kg")
    expect(qu.scale_price_to_base_unit(12.34)).to eq([8.23, "kg"])
    qu = QuantityUnit.new(1500, "g")
    expect(qu.scale_price_to_base_unit(12.34)).to eq([8.23, "kg"])
    qu = QuantityUnit.new(1.5, "l")
    expect(qu.scale_price_to_base_unit(12.34)).to eq([8.23, "L"])
    qu = QuantityUnit.new(2400, "ml")
    expect(qu.scale_price_to_base_unit(12.34)).to eq([5.14, "L"])
  end
end