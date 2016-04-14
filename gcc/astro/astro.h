
/* ASTRO.H by G.Kopacki. Version of 27 Sep 1999 */

#if !defined(__ASTRO_H)

 #define __ASTRO_H

 #if !defined(__MATH_H)
  #include<math.h>
 #endif

typedef struct { int h, m ; double s ; } AstroTime ;
typedef struct { int y, m ; double d ; } AstroDate ;

double timetod(AstroTime *atime)
 {
 return((atime->h+(atime->m+atime->s/60.)/60.)/24.);
 }

void hourtotime(double hour, AstroTime *atime)
 {
 char negative=0 ;
 double frac, integ ;
 if(hour<0.0) { negative++ ; hour=-hour ; }
 frac=modf(hour,&integ) ; atime->h=(int)integ ;
 frac=modf(60*frac,&integ) ; atime->m=(int)integ ;
 atime->s=60*frac ;
 if(negative) atime->h=-atime->h ;
 }

double JD(AstroDate *adate)
 {
 long int j ;
 double f, d_int ;
 f=modf(adate->d,&d_int)-0.5 ;
 j=367L*adate->y-
  7L*(adate->y+(adate->m+9L)/12L)/4L-
  3L*((adate->y+(adate->m-9L)/7L)/100L+1L)/4L+
  275L*adate->m/9L+1721029L ;
 if(f<0) { f+=1 ; j-- ; }
 if(adate->y<0) j+=2 ;
 return(j+f+d_int);
 }

double JDymd(int year, int month, double day)
 {
 long int j ;
 double f, d_int ;
 f=modf(day,&d_int)-0.5 ;
 j=367L*year-
  7L*(year+(month+9L)/12L)/4L-
  3L*((year+(month-9L)/7L)/100L+1L)/4L+
  275L*month/9L+1721029L ;
 if(f<0) { f+=1 ; j-- ; }
 if(year<0) j+=2 ;
 return(j+f+d_int);
 }

#if !defined(__TDB_H)

double intconv(x)
double x ;
 {
 short int sign=1 ;
 double xint ;
 if(x<0) { x=-x ; sign=-1 ;}
 if(modf(x,&xint)>=0.5) xint+=1. ;
 if(sign==-1) xint=-xint ;
 return(xint);
 }
 
#endif 

void JDtoDate(double jd, AstroDate *adate, AstroTime *atime)
 {
 int g, i, j ;
 double h ;
 jd+=0.5 ;
 h=jd-(long int)jd ;
 hourtotime(24*h,atime);
 jd-=0.5 ;
 jd=intconv(jd) ;
 g=(int)((int)((jd+68569)/36524.25)*3.0/4.0)-38 ;
 j=4*(jd+g+1401)+3 ;
 i=2+5*(int)((j%1461)/4.0) ;  
 adate->d=1+(int)((i%153)/5.0) ;
 adate->m=1+(2+i/153)%12 ;
 adate->y=j/1461-4716+(int)((14-adate->m)/12.0) ;
 }

void precession(epochs, epoche, rec, dec)
 double epochs, epoche, *rec, *dec ;
 {
 AstroDate d ;
 double jds, jde, ts, te, aa, bb, cc, rr, dd, x, y, t ;

 d.y=epochs ; d.m=d.d=0.0 ;
 jds=JD(&d) ; // jds=2433282.423 ;
 ts=(jds-2451545.0)/36525.0 ; 
 d.y=epoche ;
 jde=JD(&d) ; // jde=2444970.174 ;
 te=(jde-jds)/36525.0 ;
// printf(" %f %f\n", jds, ts);
// printf(" %f %f\n", jde, te);

 aa=(2306.218+1.397*ts)*te+0.302*te*te+0.018*te*te*te ;
 bb=aa+0.793*te*te ;
 cc=(2004.311-0.853*ts)*te-0.427*te*te-0.042*te*te*te ;
 aa/=3600.0 ; bb/=3600.0 ; cc/=3600.0 ;
// printf(" %f %f %f\n", aa, bb, cc);
 aa*=M_PI/180.0 ; bb/=15.0 ; cc*=M_PI/180.0 ;

 *rec*=M_PI*15.0/180.0 ; *dec*=M_PI/180.0 ;
 rr=*rec ; dd=*dec ;
 t=atan(fabs(sin(rr+aa)/(cos(cc)*cos(rr+aa)-tan(dd)*sin(cc)))) ;
 t*=180.0/(M_PI*15.0) ;
 x=sin(rr+aa) ;
 y=cos(cc)*cos(rr+aa)-tan(dd)*sin(cc) ;
// printf("xyt:  %.5f %.5f %.5f\n", x, y, t*15.0);
 if(x>0 && y>0) *rec=t ;
 if(x>0 && y<0) *rec=12.0-t ;
 if(x<0 && y>0) *rec=24.0-t ;
 if(x<0 && y<0) *rec=12+t ;
// printf("rb:  %.5f %.5f %.5f\n", *rec*15.0, bb*15.0, (*rec+bb)*15.0);
 *rec+=bb ;
 *dec=asin(sin(cc)*cos(dd)*cos(rr+aa)+cos(cc)*sin(dd)) ;
 *dec*=180.0/M_PI ;

 if(*rec>=24.0) *rec-=24.0 ;
 }

