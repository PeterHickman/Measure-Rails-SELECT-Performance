#!/usr/bin/env ruby
# encoding: UTF-8

def output_line(line)
  line.gsub!(/\s+/, ' ')
  if line.index('LOG:') == 0
    if line =~ /LOG:\sduration:.*statement:/
      line.gsub!(/LOG: duration: /,'(')
      line.gsub!(/ ms statement:/, ' ms)')
      puts line
    end
  end
end

text = ''

ARGF.each do |line|
  line.chomp!
  if line =~ /^\s+/
    text += line
  else
    output_line(text)
    text = line
  end
end
output_line(text)
