set terminal x11
set output "bias_2_interp.ps"
set title "BIAS_2 interpolation"
set xlabel "Time  JD - int(JD)  [d]"
set ylabel "diff.  BIAS   [ADU]"
unset key
plot 'object_2_bias_interp.data' u 2:3 w p ps 1.5 pt 6 lt 3
pause -1
