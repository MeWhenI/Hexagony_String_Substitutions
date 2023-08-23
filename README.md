# Hexagony String Substitutions

This code generates a Hexagony program which loops over its arguments, optionally appending a string to the beginning and/or end of each before performing a series of string subsitutions and outputting the result optionally followed by a newline. The generated Hexagony program will terminate with a divide-by-zero error.

`append_front` and `append_end` are strings that will be appended to the front and end of each string, respectively, before performing performing substitutions. Either can be left as an empty string to append nothing in its place.

`substitutions` is an array of string pairs in the form `[pattern, replacement]` where all instances of `pattern` will be replaced with `replacement`.

`add_newlines` is a boolean which determines whether the Hexagony program prints a newline after each argument.

`minify_output` is a boolean which determines whether extra whitespace and no-ops are removed.

Created 2023 by https://github.com/MeWhenI
