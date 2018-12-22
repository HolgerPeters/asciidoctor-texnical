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

class Image
  def self.generate_inline(equ_data, equ_id, handler)
    generate(%($#{equ_data}$), equ_id, handler)
  end

  def self.generate_block(equ_data, equ_id, handler)
    generate(%($$#{equ_data}$$), equ_id, handler)
  end

  def self.generate(input, equ_id, handler)
    width = 100
    height = 100

    equ_id ||= %(stem-#{::Digest::MD5.hexdigest input})
    img_filename = %(#{equ_id}.png)
    # img_filepth = ::File.join handler.image_output_dir, img_target_filename
    content = "#{HEADER}\\begin{document} #{input}\\end{document} "
    target_path = File.absolute_path handler.image_target_dir
    dir = Dir.mktmpdir
    tpth = File.join dir, img_filename
    stdout = ''
    Dir.chdir(dir) do
      File.open('eq.tex', 'w') { |file| file.write(content) }
      Open3.popen3('latex -interaction=batchmode eq.tex') do |_stdin, _stdout, _stderr, wait_thr|
        raise ValueError if wait_thr.value != 0
      end
      stdout, = Open3.capture2("dvipng -o #{tpth} -T tight -z9 -D 400 -q --height --width eq.dvi")
      FileUtils.cp(tpth, target_path)
    end

    img_target = ::File.join handler.image_target_dir, img_filename
    width, height = extract_dimensions_from_output(stdout)
    Image.new input, width, height, img_target
  end

  def self.extract_dimensions_from_output(captured_stdout)
    height = captured_stdout.scan(/height=-?(\d+)/)
    width = captured_stdout.scan(/width=(\d+)/)
    [width[0][0].to_i, height[0][0].to_i]
  end

  def initialize(input, width, height, img_target)
    @width = width
    @height = height
    @input = input
    @target_path = img_target
  end

  attr_reader :width
  attr_reader :height
  attr_reader :target_path

  def raw_data
    nil
  end
end
