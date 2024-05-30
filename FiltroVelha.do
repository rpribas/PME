****************************************************************
* Building PME database (old version)
* Rafael Perez Ribas and Sergei Suarez Dillon Soares
* March 30, 2007
****************************************************************

****************************************************************
* System parameters
****************************************************************

set mem 900m
set virtual on
set more off
cd "C:\PME\Antiga"


****************************************************************
* Filter for each year
****************************************************************

forvalues year = 1991/2002 {

   qui {

      if `year' >= 1991 & `year' <=1999 {
         loc AA = `year'-1900
         dis `AA'
      }
      else if `year' == 2000 {
         loc AA "2K"
      }
      else {
         loc AA = `year'-2000
      }

      cd `year'

      * The data are divided by RM.
      * We run the filter by RM and after we join each file.

      foreach RM in BA MG PE RJ RS SP {

         tempfile t`year'`RM'

         if `year' <= 2000 {

            tempfile d`year'`RM'

            #d ;

            infix uf 1-2              ano 3-6             mes 7-8
                  v102 9-16           v103 17-18          v101 19-22
                  v104 23             v105 24-25          v106 26
                  v107 27-29          v108 30             v109 31-32
                  v110 33-34          v111 35-36          v112 37
                  v113 38             v002 39-43          v003 44
                  v2001 45-46         v2002 47-48         v600 49-57
            using PME`AA'`RM'D.txt, clear;

            compress; sort uf ano mes v102 v103; sa `d`year'`RM'', replace;

            infix uf 1-2              ano 3-6             mes 7-8
                  v102 9-16           v103 17-18          v201 19-20
                  v202 21             v203 22             v204 23
                  v205 24             v206 25-26          v236 27-28
                  v246 29-31          v207 32             v208 33
                  v209 34             v210 35             v211 36
                  v301 37             v302 38             v303 39-41
                  v304 42-44          v305 45             v306 46
                  v307 47             v308 48             v309 49-57
                  v339 58-59          v310 60-61          v311 62-70
                  v341 71-72          v312 73-74          v313 75
                  v314 76             v315 77             v316 78-79
                  v346 80-81          v356 82-83          v366 84
                  v317 85-86          v347 87-88          v318 89
                  v319 90             v320 91-92          v350 93-94
                  v360 95-96          v321 97-99          v322 100-102
                  v323 103            v324 104            v325 105-106
                  v355 107-108        v326 109            v327 110
                  v328 111            v256 112-114        peso 129-137
            using PME`AA'`RM'P.txt, clear;

            #d cr

            * Joining individual and household data

            joinby uf ano mes v102 v103 using `d`year'`RM''

         }
         else {

            u PME0`AA'`RM', clear

            drop v1 v11 v9316

            g mes = v105
            g ano = `year'

            ren v10 uf
            ren v2 v002
            ren v3 v003

            capture confirm numeric variable v327 v328 v256
            if _rc==111 {

               g v327 = .
               g v328 = .

               tempvar yborn date birth

               g `yborn' = 1000 + v246 if v246>800 & v246<999
               g `date' = mdy(v2002,v2001,ano)
               g `birth' = mdy(v236,v206,`yborn')
               replace `birth' = mdy(v236,v206-1,`yborn') if `birth'==.
               replace `birth' = mdy(v236,v206-3,`yborn') if `birth'==.

               g v256 = (`date' - `birth')/365.25
               replace v256 = v246 if v246<99
               recode v256 . = 999
               recast int v256, force

            }

            if `year' == 2001 {

               g peso=213.7142  if uf==26 & v105==1
               replace peso=203.3908 if uf==29 & v105==1
               replace peso=197.7681 if uf==31 & v105==1
               replace peso=545.3497 if uf==33 & v105==1
               replace peso=822.1837 if uf==35 & v105==1
               replace peso=217.4019 if uf==43 & v105==1
               replace peso=214.4016 if uf==26 & v105==2
               replace peso=203.6971 if uf==29 & v105==2
               replace peso=199.7494 if uf==31 & v105==2
               replace peso=542.0587 if uf==33 & v105==2
               replace peso=833.452 if uf==35 & v105==2
               replace peso=216.5895 if uf==43 & v105==2
               replace peso=217.8683 if uf==26 & v105==3
               replace peso=204.1131 if uf==29 & v105==3
               replace peso=201.8901 if uf==31 & v105==3
               replace peso=536.4843 if uf==33 & v105==3
               replace peso=834.1979 if uf==35 & v105==3
               replace peso=216.6256 if uf==43 & v105==3
               replace peso=217.822 if uf==26 & v105==4
               replace peso=206.6109 if uf==29 & v105==4
               replace peso=206.4466 if uf==31 & v105==4
               replace peso=535.4308 if uf==33 & v105==4
               replace peso=841.2175 if uf==35 & v105==4
               replace peso=217.4367 if uf==43 & v105==4
               replace peso=213.4526 if uf==26 & v105==5
               replace peso=203.6412 if uf==29 & v105==5
               replace peso=205.857 if uf==31 & v105==5
               replace peso=538.7639 if uf==33 & v105==5
               replace peso=842.0156 if uf==35 & v105==5
               replace peso=217.4904 if uf==43 & v105==5
               replace peso=214.2292 if uf==26 & v105==6
               replace peso=205.5495 if uf==29 & v105==6
               replace peso=206.1336 if uf==31 & v105==6
               replace peso=545.314 if uf==33 & v105==6
               replace peso=844.8575 if uf==35 & v105==6
               replace peso=220.0946 if uf==43 & v105==6
               replace peso=214.0449 if uf==26 & v105==7
               replace peso=210.1666 if uf==29 & v105==7
               replace peso=207.4375 if uf==31 & v105==7
               replace peso=554.0944 if uf==33 & v105==7
               replace peso=847.453 if uf==35 & v105==7
               replace peso=221.397 if uf==43 & v105==7
               replace peso=220.2487 if uf==26 & v105==8
               replace peso=211.0173 if uf==29 & v105==8
               replace peso=211.1764 if uf==31 & v105==8
               replace peso=560.5 if uf==33 & v105==8
               replace peso=851.451 if uf==35 & v105==8
               replace peso=227.2976 if uf==43 & v105==8
               replace peso=219.7539 if uf==26 & v105==9
               replace peso=212.6683 if uf==29 & v105==9
               replace peso=212.6679 if uf==31 & v105==9
               replace peso=558.6444 if uf==33 & v105==9
               replace peso=848.089 if uf==35 & v105==9
               replace peso=227.2848 if uf==43 & v105==9
               replace peso=220.1929 if uf==26 & v105==10
               replace peso=214.5961 if uf==29 & v105==10
               replace peso=212.934 if uf==31 & v105==10
               replace peso=567.9142 if uf==33 & v105==10
               replace peso=860.6211 if uf==35 & v105==10
               replace peso=224.2541 if uf==43 & v105==10
               replace peso=220.6327 if uf==26 & v105==11
               replace peso=215.9495 if uf==29 & v105==11
               replace peso=214.427 if uf==31 & v105==11
               replace peso=569.7418 if uf==33 & v105==11
               replace peso=866.6626 if uf==35 & v105==11
               replace peso=224.3404 if uf==43 & v105==11
               replace peso=220.1788 if uf==26 & v105==12
               replace peso=220.1413 if uf==29 & v105==12
               replace peso=218.9296 if uf==31 & v105==12
               replace peso=584.1573 if uf==33 & v105==12
               replace peso=880.3675 if uf==35 & v105==12
               replace peso=228.5147 if uf==43 & v105==12

            }

            if `year' == 2002 {

               g peso=226.703 if uf==26 & v105==1
               replace peso=221.1513 if uf==29 & v105==1
               replace peso=214.8492 if uf==31 & v105==1
               replace peso=579.6412 if uf==33 & v105==1
               replace peso=889.0125 if uf==35 & v105==1
               replace peso=229.5069 if uf==43 & v105==1
               replace peso=216.6538 if uf==26 & v105==2
               replace peso=221.1619 if uf==29 & v105==2
               replace peso=214.3279 if uf==31 & v105==2
               replace peso=578.1032 if uf==33 & v105==2
               replace peso=878.4318 if uf==35 & v105==2
               replace peso=228.5094 if uf==43 & v105==2
               replace peso=218.8795 if uf==26 & v105==3
               replace peso=223.3373 if uf==29 & v105==3
               replace peso=217.0138 if uf==31 & v105==3
               replace peso=578.5018 if uf==33 & v105==3
               replace peso=883.2189 if uf==35 & v105==3
               replace peso=227.0876 if uf==43 & v105==3
               replace peso=215.7301 if uf==26 & v105==4
               replace peso=223.5785 if uf==29 & v105==4
               replace peso=214.98 if uf==31 & v105==4
               replace peso=574.7747 if uf==33 & v105==4
               replace peso=881.8996 if uf==35 & v105==4
               replace peso=225.5203 if uf==43 & v105==4
               replace peso=215.4215 if uf==26 & v105==5
               replace peso=220.3335 if uf==29 & v105==5
               replace peso=211.5174 if uf==31 & v105==5
               replace peso=561.6557 if uf==33 & v105==5
               replace peso=888.0235 if uf==35 & v105==5
               replace peso=225.0132 if uf==43 & v105==5
               replace peso=218.1024 if uf==26 & v105==6
               replace peso=221.0084 if uf==29 & v105==6
               replace peso=210.8418 if uf==31 & v105==6
               replace peso=566.4537 if uf==33 & v105==6
               replace peso=912.7505 if uf==35 & v105==6
               replace peso=224.4551 if uf==43 & v105==6
               replace peso=218.6877 if uf==26 & v105==7
               replace peso=218.0988 if uf==29 & v105==7
               replace peso=210.5094 if uf==31 & v105==7
               replace peso=558.0085 if uf==33 & v105==7
               replace peso=908.9921 if uf==35 & v105==7
               replace peso=224.6733 if uf==43 & v105==7
               replace peso=221.8821 if uf==26 & v105==8
               replace peso=221.3093 if uf==29 & v105==8
               replace peso=211.8993 if uf==31 & v105==8
               replace peso=554.79 if uf==33 & v105==8
               replace peso=897.6215 if uf==35 & v105==8
               replace peso=226.1524 if uf==43 & v105==8
               replace peso=226.9698 if uf==26 & v105==9
               replace peso=223.1509 if uf==29 & v105==9
               replace peso=213.8094 if uf==31 & v105==9
               replace peso=566.2498 if uf==33 & v105==9
               replace peso=904.2851 if uf==35 & v105==9
               replace peso=222.7205 if uf==43 & v105==9
               replace peso=227.9736 if uf==26 & v105==10
               replace peso=226.8327 if uf==29 & v105==10
               replace peso=214.3312 if uf==31 & v105==10
               replace peso=573.9971 if uf==33 & v105==10
               replace peso=896.4196 if uf==35 & v105==10
               replace peso=219.262 if uf==43 & v105==10
               replace peso=233.2976 if uf==26 & v105==11
               replace peso=228.8361 if uf==29 & v105==11
               replace peso=218.8924 if uf==31 & v105==11
               replace peso=580.1335 if uf==33 & v105==11
               replace peso=898.4646 if uf==35 & v105==11
               replace peso=221.4004 if uf==43 & v105==11
               replace peso=238.3226 if uf==26 & v105==12
               replace peso=231.5581 if uf==29 & v105==12
               replace peso=221.3981 if uf==31 & v105==12
               replace peso=589.8571 if uf==33 & v105==12
               replace peso=916.0452 if uf==35 & v105==12
               replace peso=231.8163 if uf==43 & v105==12

            }

            bys uf v105: g v600 = peso*_N

         }


         * Saving temporary file

         compress
         sa `t`year'`RM'', replace

      }


      * Joining the data from consecutive months

      foreach RM in BA MG PE RJ RS {
         append using `t`year'`RM''
      }


      * Other variables

      recode v206 0 = 99
      recode v236 20 30 = 99

      replace v246 = ano - 1000 - v246 if v246>=10 & v246<99
      replace v246 = 999 if v246<800

      g escol = 1       if v210==0
      replace escol = 2 if ((v210==1 | v210==3) & v209>=1 & v209<=3) ///
                        | (v209==4 & v210==1 & v211==3)
      replace escol = 3 if (v210==1 & ((v209==4 & v211==1) | v209==5)) ///
                        | (v210==2 & ((v209>=1 & v209<=3) | ///
                        (v209==4 & v211==3))) | (v210==3 & v209>=4 & v209<=7)
      replace escol = 4 if (v210==2 & ((v209==4 & v211==1) | v209==5)) ///
                        | (v210==3 & v209==8) | ((v210==4 | v210==5) ///
                        & (v209==1 | v209==2)) | (v210==5 & v209==3 & v211==3)
      replace escol = 5 if (v210==4 & v209==3) | (v210==5 & (v209==3 | ///
                        v209==4) & v211==1) | v210==6 | v210==7
      recode escol . = 6


      tempvar p

      g `p' = v105 + v106

      if `year' == 1991 {
         g str1 panel = "U" if `p'>=2 & `p'<=5
         replace panel = "V" if `p'>=6 & `p'<=9
         replace panel = "W" if `p'>=10 & `p'<=13
         replace panel = "X" if `p'>=14 & `p'<=16
      }
      if `year' == 1992 {
         g str1 panel = "X" if (`p'>=2 & `p'<=5) | (`p'>=14 & `p'<=16)
         replace panel = "Y" if `p'>=6 & `p'<=9
         replace panel = "Z" if `p'>=10 & `p'<=13
      }
      if `year' == 1993 {
         g str1 panel = "X" if `p'>=2 & `p'<=5
         replace panel = "Y" if `p'>=6 & `p'<=9
         replace panel = "Z" if `p'>=10 & `p'<=13
         replace panel = "A" if `p'>=14 & `p'<=16
      }
      if `year' == 1994 {
         g str1 panel = "A" if (`p'>=2 & `p'<=5) | (`p'>=14 & `p'<=16)
         replace panel = "B" if `p'>=6 & `p'<=9
         replace panel = "C" if `p'>=10 & `p'<=13
      }
      if `year' == 1995 {
         g str1 panel = "A" if `p'>=2 & `p'<=5
         replace panel = "B" if `p'>=6 & `p'<=9
         replace panel = "C" if `p'>=10 & `p'<=13
         replace panel = "D" if `p'>=14 & `p'<=16
      }
      if `year' == 1996 {
         g str1 panel = "D" if (`p'>=2 & `p'<=5) | (`p'>=14 & `p'<=16)
         replace panel = "E" if `p'>=6 & `p'<=9
         replace panel = "F" if `p'>=10 & `p'<=13
      }
      if `year' == 1997 {
         g str1 panel = "D" if `p'>=2 & `p'<=5
         replace panel = "E" if `p'>=6 & `p'<=9
         replace panel = "F" if `p'>=10 & `p'<=13
         replace panel = "G" if `p'>=14 & `p'<=16
      }
      if `year' == 1998 {
         g str1 panel = "G" if (`p'>=2 & `p'<=5) | (`p'>=14 & `p'<=16)
         replace panel = "H" if `p'>=6 & `p'<=9
         replace panel = "I" if `p'>=10 & `p'<=13
      }
      if `year' == 1999 {
         g str1 panel = "G" if `p'>=2 & `p'<=5
         replace panel = "H" if `p'>=6 & `p'<=9
         replace panel = "I" if `p'>=10 & `p'<=13
         replace panel = "J" if `p'>=14 & `p'<=16
      }
      if `year' == 2000 {
         g str1 panel = "J" if (`p'>=2 & `p'<=5) | (`p'>=14 & `p'<=16)
         replace panel = "K" if `p'>=6 & `p'<=9
         replace panel = "L" if `p'>=10 & `p'<=13
      }
      if `year' == 2001 {
         g str1 panel = "J" if `p'>=2 & `p'<=5
         replace panel = "K" if `p'>=6 & `p'<=9
         replace panel = "L" if `p'>=10 & `p'<=13
         replace panel = "M" if `p'>=14 & `p'<=16
      }
      if `year' == 2002 {
         g str1 panel = "M" if (`p'>=2 & `p'<=5) | (`p'>=14 & `p'<=16)
         replace panel = "N" if `p'>=6 & `p'<=9
         replace panel = "O" if `p'>=10 & `p'<=13
      }

      recode `p' (2 6 10 14 = 1) (3 7 11 15 = 2) ///
                 (4 8 12 16 = 3) (5 9 13 = 4), g(entrev)
      replace entrev = entrev + 4 ///
         if ((ano==1991 | ano==1993 | ano==1995 | ano==1997 | ano==1999 | ano==2001) ///
         & `p'>=2 & `p'<=13) | ///
         ((ano==1992 | ano==1994 | ano==1996 | ano==1998 | ano==2000 | ano==2002) ///
         & `p'>=14 & `p'<=16)

      cd ..

      cd Bases_dta


      * Saving the database by year

      compress
      capture drop __*

      order uf ano mes panel entrev v102 v103 v101 v104 v105 v106 v107 v108 v109 v110 ///
            v111 v112 v113 v002 v003 v2001 v2002 v201 v202 v203 v204 v205 v206 ///
            v236 v246 v256 v207 v208 v209 v210 v211 v301 v302 v303 v304 v305 v306 v307 ///
            v308 v309 v339 v310 v311 v341 v312 v313 v314 v315 v316 v346 v356 v366 v317 ///
            v347 v318 v319 v320 v350 v360 v321 v322 v323 v324 v325 v355 v326 v327 v328 ///
            escol v600 peso

      sa pme`year', replace

      cd ..

   }
}

****************************************************************
*End of Do file
****************************************************************
