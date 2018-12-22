# frozen_string_literal: true

require File.expand_path('lib/asciidoctor-texnical/version',
                         File.dirname(__FILE__))

Gem::Specification.new do |s|
  s.name = 'asciidoctor-texnical'
  s.version = Asciidoctor::Texnical::VERSION
  s.date = '2017-01-09'
  s.summary = 'Asciidoctor STEM processor shelling out to latex'
  s.description = 'An Asciidoctor extension to converts latexmath equations to SVG or PNGs'
  s.authors = ['Holger Peters', 'Tobias Stumm', 'Zhang Yang', 'Dan Allen']
  s.files = ['lib/asciidoctor-texnical',
             'lib/asciidoctor-texnical/extension.rb',
             'lib/asciidoctor-texnical/image.rb',
             'lib/asciidoctor-texnical/mathematical.rb',
             'lib/asciidoctor-texnical/version.rb',
             'lib/asciidoctor-texnical.rb']
  s.homepage = 'https://github.com/HolgerPeters/asciidoctor-texnical'
  s.license = 'MIT'
  s.add_dependency 'ruby-enum', '~> 0.4'
  s.add_runtime_dependency 'asciidoctor', '~> 1.4'
  s.add_runtime_dependency 'asciidoctor-pdf', '~> 1.4'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
end
