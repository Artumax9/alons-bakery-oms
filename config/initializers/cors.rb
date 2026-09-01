# Cross-Origin Resource Sharing. The SPA lives on a different origin
# (Vite in dev, Vercel in prod), so the browser needs these headers.
#
# CORS_ORIGINS is a comma-separated list; defaults to the local Vite dev server.
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins ENV.fetch("CORS_ORIGINS", "http://localhost:5173").split(",").map(&:strip)

    resource "*",
      headers: :any,
      methods: [ :get, :post, :put, :patch, :delete, :options, :head ]
  end
end
