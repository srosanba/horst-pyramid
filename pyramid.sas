options mprint;

%let path = H:\GitHub\srosanba\pyramid\horst-pyramid;
%*let path = /folders/myfolders/horst-pyramid;


%macro pyramid(goal=);

   data _null_;
      today = today();
      call symputx('today',put(today,yymmdd10.));
   run;

   proc format;
      value pyr10c
         1 = "9"
         2 = "10a"
         3 = "10b"
         4 = "10c"
         ;
      value pyr10d
         1 = "10a"
         2 = "10b"
         3 = "10c"
         4 = "10d"
         ;
      value pyr11a
         1 = "10b"
         2 = "10c"
         3 = "10d"
         4 = "11a"
         ;
      value pyr11b
         1 = "10c"
         2 = "10d"
         3 = "11a"
         4 = "11b"
         ;
      value pyr11c
         1 = "10d"
         2 = "11a"
         3 = "11b"
         4 = "11c"
         ;
      value pyr11d
         1 = "11a"
         2 = "11b"
         3 = "11c"
         4 = "11d"
         ;
      value pyr12a
         1 = "11b"
         2 = "11c"
         3 = "11d"
         4 = "12a"
         ;
   run;


   *--- generate pyramid outline ---;
   data outline;
      y = 1;
      do xo = -3.5 to 3.5;
         output;
      end;
      y = 2;
      do xo = -1.5 to 1.5;
         output;
      end;
      y = 3;
      do xo = -0.5 to 0.5;
         output;
      end;
      y = 4;
      xo = 0;
      output;
      format y pyr&goal..;
   run;


   *--- import tick list ---;
   proc import 
         datafile="&path/ticks.csv"
         out=tickimport
         dbms=csv
         replace
         ;
   run;


   *-- count ticks at each grade ---;
   proc sql;
      create   table grades as
      select   distinct y
      from     outline
      ;
      create   table tickplot0 as
      select   y
      from     tickimport as ti
               inner join grades as g
               on ti.grade = put(g.y,pyr&goal..)
      order by y
      ;
      create   table tickplot1 as
      select   y, count(*) as count
      from     tickplot0
      group by y
      ;
   quit;


   *--- add rows for grades not present ---;
   data tickplot2;
      merge grades tickplot1;
      by y;
      if missing(count) then
         count = 0;
   run;

   proc sort data=tickplot2;
      by descending y;
   run;


   *--- relocate over-climbed grades ---;
   data tickplot3;
      set tickplot2;
      retain carry 0;
      if y = 4 then do;
         if count > 1 then do;
            carry = count - 1;
            count = 1;
         end;
      end;
      else if y = 3 then do;
         count = count + carry;
         if count > 2 then do;
            carry = count - 2;
            count = 2;
         end;
      end;
      else if y = 2 then do;
         count = count + carry;
         if count > 4 then do;
            carry = count - 4;
            count = 4;
         end;
      end;
      else if y = 1 then do;
         count = count + carry;
         if count > 8 then do;
            carry = count - 8;
            count = 8;
         end;
      end;
   run;


   *--- place ticks over outline ---;
   data tickplot4;
      set tickplot3;
      if count > 0 then do;
         if mod(count,2) = 0 then do;
            start = -1*count/2 + 0.5;
            end = -1*start;
         end;
         else if mod(count,2) = 1 then do;
            start = -1*count/2;
            end = -1*start - 1;
         end;
         if y = 4 then do;
            start = 0;
            end = 0;
         end;
         do xt = start to end;
            output;
         end;
      end;
   run;


   *--- plot outline and ticks ---;
   data plotdata;
      set outline tickplot4;
   run;

   ods graphics / reset=all width=6in height=2.75in;
   ods listing gpath = "&path";
   ods graphics / imagename = "pyr&goal";

   proc sgplot data=plotdata noautolegend;
      scatter x=xo y=y / markerattrs=(symbol=square size=50);
      scatter x=xt y=y / markerattrs=(symbol=squarefilled size=40 color=green);
      yaxis display=(nolabel) integer;
      xaxis display=none;
      inset "&today" / position=topright;
   run;

%mend pyramid;

ods pdf file="&path/pyramids.pdf" startpage=never;
%pyramid(goal=10d)
%pyramid(goal=11a)
%pyramid(goal=11b)
ods pdf close;
