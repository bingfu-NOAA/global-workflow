C$$$  SUBPROGRAM DOCUMENTATION BLOCK
C                .      .    .                                       .
C SUBPROGRAM:    FILTER      FILTER THE STATIONS
C   PRGMMR: LARRY SAGER      ORG: W/NMC41    DATE: 97-01-07
C
C ABSTRACT: FILTER THINS THE DATA                            
C
C PROGRAM HISTORY LOG:
C   97-01-07  LARRY SAGER
C
C USAGE:    CALL FILTER  (HDR, HDT, ARR, IPRIOR, ITYP, IRYN)
C   INPUT ARGUMENT LIST:
C     HDR      - STATION HEADER INFORMATION
C     HDT      - STATION DATE INFORMATION
C     ARR      - STATION DATA                       
C     ITYP     - TYPE FLAG (SYNOPTIC/METAR)
C     IJMIN    - JULIAN MINUTE FOR RUN TIME
C     IJREP    - JULIAN MINUTE FOR REPORT OB TIME
C
C   OUTPUT ARGUMENT LIST:      (INCLUDING WORK ARRAYS)
C     IRYN     - PRIORITY FROM TABLES
C
C REMARKS: LIST CAVEATS, OTHER HELPFUL HINTS OR INFORMATION
C
C ATTRIBUTES:
C   LANGUAGE: FORTRAN 90
C   MACHINE:  IBM SP
C
C$$$
      SUBROUTINE FILTER (HDR, HDT, ARR, IPRIOR, ITYP, 
     1         IJMIN, IJREP, IRYN)
C 
C     THIS SUBROUTINE USES THE PRIORITY TABLES TO DO
C     AN INITIAL THINNING OF THE DATA
C
C        RETURN CODE  IRET  =  1   ACCEPT REPORT    
C                           =  0   REJECT REPORT
C
      CHARACTER*8   CSTAT
C
      REAL          ARR(*)
      REAL          HDR(*)
      REAL          HDT(*)
C
      INTEGER       IWGT(40)
C
      LOGICAL       LSWIT
C
      EQUIVALENCE   (CSTAT,RSTAT)
      EQUIVALENCE   (RSTAT,ISTAT) 
C
      DATA   IWGT   /8, 0, 4, 4, 1, 1, 7*0, 1, 1,
     1        2*0, 1, 2*0, 1, 2*0, 2, 2, 1, 3*0,
     2        7*1, 4*0/
C
      IRYN = 1
C     
C     START BY ASSIGNING A BASIC STATION WEIGHT ACCORDING
C       TO DATA TYPE
C
      RSTAT = HDR(1)  
      LSWIT = .TRUE.
      IF (ITYP .EQ. 1) THEN
C
C        LKLNDNAM SEARCHES THE LAND TABLES TO FIND THE 
C          PRIORITY FOR THIS STATION
C
         CALL LKLNDNAM(CSTAT, LSWIT, IPRIOR, IRET)
      ELSE
         IRET = 0
         IPRIOR = 20        
         IF (ITYP .GT. 3) IPRIOR = 50
      END IF
C
C     ADD WEIGHT TO THE BASIC PRIORITY FOR EACH DATA
C       PARAMETER PRESENT
C
      IF (IRET .NE. -1)THEN
         IADD = 0
         DO K = 1,40
            IF (ARR(K) .LT. 999999.) IADD = IADD + IWGT(K)
         END DO
C
C        HANDLE THE PRESENT WEATHER SEPARATELY
C
         IWW = ARR(12)
         IF (IWW .LT. 99999) IADD = IADD + IWW/10 + 1
C
C        ADD THE EXTRA WEIGHT TO THE PRIORITY OF THIS 
C          STATION
C
         IPRIOR = IPRIOR + IADD
      END IF
C
C     REDUCE THE PRIORITY BY 50% IF THIS REPORT IS MORE THAN
C       40 MINUTES OLD
C
      IDIF = IJMIN - IJREP
      IF(IDIF .LT. 0) IDIF = -IDIF
      IF(IDIF .GT. 40) THEN     
         IPRIOR = IPRIOR/2    
C        PRINT *,' HOUR OLD--PRIORITY REDUCED 50%'
      END IF

C 
C     SET THE RETURN FLAG TO 0 (REJECT) IF THE STATION HAS A    
C       VERY LOW PRIORITY                            
C
C     IF (IPRIOR .LT. 5) IRYN = 0
C
C     COMPARE THE 
      RETURN
      END
