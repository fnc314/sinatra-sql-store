require 'pry'
require 'sinatra'
require 'sinatra/reloader'
require 'pg'

def dbname
  "storeadminsite"
end

def with_db
  c = PGconn.new(:host => "localhost", :dbname => "storeadminsite")
  yield c
  c.close
end

get '/' do
  erb :index
end

# The Products machinery:

# Get the index of products
get '/products' do
  c = PGconn.new(:host => "localhost", :dbname => "storeadminsite")

  # Get all rows from the products table.
  @products = c.exec_params("SELECT * FROM products;")
  c.close
  erb :products
end

# Get the form for creating a new product
get '/products/new' do
  erb :new_product
end

# POST to create a new product
post '/products' do
  c = PGconn.new(:host => "localhost", :dbname => "storeadminsite")

  # Insert the new row into the products table.
  c.exec_params("INSERT INTO products (name, price, description) VALUES ($1,$2,$3)",
                  [params["name"], params["price"], params["description"]])

  # Assuming you created your products table with "id SERIAL PRIMARY KEY",
  # This will get the id of the product you just created.
  new_product_id = c.exec_params("SELECT currval('products_id_seq');").first["currval"]
  c.close
  redirect "/products/#{new_product_id}"
end

# Update a product
post '/products/:id' do
  c = PGconn.new(:host => "localhost", :dbname => "storeadminsite")

  # Update the product.
  c.exec_params("UPDATE products SET (name, price, description) = ($2, $3, $4) WHERE products.id = $1 ",
                [params["id"], params["name"], params["price"], params["description"]])
  c.close
  redirect "/products/#{params["id"]}"
end

get '/products/:id/edit' do
  c = PGconn.new(:host => "localhost", :dbname => "storeadminsite")
  @product = c.exec_params("SELECT * FROM products WHERE products.id = $1", [params["id"]]).first
  c.close
  erb :edit_product
end

# DELETE to delete a product
post '/products/:id/destroy' do

  c = PGconn.new(:host => "localhost", :dbname => "storeadminsite")
  c.exec_params("DELETE FROM products WHERE products.id = $1", [params["id"]])
  c.close
  redirect '/products'
end

# GET the show page for a particular product
get '/products/:id' do
  c = PGconn.new(:host => "localhost", :dbname => "storeadminsite")
  @product = c.exec_params("SELECT * FROM products WHERE products.id = $1;", [params[:id]]).first
  c.close
  erb :product
end
# ----------------------------------------------------------------------------------------------------------------
get '/categories' do
  c = PGconn.new(:host => "localhost", :dbname => "storeadminsite")
  @categories = c.exec_params("SELECT * FROM categories;")
  c.close
  erb :categories
end

get '/categories/new' do
  erb :new_category
end

post '/categories' do
  c = PGconn.new(:host => "localhost", :dbname => "storeadminsite")
  c.exec_params("INSERT INTO categories (name) VALUES ($1)", [params["name"]])
  c.close
  redirect '/categories'
end

get '/categories/:id' do
  c = PGconn.new(:host => "localhost", :dbname => "storeadminsite")
  @categories = c.exec_params("SELECT * FROM categories WHERE categories.id = $1;", [params[:id]]).first
  c.close
  get_categories
  get_products
  get_cat_prod
  erb :category
end

get '/categories/:id/edit' do
  c = PGconn.new(:host => "localhost", :dbname => "storeadminsite")
  @product = c.exec_params("SELECT * FROM products WHERE products.id = $1", [params["id"]]).first
  c.close
end

post '/categories/:id/destroy' do
  c = PGconn.new(:host => "localhost", :dbname => "storeadminsite")
  c.exec_params("DELETE FROM categories WHERE categories.id = $1", [params["id"]])
  c.close
  redirect '/categories'
end

def get_products
  c = PGconn.new(:host => "localhost", :dbname => "storeadminsite")
  @all_products = c.exec_params("SELECT * FROM products")
  c.close
  return @all_products
end

def get_categories
  c = PGconn.new(:host => "localhost", :dbname => "storeadminsite")
  @all_categories = c.exec_params("SELECT * FROM categories")
  c.close
  return @all_categories
