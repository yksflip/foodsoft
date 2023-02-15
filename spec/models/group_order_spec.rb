require_relative '../spec_helper'

describe GroupOrder do
  let(:ordergroup) { create(:ordergroup) }
  let(:user)       { create :user, groups: [ordergroup] }
  let(:supplier)   { create(:supplier, article_count: 3) }
  let(:order)      { create :order, supplier: supplier }

  # the following two tests are currently disabled - https://github.com/foodcoops/foodsoft/issues/158

  # it 'needs an order' do
  #   expect(FactoryBot.build(:group_order, ordergroup: user.ordergroup)).to be_invalid
  # end

  # it 'needs an ordergroup' do
  #   expect(FactoryBot.build(:group_order, order: order)).to be_invalid
  # end

  describe do
    let(:go) { create :group_order, order: order, ordergroup: ordergroup }

    it 'has zero price initially' do
      expect(go.price).to eq(0)
    end
  end

  describe "load data for javascript" do
    let(:group_order)            { create :group_order, order: order, ordergroup: ordergroup }
    let!(:article)               { order.articles.first }
    let(:order_article)          { OrderArticle.find_or_create_by!(order: order, article: article) }
    let(:previous_order)         { create :order, supplier: supplier, starts: 20.days.ago, ends: 18.days.ago }
    let(:previous_group_order)   { create :group_order, order: previous_order, ordergroup: ordergroup }
    let(:previous_order_article) { OrderArticle.find_or_create_by!(order: previous_order, article: article) }

    it "includes data from the last order" do
      create :group_order_article,
              order_article: previous_order_article,
              group_order: previous_group_order,
              quantity: 23,
              tolerance: 11

      order.order_articles.map(&:update_results!)
      order.group_orders.map(&:update_price!)

      order_article_data = group_order.load_data[:order_articles][order_article.id]

      expect(order_article_data[:previous_quantity]).to eq(23)
      expect(order_article_data[:previous_tolerance]).to eq(11)

    end
  end
end
