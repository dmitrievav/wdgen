#!/usr/bin/env ruby
# -*- encoding: utf-8 -*-

# Classes and functions
def permutation a, size: nil, filter: nil, multi_times: false, verbose: false, debug: false

  template = <<-EOF
  def _permutation a, filter
    #Just as an example
    #{if multi_times
        '#it is multi_times'
      else
        '#it is not multi_times'
      end}
    total = 0
    matched = 0
    tmp = []
    ret = []
    dict = Hash.new(0)
    a.each {|i| dict[i] += 1}
  <% (1..n).each do |i| %>
    dict.each do |k, v|
    <% unless multi_times %>
      next if dict[k] < 1
      dict[k] -= 1
    <% end %>
      tmp << k
  <% end %>
  <% if n > 0 %>
      <%= 'total += 1' if verbose %>
      <%= 'if tmp.join =~ /\#{filter}/' if filter %>
        if block_given?
          yield tmp
        else
          ret << tmp.clone
        end
        <%= 'matched += 1' if verbose %>
      <% if filter and verbose %>
      else
        STDERR.print "\#{tmp.join} \\r"
      <% end %>
      <%= 'end' if filter %>
  <% end %>
  <% (1..n).each do |i| %>
    <% unless multi_times %>
      dict[k] += 1
    <% end %>
      tmp.delete_at(-1)
    end
  <% end %>
    <%= 'STDERR.puts "matched: \#{matched}"' if verbose %>
    <%= 'STDERR.puts "total: \#{total}"' if verbose %>
    return ret unless block_given?
  end
  EOF

  require 'erb'
  n = (size.nil?) ? a.length : size
  b = binding
  b.local_variable_set(:n, n)
  b.local_variable_set(:filter, filter)
  b.local_variable_set(:multi_times, multi_times)
  b.local_variable_set(:verbose, verbose)
  dyn_code = ERB.new(template).result(b)
  puts dyn_code.gsub(/\n\s*\n/m, "\n") if debug
  eval(dyn_code)

  if block_given?
    _permutation(a, filter) {|i| yield i}
  else
    return _permutation(a, filter)
  end
end

def usage
  puts "Usage #{$0} [-b] [-f regexp] [-n size] [-m] [-d] [-v] [str]"
  puts """
  -b - Benchmark
  -f - Regexp filter
  -n - Word size limit ( <= size )
  -v - Verbose
  -d - Debug
  -m - Any symbol can be used any times
  -az - Symbols 'abcdefghijklmnopqrstuvwxyz'
  -AZ - Symbols 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
  -09 - Digits '0123456789'

  Example:

  #{$0} abc
  #{$0} 01 -n 8 -m -f '^1{7,7}' -v
  #{$0} 01 -n 20 -m -f '1{18,19}$' -v -d
  #{$0} -az -m -n 4 -f 'well|done|ruby' -v

  for d in $(#{$0} -09 -m -n 2 -f '(0[1-9]|[1-2][0-9]|3[0-1])'); do
  for m in $(#{$0} -09 -m -n 2 -f '(0[1-9]|1[0-2])'); do
  for g in $(#{$0} -09 -m -n 4 -f '19([5-9][0-9])'); do
  echo $d$m$g; done; done; done
  """
  exit 0
end

# Options
filter = nil
size = nil
benchmark = false
verbose = false
debug = false
multi_times = false
dict = ""

# Main
trap("SIGINT") { exit! }

if __FILE__ == $0
  if ARGV.empty? or ARGV.include?("-h")
    ARGV.delete("-h")
    usage
  end
  if ARGV.include?("-v")
    ARGV.delete("-v")
    verbose = true
  end
  if ARGV.include?("-d")
    ARGV.delete("-d")
    debug = true
  end
  if ARGV.include?("-m")
    ARGV.delete("-m")
    multi_times = true
  end
  if ARGV.include?("-az")
    ARGV.delete("-az")
    dict << 'abcdefghijklmnopqrstuvwxyz'
  end
  if ARGV.include?("-AZ")
    ARGV.delete("-AZ")
    dict << 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
  end
  if ARGV.include?("-09")
    ARGV.delete("-09")
    dict << '0123456789'
  end
  if ARGV.include?("-f")
    filter = ARGV[ARGV.index("-f")+1]
    ARGV.delete_at(ARGV.index("-f")+1)
    ARGV.delete("-f")
  end
  if ARGV.include?("-n")
    size = (ARGV[ARGV.index("-n")+1]).to_i
    ARGV.delete_at(ARGV.index("-n")+1)
    ARGV.delete("-n")
  end
  if ARGV.include?("-b")
    ARGV.delete("-b")
    benchmark = true
  end

  if ARGV.length > 1
    usage
  end

  if benchmark
    require 'benchmark'
    a = (1..10).map {|i| i}
    c = 1000*1000
    i = 0
    Benchmark.bm do |bm|
      bm.report("1kk per ") { permutation(a, filter: filter ? '' : nil) { i += 1; break if i >= c }}
    end
  end

  dict << ARGV[0] if ARGV[0]
  a = dict.split("")
  permutation(a, size: size, filter: filter, multi_times: multi_times, verbose: verbose, debug: debug) { |i|
    i.each { |i| print i }
    puts
  }
  #puts "Without yield it is long feed back ..."
  #arr = permutation(a)
  #arr.each {|i| print i; puts}
end