end

def get_cat_prod
  c = PGconn.new(:host => "localhost", :dbname => "storeadminsite")
  @all_cat_prod = c.exec_params("SELECT * FROM cat_prod")
  c.close
  return @all_cat_prod
end

def get_cat_id(name)
  get_categories
  @all_categories.each do |x|
    if x["name"] == name
      return x["id"].to_i
    end
  end
end

def get_prod_id(name)
  get_products
  @all_products.each do |x|
    if x["name"] == name
      return x["id"].to_i
    end
  end
end



# def create_catprod_table
#   c = PGconn.new(:host => "localhost", :dbname => "storeadminsite")
#   c.exec %q{
#     CREATE TABLE cat_prod(
#     id SERIAL PRIMARY KEY,
#     cat_id INTEGER,
#     prod_id INTEGER);
#   }
#   c.close
# end

# def seed_catprod_table
#   catprod=[[1,4],[1,5],[2,1],[2,8],[2,9],[3,3],[3,4],[3,5],[3,6],[4,7],[4,2],[5,8],[5,9]]
#   c = PGconn.new(:host => "localhost", :dbname => "storeadminsite")
#   catprod.each do |x|
#     c.exec_params("INSERT INTO cat_prod (cat_id,prod_id) VALUES ($1,$2);", x)
#   end
#   c.close
# end


# # Update a product
# post '/products/:id' do
#   c = PGconn.new(:host => "localhost", :dbname => "storeadminsite")

#   # Update the product.
#   c.exec_params("UPDATE products SET (name, price, description) = ($2, $3, $4) WHERE products.id = $1 ",
#                 [params["id"], params["name"], params["price"], params["description"]])
#   c.close
#   redirect "/products/#{params["id"]}"
# end

# get '/products/:id/edit' do
#   c = PGconn.new(:host => "localhost", :dbname => "storeadminsite")
#   @product = c.exec_params("SELECT * FROM products WHERE products.id = $1", [params["id"]]).first
#   c.close
#   erb :edit_product
# end

# # GET the show page for a particular product
# get '/products/:id' do
#   c = PGconn.new(:host => "localhost", :dbname => "storeadminsite")
#   @product = c.exec_params("SELECT * FROM products WHERE products.id = $1;", [params[:id]]).first
#   c.close
#   erb :product
# end

# def create_products_table
#   c = PGconn.new(:host => "localhost", :dbname => "storeadminsite")
#   c.exec %q{
#   CREATE TABLE products (
#     id SERIAL PRIMARY KEY,
#     name varchar(255),
#     price decimal,
#     description text
#   );
#   }
#   c.close
# end

# def create_catergory_table
#   c = PGconn.new(:host => "localhost", :dbname => "storeadminsite")
#   c.exec %q{
#     CREATE TABLE categories(
#     id SERIAL PRIMARY KEY,
#     name text);
#   }
#   c.close
# end

# def seed_category_table
#   categories = [["Writing Surface"], ["Weapon"], ["Teaching Aids"], ["Transportation"], ["Kitchen Appliances"]]
#   c = PGconn.new(:host => "localhost", :dbname => "storeadminsite")
#   categories.each do |cat|
#     c.exec_params("INSERT INTO categories (name) VALUES ($1);", cat)
#   end
#   c.close
# end

# def seed_products_table
#   products = [["Laser", "325", "Good for lasering."],
#               ["Shoe", "23.4", "Just the left one."],
#               ["Wicker Monkey", "78.99", "It has a little wicker monkey baby."],
#               ["Whiteboard", "125", "Can be written on."],
#               ["Chalkboard", "100", "Can be written on.  Smells like education."],
#               ["Podium", "70", "All the pieces swivel separately."],
#               ["Bike", "150", "Good for biking from place to place."],
#               ["Kettle", "39.99", "Good for boiling."],
#               ["Toaster", "20.00", "Toasts your enemies!"],
#              ]

#   c = PGconn.new(:host => "localhost", :dbname => "storeadminsite")
#   products.each do |p|
#     c.exec_params("INSERT INTO products (name, price, description) VALUES ($1, $2, $3);", p)
#   end
#   c.close
# end
