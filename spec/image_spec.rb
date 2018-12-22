# frozen_string_literal: true

require 'asciidoctor-texnical/image'
require 'asciidoctor-texnical/mathematical'
require 'asciidoctor/extensions'

describe Image do
  it 'An image is generated' do
    dir = Dir.mktmpdir
    Dir.chdir(dir) do
      target_path = ::File.join dir, './spec_target'
      Dir.mkdir target_path
      mathematical = Mathematical.new 140, target_path
      img = Image.generate_block('x^2 + x', 'equid', mathematical)
      expect(File.exist?(File.join(target_path, 'equid.png'))).to be true

      # test for attributes of image
      expect(File.join(target_path, 'equid.png')).to eql(img.target_path)
      expect(img.width).to be 177 # who knows if this is stable
      expect(img.height).to be 389 # who knows if this is stable
    end
  end
end
