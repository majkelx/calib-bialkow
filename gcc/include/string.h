
/* GKSTRING.H for GCC
   Version of 3 Apr 1997 by G.Kopacki */

/* 
   3 Apr 1997 : getstr() changed.
  14 Oct 1997 : fstrcomp() added.
  21 Apr 2000 : spstrip(), whitestrip(), whitelnstrip() corrected!
  20 Jun 2000 : strlen() declared when it is not known
   4 Jul 2000 : strcopy(line,0) is not correct! use strcopy(line,"");
   7 Sep 2000 : bugs in fstrcomp() corrected.
   6 May 2003 : strpcomp() and searchstr() added
  18 Aug 2003 : searchpstr() added 
  16 Feb 2006 : strncomp() added.
   3 Mar 2006 : strlen() removed completely
*/

#include<string.h>

#if !defined(__GKSTRING_H)

#define __GKSTRING_H

#include<stdio.h>
#include<stdlib.h>

#if !defined(MaxNofChars)
#define MaxNofChars 1024
#endif

char whitech(char);
char whitelnch(char);
//int  strlen(char *);
char strcomp(char *, char *);
char strncomp(char *, char *);
void strcopy(char *, char *);
void stradd(char *, char *);
void spstrip(char *, char *);
void whitestrip(char *);
void whitelnstrip(char *);
#if !defined(__dj_include_string_h_)
char getln(FILE *, char *);
#endif
char getstr(FILE *, char *);
void getext(char *, char *);
char tolnend(FILE *);
char isemptystr(char *);

char whitech(c)
char c ;
 { 
 return((c==' '||c=='\t')? 1 : 0);
 }

char whitelnch(c)
char c ;
 { 
 return((c==' '||c=='\t'||c=='\n')? 1 : 0);
 }

char getln(file, line)
FILE *file ; char *line ;
 {
 int i=0 ;
 for( ; (*line=getc(file))!='\n' && !feof(file) ; line++, i++)
   if(i==MaxNofChars)
     { printf("  Wrn: getln: line to big! Break.\n"); break ; }
 *line=0 ;
 if(feof(file)) return(0);
 return(1);
 }

char getstr(file, str)
FILE *file ; char *str ;
 {
 char c ;
 int i=1 ;
 for(c=getc(file) ; whitech(c) ; c=getc(file));
 *str=0 ;
 if(feof(file) || c=='\n') return(0);
 for(*str++=c ; !whitech((*str=getc(file))) && !feof(file) ; str++)
   {
   if(i==MaxNofChars)
     { printf("  Wrn: getstr: line to big! Break.\n"); break ; }
   if(*str=='\n') { break ; }
   }
 *str=0 ; return(1);
 }

void getext(file, ext)
char *file ; char *ext ;
 {
 int i ;
 for(i=0 ; *file ; file++, i++);
 for(file--, i-- ; i>=0 ; file--, i--)
   if(*file=='.') break ;
 *ext=0 ;
 if(*file=='.')
   {
   for(i++ ; (*ext++=*++file)!=0 ; i++);
   for(file--, i-- ; i>=0 ; file--, i--)
     if(*file=='.') { *file=0 ; break ; }
   }
 }

/*
#if !defined(__dj_include_string_h_)
int strlen(str)
char *str ;
 {
 int i ;
 for(i=0 ; *str++ ; i++);
 return(i);
 } 
#endif
*/

void strcopy(str, copy)
char *str ; char *copy ;
 {
 while((*str++=*copy++)!=0);
 }

void stradd(str, add)
char *str ; char *add ;
 {
 while(*str) str++ ;
 while((*str++=*add++)!=0);
 }

// strings have to be the same lenght
char strcomp(str1, str2)
char *str1 ; char *str2 ;
 {
 if(strlen(str1)!=strlen(str2)) return(0);
 for( ; *str1==*str2 ; str1++, str2++)
   if(!*str1) return(1);
 return(0);
 }

// strings do not have to be the same lenght
char strncomp(str1, str2)
char *str1 ; char *str2 ;
 {
 if(!*str1 || !*str2) return(0);
 for( ; *str1 && *str2 ; str1++, str2++)
   if(*str1!=*str2) return(0);
 return(1);
 }

char fstrcomp(str1, str2)
char *str1 ; char *str2 ;
 {
 if(!*str1 && !*str2) return(1);
 if(!*str1 || !*str2) return(0);
 for( ; *str1 && *str2 ; str1++, str2++)
   if(*str1!=*str2) break ;
 if(!*str1 || !*str2) return(1);
 return(0);
 }

void spstrip(str, strip)
char *str ; char *strip ;
 {
 for( ; *str==' ' ; str++);
 if(!*str) { *strip=0 ; return ; }
 for( ; (*strip=*str)!=0 ; strip++, str++);
 while(*--strip==' ');
 *++strip=0 ;
 }

void whitestrip(str)
char *str ;
 {
 int istr, itemp ;
 char *temp=(char *)malloc(strlen(str)+1) ;
 if(!temp) return ;
 for(istr=0 ; str[istr] && whitech(str[istr]) ; istr++);
 if(!str[istr]) { *str=0 ; return ; }
 for(itemp=0 ; str[istr] ; istr++, itemp++) temp[itemp]=str[istr] ;
 for(istr--, itemp-- ; whitech(str[istr]) && istr>=0 ; istr--, itemp--);
 temp[++itemp]=0 ;
 for(itemp=0 ; temp[itemp] ; itemp++) str[itemp]=temp[itemp] ;
 str[itemp]=0 ;
 free(temp);
 }

void whitelnstrip(str)
char *str ;
 {
 int istr, itemp ;
 char *temp=(char *)malloc(strlen(str)+1) ;
 if(!temp) return ;
 for(istr=0 ; whitelnch(str[istr]) ; istr++);
 if(!str[istr]) { *str=0 ; return ; }
 for(itemp=0 ; str[istr] ; istr++, itemp++) temp[itemp]=str[istr] ;
 for(istr--, itemp-- ; whitelnch(str[istr]) && istr>=0 ; istr--, itemp--);
 temp[++itemp]=0 ;
 for(itemp=0 ; temp[itemp] ; itemp++) str[itemp]=temp[itemp] ;
 str[itemp]=0 ;
 free(temp);
 }

char tolnend(Inp)
FILE *Inp ;
 {
 while(getc(Inp)!='\n') if(feof(Inp)) return(0);
 return(1);
 }

char isemptystr(str)
char *str ;
 {
 while(*str) if(!whitech(*str++)) return(0);
 return(1);
 }

char strpcomp(str, text) char *str, *text ;
 {
 if(strlen(str)>strlen(text)) return(0) ;
 while(*str)
   if(*str++!=*text++) return(0);
 return(1);
 }

int searchstr(text, str) char *text, *str ;
 {
 int ifind=0, lenofstr=strlen(str) ;
 if(lenofstr>strlen(text)) return(0);
 while(*text) 
   if(strpcomp(str,text)) { text+=lenofstr ; ifind++ ; }
   else text++ ;
 return(ifind);
 }

/* searchpstr() returns -1 if str was not found in text, 
   otherwise the index of the first letter after str. */
int searchpstr(text, str) char *text, *str ;
 {
 int idx=0, ifound=0, lenofstr=strlen(str) ;
 if(lenofstr>strlen(text)) return(-1);
 while(*text) 
   if(strpcomp(str,text)) { text+=lenofstr ; idx+=lenofstr, ifound=1 ; break ; }
   else { text++ ; idx++ ; }
 return(ifound?idx:-1);
 }

#endif
