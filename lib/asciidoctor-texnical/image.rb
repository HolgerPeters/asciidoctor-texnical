# frozen_string_literal: true

require 'tmpdir'
require 'open3'

HEADER = '\documentclass[12pt]{article}
    \usepackage[utf8]{inputenc}
    \usepackage{amsmath}
    \usepackage{amsthm}
    \usepackage{amssymb}
    \usepackage{amsfonts}
    \usepackage{anyfontsize}
    \usepackage{bm}
    \pagestyle{empty}'

# The Image class represents an image that is generated from a latex equation expression.
class Image
  def self.generate_inline(equ_data, equ_id, handler)
    Image.new %($#{equ_data}$), equ_id, handler
  end

  def self.generate_block(equ_data, equ_id, handler)
    Image.new %($$#{equ_data}$$), equ_id, handler
  end

  def initialize(input, equ_id, handler)
    equ_id ||= %(stem-#{::Digest::MD5.hexdigest input})
    @filename = %(#{equ_id}.png)
    target_path = File.absolute_path handler.image_target_dir
    dir = Dir.mktmpdir
    tpth = File.join dir, @filename
    Dir.chdir(dir) do
      generate_png(input, tpth, handler.ppi)
      FileUtils.cp(tpth, target_path)
    end
  end

  def generate_png(input, pth, ppi)
    File.open('eq.tex', 'w') do |file|
      file.write("#{HEADER}\\begin{document} #{input}\\end{document} ")
    end
    _ = Open3.capture2('latex -interaction=batchmode eq.tex')
    stdout, = Open3.capture2("dvipng -o #{pth} -T tight -z9 -D #{ppi} -q --height --width eq.dvi")
    extract_dimensions_from_output(stdout)
  end

  def extract_dimensions_from_output(captured_stdout)
    @height = captured_stdout.scan(/height=-?(\d+)/)[0][0].to_i
    @width = captured_stdout.scan(/width=(\d+)/)[0][0].to_i
  end

  attr_reader :width
  attr_reader :height
  attr_reader :filename
end
