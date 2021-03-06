/******************* URBAN INSTITUTE MACRO LIBRARY *********************
 
 Macro: Freq_table

 Description: SAS autocall macro to create a data set containing frequency 
 distributions for a set of variables from an input data set.  
 Each value of a variable in the input data set is a single obs
 in the output data set.  The output data set contains the
 following variables:

   Variable - The name of the variable
   Value    - The raw value of the variable (nb: this is a char var)
   FmtValue - The formatted value of the variable.  If variable is
               unformatted, then this is the same as Value.
   Frequency - Frequency of the value for the variable
   Percent   - Percentage of value for the variable
   CumFrequency - Cumm. frequency of the value for the variable
   CumPercent   - Cumm. percentage of value for the variable
 
 Use: Open code
 
 Author: Peter Tatian
 
***********************************************************************/

%macro Freq_table( 
    in_data = ,    /** Input data set **/
    var_list = ,   /** List of variables for frequencies **/
    formats = ,    /** Format assignments for variables (optional, Formats saved in data set will be used if no formats specified in macro.) **/
    out_data = ,   /** Output data set **/
    missing = Y,   /** Include missing values in freqencies (Y/N) **/ 
    print = N,     /** Print freq tables in listing output (Y/N) **/
    mprint = N     /** Print resolved macro code in LOG **/
  );

  /*************************** USAGE NOTES *****************************
   
   SAMPLE CALL: 
     %Freq_table( 
       in_data = Test, 
       var_list = q1 q2 q3, 
       formats = q1 q1f. q3 $q3f.,
       out_data = Test_freq_table,
       missing = Y
       )

    The following named parameters must be supplied:
        in_data   = Input data set
        var_list  = List of variables to include in freqs.
        out_data  = Output data set
   
    The following parameters are optional:
        formats   = Format specifications for variables
                    (Formats saved in data set will be used
                     if no formats specified in macro.)
        missing   = Include missing values in freqs (Y/N, def. Y)
        print     = Print freq tables in listing output (Y/N, def. N)
  *********************************************************************/

  /*************************** UPDATE NOTES ****************************

   11/26/02  Peter A. Tatian
   09/02/04  Added check for empty variable list.  Macro exits if VAR_LIST
             is blank.
   06/24/06  Fixed problems introduced with switch to SAS 9.
             Added MPRINT= option.
   12/11/06  Now supports both SAS versions 8 & 9.
             Changed length of output data set var. VARIABLE to 32 
             to be compatible with Proc Contents data set.
   02/23/11  PAT  Added declaration for local macro vars.

  *********************************************************************/

  %***** ***** ***** MACRO SET UP ***** ***** *****;
   
  %local SAS_VER namelist i var;

  %Note_mput( macro=Freq_table, msg=Macro starting. )
  
  %** Save current MPRINT setting and reset based on MPRINT= parameter **;

  %Push_option( mprint, quiet=y )

  %if %mparam_is_yes( &mprint ) %then %do;
    options mprint;
  %end;
  %else %do;
    options nomprint;
  %end;
  
    
  %***** ***** ***** ERROR CHECKS ***** ***** *****;

  %** Check compatible SAS version **;

  %let SAS_VER = %sysfunc( int( &SYSVER ) );
  
  %if &SAS_VER ~= 8 and &SAS_VER ~= 9 %then %do;
    %err_mput( macro=Freq_table, msg=Macro does not support this version of SAS. )
    %goto exit;
  %end;
  
  %** Check that variable list is not empty **;

  %if %length( &var_list ) = 0 %then %do;
    %Note_mput( macro=Freq_table, msg=Variable list passed to macro FREQ_TABLE is empty. )
    %goto exit;
  %end;


  %***** ***** ***** MACRO BODY ***** ***** *****;

  %if %mparam_is_no( &print ) %then %do;
    ods listing close;
  %end;
  
  %if &SAS_VER = 9 %then %do;
    ods output onewayfreqs=_Freq_table;
    %let namelist = _Freq_table;
  %end;
  %else %if &SAS_VER = 8 %then %do;
    ods output onewayfreqs(match_all=namelist)=_Freq_table;
  %end;

  proc freq data=&in_data;
    tables &var_list 
      %if %mparam_is_yes( &missing ) %then %do; 
        /missing
      %end;
    ;
    %if %length( &formats ) > 0 %then %do;
      format &formats;
    %end;

  run;

  ods output close;

  %if %mparam_is_no( &print ) %then %do;
    ods listing;
  %end;

  data &out_data;

    set &namelist;

    length Variable $ 32 Value $ 40 FmtValue $ 80;
    
    %** Initialize loop counter and read first var from list **;

    %let i = 1;
    %let var = %scan( &var_list, &i );
    
    %** Execute loop until end of list is reached **;
    
    %do %while( %length( &var ) > 0 );

      %if &SAS_VER = 9 %then %do;
        %** SAS ver. 9 code **;
        Variable = substr( Table, 7 );
        if vname( &var ) = Variable then do;
          Value = trim( &var );
          FmtValue = trim( f_&var );
        end;
      %end;
      %else %if &SAS_VER = 8 %then %do;
        %** SAS ver. 8 code **;
        Variable = Table;
        if vname( &var ) = Variable then do;
          Value = trim( &var );
          FmtValue = trim( f_&var );
        end;
      %end;
    
      %** Increment list pointer and read next var name **;

      %let i = %eval( &i + 1 );
      %let var = %scan( &var_list, &i );
      
    %end;
    
    label 
      Value = 'Value of variable'
      FmtValue = 'Formatted value of variable'
      Table = 'Variable name';

    keep CumFrequency CumPercent FmtValue Frequency Percent Value Variable;

  run;

  ** Delete temporary data sets **;

  proc datasets library=work memtype=(data) nolist nowarn;
    delete &namelist;
  quit;

  %exit:


  %***** ***** ***** CLEAN UP ***** ***** *****;

  %** Restore system options **;

  %Pop_option( mprint, quiet=y )
  

  %Note_mput( macro=Freq_table, msg=Macro exiting. )

%mend Freq_table;



/************************ UNCOMMENT TO TEST ***************************

title 'Freq_table:  UISUG Macro Library';

options nocenter;
options mprint symbolgen nomlogic;

** Locations of SAS autocall macro libraries **;

*filename uiautos  "Uiautos:";
*filename uiautos  "C:\Projects\UISUG\Uiautos";
filename uiautos  "K:\Metro\Ptatian\UISUG\Uiautos";
options sasautos=(uiautos sasautos);

%put _all_;

data Test;

  input Id Q1 Q2 Q3 $;
  
  if q3 = "." then q3 = "";

  cards;
  1 1 2 a
  2 2 5 b
  3 1 3 c
  4 3 4 d
  5 2 5 e
  6 . 3 .
  ;

run;

proc format;
  value Q1f
    1 = 'Yes'
    2 = 'No'
    3 = 'Maybe'
    . = 'Missing';
  value $q3f
    a = 'Value A'
    b = 'Value B'
    c = 'Value C'
    d = 'Value D';

run;

%Freq_table( 
  in_data = Test, 
  var_list = q1 q2 q3, 
  formats = q1 q1f. q3 $q3f.,
  out_data = Test_freq_table,
  missing = Y,
  print = Y,
  mprint = Y
  )

proc contents data=Test_freq_table;

proc print data=Test_freq_table noobs;
  var variable value fmtvalue frequency percent cumfrequency cumpercent;
  title2 'File=Test_freq_table';

run;

/**********************************************************************/

