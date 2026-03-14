# lex-cognitive-tectonics

A LegionIO cognitive architecture extension that models belief revision as plate tectonics. Beliefs drift through conceptual space, collide, and interact via convergent, divergent, or transform boundaries. Stress accumulates and releases as earthquakes — sudden, cascading belief shifts.

## What It Does

Manages **belief plates** — cognitive beliefs with position, mass, and drift velocity in a 2D space. A background actor moves all plates every 60 seconds. When plates collide, the caller resolves the interaction by choosing a boundary type:

- **Convergent**: beliefs merge; masses and drifts average together
- **Divergent**: beliefs split and drift apart; mass halves
- **Transform**: friction builds stress; at threshold stress triggers an earthquake

Earthquakes release stress and propagate to nearby plates.

## Usage

```ruby
require 'lex-cognitive-tectonics'

client = Legion::Extensions::CognitiveTectonics::Client.new

# Create belief plates
r1 = client.create_plate(domain: :ethics, content: 'harm prevention is primary', mass: 0.8,
                          drift_vector: { x: 0.01, y: 0.0 })
# => { success: true, plate_id: "uuid...", plate: { mass: 0.8, state: :active, position: {...}, ... } }

r2 = client.create_plate(domain: :ethics, content: 'autonomy is primary', mass: 0.7,
                          drift_vector: { x: -0.01, y: 0.0 })

# Advance one tick (also fires automatically every 60s via Actor::DriftTick)
client.drift_tick(delta_t: 1.0)
# => { success: true, plates_moved: 2, collisions_detected: 0, collisions: [] }

# If plates collide, resolve the interaction
# (plates with distance < 0.2 are flagged as collisions)
client.resolve_collision(
  plate_a_id: r1[:plate_id],
  plate_b_id: r2[:plate_id],
  boundary_type: :transform
)
# => { success: true, boundary_type: :transform, outcome: :friction, stress_added: 0.28 }

# Manually trigger an earthquake at a plate
client.trigger_earthquake(plate_id: r1[:plate_id], magnitude: 2.5)
# => { success: true, event_id: "uuid...", event: { type: :earthquake, magnitude: 2.5, label: :light, ... } }

# System report
client.tectonic_status
# => { success: true, total_plates: 2, active_plates: 2, high_stress_count: 0, seismic_events: 1, ... }
```

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT
