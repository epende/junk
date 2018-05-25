gnuplot -e 'set terminal png; plot "~/temp1.txt" title "outside" with lines, "~/temp2.txt" title "inside" with lines' > graph.png
