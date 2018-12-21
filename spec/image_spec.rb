# frozen_string_literal: true

require 'asciidoctor-texnical/image'
require 'asciidoctor-texnical/mathematical'

describe Image do
  it 'An image is generated' do
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        out_pth = ::File.join dir, './spec_out'
        target_pth = ::File.join dir, './spec_target'
        mathematical = Mathematical.new 140, out_pth, target_pth
        img = Image.generate_block('x^2 + x', 'equid', mathematical)
        expect(File.exist?(File.join(target_path, 'equid.png'))).to be true
        expect(File.join(target_path, 'equid.png')).to eql(img.target_path)
      end
    end
  end
end
