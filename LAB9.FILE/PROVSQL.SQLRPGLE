000100181121	
000101181121
000106181121
000107181121     FQPRINT    O    F  132        PRINTER OFLIND(*INOF) FORMOFL(60) FORMLEN(66)
000108181121     D CustomerRecord  DS
000109181121     D CustId                         6
000110181121     D FullName                      31
000111181121     D City                          20
000112181121     D Purchase                       7  2
000113181121     D PDate                           D
000114181121     D Province                      10
000115181121     D ProvinceH       S             10
000116181121
000117181121
000118181121     D TotalCost       S              8  2
000119181121     D TotalRecords    S              5  0
000120181121     D TotalExtended   S              9  2
000121181121     D OntarioTot      S              3  0
000122181121     D QuebecTot       S              3  0
000123181121     D ManitobaTot     S              3  0
000124181121     D EndOfFile       S               N
000125181121     C/EJECT
000126181121     C******************************
000127181121     C*                        *   M A I N   R O U T I N E   *                       *
000128181121     C******************************
000129181121      /FREE
000130181121                EXSR PrepareFiles;
000131181121                EXCEPT HEADINGS;
000132181121                EXSR GetRow;
000133181121                Except NewProv;
000134181121                ProvinceH = Province;
000135181121                DOW NOT EndOfFile;
000136181121                    IF *INOF = *ON;
000137181121                        EXCEPT HEADINGS;
000138181121                       *INOF = *OFF;
000139181121                    ENDIF;
000140181121                    If ProvinceH = Province;
000141181121                       Except Detail;
000142181121                    Else;
000143181121                       ProvinceH = Province;
000144181121                       Except NewProv;
000145181121                       Except Detail;
000146181121                    EndIf;
000147181121                    TotalCost     = TotalCost     + Purchase;
000148181121                    TotalRecords= TotalRecords + 1;
000149181121                    EXSR GetRow;
000150181121                ENDDO;
000151181121                EXSR WRAPUP;
000152181121                EXCEPT Totals;
000153181121                *INLR = *ON;
000154181121                RETURN;
000155181121
000156181121
000157181121        // O P E N F I L E S   S U B R O U T I N E
000158181121
000159181121           BEGSR  PrepareFiles;
000160181121        // S E T   U P   T H E   T E M P O R A R Y   R E S U L T  S T R U C T U R E
000161181121           EXEC SQL
000162181121             DECLARE ALLPROVCURSOR CURSOR
000163181121             FOR
000164181121             SELECT CUSTID, TRIM(FNAME)|| ' ' || TRIM(LNAME),
000165181121                    CITY, PURCHASE, PDATE, 'Ontario' AS PROVINCE
000166181121             FROM BCI433LIB/ONTARIO
000167181121             WHERE PURCHASE > 150
000168181121             UNION ALL
000169181121             SELECT CUSTID, TRIM(FNAME)|| ' ' || TRIM(LNAME),
000170181121                    CITY, PURCHASE, PDATE, 'Quebec' AS PROVINCE
000171181121             FROM BCI433LIB/QUEBEC
000172181121             WHERE PURCHASE > 150
000173181121             UNION ALL
000174181121             SELECT CUSTID, TRIM(FNAME)|| ' ' || TRIM(LNAME),
000175181121                    CITY, PURCHASE, PDATE, 'Manitoba' AS PROVINCE
000176181121             FROM BCI433LIB/MANITOBA
000177181121             WHERE PURCHASE > 150
000178181121             FOR READ ONLY;
000179181121
000180181121        // A   T E M P O R A R Y   R E S U L T   T A B L E   I S   C R E A T E D
000181181121           EXEC SQL
000182181121             OPEN ALLPROVCURSOR;
000183181121             IF SQLCODE <> 0 OR SQLWN0 = 'W';
000184181121                ENDOFFILE = *ON;
000185181121             ENDIF;
000186181121
000187181121            ENDSR;
000188181121
000189181121
000190181121       BEGSR GETROW;
000191181121
000192181121          EXEC SQL
000193181121            FETCH NEXT
000194181121             FROM ALLPROVCURSOR
000195181121             INTO :CustomerRecord;
000196181121           IF SQLCODE <> 0 OR SQLWN0 ='W';
000197181121            EndOfFile = *on;
000198181121           ENDIF;
000199181121
000200181121       ENDSR;
000201181121
000202181121
000203181121
000204181121        // W R A P U P     S U B R O U T I N E
000205181121
000206181121       BEGSR WRAPUP;
000207181121           EXEC SQL
000208181121             CLOSE ALLPROVCURSOR;
000209181121              IF SQLCODE <> 0 OR SQLWN0 ='W';
000210181121                EndOfFile = *ON;
000211181121             ENDIF;
000212181121
000213181121           EXEC SQL
000214181121
000215181121              SELECT COUNT(*) INTO :OntarioTot
000216181121              FROM BCI433LIB/ONTARIO
000217181121              WHERE  PURCHASE <= 150;
000218181121             IF SQLCODE <> 0 OR SQLWN0 ='W';
000219181121              OntarioTot = -999;
000220181121             ENDIF;
000221181121
000222181121           EXEC SQL
000223181121
000224181121              SELECT COUNT(*) INTO :QuebecTot
000225181121              FROM BCI433LIB/QUEBEC
000226181121              WHERE  PURCHASE <= 150;
000227181121              IF SQLCODE <> 0 OR SQLWN0 ='W';
000228181121               QuebecTot = -999;
000229181121              ENDIF;
000230181121
000231181121           EXEC SQL
000232181121
000233181121             SELECT COUNT(*) INTO :ManitobaTot
000234181121             FROM BCI433LIB/MANITOBA
000235181121             WHERE  PURCHASE <= 150;
000236181121            IF SQLCODE <> 0 OR SQLWN0 ='W';
000237181121              ManitobaTot = -999;
000238181121            ENDIF;
000239181121
000240181121       ENDSR;
000241181121      /END-FREE
000242181121
000243181121     OQPRINT    E            HEADINGS       2 02
000244181121     O                                           67 'Customers > $150.00'
000245181121     O                                          110 'Page:'
000246181121     O                       PAGE               115
000247181121     O          E            HEADINGS       1
000248181121     O                                            8 'Province'
000249181121     O                                           23 'Customer ID'
000250181121     O                                           42 'Full Name'
000251181121     O                                           64 'City'
000252181121     O                                           90 'Purchase'
000253181121     O                                          101 'Purchase'
000254181121     O          E            HEADINGS       2
000255181121     O                                           89 'Amount'
000256181121     O                                           99 'Date'
000257181121     o          E            NewProv        1
000258181121     O                       Province            10
000259181121     o          E            DETAIL         1
000260181121     O                       CustID              20
000261181121     O                       FullName            61
000262181121     O                       City                74
000263181121     O                       Purchase      1     90
000264181121     O                       PDate              103
000265181121     O          E            Totals      2  1
000266181121     O                                           79 'Total Amount:'
000267181121     O                       TotalCost     1     90
000268181121     O          E            Totals      1  1
000269181121     O                                           17 'Total Customers:'
000270181121     O                       TotalRecords  1     24
000271181121     O          E            TOTALS         2 02
000272181121     O                                           67 'Customers <= $150.00'
000273181121     O                                          110 'Page:'
000274181121     O                       PAGE               115
000275181121     O          E            Totals         2
000276181121     O                                           18 'Ontario'
000277181121     O                                           41 'Quebec'
000278181121     O                                           69 'Manitoba'
000279181121     O          E            Totals         1
000280181121     O                       OntarioTot    1     15
000281181121     O                       QuebecTot     1     38
000282181121     O                       ManitobaTot   1     66
