require "rails_helper"

RSpec.describe NotifyOrderCreatedJob, type: :job do
  let(:order) { create(:order, :with_items) }

  def stub_webhook_url(value)
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with("N8N_WEBHOOK_URL").and_return(value)
  end

  it "posts the serialized order to the configured webhook" do
    stub_webhook_url("https://n8n.example/webhook")
    client = instance_double(Webhooks::Client)
    allow(Webhooks::Client).to receive(:new).with("https://n8n.example/webhook").and_return(client)
    allow(client).to receive(:post)

    described_class.perform_now(order.id)

    expect(client).to have_received(:post).with(hash_including(event: "order.created"))
  end

  it "does nothing when N8N_WEBHOOK_URL is not set" do
    stub_webhook_url(nil)
    allow(Webhooks::Client).to receive(:new)

    described_class.perform_now(order.id)

    expect(Webhooks::Client).not_to have_received(:new)
  end
end
