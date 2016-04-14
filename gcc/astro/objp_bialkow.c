#include<stdio.h>
#include<stdlib.h>
#include<math.h>
//#include<dos.h>
#include<time.h>
#include"../include/string.h"
#include"../include/version.h"
#include"astro.h"

void usage(void)
 {
 version("OBJP_BIALKOW","17 Dec 2013");
 printf(" Usage:\n");
 printf(" objp_bialkow d=<year>,<month>,<day> t=<hour>:<minute>:<second> c=<RA>,<DEC>\n");
 printf(" Time is set as UTC\n");
 printf(" Object position for epoch 2000.0 expressed as: RA [h:m:s], DEC [d:am:as]\n");
 printf("\n");
 printf(" Output format:\n");
// printf(" Azimuth [-180,180] deg; 0 deg -- South, -90 deg -- East.\n");
 printf(" JD [d]  LMST [h:m:s]  HA [h:m:s]  Dec [deg:am:as]  Alt [deg]   Airmass\n");
 }

#define ERR_OPT 0
#define  OK_OPT 1
#define NOT_OPT 2

double dtor=M_PI/180.0 ;

double obslong=1.110537 ; /* Bialkow longitude [hour] */
double obslat=51.474167 ; /* Bialkow latitude [deg] */

static AstroTime atime ;
static AstroDate adate ;
static char date_man, time_man, object_man ;  

double obj_ra, obj_dec ;

enum { wd_date, wd_time, wd_obj, NofKeyWords } ;	    
static char *KeyWord[] = { "d", "t", "c" } ;

char setoption(char *option)
 {
 int i, y, m, d, s, rah, ram, ras, decd, decm, decs ;
 char key[50], value[50] ;
// if(*option!='-' && *option!='/') return(NOT_OPT);
// option++ ;
 for(i=0 ; *option && *option!='=' ; )
   key[i++]=*option++ ;
 key[i]=0 ;
 option++ ;
 for(i=0 ; *option ; ) value[i++]=*option++ ;
 value[i]=0 ;
 if(!*key) 
   { printf(" Wrn: Key word is empty!\n"); return(ERR_OPT) ; }
 for(i=0 ; i<NofKeyWords ; i++)
   if(strcomp(key,KeyWord[i])) break ;
 if(i==NofKeyWords)
   { printf(" Wrn: Unknown key word \"%s\"!\n", key); return(ERR_OPT); }
 switch(i)
   {
   case wd_date :
     if(sscanf(value,"%d,%d,%d",&y,&m,&d)!=3)
       if(sscanf(value,"%d:%d:%d",&y,&m,&d)!=3)
         if(sscanf(value,"%d-%d-%d",&y,&m,&d)!=3)
           { printf(" Date reading error!\n"); return(ERR_OPT) ; }
     adate.y=y ; adate.m=m ; adate.d=d ;  
     date_man=1 ;  
     break ;
   case wd_time :
     if(sscanf(value,"%d,%d,%d",&y,&m,&s)!=3)
       if(sscanf(value,"%d:%d:%d",&y,&m,&s)!=3)
         { printf(" Time reading error!\n"); return(ERR_OPT) ; }
     atime.h=y ; atime.m=m ; atime.s=s ;  
     time_man=1 ;  
     break ;    
   case wd_obj :
     if(sscanf(value,"%d:%d:%d,%d:%d:%d",&rah,&ram,&ras,&decd,&decm,&decs)!=6)
       { printf(" Object position reading error!\n"); return(ERR_OPT) ; }
     obj_ra=rah+(ram+ras/60.0)/60.0 ;
     if(decd<0.0)
       obj_dec=decd-(decm+decs/60.0)/60.0 ;
     else
       obj_dec=decd+(decm+decs/60.0)/60.0 ;
     object_man=1 ;  
     break ;    
   }
 return(OK_OPT);
 }

int main(int narg, char **arg)
 {
 int i, phase ;
 double epoch, currepoch, jd ;
 double gmst, ra, dec, ha, alt, azimuth, airm=0.0 ;
 double dist ;

 if(narg!=4) { usage(); return(0); }
 for(i=1, arg++ ; i<narg ; i++)
   if(setoption(*arg++)==ERR_OPT) return(0);

// printf(" Observatory coordinates: long=%.4f lat=%.4f\n", obslong, obslat);
 
 ra=obj_ra ; dec=obj_dec ; epoch=2000.0 ;
// printf(" Object coordinates: ra=%.4f dec=%.4f epoch=%.1f\n", ra, dec, epoch);
 
// printf(" Date: %02d:%02d:%02.0f  ",adate.y,adate.m,adate.d);
// printf(" Time: %02d:%02d:%02.0f  ",atime.h,atime.m,atime.s);
 
 jd=JDymd(adate.y,adate.m,adate.d+(atime.h+(atime.m+atime.s/60.0)/60.0)/24.0) ;
 printf(" %.6f ", jd);

 currepoch=adate.y+(adate.m+adate.d/30.0)/12.0 ;
 precession(epoch,currepoch,&ra,&dec);
// printf(" Object coordinates: ra=%.4f dec=%.4f epoch=%.1f\n", ra, dec, currepoch); 
 
 obj_ra=ra*15*dtor ; obj_dec=dec*dtor ;

 gmst=GMST(&adate,&atime)+obslong ;
 while(gmst<0.0) gmst+=24.0 ;
 while(gmst>=24.0) gmst-=24.0 ;
 hourtotime(gmst,&atime);
 printf(" %02d:%02d:%02.0f",atime.h,atime.m,atime.s);

// printf("               HA          Dec      Azim     Alt   Airmass\n");
// printf(" OBJECT :  ");

 ha=gmst-ra ;
 while(ha<0.0) ha+=24.0 ;
 while(ha>=24.0) ha-=24.0 ;
 hourtotime(ha,&atime);
 printf(" %2d:%02d:%02.0f ",atime.h,atime.m,atime.s);

 hourtotime(dec,&atime);
 printf("%3d:%02d:%02.0f ",atime.h,atime.m,atime.s);
 
 obslat*=dtor ;
 dec*=dtor ;
 ha*=15.0*dtor ;
 ;
 alt=sin(obslat)*sin(dec)+cos(obslat)*cos(dec)*cos(ha) ;
 alt=asin(alt) ;
 ;
 azimuth=atan2(sin(ha),-tan(dec)*cos(obslat)+sin(obslat)*cos(ha)) ;

 if(alt>0.1) airm=1/(cos((M_PI/2.0)-alt)+0.025*exp(-11.0*cos((M_PI/2.0)-alt)));
 alt/=dtor ;
 azimuth/=dtor ;
// printf(" %6.1f   %6.2f  %6.4f\n", azimuth, alt, airm );
 printf(" %6.2f  %6.4f\n", alt, airm );

 return(1);
 }
