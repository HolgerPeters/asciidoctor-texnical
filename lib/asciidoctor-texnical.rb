# frozen_string_literal: true

require_relative 'asciidoctor-texnical/extension'

Asciidoctor::Extensions.register do
  treeprocessor TexnicalTreeprocessor
end
