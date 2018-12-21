# frozen_string_literal: true

require 'pathname'
require 'asciidoctor/extensions'

require_relative 'mathematical'

autoload :Digest, 'digest'

# Treeprocessor converting equations into images
class TexnicalTreeprocessor < Asciidoctor::Extensions::Treeprocessor
  def process(document)
    ppi_s = (document.attr 'texnical-ppi') || '300.0'
    ppi = ppi_s.to_f
    image_output_dir, image_target_dir = image_output_and_target_dir document
    ::Asciidoctor::Helpers.mkdir_p image_output_dir unless ::File.directory? image_output_dir
    texnical = ::Mathematical.new ppi, image_output_dir, image_target_dir

    unless (stem_blocks = document.find_by context: :stem).nil_or_empty?
      stem_blocks.each do |stem|
        texnical.handle_stem_block stem, self
      end
    end

    unless (prose_blocks = document.find_by do |b|
      (b.content_model == :simple && (b.subs.include? :macros)) || b.context == :list_item
    end).nil_or_empty?
      prose_blocks.each do |prose|
        texnical.handle_prose_block prose, self
      end
    end
    nil
  end

  def image_output_and_target_dir(parent)
    document = parent.document

    output_dir = parent.attr('imagesoutdir')
    if output_dir
      base_dir = nil
      if parent.attr('imagesdir').nil_or_empty?
        target_dir = output_dir
      else
        # When imagesdir attribute is set, every relative path is prefixed with it. So the real target dir shall then be relative to the imagesdir, instead of being relative to document root.
        doc_outdir = parent.attr('outdir') || (document.respond_to?(:options) && document.options[:to_dir])
        abs_imagesdir = parent.normalize_system_path(parent.attr('imagesdir'), doc_outdir)
        abs_outdir = parent.normalize_system_path(output_dir, base_dir)
        p1 = ::Pathname.new abs_outdir
        p2 = ::Pathname.new abs_imagesdir
        target_dir = p1.relative_path_from(p2).to_s
      end
    else
      base_dir = parent.attr('outdir') || (document.respond_to?(:options) && document.options[:to_dir])
      output_dir = parent.attr('imagesdir')
      # since we store images directly to imagesdir, target dir shall be NULL && asciidoctor converters will prefix imagesdir.
      target_dir = '.'
    end

    output_dir = parent.normalize_system_path(output_dir, base_dir)
    [output_dir, target_dir]
  end
end
