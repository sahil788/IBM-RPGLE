000100181204        CTL-OPT NoMain DatFMT(*USA);
000101181204
000102181204      /COPY Lab10,DateProtos
000103181204
000104181204        DCL-PROC DayOfWeek Export;
000105181204          DCL-PI *n Zoned(1);
000106181204            WorkDate Date;
000107181204          END-PI;
000108181204
000109181204          DCL-S AnySunday Date Inz(D'04/02/1995');
000110181204          DCL-S WorkNum Packed(7);
000111181204          DCL-S WorkDay Zoned(1);
000112181204
000113181204          WorkNum = %diff(WorkDate : AnySunday : *D);
000114181204          WorkDay = %Rem(WorkNum : 7);
000115181204
000116181204         IF WorkDay < 1;
000117181204           WorkDay += 7;
000118181204         ENDIF;
000119181204
000120181204        Return WorkDay;
000121181204
000122181204        END-PROC;
000123181204
000124181204        DCL-PROC DayName Export;
000125181204           DCL-PI *n Char(9);
000126181204              AnyDate Date;
000127181204           END-PI;
000128181204
000129181204           DCL-DS DayData;
000130181204             *n Char(9) INZ('Monday');
000131181204             *n Char(9) INZ('Tuesday');
000132181204             *n Char(9) INZ('Wednesday');
000133181204             *n Char(9) INZ('Thursday');
000134181204             *n Char(9) INZ('Friday');
000135181204             *n Char(9) INZ('Saturday');
000136181204             *n Char(9) INZ('Sunday');
000137181204
000138181204           DayArray Char(9) Dim(7) Pos(1);
000139181204           END-DS;
000140181204
000141181204           Return DayArray(DayOfWeek(AnyDate));
000142181204
000143181204        END-PROC;
000144181204
000145181204        DCL-PROC DateWords Export;
000146181204         DCL-PI DateWords Char(30);
000147181204          AnyDate Date;
000148181204         END-PI;
000149181204
000150181204         DCL-DS YeaData;
000151181204             *n Char(9) INZ('January');
000152181204             *n Char(9) INZ('Febuary');
000153181204             *n Char(9) INZ('March');
000154181204             *n Char(9) INZ('April');
000155181204             *n Char(9) INZ('May');
000156181204             *n Char(9) INZ('June');
000157181204             *n Char(9) INZ('July');
000158181204             *n Char(9) INZ('August');
000159181204             *n Char(9) INZ('September');
000160181204             *n Char(9) INZ('October');
000161181204             *n Char(9) INZ('November');
000162181204             *n Char(9) INZ('December');
000163181204
000164181204           YearArray Char(9) Dim(12) Pos(1);
000165181204         END-DS;
000166181204
000167181204         DCL-S result Char(30);
000168181204
000169181204         result =
000170181204           %Trim(DayName(AnyDate)) + ' ' +
000171181204           %Trim(YearArray(%subdt(AnyDate:*MONTHS))) + ' ' +
000172181204           %Trim(%Char(%subdt(AnyDate:*DAYS))) + ', ' +
000173181204           %Trim(%Char(%subdt(AnyDate:*YEARS)));
000174181204
000175181204         return result;
000176181204        END-PROC;
