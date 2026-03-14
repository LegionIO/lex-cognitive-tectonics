# lex-cognitive-tectonics

**Level 3 Leaf Documentation**
- **Parent**: `/Users/miverso2/rubymine/legion/extensions-agentic/CLAUDE.md`
- **Gem**: `lex-cognitive-tectonics`
- **Version**: 0.1.0
- **Namespace**: `Legion::Extensions::CognitiveTectonics`

## Purpose

Models belief revision as plate tectonics. Cognitive beliefs are represented as plates with mass, position, and drift vectors in a 2D space. Plates drift over time, collide, and interact via three boundary types: convergent (beliefs merge), divergent (beliefs split and drift apart), or transform (friction accumulates stress that eventually triggers earthquakes). Seismic events model sudden, cascading belief shifts. A periodic `DriftTick` actor moves all plates each tick.

## Gem Info

- **Gemspec**: `lex-cognitive-tectonics.gemspec`
- **Require**: `lex-cognitive-tectonics`
- **Ruby**: >= 3.4
- **License**: MIT
- **Homepage**: https://github.com/LegionIO/lex-cognitive-tectonics

## File Structure

```
lib/legion/extensions/cognitive_tectonics/
  version.rb
  helpers/
    constants.rb         # Boundary types, magnitude labels, stress/collision thresholds
    belief_plate.rb      # BeliefPlate class — one belief with position, mass, stress
    seismic_event.rb     # SeismicEvent class — earthquake/tremor/aftershock record
    tectonic_engine.rb   # TectonicBoundaries module + TectonicEngine class
  runners/
    cognitive_tectonics.rb  # Runner module — public API (extend self)
  actors/
    drift_tick.rb        # Actor::DriftTick — fires drift_tick every 60s
  client.rb
```

## Key Constants

| Constant | Value | Meaning |
|---|---|---|
| `MAX_PLATES` | 50 | Hard cap on belief plates (raises if exceeded) |
| `MAX_QUAKES` | 200 | Seismic history ring size |
| `COLLISION_THRESHOLD` | 0.2 | Distance below which two plates collide |
| `SUBDUCTION_RATIO` | 0.7 | Mass below which a plate is subductable |
| `AFTERSHOCK_DECAY` | 0.3 | Magnitude multiplier reduction for aftershocks |
| `STRESS_QUAKE_TRIGGER` | 1.0 | Stress accumulation that auto-triggers earthquake |
| `MIN_DRIFT_RATE` | 0.001 | Minimum allowed drift component (reference) |
| `MAX_DRIFT_RATE` | 0.05 | Maximum allowed drift component (reference) |

`BOUNDARY_TYPES`: `[:convergent, :divergent, :transform]`

`PLATE_STATES`: `[:active, :subducted, :dormant]`

Magnitude labels: `[0,1)` = `:micro`, `[1,2)` = `:minor`, `[2,3)` = `:light`, `[3,4)` = `:moderate`, `[4,5)` = `:strong`, `5+` = `:great`

## Key Classes

### `Helpers::BeliefPlate`

One cognitive belief with spatial position, mass, drift, and stress.

- `drift!(delta_t)` — advances position by `drift_vector * delta_t`; only active plates drift
- `accumulate_stress!(amount)` — adds to `@stress_accumulation`
- `release_stress!` — resets stress to 0.0; returns the released amount
- `subducted?` — mass < `SUBDUCTION_RATIO`
- `subduct!` / `dormant!` — transitions state
- `active?` — `state == :active`
- `distance_to(other_plate)` — Euclidean distance between positions
- Position is initialized with random `x,y` in `[-10.0, 10.0]` if not provided

### `Helpers::SeismicEvent`

A seismic event record for the history log.

- `EVENT_TYPES`: `[:earthquake, :tremor, :aftershock]`
- `label` — magnitude label from `Constants#label_for`
- `aftershock?` — type == `:aftershock`
- Fields: `id`, `type`, `magnitude`, `epicenter_plate_id`, `affected_plate_ids`, `parent_event_id`, `timestamp`

