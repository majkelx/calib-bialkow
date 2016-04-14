
/*  TIMECAT.H for Unix C. Version of 28 Aug 1999 by G.Kopacki */

/* 23-06-98: freecat() added */
/* 23-06-98: comment lines in input catalogue */
/* 18-08-98: sreadcat() added */

#if !defined(__FILECAT_H)

#define __FILECAT_H

#include<stdio.h>
#include<stdlib.h>
/*
#include"string.h"
*/

/*
#if !defined(MaxNofChars)
#define MaxNofChars 256
#endif
*/

#if !defined(MaxNofNames)
#define MaxNofNames 66000
#endif

#define done() printf("  done.")

struct FileCat
  { int no ; double time[MaxNofNames], char *name[MaxNofNames] ; } ;

/* Function prototypes */

int  sreadcat(char *, struct FileCat *);
int  freadcat(char *, struct FileCat *);
void freecat(struct FileCat *);
char isfilename(char *);
char iscat(char *);

/* Function definitions */

int sreadcat(file, list)
char *file ; struct FileCat *list ;
 {
 int ilist=0 ;
 printf(" File catalogue reading (<string>)...");
 list->time[ilist]=0.0 ;
 if(!(list->name[ilist]=(char *)malloc(strlen(file)+1)))
   { printf("\n  Wrn: freadcat: Not enougth dynamic memory!\n");
   return(0); }
 strcopy((*list).name[ilist],file);
 ilist++ ;
 list->no=ilist ;
 if(!ilist)
   { printf("\n  Err: There is nothing in catalogue file \"%s\"!\n", file);
   return(0); }
 done(); printf("  (%d file(s))\n", ilist); return(ilist);
 }

int freadcat(file, list)
char *file ; struct FileCat *list ;
 {
 int ilist ;
 char temp[MaxNofChars], name[MaxNofChars], time[MaxNofChars] ;
 FILE *cat=fopen(file,"rt") ;
 printf(" File catalogue reading (%s)...", file);
 if(!iscat(file))
   { printf("\n Err: Invalid catalog name!\n"); return(0); }
 if(!cat)
   { printf("\n  Err: Catalogue file \"%s\" not open for reading!\n", file);
   return(0); }
 for(ilist=0 ; !feof(cat) ; ilist++)
   {
   if(ilist==MaxNofNames)
     { 
     printf("\n  Err: To many names in catalogue file \"%s\"!", file);
     return(0);
//     printf(" Break. [max=%d]", MaxNofNames); break ; 
     }
   do { getln(cat,temp); } while(*temp=='%');
   if(sscanf(temp,"%s%s",name,time)!=2)
     { break ; }
   if(!isfilename(name)) 
     { printf("\n  Wrn: Invalid file name! Break.\n"); break ; }
   if(!(list->name[ilist]=(char *)malloc(strlen(name)+1)))
     { printf("\n  Wrn: freadcat: Not enougth dynamic memory!\n");
     break ; }
   strcopy((*list).name[ilist],name);
   list->time[ilist]=atof(time) ;
   }
 fclose(cat);
 list->no=ilist ;
 if(!ilist)
   { printf("\n  Err: There is nothing in catalogue file \"%s\"!\n", file);
   return(0); }
 done(); printf("  (%d file(s))\n", ilist); return(ilist);
 }

void freecat(list)
struct FileCat *list ;
 {
 int ilist ;
 for(ilist=0 ; ilist<list->no ; ilist++)
   free(list->name[ilist]);
 }

char isfilename(str)
char *str ;
 {
 for( ; *str ; str++)
   if(whitech(*str)) return(0);
 return(1);
 }

char iscat(file)
char *file ;
 {
 int len=strlen(file) ;
 if(len<4) return(0);
 if(strcomp(file+len-4,".cat")) return(1);
 return(0);
 }

#endif
