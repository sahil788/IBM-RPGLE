000100181120     F**************************************************************************
000101181120     F*  CUSTOMER18 READ BY NATIVE LANGUAGE (ILE RPG)
000102181120     F*  CONTACTW18 ROW RETRIEVED WITH EMBEDDED SQL
000103181120     F*  DETAIL REPORT LINE INCLUDES INFORMATION FROM CUSTOMER18 AND CONTACTW18
000104181120     F*  SUMMARY REPORT INFORMATION RETRIEVED WITH EMBEDDED SQL STATEMENTS
000105181120     F**************************************************************************
000106181120
000107181120     FCUSTOMER18IF   E             DISK    RENAME(CUSTOMER18:CUSTOMERRF)
000108181120     FQPRINT    O    F  132        PRINTER OFLIND(*INOF) FORMOFL(30) FORMLEN(66)
000109181120
000110181120     D*  H O S T   V A R I A B L E S
000111181120     D CONTACTF18    E DS
000112181120     D ContactTotal    S              5  0
000113181120     D CustomerTotal   S              5  0
000114181120     D UnknownTotal    S              5  0
000115181120     D OldestDate      S               D
000116181120     D MostRecentDate  S               D
000117181120     D User            S             10
000118181120     D Server          S             10
000119181120     D TimeStamp       S               Z
000120181120     D DateIn          S              5  0
000121181120
000122181120     D*  I N D I C A T O R   V A R I A B L E S
000123181120     D IndLastDateC    S              4B 0
000124181120     D IndNextDateC    S              4B 0
000125181120
000126181120     D Dummy           S              1  0
000127181120     D Flag            S              7
000128181120     D NextCallDate    S               D
000129181120     C/EJECT
000130181120     C**************************************************************************
000131181120     C*                        ***   M A I N   R O U T I N E   ***
000132181120     C**************************************************************************
000133181120      /FREE
000134181120                EXSR SummaryInfo;
000135181120                EXCEPT HEADINGS;
000136181120                READ CUSTOMER18;
000137181120                DOW NOT %EOF;
000138181120                    EXSR SQLSelect;
000139181120                    IF *INOF = *ON;
000140181120                       EXCEPT HEADINGS;
000141181120                       *INOF = *OFF;
000142181120                    ENDIF;
000143181120                    EXCEPT DETAIL;
000144181120                   READ CUSTOMER18;
000145181120                ENDDO;
000146181120                EXCEPT TOTALS;
000147181120                *INLR = *ON;
000148181120                RETURN;
000149181120        //*************************************************************************
000150181120        //   S Q L S E L E C T   S U B R O U T I N E
000151181120   //   //********************************************************************
000152181120   //                  BEGSR    SQLSelect ;
000153181120   //    // A row from the contacts table that has the same customer number found in the
000154181120   //    // record read from the CUSTOMER18 file. That row is retrieved to find out the last
000155181120   //    // date called, phone number, comments and the salesperson number.
000156181120   //
000157181120   //    //  The call back interval is added to the last date called to determine the
000158181120   //    //  next date to call.  Since null values may be stored in the last date called
000159181120   //    // indicator variables are used.
000160181120
000161181120
000162181120                                   EXEC SQL
000163181120                                     SELECT PHNLDC + PHNCIT DAYS, PHNLDC,
000164181120                                            CSTPHN, PHNCOM, CSTSLN
000165181120
000166181120                                     INTO :NextCallDate :IndNextDateC,
000167181120                                          :PHNLDC :IndLastDateC,
000168181120                                          :CSTPHN, :PHNCOM, :CSTSLN
000169181120                                     FROM BCI433LIB/CONTACTF18
000170181120                                     WHERE CSTNUM = :CSTNUM;
000171181120
000172181120                                     IF IndLastDateC = -1;
000173181120                                       CSTPHN = 'UNKNOWN DATE';
000174181120                                       NextCallDate = D'9999-09-09';
000175181120                                       PHNLDC = D'9999-09-09';
000176181120
000177181120                                     ELSE;
000178181120                                       IF IndLastDateC <> 0;
000179181120                                         CSTPHN = 'Date Problem';
000180181120                                         NextCallDate = D'9999-09-09';
000181181120                                         PHNLDC = D'9999-09-09';
000182181120                                       ENDIF;
000183181120                                     ENDIF;
000184181120
000185181120                                     SELECT;
000186181120                                       WHEN SQLSTATE = '00000';
000187181120                                         DUMMY = 0;
000188181120                                       WHEN SQLSTATE = '02000';
000189181120                                         CSTPHN = 'Not Found';
000190181120                                         NextCallDate =  D'9999-09-09';
000191181120                                         PHNLDC =  D'9999-09-09';
000192181120                                         PHNCOM = *ALL'*';
000193181120                                         CSTSLN = *ALL'*';
000194181120                                       WHEN %Subst (SQLSTATE :1 :2) = '01';
000195181120                                         NextCallDate =  D'9999-09-09';
000196181120                                         PHNLDC =  D'9999-09-09';
000197181120                                         PHNCOM = *ALL'*';
000198181120                                         CSTSLN = *ALL'*';
000199181120                                         CSTPHN = *ALL'*';
000200181120                                       OTHER;
000201181120                                         NextCallDate =  D'9999-09-09';
000202181120                                         PHNLDC =  D'9999-09-09';
000203181120                                         PHNCOM = *ALL'*';
000204181120                                         CSTSLN = *ALL'*';
000205181120                                         CSTPHN = *ALL'*';
000206181120                                     ENDSL;
000207181121                                     EXEC SQL
000208181121                                              SELECT MIN(PHNLDC)
000209181121                                              INTO :OLDESTDATE
000210181121                                              FROM BCI433LIB/CONTACTF18;
000211181121                                              IF FLAG = '';
000212181121                                              IF OLDESTDATE = PHNLDC;
000213181121                                              FLAG = '<-----';
000214181121                                              ENDIF;
000215181121                                              ENDIF;
000216181121                                              IF FLAG = '<-----';
000217181121                                              IF NOT (OLDESTDATE = PHNLDC);
000218181121                                              FLAG = '';
000219181121                                              ENDIF;
000220181121                                              ENDIF;
000221181120
000279181120
000280181120
000281181120
000282181120
000283181120
000284181120
000285181120
000286181120
000287181120
000288181120
000289181120
000290181120
000291181120
000292181120
000293181120
000294181120
000295181120
000296181120
000297181120
000298181120
000299181120
000300181120
000301181120
000302181120
000303181120
000304181120
000305181120
000306181120
000307181120
000468181120
000469181120
000470181120
000471181120
000472181120
000473181120
000474181120
000475181120
000476181120
000477181120                         ENDSR ;
000478181120        //**********************************************************************
000479181120        // S U M M A R Y I N F O   S U B R O U T I N E
000480181120        //**********************************************************************
000481181120                         BEGSR  SummaryInfo;
000482181120        //  D E T E R M I N E   T O T A L S   F O R   CONTACTW18 & CUSTOMER18
000483181120                             EXEC SQL
000484181120                                    SELECT COUNT(*) INTO :ContactTotal
000485181120                                   FROM  BCI433LIB/CONTACTW18;
000486181120
000487181120                                   IF (SQLCODE <> 0) OR (SQLWN0 = 'W');
000488181120                                     ContactTotal = -99999;
000489181120                                   ENDIF;
000490181121
000491181121                                   EXEC SQL
000492181121                                    SELECT COUNT(*) INTO :CustomerTotal
000493181121                                   FROM  BCI433LIB/CUSTOMER18;
000494181121
000495181121                                   IF (SQLCODE <> 0) OR (SQLWN0 = 'W');
000496181121                                     CustomerTotal = -99999;
000497181121                                   ENDIF;
000498181120
000499181120
000500181120
000501181120
000502181120
000503181120
000504181120
000505181120
000506181120
000507181120
000508181120
000509181120
000510181120
000511181120
000512181120
000513181120        // D E T E R M I N E   N U M B E R   O F   U N K N O W N   L A S T   D A T E
000514181120       //  C A L L E D   R E C O R D S
000515181120                        EXEC SQL
000516181120                                   SELECT COUNT(*)
000517181120                                     INTO :UnknownTotal
000518181120                                     FROM BCI433LIB/CONTACTW18
000519181120                                     WHERE CstLastCAllDate IS NULL;
000520181120
000521181120
000522181120                                   IF (SQLCODE <> 0) OR (SQLWN0 = 'W');
000523181120                                     UnknownTotal =-99999;
000524181120                                   ENDIF;
000525181120
000526181120
000527181120
000528181120
000529181120
000530181120
000531181120
000532181120        //  D E T E R M I N E   O L D E S T   &  M O S T   R E C E N T  L A S T
000533181120       //   C A L L B A C K   D A T E S
000534181120                              EXEC SQL
000535181120                                   SELECT MIN(PHNLDC) INTO :OldestDate
000536181120                                     FROM BCI433LIB/CONTACTW18;
000537181120
000538181120                                   IF (SQLCODE <> 0) OR (SQLWN0 = 'W')
000539181120                                      AND (SQLWN2 <> 'W');
000540181120                                     OldestDate = D'9999-09-09';
000541181120                                   ENDIF;
000542181120
000543181120                                 EXEC SQL
000544181120                                   SELECT MAX(PHNLDC) INTO :MostRecentDate
000545181120                                     FROM BCI433LIB/CONTACTW18;
000546181120
000547181120                                   IF (SQLCODE <> 0) OR (SQLWN0 = 'W')
000548181120                                     AND (SQLWN2 <> 'W');
000549181120                                     MostRecentDate = D'9999-09-09';
000550181120                                   ENDIF;
000551181120
000552181120
000553181120
000554181120
000555181120
000556181120
000557181120
000558181120
000559181120
000560181120
000561181120
000562181120
000563181120
000564181120
000565181120
000566181120
000567181120
000568181120
000569181120
000570181120       // D E T E R M I N E   T H E   U S E R,  S E R V E R,  &   T I M E S T A M P
000571181120                EXEC SQL
000572181120                                   SELECT USER, CURRENT TIMESTAMP,CURRENT SERVER
000573181120                                     INTO :User, :Timestamp, :Server
000574181120                                     FROM SYSIBM/SYSDUMMY1;
000575181120                ENDSR;
000576181120
000577181120
000578181120
000579181120
000580181120
000581181120      /END-FREE
000582181120     OQPRINT    E            HEADINGS       2 02
000583181120     O                                            5 'USER:'
000584181120     O                       USER                16
000585181120     O                                           28 'TIMESTAMP:'
000586181120     O                       TIMESTAMP           55
000587181120     O                                           64 'SERVER:'
000588181120     O                       SERVER              75
000589181120     O                                           87 'PAGE:'
000590181120     O                       PAGE                90
000591181120     O          E            HEADINGS       2
000592181120     O                                           54 'Phone Log Report'
000593181120     O                       UDATE         Y     89
000594181120     O          E            HEADINGS       1
000595181120     O                                            5 'Sales'
000596181120     O                                           15 'Customer'
000597181120     O                                           31 'Customer Name'
000598181120     O                                           59 'Telephone'
000599181120     O                                           75 'Last Call'
000600181120     O                                           88 'Oldest Call'
000601181120     O                                          101 'Next Call'
000602181120     O          E            HEADINGS       2
000603181120     O                                            3 'ID'
000604181120     O                                           13 'Number'
000605181120     O                                           73 'Date'
000606181120     O                                           85 'Date'
000607181120     O                                           98 'Date'
000608181120     O          E            DETAIL         1
000609181120     O                       CSTSLN               3
000610181120     O                       CSTNUM              13
000611181120     O                       CSTNAM              48
000612181120     O                       CSTPHN              64
000613181120     O                       PHNLDC              75
000614181120     O                       FLAG                86
000615181120     O                       NextCallDate       101
000616181120     O          E            TOTALS      2  2
000617181120     O                                           32 'Summary Information'
000618181120     O          E            TOTALS         1
000619181120     O                                           26 'CONTACTW18 Total Records:'
000620181120     O                       ContactTotal  1     34
000621181120     O          E            TOTALS         1
000622181120     O                                           26 'CUSTOMER18 Total Records:'
000623181120     O                       CustomerTotal 1     34
000624181120     O          E            TOTALS      1  1
000625181120     O                                           27 'Oldest Last Callback Date:'
000626181120     O                       OldestDate          42
000627181120     O          E            TOTALS         1
000628181120     O                                           27 'Most Recent Callback Date:'
000629181120     O                       MostRecentDate      42
000630181120     O          E            TOTALS      2  1
000631181120     O                                           22 'Total Records with an'
000632181120     O                                           47 'Unknown Last Date Called'
000633181120     O                                           62 'in CONTACTW18:'
000634181120     O                       UnknownTotal        70
