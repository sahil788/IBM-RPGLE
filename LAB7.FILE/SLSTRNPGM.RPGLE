000100181114     FSALESTRANSIF   E             DISK    RENAME(SALESTRANS:SALESTRANR)
000101181114     FSALESSTAF2UF A E           K DISK
000102181114     FQPRINT    O    F  132        PRINTER OFLIND(*INOF)
000103181114     D SALESTRANSDS    DS
000104181114     D   TDEPT
000105181114     D   TSALESID
000106181114     D   TFNAME
000107181114     D   TLNAME
000108181114     D   TCITY
000109181114     D   TADDRESS
000110181114     D   TPCODE
000111181114     D SALESSTAF2DS    DS
000112181114     D    DEPT
000113181114     D    SALESID
000114181114     D    FNAME
000115181114     D    LNAME
000116181114     D    CITY
000117181114     D    ADDRESS
000118181114     D    PCODE
000119181114     D FullKey         DS                  LikeRec(SALESTFR: *Key)
000120181114     C/FREE
000121181114                   EXCEPT HEADINGS;
000122181114                   READ   SALESTRANS;
000123181114                   DOW NOT %EOF;
000124181114                         FullKey = TDept + TSalesID;
000125181114                         Chain %kds(FullKey)SalesStaf2;
000126181114                      SELECT;
000127181114                        WHEN %FOUND(SALESSTAF2);
000128181114                        SELECT;
000129181114                           WHEN TCODE = 'C';
000130181114                              EXSR CHGREC;
000131181114                           WHEN TCODE = 'D';
000132181114                              EXSR DELREC;
000133181114                           OTHER;
000134181114                              EXSR ERROR;
000135181114                        ENDSL;
000136181114                        WHEN NOT %FOUND(SALESSTAF2);
000137181114                           IF TCODE = 'A';
000138181114                              EXSR ADDREC;
000139181114                           ELSE;
000140181114                              EXSR ERROR;
000141181114                           ENDIF;
000142181114                        WHEN %ERROR;
000143181114                              EXSR ERROR;
000144181114                        ENDSL;
000145181114                        EXCEPT DETAIL;
000146181114                        READ SALESTRANS;
000147181114                   ENDDO;
000148181114                   *INLR = *ON;
000149181114                   RETURN;
000150181114         BEGSR  ADDREC;
000151181114                    SalesStaf2ds = SalestransDS;
000152181114                    Phone = %dec(TPhone:10:0);
000153181114                   WRITE SALESTFR;
000154181114         ENDSR;
000155181114         BEGSR  CHGREC;
000156181114                   SALESSTAF2DS = SALESTRANSDS;
000157181114                   Phone        = %Dec(TPhone:10:0);
000158181114                   UPDATE SALESTFR;
000159181114         ENDSR;
000160181114         BEGSR  DELREC;
000161181114                   DELETE SALESTFR;
000162181114         ENDSR;
000163181114         BEGSR  ERROR;
000164181114                   TFNAME = 'UPDATE/DELETE/CHANGE';
000165181114                   TLNAME = 'E R R O R';
000166181114         ENDSR;
000167181114      /END-FREE
000168181114     OQPRINT    E            HEADINGS       2 02
000169181114     O                                            8 'PAGE'
000170181114     O                       PAGE                13
000171181114     O                                           50 'SALESSTAFF UPDATE'
000172181114     O                                           64 'DATE'
000173181114     O                       UDATE         Y     73
000174181114     O          E            HEADINGS       1
000175181114     O                                            4 'CODE'
000176181114     O                                           10 'DEPT'
000177181114     O                                           14 'ID'
000178181114     O                                           28 'FIRST NAME'
000179181114     O                                           49 'LAST NAME'
000180181114     O                                           66 'CITY'
000181181114     O                                           91 'ADDRESS'
000182181114     O                                          113 'PHONE'
000183181114     O                                          125 'POSTAL'
000184181114     O          E            HEADINGS       2
000185181114     O                                          124 'CODE'
000186181114     O          E            DETAIL         1
000187181114     O                       TCODE                2
000188181114     O                       TDEPT                9
000189181114     O                       TSALESID            15
000190181114     O                       TFNAME              38
000191181114     O                       TLNAME              60
000192181114     O                       TCITY               82
000193181114     O                       TADDRESS           102
000194181114     O                       TPHONE             116
000195181114     O                       TPCODE             125
