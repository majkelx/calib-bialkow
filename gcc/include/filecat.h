
/*  FILECAT.H for Unix C. Version of 3 Jul 1996 by G.Kopacki */

/* 23-06-98: freecat() added */
/* 23-06-98: comment lines in input catalogue */
/* 18-08-98: sreadcat() added */
/* 13-09-99: firststr() added */
/* 13-09-99: freadcat() updated */
/* 17-08-00: PairCat, freadpcat(), freepcat() added */

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

#undef done
#define done() printf(" ok")

struct FileCat { int no ; char *name[MaxNofNames] ; } ;
struct PairCat
  { int no ; char *fname[MaxNofNames], *sname[MaxNofNames] ; } ;

/* Function prototypes */

int  sreadcat(char *, struct FileCat *);
int  freadcat(char *, struct FileCat *);
void freecat(struct FileCat *);
int  freadpcat(char *, struct PairCat *);
void freepcat(struct PairCat *);
char isfilename(char *);
char iscat(char *);

/* Function definitions */

int sreadcat(file, list)
char *file ; struct FileCat *list ;
 {
 int ilist=0 ;
 printf(" File catalogue reading (<string>)...");
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

void firststr(str)
char *str ;
 {
 for( ; *str ; str++)
   if(whitech(*str)) break ;
 *str=0 ;  
 }

int freadcat(file, list)
char *file ; struct FileCat *list ;
 {
 int ilist ;
 char temp[MaxNofChars] ;
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
   whitestrip(temp); firststr(temp);
   if(!isfilename(temp)) 
     { printf("\n  Wrn: Invalid file name! Break.\n"); break ; }
   if(strcomp(temp,"")) break ;
   if(!(list->name[ilist]=(char *)malloc(strlen(temp)+1)))
     { printf("\n  Wrn: freadcat: Not enougth dynamic memory!\n");
     break ; }
   strcopy((*list).name[ilist],temp);
   }
 fclose(cat);
 list->no=ilist ;
 if(!ilist)
   { printf("\n  Err: There is nothing in catalogue file \"%s\"!\n", file);
   return(0); }
 done(); printf("  (%d file(s))\n", ilist); return(ilist);
 }

int freadpcat(file, list)
char *file ; struct PairCat *list ;
 {
 int ilist ;
 char temp[MaxNofChars], ftemp[MaxNofChars], stemp[MaxNofChars] ;
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
     { printf("\n  Wrn: To many names in catalogue file \"%s\"!", file);
     printf(" Break. [max=%d]", MaxNofNames); break ; }
   do { getln(cat,temp); } while(*temp=='%');
   whitestrip(temp);
   if(strcomp(temp,"")) break ;
   if(sscanf(temp,"%s%s",ftemp,stemp)!=2)
     { printf("\n  Wrn: Scanning fault! Break.\n"); break ; }
   if(!isfilename(ftemp) || !isfilename(stemp)) 
     { printf("\n  Wrn: Invalid file name! Break.\n"); break ; }
   if(!(list->fname[ilist]=(char *)malloc(strlen(ftemp)+1)))
     { printf("\n  Wrn: freadcat: Not enougth dynamic memory!\n");
     break ; }
   strcopy((*list).fname[ilist],ftemp);
   if(!(list->sname[ilist]=(char *)malloc(strlen(stemp)+1)))
     { printf("\n  Wrn: freadcat: Not enougth dynamic memory!\n");
     break ; }
   strcopy((*list).sname[ilist],stemp);
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

void freepcat(list)
struct PairCat *list ;
 {
 int ilist ;
 for(ilist=0 ; ilist<list->no ; ilist++)
   {
   free(list->fname[ilist]);
   free(list->sname[ilist]);
   }
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
