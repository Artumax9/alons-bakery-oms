class ProductBlueprint < Blueprinter::Base
  identifier :id

  fields :name, :description, :price, :active, :stock
end
