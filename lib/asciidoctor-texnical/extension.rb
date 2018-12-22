# frozen_string_literal: true

require 'pathname'
require 'asciidoctor/extensions'

require_relative 'mathematical'

autoload :Digest, 'digest'

class TexnicalTreeprocessor < Asciidoctor::Extensions::Treeprocessor
  def process(document)
    ppi_s = (document.attr 'texnical-ppi') || '300.0'
    ppi = ppi_s.to_f

    target_dir = document.attr('imagesdir')
    ::Asciidoctor::Helpers.mkdir_p target_dir unless ::File.directory? target_dir
    texnical = ::Mathematical.new ppi, target_dir

    unless (stem_blocks = document.find_by context: :stem).nil_or_empty?
      stem_blocks.each do |stem|
        texnical.handle_stem_block stem, self
      end
    end

    unless (prose_blocks = document.find_by do |b|
      (b.content_model = :simple && (b.subs.include? :macros)) || b.context == :list_item
    end).nil_or_empty?
      prose_blocks.each do |prose|
        texnical.handle_prose_block prose, self
      end
    end
    nil
  end
end
