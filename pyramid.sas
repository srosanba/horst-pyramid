%let path = H:\GitHub\srosanba\pyramid;


%macro pyramid(goal=);

   proc format;
      value pyr11a
         1 = "10a"
         2 = "10b"
         3 = "10c"
         4 = "10d"
         5 = "11a"
         ;
      value pyr11b
         1 = "10b"
         2 = "10c"
         3 = "10d"
         4 = "11a"
         5 = "11b"
         ;
      value pyr11c
         1 = "10c"
         2 = "10d"
         3 = "11a"
         4 = "11b"
         5 = "11c"
         ;
      value pyr11d
         1 = "10d"
         2 = "11a"
         3 = "11b"
         4 = "11c"
         5 = "11d"
         ;
      value pyr12a
         1 = "11a"
         2 = "11b"
         3 = "11c"
         4 = "11d"
         5 = "12a"
         ;
   run;


   *--- generate pyramid outline ---;
   data outline;
      y = 1;
      do xo = -7.5 to 7.5;
         output;
      end;
      y = 2;
      do xo = -3.5 to 3.5;
         output;
      end;
      y = 3;
      do xo = -1.5 to 1.5;
         output;
      end;
      y = 4;
      do xo = -0.5 to 0.5;
         output;
      end;
      y = 5;
      xo = 0;
      output;
      format y pyr&goal..;
   run;


   *--- import tick list ---;
   proc import 
         datafile="&path/ticks.csv"
         out=tickimp
         dbms=csv
         replace
         ;
   run;


   *-- combine outline and tick list ---;
   proc sql;
      create   table grades as
      select   distinct y
      from     outline
      ;
      create   table tickplot0 as
      select   y
      from     tickimp as tl
               left join grades as g
               on tl.grade = put(g.y,pyr&goal..)
      order by y
      ;
      create   table tickplot1 as
      select   y, count(*) as count
      from     tickplot0
      group by y
      ;
   quit;

   data tickplot2;
      set tickplot1;
      if mod(count,2) = 0 then do;
         start = -1*count/2 + 0.5;
         end = -1*start;
      end;
      else if mod(count,2) = 1 then do;
         start = -1*count/2;
         end = -1*start - 1;
      end;
      do xt = start to end;
         output;
      end;
      if y = 5 then 
         put "W" "ARNING: you have accomplished your goal!!!";
   run;

   data plotdata;
      set outline tickplot2;
   run;


   *--- plot the outline ---;
   ods graphics / reset=all width=8in height=3in;
   ods listing gpath = "&path";
   ods graphics / imagename = "pyr&goal";

   proc sgplot data=plotdata noautolegend;
      scatter x=xo y=y / markerattrs=(symbol=square size=40);
      scatter x=xt y=y / markerattrs=(symbol=squarefilled size=30 color=green);
      yaxis display=(nolabel);
      xaxis display=none;
   run;

%mend pyramid;

ods pdf file="&path/pyramids.pdf" startpage=never;
%pyramid(goal=11a)
%pyramid(goal=11b)
%pyramid(goal=11c)
ods pdf close;