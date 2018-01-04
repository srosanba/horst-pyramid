%let path = H:\GraphicsGroup\pyramid;

libname pyramid "path";

proc format;
   value grade
      1 = "10a"
      2 = "10b"
      3 = "10c"
      4 = "10d"
      5 = "11a"
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
   format y grade.;
run;


*--- generate tick list ---;
data ticklist;
   input dtc $ 1-10 grade $ 12-14;
   datalines;
2018-01-02 10a
2018-01-02 10b
2018-01-02 10a
2018-01-02 10c
2018-01-04 10c
2018-01-04 10b
2018-01-04 10c
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
   from     ticklist as tl
            left join grades as g
            on tl.grade = put(g.y,grade.)
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
ods graphics / imagename = "pyramid";

proc sgplot data=plotdata noautolegend;
   scatter x=xo y=y / markerattrs=(symbol=square size=40);
   scatter x=xt y=y / markerattrs=(symbol=squarefilled size=30 color=green);
   yaxis display=(nolabel);
   xaxis display=none;
run;
