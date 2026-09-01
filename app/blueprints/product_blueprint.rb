class ProductBlueprint < Blueprinter::Base
  identifier :id

  fields :name, :description, :price, :active, :stock, :image_url, :category
end
