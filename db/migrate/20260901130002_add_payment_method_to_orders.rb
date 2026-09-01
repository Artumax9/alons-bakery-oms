class AddPaymentMethodToOrders < ActiveRecord::Migration[8.0]
  def change
    # Which method the customer picked at checkout. Alondra still collects the
    # money out-of-band (WhatsApp); this is just a record. Default 0 (cash) so
    # existing rows stay valid.
    add_column :orders, :payment_method, :integer, default: 0, null: false
  end
end
