
report = <<EOF
Hello world ภาษาไทย
1
2
3
4


.
EOF

open("| lpr", "w") { |f| f.puts report }

