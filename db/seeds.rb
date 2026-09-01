# Idempotent seed data for Alon's Bakery. Run with `bin/rails db:seed`.

products = [
  { name: "Cachito de jamón", description: "Bollo relleno de jamón", price: 1200, stock: 40 },
  { name: "Roll de canela", description: "Con glaseado", price: 1500, stock: 60 },
  { name: "Golfeado", description: "Con papelón y queso de mano", price: 1300, stock: 30 },
  { name: "Pan dulce relleno", description: "Relleno de crema pastelera", price: 1800, stock: 20 },
  { name: "Torta de zanahoria (porción)", description: "Con frosting de queso crema", price: 2500, stock: 15 }
]

products.each do |attrs|
  Product.find_or_create_by!(name: attrs[:name]) do |product|
    product.assign_attributes(attrs)
  end
end

customers = [
  { name: "Alondra", phone: "+58 412 0000000", email: "alondra@example.com" },
  { name: "Cliente de prueba", phone: "+58 414 1111111", email: "cliente@example.com" }
]

customers.each do |attrs|
  Customer.find_or_create_by!(email: attrs[:email]) do |customer|
    customer.assign_attributes(attrs)
  end
end

puts "Seeded #{Product.count} products and #{Customer.count} customers."
