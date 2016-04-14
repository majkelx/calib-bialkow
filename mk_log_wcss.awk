#!/usr/bin/env gawk -f

BEGIN {
if(ARGC!=2) {print "\nFITS header content extractor (ZK, ver. BIALKOW 2013-11-10)\n Usage: ./mklog-bialkow <fits_file>"
print " The program requires \"dfits\" from ESO eclipse package: http://www.eso.org/sci/software/eclipse/\n"; exit}

if(ARGV[1]!~ /.fits/) {print "File name with .fits extension expected !"; exit};

"file " ARGV[1] | getline ; if($0!~ /FITS/) {print ARGV[1]" is not FITS file !"; print $0; exit} ;

nn=gensub(".fits",".h","g",ARGV[1]); system("dfits " ARGV[1] " > " nn);  ARGV[1]=nn;
z="'"
}

$1~ /OBS-DATE/ {date_ut=gensub(z,"","g",$2)}
$1~ /EXPOSURE/ {expt=$2}
$1~ /UT/ {ut_s=gensub(z,"","g",$3)}
$1~ /DATA-TYP/ {data_type=gensub(z,"","g",$2)}
$1~ /FILTER/ {filter=gensub(z,"","g",$3); if(filter=="Ha") {if($4~ /narrow/) filter="Han"; if($4~ /wide/) filter="Haw" } } 
#$1~ /^RA/ {ra=$3}
#$1~ /^DEC/ {dec=$3}
#$1~ /AIRMASS/ {x=$3}
$1~ /OBJECT/ {object=$3$4}
$2~ /file/ {file=$3}
$1~ /GAIN/ {speed=$3}
$1~ /BIN / {bin=$3}
$1~ /CCDTEMP/ {tc=$3}
$1~ /OBSERVER/ {observer=$2}

END {
if(NR==0) exit
nd=split(date_ut,date_tab,"/");
nh=split(ut_s,ut_tab,":");
year_ut=sprintf("%4d",date_tab[3]);
month_ut=sprintf("%02d",date_tab[2]);
day_ut=sprintf("%02d",date_tab[1]);
hour_ut=sprintf("%02d",ut_tab[1]);
min_ut=sprintf("%02d",ut_tab[2]);
sec_ut=sprintf("%02d",ut_tab[3]);
temp=sprintf("%02d",ut_tab[3]);

dd=sprintf("%4d %02d %02d %02d %02d %02d",year_ut,month_ut,day_ut,hour_ut,min_ut,sec_ut);
("jday " dd) | getline jday

 
printf("%22s %4d %02d %02d  %02d %02d %02d %6.1f %3s %3s %7s %12s %15.6f %5.1f %4s\n", file, year_ut, month_ut, day_ut, hour_ut,min_ut, sec_ut, expt, speed, filter, data_type, object, jday, tc, observer) ;
system("rm " nn)
}

