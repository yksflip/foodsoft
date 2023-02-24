require_relative 'seed_helper.rb'

FinancialTransactionClass.create!(:id => 1, :name => 'Standard')
FinancialTransactionClass.create!(:id => 2, :name => 'Foodsoft')
FinancialTransactionType.create!(:id => 1, :name => "Foodcoop", :financial_transaction_class_id => 1)

alice = User.create!(:id => 1, :nick => "alice", :password => "secret", :first_name => "Alice", :last_name => "Administrator", :email => "admin@foo.test", :phone => "+4421486548", :created_on => 'Wed, 15 Jan 2014 16:15:33 UTC +00:00')
bob = User.create!(:id => 2, :nick => "bob", :password => "secret", :first_name => "Bob", :last_name => "Doe", :email => "bob@doe.test", :created_on => 'Sun, 19 Jan 2014 17:38:22 UTC +00:00')


Workgroup.create!(:id => 1, :name => "Administrators", :description => "System administrators.", :account_balance => 0.0, :created_on => 'Wed, 15 Jan 2014 16:15:33 UTC +00:00', :role_admin => true, :role_suppliers => true, :role_article_meta => true, :role_finance => true, :role_orders => true, :next_weekly_tasks_number => 8, :ignore_apple_restriction => false)
Workgroup.create!(:id => 2, :name => "Finances", :account_balance => 0.0, :created_on => 'Sun, 19 Jan 2014 17:40:03 UTC +00:00', :role_admin => false, :role_suppliers => false, :role_article_meta => false, :role_finance => true, :role_orders => false, :next_weekly_tasks_number => 8, :ignore_apple_restriction => false)
Ordergroup.create!(:id => 5, :name => "Alice WG", :account_balance => 0.90E2, :created_on => 'Sat, 18 Jan 2014 00:38:48 UTC +00:00', :role_admin => false, :role_suppliers => false, :role_article_meta => false, :role_finance => false, :role_orders => false, :stats => { :jobs_size => 0, :orders_sum => 1021.74 }, :next_weekly_tasks_number => 8, :ignore_apple_restriction => true)
Ordergroup.create!(:id => 8, :name => "Bob's Family", :account_balance => 0.90E2, :created_on => 'Wed, 09 Apr 2014 12:23:29 UTC +00:00', :role_admin => false, :role_suppliers => false, :role_article_meta => false, :role_finance => false, :role_orders => false, :contact_person => "John Doe", :stats => { :jobs_size => 0, :orders_sum => 0 }, :next_weekly_tasks_number => 8, :ignore_apple_restriction => false)
FinancialTransaction.create!(:ordergroup_id => 5, :amount => 0.90E2, :note => "Bank transfer", :user_id => 2, :created_on => 'Mon, 17 Feb 2014 16:19:34 UTC +00:00', :financial_transaction_type_id => 1)
FinancialTransaction.create!(:ordergroup_id => 8, :amount => 0.90E2, :note => "Bank transfer", :user_id => 2, :created_on => 'Mon, 17 Feb 2014 16:19:34 UTC +00:00', :financial_transaction_type_id => 1)

Membership.create!(:group_id => 1, :user_id => 1)
Membership.create!(:group_id => 5, :user_id => 1)
Membership.create!(:group_id => 2, :user_id => 2)
Membership.create!(:group_id => 8, :user_id => 2)

supplier_category = SupplierCategory.create!(:id => 1, :name => "Other", :financial_transaction_class_id => 1)

chocolate_supplier = Supplier.create!(
  name: "Kollektiv CHOCK!",
  address: "Grabower Straße 1\n12345 Berlin",
  phone: "0123456789",
  email: "info@bbakery.test",
  supplier_category: supplier_category
)

nkn_supplier = Supplier.create!(
  name: "Naturgut Süd",
  address: "Somewhere in Hamburg, maybe St. Pauli?",
  phone: "0123434789",
  email: "foodsoft@local-it.org",
  supplier_category: supplier_category
)

chocolate_category = ArticleCategory.create!(name: "Schokolade")
obst_category = ArticleCategory.create!(name: "Obst, Gemüse, Sprossen, Pilze")
nudeln_category = ArticleCategory.create!(name: "Nudeln, Trockenfrüchte, Müsli")
reis_category = ArticleCategory.create!(name: "Getreide, Ölsaaten. Nußkerne")

