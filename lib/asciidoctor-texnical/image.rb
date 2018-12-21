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
    img_target_filename = %(#{equ_id}.png)
    # img_filepth = ::File.join handler.image_output_dir, img_target_filename
    content = "#{HEADER}\\begin{document} #{input}\\end{document} "
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        puts "Dir: #{dir}"
        File.open('eq.tex', 'w') { |file| file.write(content) }
        Open3.popen3('latex -interaction=batchmode eq.tex') do |_stdin, _stdout, _stderr, wait_thr|
          exit_status = wait_thr.value
          puts "Exit status: #{exit_status}"
        end
        Open3.popen3("dvipng -o #{img_target_filename} -T tight -z9 -D 400 eq.dvi") do |_stdin, _stdout, _stderr, wait_thr|
          exit_status = wait_thr.value
          puts "Exit status: #{exit_status}"
        end
        FileUtils.cp(img_target_filename, handler.image_output_dir)
      end
    end

    img_target = ::File.join handler.image_target_dir, img_target_filename unless handler.image_target_dir == '.'
    Image.new input, width, height, img_target
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
