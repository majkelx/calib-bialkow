set terminal postscript color solid 15
set output "bias_16_interp.ps"
set title "BIAS_16 interpolation"
set xlabel "Time  JD - int(JD)  [d]"
set ylabel "diff.  BIAS   [ADU]"
unset key
plot 'night-bias-diff_16.data' u 2:3 w lp ps 2 pt 7 lt 1,'object_16_bias_interp.data' u 2:3 w p ps 1.5 pt 6 lt 3

