# Request specs hit the panel endpoints, which require the ADMIN_TOKEN header.
# This stubs the env var to a known value and gives specs an `admin_headers`
# helper.
module AdminAuthHelper
  ADMIN_TOKEN = "test-admin-token"

  def admin_headers
    { "X-Admin-Token" => ADMIN_TOKEN }
  end
end

RSpec.configure do |config|
  config.include AdminAuthHelper, type: :request

  config.before(:each, type: :request) do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with("ADMIN_TOKEN").and_return(AdminAuthHelper::ADMIN_TOKEN)
  end
end
