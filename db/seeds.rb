# Idempotent seed data for Alon's Bakery. Run with `bin/rails db:seed`.
#
# `find_or_initialize_by` + `update!` (instead of the block form of
# `find_or_create_by!`) so that re-running the seed also backfills new
# columns onto products that were created by an earlier run.

products = [
  {
    name: "Cachito de jamón", category: "Salados", price: 1200, stock: 40,
    description: "Bollo relleno de jamón",
    image_url: "https://images.unsplash.com/photo-1568254183919-78a4f43a2877?w=800"
  },
  {
    name: "Roll de canela", category: "Dulces", price: 1500, stock: 60,
    description: "Con glaseado",
    image_url: "https://images.unsplash.com/photo-1509365465985-25d11c17e812?w=800"
  },
  {
    name: "Golfeado", category: "Dulces", price: 1300, stock: 30,
    description: "Con papelón y queso de mano",
    image_url: "https://images.unsplash.com/photo-1585476840133-4c5da8de3f5e?w=800"
  },
  {
    name: "Pan dulce relleno", category: "Dulces", price: 1800, stock: 20,
    description: "Relleno de crema pastelera",
    image_url: "https://images.unsplash.com/photo-1600325580308-6033fa32c8d4?w=800"
  },
  {
    name: "Torta de zanahoria (porción)", category: "Tortas", price: 2500, stock: 15,
    description: "Con frosting de queso crema",
    image_url: "https://images.unsplash.com/photo-1621303837174-89787a7d4729?w=800"
  }
]

products.each do |attrs|
  Product.find_or_initialize_by(name: attrs[:name]).update!(attrs)
end

customers = [
  { name: "Alondra", phone: "+58 412 0000000", email: "alondra@example.com" },
  { name: "Cliente de prueba", phone: "+58 414 1111111", email: "cliente@example.com" }
]

customers.each do |attrs|
  Customer.find_or_initialize_by(email: attrs[:email]).update!(attrs)
end

puts "Seeded #{Product.count} products and #{Customer.count} customers."
