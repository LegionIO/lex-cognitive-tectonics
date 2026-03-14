# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveTectonics
      class Client
        include Runners::CognitiveTectonics

        attr_reader :engine

        def initialize(engine: nil, **)
          @engine          = engine || Helpers::TectonicEngine.new
          @default_engine  = @engine
        end
      end
    end
  end
end
