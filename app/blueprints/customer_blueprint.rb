class CustomerBlueprint < Blueprinter::Base
  identifier :id

  fields :name, :phone, :email
end
