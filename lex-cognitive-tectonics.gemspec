# frozen_string_literal: true

require_relative 'lib/legion/extensions/cognitive_tectonics/version'

Gem::Specification.new do |spec|
  spec.name          = 'lex-cognitive-tectonics'
  spec.version       = Legion::Extensions::CognitiveTectonics::VERSION
  spec.authors       = ['Esity']
  spec.email         = ['matthewdiverson@gmail.com']

  spec.summary       = 'LEX Cognitive Tectonics'
  spec.description   = 'Tectonic belief-plate model for LegionIO — conviction as mass, drift vectors, ' \
                       'convergent/divergent/transform boundaries, seismic belief shifts, and aftershock cascades'
  spec.homepage      = 'https://github.com/LegionIO/lex-cognitive-tectonics'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.4'

  spec.metadata['homepage_uri']        = spec.homepage
  spec.metadata['source_code_uri']     = 'https://github.com/LegionIO/lex-cognitive-tectonics'
  spec.metadata['documentation_uri']   = 'https://github.com/LegionIO/lex-cognitive-tectonics'
  spec.metadata['changelog_uri']       = 'https://github.com/LegionIO/lex-cognitive-tectonics'
  spec.metadata['bug_tracker_uri']     = 'https://github.com/LegionIO/lex-cognitive-tectonics/issues'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.require_paths = ['lib']
  spec.add_development_dependency 'legion-gaia'
end