Article.create!(
  name: "Vollmilch-Schokolade",
  supplier_id: chocolate_supplier.id,
  article_category_id: chocolate_category.id,
  manufacturer: "Grabower Süßwaren GmbH",
  origin: "D", price: 3.0, tax: 7.0,
  unit: "200g", unit_quantity: 5, 
  note: "bio, fairtrade, 40% Kakao, vegan",
  availability: true, order_number: "1")

Article.create!(
  name: "Weiße Schokolade",
  supplier_id: chocolate_supplier.id,
  article_category_id: chocolate_category.id,
  manufacturer: "Grabower Süßwaren GmbH",
  origin: "D", price: 3.49, tax: 7.0,
  unit: "200g", unit_quantity: 5,
  note: "bio, fairtrade, 40% Kakao, vegan",
  availability: true, order_number: "2")
  
dark_chocolate = Article.create!(
  name: "Dunkle Schokolade",
  supplier_id: chocolate_supplier.id,
  article_category_id: chocolate_category.id,
  manufacturer: "Grabower Süßwaren GmbH",
  origin: "D", price: 2.89, tax: 7.0,
  unit: "200g", unit_quantity: 5, 
  note: "bio, fairtrade, 40% Kakao, vegan",
  availability: true, order_number: "3")

Article.create!(
  name: "Himbeer-Schokolade",
  supplier_id: chocolate_supplier.id,
  article_category_id: chocolate_category.id,
  manufacturer: "Grabower Süßwaren GmbH",
  origin: "D", price: 2.89, tax: 7.0,
  unit: "170g", unit_quantity: 4, 
  note: "bio, fairtrade, 40% Kakao, vegan",
  availability: true, order_number: "4")

previous_order = seed_order(supplier_id: chocolate_supplier.id, starts: 10.days.ago, ends: 7.days.ago)

GroupOrderArticle.create!(
  group_order: GroupOrder.create!(order_id: previous_order.id, ordergroup_id: 8),
  order_article: previous_order.order_articles.find_by(article_id: dark_chocolate.id),
  quantity: 5, tolerance: 0)

previous_order.close!(alice)

seed_order(supplier_id: chocolate_supplier.id, starts: 0.days.ago, ends: 7.days.from_now)


apple = Article.create!(
  name: "Äpfel Elstar",
  supplier_id: nkn_supplier.id,
  article_category_id: obst_category.id,
  manufacturer: "Obsthof Bruno Brugger",
  origin: "D", price: 3.49, tax: 7.0,
  unit: "1kg", unit_quantity: 10, 
  note: "lecker, fruchtig, demeter",
  availability: true, order_number: "5")
  
brokkoli = Article.create!(
  name: "Brokkoli",
  supplier_id: nkn_supplier.id,
  article_category_id: obst_category.id,
  manufacturer: "Fattoria degli Orsi",
  origin: "IT", price: 2.89, tax: 7.0,
  unit: "400g", unit_quantity: 6,
  note: "gesund und lecker",
  availability: true, order_number: "6")

tomatoes = Article.create!(
  name: "Tomaten",
  supplier_id: nkn_supplier.id,
  article_category_id: obst_category.id,
  manufacturer: "Terra di Puglia",
  origin: "IT", price: 2.89, tax: 7.0,
  unit: "500g", unit_quantity: 20, 
  note: "pomodori italianio, demeter",
  availability: true, order_number: "7")

rice = Article.create!(
  name: "Reis",
  supplier_id: nkn_supplier.id,
  article_category_id: reis_category.id,
  manufacturer: "Finck",
  origin: "D", price: 3.29, tax: 7.0,
  unit: "3kg", unit_quantity: 10, 
  note: "Reis im Vorratssack, demeter",
  availability: true, order_number: "8")

spaghetti = Article.create!(
  name: "Spaghetti",
  supplier_id: nkn_supplier.id,
  article_category_id: nudeln_category.id,
  manufacturer: "Pastificio Zanellini spa",
  origin: "D", price: 2.89, tax: 7.0,
  unit: "500g", unit_quantity: 4, 
  note: "100% italienisches Hartweizengrieß",
  availability: true, order_number: "9")

