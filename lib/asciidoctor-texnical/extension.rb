# frozen_string_literal: true

require 'pathname'
require 'asciidoctor/extensions'

require_relative 'mathematical'

autoload :Digest, 'digest'

class TexnicalTreeprocessor < Asciidoctor::Extensions::Treeprocessor
  def process(document)
    ppi_s = (document.attr 'texnical-ppi') || '192.0'
    ppi = ppi_s.to_f

    target_dir = document.attr('imagesdir')
    ::Asciidoctor::Helpers.mkdir_p target_dir unless ::File.directory? target_dir
    texnical = ::Mathematical.new ppi, target_dir

    unless (stem_blocks = document.find_by context: :stem).nil_or_empty?
      stem_blocks.each do |stem|
        texnical.handle_stem_block stem, self
      end
    end

    # unless (prose_blocks = document.find_by do |b|
    #   (b.content_model = :simple && (b.subs.include? :macros)) || b.context == :list_item
    # end).nil_or_empty?
    #   prose_blocks.each do |prose|
    #     texnical.handle_prose_block prose, self
    #   end
    # end
    # # handle table cells of the "asciidoc" type, as suggested by mojavelinux
    # # at asciidoctor/asciidoctor-mathematical#20.
    # unless (table_blocks = document.find_by context: :table).nil_or_empty?
    #   table_blocks.each do |table|
    #     (table.rows[:body] + table.rows[:foot]).each do |row|
    #       row.each do |cell|
    #         if cell.style == :asciidoc
    #           process cell.inner_document
    #         elsif cell.style != :literal
    #           handle_nonasciidoc_table_cell cell, mathematical, image_output_dir, image_target_dir, format, inline
    #         end
    #       end
    #     end
    #   end
    # end

    # unless (sect_blocks = document.find_by content: :section).nil_or_empty?
    #   sect_blocks.each do |sect|
    #     handle_section_title sect, mathematical, image_output_dir, image_target_dir, format, inline
    #   end
    # end

    nil
  end
end
