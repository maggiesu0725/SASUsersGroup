/******************* URBAN INSTITUTE MACRO LIBRARY *********************
 
 Macro: ListUnion

 Description: Autocall macro returns a union of items between
 two lists.  All duplicate items are removed.
 
 Use: Function
 
 Author: Peter Tatian
 
***********************************************************************/

%macro ListUnion(
  list1,           /* List of items #1 */
  list2,           /* List of items #2 */
  delim=%str( )    /* Delimiter for list (def. blank char) */
  );

  /*************************** USAGE NOTES *****************************
   
   SAMPLE CALL: 
     %ListUnion( A B C D, E F G )
       returns A B C D E F G

  *********************************************************************/

  /*************************** UPDATE NOTES ****************************


  *********************************************************************/

  %***** ***** ***** MACRO SET UP ***** ***** *****;
   
  %local ListUnion;
    
    
  %***** ***** ***** ERROR CHECKS ***** ***** *****;



  %***** ***** ***** MACRO BODY ***** ***** *****;

  %let ListUnion = %ListNoDup( %unquote( &list1&delim&list2 ), delim=&delim );
  &ListUnion

  %exit:


  %***** ***** ***** CLEAN UP ***** ***** *****;

%mend ListUnion;


/************************ UNCOMMENT TO TEST ***************************

**options mprint symbolgen mlogic;

** Autocall macros **;

filename automac "K:\Metro\PTatian\UISUG\Uiautos\";
options sasautos=(automac sasautos);

%let list1 = A B C D;
%let list2 = E F G;
%let union = [%ListUnion( &list1, &list2 )];
%put _user_;

%let list1 = A B C D;
%let list2 = A B E F D G;
%let union = [%ListUnion( &list1, &list2 )];
%put _user_;

/**********************************************************************/

