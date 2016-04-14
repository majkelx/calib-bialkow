
#if !defined(__WORDS_H)

#define __WORDS_H

/*
#include"string.h"
*/

#define MAXNLIST 256
#define MAXNWORD 456

#define TOMANYLI  0
#define TOMANYWC  1

#define MORE  1
#define STOP  0

typedef char WordList[MAXNLIST][MAXNWORD+1] ;

int  lnphrs(char *line, WordList words);
int  lnwds(char *line, WordList words);
void warning(char wind);

int lnphrs(line, word)
 char *line ; WordList word ;
 {
 int ilist, iword, Ind=MORE ;
 for( ; *line==' ' ; line++);
 for(ilist=iword=0 ; *line ; iword=0, ilist++, Ind=MORE)
   {
   if(ilist==MAXNLIST) { warning(TOMANYLI); break; }
   while(Ind==MORE)
     {
     if(iword==MAXNWORD) { warning(TOMANYWC); break; }
     while(*line!=' ' && *line)
       {
       if(iword==MAXNWORD) break;
       word[ilist][iword++]=*line++ ;
       }
     for(Ind=STOP ; *line==' ' ; Ind++, line++);
     if(iword==MAXNWORD) { warning(TOMANYWC); break; }
     if(Ind==MORE) word[ilist][iword++]=' ' ;
     }
   word[ilist][iword]=0 ;
   }
 return(ilist);
 }

int lnwds(line, word)
 char *line ; WordList word ;
 {
 int ilist, iword ;
 for(ilist=0 ; *line ; ilist++)
   {
   if(ilist==MAXNLIST) { warning(TOMANYLI); break; }
   while(whitech(*line)) line++ ;
   for(iword=0 ; !whitech(*line) && *line ; )
     {
     if(iword==MAXNWORD)
       { warning(TOMANYWC);
       while(!whitech(*line) && *line) line++ ;
       break; }
     word[ilist][iword++]=*line++ ;
     }
   word[ilist][iword]=0 ;
/*   printf("\n %d <%s>", ilist, word[ilist]); */
   }
 return(ilist);
 }

void warning(wind)
 char wind ;
 {
 printf("\n Warning: ");
 switch(wind)
   {
   case(TOMANYLI): printf("Word list to long [max=%d]", MAXNLIST);
     break;
   case(TOMANYWC): printf("Word to long [max=%d]", MAXNWORD);
     break;
   }
 }

#endif
