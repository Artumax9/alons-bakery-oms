# Alon's Bakery — API

Backend de gestión de pedidos para **Alon's Bakery**, una repostería artesanal
venezolana real. API REST en Rails 8 que devuelve JSON puro; la interfaz es un
SPA aparte (repo `alons_bakery_web`).

```
React SPA  ──HTTP/JSON──▶  API Rails (este repo)  ──▶  PostgreSQL
                                  │
                                  └──▶  n8n  ──▶  WhatsApp / Telegram / Google Sheet
```

## Por qué existe

Doble objetivo: (a) que Alondra gestione pedidos de verdad, y (b) mostrar en
entrevistas diseño orientado a objetos estilo Sandi Metz, testing en RSpec en tres
niveles y una integración real con n8n.

## Stack

- Ruby 3.3 · Rails 8 en modo `--api` · PostgreSQL
- **Blueprinter** para serializar (lista blanca de campos explícita)
- **solid_queue** para jobs en background (sin Redis)
- **RSpec** + FactoryBot + shoulda-matchers
- **n8n** vía webhook para notificar a Alondra

## Correr localmente

```bash
bundle install
bin/rails db:prepare db:seed        # crea, migra y carga el catálogo real
bundle exec rspec                    # ~50 ejemplos: model, service, request
bin/rails server                     # http://localhost:3000
```

Para las notificaciones a n8n:

```bash
cp .env.example .env                 # setear N8N_WEBHOOK_URL (o una URL de webhook.site)
bin/jobs                              # worker de solid_queue, en otra terminal
```

Sin `N8N_WEBHOOK_URL` el job simplemente loguea y no falla.

## Endpoints

| Método | Ruta | Qué hace |
|---|---|---|
| GET | `/api/v1/products` | catálogo (solo activos) |
| GET | `/api/v1/products/:id` | un producto |
| GET | `/api/v1/customers` · `/:id` | clientes |
| POST | `/api/v1/customers` | alta de cliente |
| GET | `/api/v1/orders` · `/:id` | pedidos |
| POST | `/api/v1/orders` | crea un pedido (recalcula precios y stock) |
| PATCH | `/api/v1/orders/:id/status` | transición de estado |

## Decisiones de diseño

- **Los precios siempre se recalculan en el servidor.** El cliente manda solo
  `product_id` y `quantity`; `Orders::LineBuilder` trae el precio del `Product` y lo
  congela en el `OrderItem`. Si Alondra sube un precio, los pedidos viejos conservan
  el suyo.
- **El descuento por docena vive en una sola clase.** `Pricing::DozenDiscount` es un
  POR de ~10 líneas, sin base de datos, con las constantes nombradas
  (`UNITS_PER_DOZEN`, `FREE_UNITS_PER_DOZEN`). Cambiar la regla toca ese archivo y
  nada más. `discount_amount` se guarda aparte del total para que el cálculo sea
  auditable (`total = subtotal − discount`).
- **El webhook a n8n va a un job en background.** Si n8n está caído o lento, el
  cliente que hizo el pedido no puede quedarse esperando — el pedido ya se guardó.
  `NotifyOrderCreatedJob` con `retry_on` para errores de red.
- **La máquina de estados es un hash congelado** (`Orders::StatusTransition::TRANSITIONS`),
  no la gema `aasm`: 20 líneas, se entiende de un vistazo. Cancelar un pedido no
  entregado devuelve el stock.
- **Las validaciones de dominio están también en la base** (`null: false`, `CHECK`),
  no solo en ActiveRecord: red de seguridad si algo escribe por fuera de la app.
- **Sin tabla `categories`:** hoy la categoría es una etiqueta (`string`), no una
  entidad con comportamiento. Se promueve a tabla cuando necesite orden o slug propio.

## Pendientes conocidos

- Sin autenticación (el panel de Alondra la va a necesitar).
- `POST /customers` crea un cliente nuevo por cada checkout aunque repita teléfono;
  falta `find_or_initialize_by(phone:)`.
- Módulo de costeo (ingredientes + mano de obra) para que Alondra fije precios:
  diferido, con la columna `products.labor_percentage` ya creada.
- Boilerplate de `rails new` sin usar (Kamal, mailer, Active Storage).
