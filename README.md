# wdgen
Word generator.  
This is example of Ruby meta programming.  
Script dynamically creates nested loops to avoid recursion approach.

<pre><code>
Usage ./wdgen.rb [-b] [-f regexp] [-n size] [-m] [-d] [-v] [str]

  -b - Benchmark
  -f - Regexp filter
  -n - Word size limit
  -v - Verbose
  -d - Debug
  -m - Any symbol can be used any times
  -az - Symbols 'abcdefghijklmnopqrstuvwxyz'
  -AZ - Symbols 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
  -09 - Digits '0123456789'

  Example:

  ./wdgen.rb abc
  ./wdgen.rb 01 -n 8 -m -f '^1{7,7}' -v
  ./wdgen.rb 01 -n 20 -m -f '1{18,19}$' -v -d
  ./wdgen.rb -az -m -n 4 -f 'well|done|ruby' -v

  for d in $(./wdgen.rb -09 -m -n 2 -f '(0[1-9]|[1-2][0-9]|3[0-1])'); do
  for m in $(./wdgen.rb -09 -m -n 2 -f '(0[1-9]|1[0-2])'); do
  for g in $(./wdgen.rb -09 -m -n 4 -f '19([5-9][0-9])'); do
  echo $d$m$g; done; done; done
</code></pre>
