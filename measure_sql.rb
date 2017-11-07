#!/usr/bin/env ruby
# encoding: UTF-8

##
# Parse the development log and extract the SQL SELECT statements and make
# them generic and collect the timings to produce a summary.
#
# From this data you may be able to identify where additional indexed may
# improve performance or perhaps indicate where data should be cached by the
# application if the ORM is making unnecessary calls.
##

data = Hash.new

lines_found = 0
lines_skipped = 0

def clean_select(line)
  line = line.gsub('"','').
    gsub(/.\[.m/,'').       # Remove the ansi escape codes that the log adds
    gsub(/.\[..m/,'').      # Remove the ansi escape codes that the log adds
    gsub(/-?[0-9]+/,'x').   # Squish a run of digits
    gsub(/'[^']+'/, "'s'"). # Squish a run of characters
    gsub(/\[\[.*/,'')       # Later log files add the parameters to the report

  ##
  # Compresses (x,x,x,x...x) down to (x)
  ##
  while line =~ /\(x,\s*x/
    line = line.gsub(/\(x,\s*x/,'(x')
  end

  ##
  # same for ('s','s','s'...'s') down to ('s')
  ##
  while line.include?("('s','s'")
    line = line.gsub(/\('s','s'/,"('s'")
  end

  ##
  # We are not interested in the part between the SELECT and FROM
  ##
  from_at = line.index('FROM')
  line = "SELECT * #{line[from_at..-1]}"

  return line
end

ARGF.each do |line|
  next if line.include?('EXPLAIN')
  next if line.include?('CACHE')

  i = line.index('SELECT')
  if i
    lines_found += 1

    begin
      select = clean_select(line[i..-1])
      x1 = line.index('(')
      x2 = line.index(')')
      if x1 and x2
        ms = line[(x1+1)...x2].to_f

        unless data.has_key?(select)
          data[select] = {:count => 0, :ms => 0.0}
        end
        data[select][:count] += 1
        data[select][:ms] += ms
      end
    rescue Exception => e
      lines_skipped += 1
    end
  elsif line.include?('BEGIN') || line.include?('COMMIT') || line.include?('ROLLBACK')
    x1 = line.index('(')
    x2 = line.index(')')
    if x1 and x2
      key = "TRANSACTION BLOCK"
      data[key] = {:count => 0, :ms => 0.0} unless data.has_key?(key)

      ms = line[(x1+1)...x2].to_f

      data[key][:count] += 1 if line.include?('BEGIN')
      data[key][:ms] += ms
    end
  end
end

total_count = 0
total_ms = 0.0

puts "  Count   Total ms     Avg ms Query"
puts "------- ---------- ---------- #{"-" * data.keys.map{|k| k.size}.max}"
data.keys.sort.each do |key|
  puts "%7d %10.1f %10.3f %s" % [data[key][:count], data[key][:ms], data[key][:ms] / data[key][:count].to_f, key]

  total_count += data[key][:count]
  total_ms    += data[key][:ms]
end
puts "------- ---------- ---------- #{"-" * data.keys.map{|k| k.size}.max}"
puts "%7d %10.1f %10.3f" % [total_count, total_ms, total_ms / total_count.to_f]
puts
puts "Processed #{lines_found} SELECT lines, had to skip #{lines_skipped}"
