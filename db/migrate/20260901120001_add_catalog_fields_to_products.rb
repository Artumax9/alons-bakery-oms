class AddCatalogFieldsToProducts < ActiveRecord::Migration[8.0]
  def change
    # Optional: a product without a photo falls back to a placeholder in the UI.
    add_column :products, :image_url, :string

    # A plain label for the storefront filter chips, not an entity with behaviour.
    # Promote to a `categories` table only when it needs its own ordering or slug.
    add_column :products, :category, :string, default: "Otros", null: false
  end
end