### `Helpers::TectonicBoundaries` (module)

Private collision resolution methods mixed into `TectonicEngine`.

- `resolve_convergent` — averages mass and drift vectors; outcome `:merged`
- `resolve_divergent` — halves mass; reverses x-drift for A, y-drift for B; outcome `:split`
- `resolve_transform` — adds `mass_a * mass_b * 0.5` stress to both; calls `check_stress_quake`; outcome `:friction`
- `check_stress_quake` — auto-triggers earthquake if plate stress >= `STRESS_QUAKE_TRIGGER`

### `Helpers::TectonicEngine`

Registry and event processing.

- `create_plate(domain:, content:, mass:, drift_vector:, position:)` — raises if at `MAX_PLATES`
- `drift_tick!(delta_t)` — drifts all active plates; detects collisions afterward
- `detect_collisions` — all active plate pairs with distance < `COLLISION_THRESHOLD`
- `resolve_collision(plate_a_id:, plate_b_id:, boundary_type:)` — dispatches to `TectonicBoundaries`; updates fault registry
- `subduct(weaker_plate_id:, stronger_plate_id:)` — absorbs 50% of weaker plate's mass into stronger; marks weaker as subducted
- `trigger_earthquake(plate_id:, magnitude:)` — releases stress; propagates 30% magnitude to nearby plates (< 5.0 distance)
- `aftershock_cascade(event_id:)` — creates aftershock at `magnitude * (1 - AFTERSHOCK_DECAY)`
- `tectonic_report` — aggregate with plate counts, high-stress count, recent quakes

## Runners

Module: `Legion::Extensions::CognitiveTectonics::Runners::CognitiveTectonics` (uses `extend self`)

| Runner | Key Args | Returns |
|---|---|---|
| `create_plate` | `domain:`, `content:`, `mass:`, `drift_vector:`, `position:` | `{ success:, plate_id:, plate: }` |
| `drift_tick` | `delta_t:` | `{ success:, plates_moved:, collisions_detected:, collisions: }` |
| `resolve_collision` | `plate_a_id:`, `plate_b_id:`, `boundary_type:` | boundary-specific result hash |
| `trigger_earthquake` | `plate_id:`, `magnitude:` | `{ success:, event_id:, event: }` |
| `tectonic_status` | — | `{ success:, total_plates:, active_plates:, high_stress_count:, recent_quakes:, ... }` |

## Actors

`Actor::DriftTick` — extends `Legion::Extensions::Actors::Every`

- Fires `drift_tick` every **60 seconds**
- `run_now?: false`, `use_runner?: false`, `check_subtask?: false`, `generate_task?: false`
- Advances all plate positions and surfaces new collisions each minute

## Integration Points

- `drift_tick` is called automatically every 60s by `Actor::DriftTick`
- Can be triggered manually via runner for faster simulation
- Collision detection returns plate ID pairs — caller decides the boundary type for `resolve_collision`
- Transform boundary is the only type that accumulates stress; high-stress states can be read via `tectonic_report`
- All state is in-memory per `TectonicEngine` instance; reset is not built in (replace `@tectonic_engine`)

## Development Notes

- `MIN_DRIFT_RATE` and `MAX_DRIFT_RATE` are defined but not enforced; drift components in `drift_vector` are caller-specified
- `nearby_plates` uses a fixed radius of 5.0 (hardcoded in `TectonicBoundaries`)
- The runner raises `ArgumentError` directly for missing required args, then rescues it into `{ success: false, error: }`
- Fault registry (`@active_faults`) is a plain array of hashes, not indexed — O(n) for lookup
- Seismic history is a ring buffer capped at `MAX_QUAKES`: `@seismic_history.shift if size > MAX_QUAKES`
