# This code generates a Hexagony program which loops over its arguments,
# optionally appending a string to the beginning and/or end of each before
# performing a series of string subsitutions and outputting the result
# optionally followed by a newline. The generated Hexagony program will
# terminate with a divide-by-zero error.
#
# `prepend` and `append` are strings that will be appended to the
# front and end of each string, respectively, before performing
# performing substitutions. Either can be left as an empty string to append
# nothing in its place.
#
# `substitutions` is an array of string pairs in the form
# [`pattern`, `replacement`] where all instances of `pattern` will be
# replaced with `replacement`.
#
# `add_newlines` is a boolean which determines whether the Hexagony program
# prints a newline after each argument.
#
# `minify_output` is a boolean which determines whether extra whitespace and
# no-ops are removed.
#
# Created 2023 by https://github.com/MeWhenI

prepend = "<"
append = ">"
substitutions = [
 ["x", "y"],
 ["hello", "goodbye"],
 ["Bad word", ""],
 ["0", "00"],
 ["<1","2"],
]
add_newlines = true
minify_output = false

if substitutions.any?{|pair| pair.class != Array || pair.count != 2 || pair.any?{|s| s.class != String }}
 abort "`substitutions` array is the wrong shape"
end

to_hxg_literal = -> n {
 abort "Something broke with int literal generation, idk" if n < 0

 # Special cases
 return "\u0001(" if n==0
 return "\u0008)" if n==9
 return "Z)" if n==91
 return "a(" if n==96
 return "\u0008)#{n%10}" if n>91 && n<96
 return "z)" if n==123
 return "\u007F(" if n==126
 
 is_valid_char = -> n { 
  is_hexagony_reserved = -> n { "\t\n\v\f\r !\"\#$%&'()*+,-./:;<=>?@[\\]^_`{|}~0123456789".chars.map(&:ord).include? n }
  is_valid_unicode = -> n { n > 0 && n <= 0x10ffff && !(n >= 0xd800 && n < 0xe000)}
  !is_hexagony_reserved[n] && is_valid_unicode[n]
 }
 extra_digits = []
 while !is_valid_char[n]
  extra_digits << n % 10
  n /= 10
 end
 return "" << n << extra_digits.reverse.join
}
encode_str = -> str { str.bytes.each_with_index.sum{|b, idx| b * 256 ** idx }}
generate_main_path = -> prepend, append {
 f = encode_str[prepend]
 e = encode_str[append]

 f_lit = to_hxg_literal[f]
 e_lit = to_hxg_literal[e]
 f_size_lit = f==0 ? 0 : to_hxg_literal[256**(Math::log(f,256).to_i+1)]
 path = 
  f != 0 && e != 0 ? "}#{e_lit}'*'+{#{f_size_lit}'*{#{f_lit}'+" :
  f != 0 ? "#{f_size_lit}'*}#{f_lit}\"+" :
  e != 0 ? "}#{e_lit}'*'+='x&" :
  "\""

 path += "\"\"'"

 substitutions.each{|pattern, replacement|
  p_lit = to_hxg_literal[encode_str[pattern]]
  r_lit = to_hxg_literal[encode_str[replacement]]
  path += "#{p_lit}'#{r_lit}]"
 }

 path += "}{="

 path.reverse
}
path_capacity = -> len { len**2*3-len*26+16 }
get_hexagon_len = -> path_size { (13..).find{|len| path_capacity[len] >= path_size }}
fill_to_len = -> front, back, len { front + ?. * (len - front.size - back.size) + back}
fill_all_to_lens = -> lines, sizes { lines.zip(sizes).map{|(front, back), len| fill_to_len[front, back, len] }}

main_path = generate_main_path[prepend, append]

hexagon_len = get_hexagon_len[main_path.size]

main_path += ?. * (path_capacity[hexagon_len] - main_path.size)

top_lines = fill_all_to_lens[ [
 ["''\u0001$/{,\\>)':","$"],
 [">='&=/.\\<>'*'","\\"],
 ["\\*'\u0100{{{&__'=+","<>"],
 ["='\\/'\u0100{}<>-<$'",".\u0001"],
 [".=*\\>.*='.&'/","\\['"],
 ["=\"\\<>\"'x&\\\"\"=\u0001$/'-",""],
 ["'&\\$_$~|.\\{\u0100'*$|/$=",""],
],hexagon_len.upto(hexagon_len+6)]

bottom_lines = fill_all_to_lens[ [
 ["\\>/&x'&x=>$\"\">/'6\u0019{;<.>\u0001(",""],
 ["/}{\u0001'$>-<>}{\u0100<>:='&$>|$\\",""],
 ["/.>\"\"\\'&_'=*'/#{add_newlines ? "<\u00010;$<" : "....\\"}=/\\",""],
 ["{&~x</x&\"x&}=%}%\"-='x&",""],
 ["\"\\>\"=/%}*'&x{:'&x{+':",""],
 ["<:<\"$/+='x&}x&\"*{%'+",""],
 ["_&~\"*\"&x}&~x\"&x=}&x",""],
],(hexagon_len*2-1).downto(hexagon_len*2-7)]

7.upto(hexagon_len-2){|line_no|
 top_size = hexagon_len + line_no - 1
 top_lines << "\\" + main_path[...top_size]
 main_path = main_path[top_size..]
 
 bottom_size = hexagon_len * 2 - line_no - 1
 bottom_lines << main_path[...bottom_size]
 main_path = main_path[bottom_size..]
}

lines = top_lines + bottom_lines

if minify_output
 out = lines.join
 h=hexagon_len-1
 needed_ops = h**2*3-h*3+2
 out =~ /(.{#{needed_ops},}?)\.*$/
 print $1
else
 lines << ?. * hexagon_len
 print lines.map{|line| ?\s * (hexagon_len * 2 - 1 - line.size) + (line).chars.join(?\s) }.join ?\n
end
