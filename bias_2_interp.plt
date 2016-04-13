set terminal postscript color solid 15
set output "bias_2_interp.ps"
set title "BIAS_2 interpolation"
set xlabel "Time  JD - int(JD)  [d]"
set ylabel "diff.  BIAS   [ADU]"
unset key
plot 'night-bias-diff_2.data' u 2:3 w lp ps 2 pt 7 lt 1,'object_2_bias_interp.data' u 2:3 w p ps 1.5 pt 6 lt 3

