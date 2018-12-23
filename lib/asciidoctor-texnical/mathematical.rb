# frozen_string_literal: true

require 'asciidoctor/extensions'

require_relative 'image'
require 'pathname'

class Mathematical
  STEM_INLINE_MACRO_RX = /\\?(?:stem|latexmath):([a-z,]*)\[(.*?[^\\])\]/m.freeze
  LINE_FEED = %(\n)

  def initialize(ppi, image_target_dir)
    @ppi = ppi
    @image_target_dir = image_target_dir
  end

  def handle_prose_block(prose)
    if prose.context == :list_item
      text = prose.instance_variable_get :@text
      text_new = handle_inline_stem prose, text
      prose.instance_variable_set :@text, text_new unless text_new.nil?
    else
      text = prose.lines * LINE_FEED
      text_new = handle_inline_stem prose, text
      prose.lines = text_new.split LINE_FEED unless text_new.nil?
    end
  end

  def handle_stem_block(stem, processor)
    return unless stem.style.to_sym == :latexmath

    ::IO.write 'test.txt', stem.content

    result = Image.generate_block stem.content, stem.id, self

    alt_text = stem.attr 'alt', %($$#{stem.content}$$)
    attrs = { 'target' => result.filename,
              'alt' => alt_text,
              'align' => 'center',
              'width' => (result.width * 0.5).to_s,
              'height' => (result.height * 0.5).to_s }

    stem_image = processor.create_image_block stem.parent, attrs
    stem_image.id = stem.id if stem.id
    if (title = stem.attributes['title'])
      stem_image.title = title
    end
    stem.parent.blocks[stem.parent.blocks.index stem] = stem_image
  end

  def handle_inline_stem(_node, text)
    source_modified = false
    if !text.nil? && (text.include? ':') && ((text.include? 'stem:') || (text.include? 'latexmath:'))
      text.gsub!(STEM_INLINE_MACRO_RX) do
        eq_id = Regexp.last_match[1] unless Regexp.last_match[1].nil_or_empty?
        eq_data = Regexp.last_match[2]
        source_modified = true
        img = Image.generate_inline eq_data, eq_id, self
        "image:#{img.filename}[width=#{img.width * 0.5},height=#{img.height * 0.5}]"
      end
    end
    text if source_modified
  end

  attr_reader :image_target_dir
  attr_reader :ppi
end
