# frozen_string_literal: true

require 'securerandom'

require 'legion/extensions/cognitive_tectonics/version'
require 'legion/extensions/cognitive_tectonics/helpers/constants'
require 'legion/extensions/cognitive_tectonics/helpers/belief_plate'
require 'legion/extensions/cognitive_tectonics/helpers/seismic_event'
require 'legion/extensions/cognitive_tectonics/helpers/tectonic_engine'
require 'legion/extensions/cognitive_tectonics/runners/cognitive_tectonics'
require 'legion/extensions/cognitive_tectonics/client'

module Legion
  module Extensions
    module CognitiveTectonics
      extend Legion::Extensions::Core if Legion::Extensions.const_defined? :Core
    end
  end
end