double GMST(AstroDate *adate, AstroTime *atime)
 {
 double d, t, gmst ;
 double f, i ;
 d=(JD(adate)-2451545.0)/36525.0 ;
// printf(" JD: %.3f  T=%.12f\n", JD(adate), d);
 gmst=8640184.812866*d+0.093104*d*d-0.0000062*d*d*d ;
 gmst/=86400.0 ;
 f=modf(gmst,&i) ;
// printf(" gmst: %.5f  %.5f %.5f\n", gmst, f, i);
 if(i<0) i-=1.0 ;
 gmst-=i ;
// printf(" gmst: %.5f  %.5f %.5f\n", gmst, f, i);
 gmst+=24110.54841/86400.0 ;
 t=(atime->h+(atime->m+atime->s/60.0)/60.0)/24.0 ;
 t*=1.00273790935 ;
 gmst+=t ;
 gmst*=24.0 ;
 if(gmst>=24.0) gmst-=24.0 ;
 return(gmst); /* GMST is given in hours and decimals */
 }

double HelCorr(double jd, double ra, double dec)
 {
 double gtor=M_PI/180.0 ;
 double EXC=0.016718, eps=23.441900*gtor ;
 int intM1 ;
 double yM1, yM, yv, yR, Hel, lsl ;
 ra*=gtor*15.0 ;
 dec*=gtor ;

 yM1=(2*M_PI*(jd-44238.5)/365.2422-3.762863*gtor)/(2*M_PI) ;
 intM1=yM1 ;
 yM=(yM1-intM1)*2*M_PI ;
 yv=yM+EXC*sin(yM) ;
 lsl=yv+282.596403*gtor ;
 yR=(1.0-EXC*EXC)/(1.0+EXC*cos(yv)) ;
 Hel=-0.0057755*(yR*cos(lsl)*cos(ra)*cos(dec)+
      yR*sin(lsl)*(sin(eps)*sin(dec)+
      cos(eps)*cos(dec)*sin(ra))) ;
 return(Hel);
 }


// 26 Jan 2003
double HelCorr1(double jd, double ra, double dec)
 {
 double gtor=M_PI/180.0 ;
 double eps=23.439291111*gtor ; // epoch 2000.0
 double S, T, L, M, Hel ;
 ra*=gtor*15.0 ;
 dec*=gtor ;
 T=(jd-2451545.0)/36525 ;
 L=280.46+36000.772*T ; 
 M=357.528+35999.05*T ; M*=gtor ;
 S=L+(1.915-0.0048*T)*sin(M)+0.02*sin(2*M) ; S*=gtor ;
 Hel=sin(dec)*sin(S)*sin(eps)+cos(dec)*cos(ra)*cos(S)+cos(dec)*sin(ra)*sin(S)*cos(eps) ;
 Hel*=0.00577553 ;
 return(-Hel);
 }

/* 
ra and dec from suncoo() valid from 1950 to 2050
*/

void suncoo(double jd, double *ra, double *dec)
 {
 double l, m, eps, lambda ;
 l=280.46+0.9856474*(jd-2451545.0) ;
 m=357.528+0.9856003*(jd-2451545.0) ;
 eps=23.439-0.0000004*(jd-2451545.0) ;
 m*=M_PI/180.0 ;
 lambda=l+1.915*sin(m)+0.02*sin(2*m) ;
 lambda*=M_PI/180.0 ;
 eps*=M_PI/180.0 ;
 *ra=atan2(cos(eps)*sin(lambda),cos(lambda)) ;
 *dec=asin(sin(eps)*sin(lambda)) ;
 while(*ra<0.0) *ra+=2*M_PI ;
 while(*ra>=2*M_PI) *ra-=2*M_PI ;
// printf(" ra= %.3f dec=%.3f [rad]\n", *ra, *dec);
 *ra*=180.0/M_PI ; 
 *ra/=15 ;
 *dec*=180.0/M_PI ;
 }

void mooncoo(double jd, double *ra, double *dec)
 {
 double t ;
 double s2r=M_PI/180.0 ; // /3600.0 ;
 double d2r=M_PI/180.0 ;
 double lambda, beta ;
 t=(jd-2451545.0)/36525.0 ;
// printf(" t = %.3f\n", t);
 lambda=218.32+481267.883*t ;
 lambda+=6.29*sin(s2r*(134.9+477198.85*t)) ;
 lambda-=1.27*sin(s2r*(259.2-413335.38*t)) ;
 lambda+=0.66*sin(s2r*(235.7+890534.23*t)) ;
 lambda+=0.21*sin(s2r*(269.9+954397.70*t)) ;
 lambda-=0.19*sin(s2r*(357.5+35999.05*t)) ;
 lambda-=0.11*sin(s2r*(186.6+966404.05*t)) ;
 beta=5.13*sin(s2r*(93.3+483202.03*t)) ;
 beta+=0.28*sin(s2r*(228.2+960400.87*t)) ;
 beta-=0.28*sin(s2r*(318.3+6003.18*t)) ;
 beta-=0.17*sin(s2r*(217.6-407332.2*t)) ;
 lambda*=d2r ;
 beta*=d2r ;
 *ra=atan2(0.9175*sin(lambda)-0.3978*tan(beta),cos(lambda)) ;
 *dec=asin(0.3978*cos(beta)*sin(lambda)+0.9175*sin(beta)) ;
 while(*ra<0.0) *ra+=2*M_PI ;
 while(*ra>=2*M_PI) *ra-=2*M_PI ;
// printf(" ra= %.3f dec=%.3f [rad]\n", *ra, *dec);
 *ra*=180.0/M_PI ; 
 *ra/=15 ;
 *dec*=180.0/M_PI ;
 }

#endif
