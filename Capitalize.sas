/******************* URBAN INSTITUTE MACRO LIBRARY *********************
 
 Macro: Capitalize

 Description: Autocall macro to capitalize the first letter of a text string.
 
 Use: Function
 
 Author: Peter Tatian
 
***********************************************************************/

%macro Capitalize( 
  s    /** String var or value **/
  );

  /*************************** USAGE NOTES *****************************
   
   SAMPLE CALL: 
     %capitalize( "URBAN INSTITUTE" )
       returns string value "Urban institute"

  *********************************************************************/

  /*************************** UPDATE NOTES ****************************


  *********************************************************************/

  %***** ***** ***** MACRO SET UP ***** ***** *****;
   
    %local ;
    
    
  %***** ***** ***** ERROR CHECKS ***** ***** *****;



  %***** ***** ***** MACRO BODY ***** ***** *****;

  ( upcase( substr( (&s), 1, 1 ) ) || lowcase( substr( (&s), 2 ) ) )


  %***** ***** ***** CLEAN UP ***** ***** *****;

  
%mend Capitalize;

/** End Macro Definition **/


/************************ UNCOMMENT TO TEST ***************************

title "Capitalize:  SAS Macro";

** Autocall macros **;

filename uiautos "K:\Metro\PTatian\UISUG\Uiautos";
options sasautos=(uiautos sasautos);

options mprint symbolgen mlogic;

data _null_;

  length cstr $ 30;

  cstr = %capitalize( "URBAN INSTITUTE" );

  put cstr=;
  
run;

data _null_;

  length str cstr $ 30;

  input str $ 1 - 12;  

  cstr = %capitalize( str );
  
  put str= cstr=;
  
  cards;
            
a           
A           
Peter Tatian
peter tatian
PETER TATIAN
pEtEr TaTiAn
  ;

run;

/**********************************************************************/
