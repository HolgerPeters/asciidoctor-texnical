# frozen_string_literal: true

require 'asciidoctor/extensions'

require_relative 'image'
require 'pathname'

class Mathematical
  STEM_INLINE_MACRO_RX = /\\?(?:stem|latexmath):([a-z,]*)\[(.*?[^\\])\]/m.freeze
  LATEX_INLINE_MACRO_RX = /\\?latexmath:([a-z,]*)\[(.*?[^\\])\]/m.freeze
  LINE_FEED = %(\n)

  def initialize(ppi, image_target_dir)
    @ppi = ppi
    @image_target_dir = image_target_dir
  end

  def to_file(path); end

  def handle_prose_block(prose, _processor)
    text = prose.context == :list_item ? (prose.instance_variable_get :@text) : (prose.lines * LINE_FEED)
    text, source_modified = handle_inline_stem prose, text
    if source_modified
      if prose.context == :list_item
        prose.instance_variable_set :@text, text
      else
        prose.lines = text.split LINE_FEED
      end
    end
  end

  def handle_stem_block(stem, processor)
    return unless stem.style.to_sym == :latexmath

    ::IO.write 'test.txt', stem.content

    result = Image.generate_block stem.content, stem.id, self

    alt_text = stem.attr 'alt', %($$#{stem.content}$$)
    attrs = { 'target' => result.target_path,
              'alt' => alt_text,
              'align' => 'center',
              'width' => result.width.to_s,
              'height' => result.height.to_s }

    stem_image = processor.create_image_block stem.parent, attrs
    stem_image.id = stem.id if stem.id
    if (title = stem.attributes['title'])
      stem_image.title = title
    end
    stem.parent.blocks[stem.parent.blocks.index stem] = stem_image
  end

  def handle_inline_stem(node, text)
    # document = node.document
    # to_html = document.basebackend? "html"
    # support_stem_prefix = document.attr? "stem", "latexmath"
    # stem_rx = support_stem_prefix ? STEM_INLINE_MACRO_RX : LATEX_INLINE_MACRO_RX

    # source_modified = false
    # # TODO: skip passthroughs in the source (e.g., +stem:[x^2]+)
    # if !text.nil? && (text.include? ":") && ((support_stem_prefix && (text.include? "stem:")) || (text.include? "latexmath:"))
    #   text.gsub!(stem_rx) do
    #     if (m = $LAST_MATCH_INFO)[0].start_with? '\\'
    #       next m[0][1..-1]
    #     end

    #     if (eq_data = m[2].rstrip).empty?
    #       next
    #     else
    #       source_modified = true
    #     end

    #     eq_data.gsub! '\]', "]"
    #     subs = m[1].nil_or_empty? ? (to_html ? [:specialcharacters] : []) : (node.resolve_pass_subs m[1])
    #     eq_data = node.apply_subs eq_data, subs unless subs.empty?
    #     img_target, img_width, img_height = make_equ_image eq_data, nil, true
    #     %(image:#{img_target}[width=#{img_width},height=#{img_height}])
    #   end
    # end

    # [text, source_modified]
  end

  attr_reader :image_output_dir
  attr_reader :image_target_dir
end
