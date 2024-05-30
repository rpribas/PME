****************************************************************
* Building PME panel (old version)
* Rafael Perez Ribas and Sergei Suarez Dillon Soares
* March 30, 2007
****************************************************************

****************************************************************
* System parameters
****************************************************************

set mem 900m
set virtual on
set more off
cd "C:\PME\Antiga\Bases_dta"


****************************************************************
* Building a pooled database and dividing it by panel
****************************************************************

forvalues i = 1/6 {

   qui {

      loc j = (2*`i') - 1
      loc ano = 1990 + `j'
      loc ano1 = 1991 + `j'
      loc ano2 = min(1992 + `j',2002)

      u pme`ano', clear

      if `ano1' != `ano2' {
         forvalues year = `ano1'/`ano2' {
            append using pme`year'
         }
      }
      else {
         append using pme`ano1'
      }

      keep if uf==33 | uf==35 | uf==43 | uf==31 | uf==26 | uf==29

      tempfile pme`i'
      sa `pme`i'', replace
   }
}


foreach panel in U V W X Y Z A B C D E F G H I J K L M N O {
qui {

   * 1991, 1992, 1993 (panels U V W X Y Z)
   if "`panel'" == "U" | "`panel'" == "V" | "`panel'" == "W" | ///
      "`panel'" == "X" | "`panel'" == "Y" | "`panel'" == "Z" {
      u `pme1' if panel == "`panel'", clear
   }

   * 1993, 1994, 1995 (panels A B C)
   else if "`panel'" == "A" | "`panel'" == "B" | "`panel'" == "C" {
      u `pme2' if panel == "`panel'", clear
   }

   * 1995, 1996, 1997 (panels D E F)
   else if "`panel'" == "D" | "`panel'" == "E" | "`panel'" == "F" {
      u `pme3' if panel == "`panel'", clear
   }

   * 1997, 1998, 1999 (panels G H I)
   else if "`panel'" == "G" | "`panel'" == "H" | "`panel'" == "I" {
      u `pme4' if panel == "`panel'", clear
   }

   * 1999, 2000, 2001 (panels J K L)
   else if "`panel'" == "J" | "`panel'" == "K" | "`panel'" == "L" {
      u `pme5' if panel == "`panel'", clear
   }

   * 2001, 2002 (panels M N O)
   else {
      u `pme6' if panel == "`panel'", clear
   }


   ****************************************************************
   * Matching of individuals
   ****************************************************************

   * Generating 'panel key' (order number in the panel)

   g p201 = v201 if entrev == 1 /* number defined based on the baseline */


   * Generating matching variables

   g back = . /* backward matched */

   g forw = . /* forward matched */


   * Matching by interview number 'i'

   forvalues i = 1/7 {


      ****************************************************************
      * Standard matching - if the birthday is correct
      ****************************************************************

      * Sorting individuals by their characteristics and month

      sort panel v106 v102 v103 v101 v202 v206 v236 v246 ano mes v201


      * Loop to look for the same observation below in the database

      loc j = 1    /*j determines the rank of the observations below*/
      loc stop = 0 /*if stop=1, the loop stops*/
      loc count = 0

      while `stop' == 0 {
         loc lastcount = `count'
         count if p201 == . & entrev == `i'+1 /* observations not matched*/
         loc count = r(N)
         if `count' == `lastcount' {
            loc stop = 1 /*stop if there is no more observations to match*/
         }
         else {
            if r(N) != 0 {

               /* Giving to observations below the panel key */

               replace p201 = p201[_n - `j'] ///
                              if panel == panel[_n - `j'] & ///
                                 v106 == v106[_n - `j'] & ///
                                 v102 == v102[_n - `j'] & ///
                                 v103 == v103[_n - `j'] & ///
                                 v101 == v101[_n - `j'] & ///
                                 v202 == v202[_n - `j'] & ///
                                 entrev == `i'+1 & entrev[_n - `j'] == `i' ///
                                 & p201 ==. & forw[_n - `j'] != 1 & /*
                                 Other characteristics
   birth day */                  v206 == v206[_n - `j'] & /*
   birth month */                v236 == v236[_n - `j'] & /*
   birth year */                 v246 == v246[_n - `j'] & /*
   non-missing bith date */      v206!=99 & v236!=99 & v246!=999


               /* Identifying forward matching*/

               replace forw = 1 if panel == panel[_n + `j'] & ///
                                   v106 == v106[_n + `j'] & ///
                                   v102 == v102[_n + `j'] & ///
                                   v103 == v103[_n + `j'] & ///
                                   v101 == v101[_n + `j'] & ///
                                   p201 == p201[_n + `j'] & ///
                                   entrev == `i' & entrev[_n + `j'] == `i'+1 ///
                                   & forw != 1

               loc j = `j' + 1 /*going to the next observation below*/
            }
            else {
               loc stop = 1 /*stop if there is no more observations to match*/
            }
         }
      }

      *Fulfill matching variables

      replace back = p201 !=. if entrev == `i'+1
      replace forw = 0 if forw != 1 & entrev == `i'


      ****************************************************************
      * Advanced matching - if the gender or birthyear is not correct
      ****************************************************************

      tempvar aux


      * Isolating matched observations

      g `aux' = (forw==1 & (entrev==1 | back==1)) | (back==1 & entrev==8)


      * Sorting individuals by household, month and their characteristics

      sort `aux' panel v106 v102 v103 v101 v206 v236 v201 ano mes


      * Loop to look for the same observation below in the database

      loc j = 1
      loc stop = 0
      loc count = 0

      while `stop' == 0 {
         loc lastcount = `count'
         count if p201==. & entrev==`i'+1
         loc count = r(N)
         if `count' == `lastcount' {
            loc stop = 1
         }
         else {
            if r(N) != 0 {

               /* Giving to observations below the panel key */

               replace p201 = p201[_n - `j'] ///
                              if panel == panel[_n - `j'] & ///
                                 v106 == v106[_n - `j'] & ///
                                 v102 == v102[_n - `j'] & ///
                                 v103 == v103[_n - `j'] & ///
                                 v101 == v101[_n - `j'] & ///
                                 entrev == `i'+1 & entrev[_n - `j'] == `i' ///
                                 & p201 ==. & forw[_n - `j'] != 1 & /*
                                 Other characteristics
   birth day */                  v206 == v206[_n - `j'] & /*
   birth month */                v236 == v236[_n - `j'] & /*
   the same order number */      v201 == v201[_n - `j'] & /*
   non-missing bith date */      v206!=99 & v236!=99


               /* Identifying forward matching*/

               replace forw = 1 if panel == panel[_n + `j'] & ///
                                   v106 == v106[_n + `j'] & ///
                                   v102 == v102[_n + `j'] & ///
                                   v103 == v103[_n + `j'] & ///
                                   v101 == v101[_n + `j'] & ///
                                   p201 == p201[_n + `j'] & ///
                                   entrev == `i' & entrev[_n + `j'] == `i'+1 ///
                                   & forw != 1

               loc j = `j' + 1
            }
            else {
               loc stop = 1
            }
         }
      }


      ****************************************************************
      * Advanced matching - just for heads, spouses and adult offspring
      ****************************************************************

      tempvar ager aux


      * Age error

      g `ager' = cond(v256>=25 & v256<999, exp(v256/30), 2)


      * Isolating matched observations

      g `aux' = (forw==1 & (entrev==1 | back==1)) | (back==1 & entrev==8)


      * Sorting individuals by household, month and their characteristics

      sort `aux' panel v106 v102 v103 v101 v202 ano mes v256 escol v201


      * Loop to look for the same observation below in the database

      loc j = 1
      loc stop = 0
      loc count = 0

      while `stop' == 0 {
         loc lastcount = `count'
         count if p201==. & entrev==`i'+1 & (v203<=2 | (v203==3 & v256>=25 ///
               & v256<999))
         loc count = r(N)
         if `count' == `lastcount' {
            loc stop = 1
         }
         else {
            if r(N) != 0 {

               /* Giving to observations below the panel key */

               replace p201 = p201[_n - `j'] ///
                              if panel == panel[_n - `j'] & ///
                                 v106 == v106[_n - `j'] & ///
                                 v102 == v102[_n - `j'] & ///
                                 v103 == v103[_n - `j'] & ///
                                 v101 == v101[_n - `j'] & ///
                                 v202 == v202[_n - `j'] & ///
                                 entrev == `i'+1 & entrev[_n - `j'] == `i' ///
                                 & p201 ==. & forw[_n - `j'] != 1 & /*
                                 Other characteristics
   age difference = f(age) */    abs(v256 - v256[_n - `j'])<=`ager' & ///
                                 v256!=999 & /*
   heads and spouses */          ((v203<=2 & v203[_n - `j']<=2) | /*
   or offspring older than 25 */ (v256>=25 & v256[_n - `j']>=25 & ///
                                 v203==3 & v203[_n - `j']==3)) & /*
   until 4 days of error */      ((abs(v206 - v206[_n - `j'])<=4 & /*
   until 2 months of error */    abs(v236 - v236[_n - `j'])<=2 & /*
   non-missing birth date */     v206!=99 & v236!=99) /*
   or */                         | /*
   1 school level error */       (abs(escol - escol[_n - `j'])<=1 /*
   and */                        & /*
   until 2 months of error */    ((abs(v236 - v236[_n - `j'])<=2 & /*
   non-missing birth month */    v236!=99 & (v206==99 | v206[_n - `j']==99)) /*
   or */                         | /*
   until 4 days of error */      (abs(v206 - v206[_n - `j'])<=4 & /*
   non-missing birth day */      v206!=99 & (v236==99 | v236[_n - `j']==99)) /*
   or */                         | /*
   nothing */                    ((v206==99 | v206[_n - `j']==99) & ///
                                 (v236==99 | v236[_n - `j']==99)))))


               /* Identifying forward matching */

               replace forw = 1 if panel == panel[_n + `j'] & ///
                                   v106 == v106[_n + `j'] & ///
                                   v102 == v102[_n + `j'] & ///
                                   v103 == v103[_n + `j'] & ///
                                   v101 == v101[_n + `j'] & ///
                                   p201 == p201[_n + `j'] & ///
                                   entrev == `i' & entrev[_n + `j'] == `i'+1 ///
                                   & forw != 1

               loc j = `j' + 1
            }
            else {
               loc stop = 1
            }
         }
      }

      *Fulfill matching variables

      replace back = p201 !=. if entrev == `i'+1
      replace forw = 0 if forw != 1 & entrev == `i'


      ****************************************************************
      * Advanced matching - just for individuals in matched households
      ****************************************************************

      * Count how many people have been matched in the household

      tempvar dom
      bys ano mes panel v106 v102 v103 v101: egen `dom' = sum(back)


      * Matching rules in the order:

      foreach w in /* the same age */ "0" /* age difference = 1 */ "1" /*
         age difference = 2 */ "2" /* age difference = f(age) */ "`ager'" /*
         age difference = 2*f(age) */ "2*`ager' & v256>=25" {


         * Isolating matched observations

         tempvar aux
         g `aux' = (forw==1 & (entrev==1 | back==1)) | (back==1 & entrev==8) | ///
                   (`dom'==0 & entrev==`i'+1)


         * Sorting individuals by household, month and their characteristics

         sort `aux' panel v106 v102 v103 v101 v202 ano mes v256 escol v201

         loc j = 1
         loc stop = 0
         loc count = 0

         while `stop' == 0 {
            loc lastcount = `count'
            count if p201 == . & entrev == `i'+1 & `dom'>0 & `dom'!=.
            loc count = r(N)
            if `count' == `lastcount' {
               loc stop = 1
            }
            else {
               if r(N) != 0 {

                  /* Giving to observations below the panel key */

                  replace p201 = p201[_n - `j'] ///
                                 if panel == panel[_n - `j'] & ///
                                    v106 == v106[_n - `j'] & ///
                                    v102 == v102[_n - `j'] & ///
                                    v103 == v103[_n - `j'] & ///
                                    v101 == v101[_n - `j'] & ///
                                    v202 == v202[_n - `j'] & ///
                                    entrev == `i'+1 & entrev[_n - `j'] == `i' ///
                                    & p201 ==. & forw[_n - `j'] != 1 & /*
                                    Other characteristics
   Matching rules defined above */  `dom' > 0 & `dom'!=. & ///
                                    ((abs(v256-v256[_n - `j'])<=`w' & ///
                                    v256!=999) | (escol==escol[_n - `j'] & ///
                                    v203==v203[_n - `j'] & (v256==999 | ///
                                    v256[_n - `j']==999)))


                  /* Identifying forward matching */

                  replace forw = 1 if panel == panel[_n + `j'] & ///
                                      v106 == v106[_n + `j'] & ///
                                      v102 == v102[_n + `j'] & ///
                                      v103 == v103[_n + `j'] & ///
                                      v101 == v101[_n + `j'] & ///
                                      p201 == p201[_n + `j'] & ///
                                      entrev == `i' & entrev[_n + `j'] == `i'+1 ///
                                      & forw != 1

                  loc j = `j' + 1
               }
               else {
                  loc stop = 1
               }
            }
         }
      }

      *Fulfill matching variables

      replace back = p201 !=. if entrev == `i'+1
      replace forw = 0 if forw != 1 & entrev == `i'


      * New panel key for the absent in the last interview

      replace p201 = `i'00 + v201 if p201 == . & entrev == `i'+1

   }


   ****************************************************************
   * Attrited returning
   ****************************************************************

   tempvar fill
   g `fill' = forw

   foreach i in 7 6 5 4 3 2 1 {

      tempvar ncode1 ncode2 aux max ager

      g `ager' = cond(v256>=25 & v256<999, exp(v256/30), 2)

      bys panel v106 v102 v103 v101 p201: g `ncode1' = 1000+p201

      g `aux' = ((`fill'==1 & (entrev==1 | back==1)) | (back==1 & entrev==8))

      bys panel v106 v102 v103 v101 p201: egen `max' = max(entrev)

      sort `aux' panel v106 v102 v103 v101 v202 entrev v201 p201

      loc j = 1
      loc stop = 0
      loc count = 0

      while `stop' == 0 {
         loc lastcount = `count'
         count if p201>`i'00 & p201<`i'99 & back==0
         loc count = r(N)
         if `count' == `lastcount' {
            loc stop = 1
         }
         else {
            if r(N) != 0 {

               replace p201 = p201[_n - `j'] ///
                              if panel == panel[_n - `j'] & ///
                                 v106 == v106[_n - `j'] & ///
                                 v102 == v102[_n - `j'] & ///
                                 v103 == v103[_n - `j'] & ///
                                 v101 == v101[_n - `j'] & ///
                                 v202 == v202[_n - `j'] & ///
                                 p201>`i'00 & p201<`i'99 & ///
                                 back==0 & `fill'[_n - `j']!=1 & ///
                                 `max'[_n - `j']<`i' & ///
                                 p201[_n - `j']<`i'00-100 & ///
                                 ((abs(v256 - v256[_n - `j'])<=`ager' & ///
                                 v256!=999 & ((abs(v206 - v206[_n - `j'])<=4 & ///
                                 abs(v236 - v236[_n - `j'])<=2 & v206!=99 & ///
                                 v236!=99) | (abs(escol - escol[_n - `j'])<=1 & ///
                                 ((abs(v236 - v236[_n - `j'])<=2 & v236!=99 & ///
                                 (v206==99 | v206[_n - `j']==99)) | ///
                                 (abs(v206 - v206[_n - `j'])<=4 & ///
                                 v206!=99 & (v236==99 | v236[_n - `j']==99)) | ///
                                 ((v206==99 | v206[_n - `j']==99) & ///
                                 (v236==99 | v236[_n - `j']==99)))))) | ///
                                 (escol==escol[_n - `j'] & v203==v203[_n - `j'] ///
                                 & (v256==999 | v256[_n - `j']==999)))

               replace `fill' = 1 if panel == panel[_n + `j'] & ///
                                     v106 == v106[_n + `j'] & ///
                                     v102 == v102[_n + `j'] & ///
                                     v103 == v103[_n + `j'] & ///
                                     v101 == v101[_n + `j'] & ///
                                     p201 == p201[_n + `j'] & ///
                                     `fill' == 0 & `max'<`i' & ///
                                     (entrev[_n + `j'] - entrev)>=2

               loc j = `j' + 1
            }
            else {
               loc stop = 1
            }
         }
      }

      bys panel v106 v102 v103 v101 `ncode1': egen `ncode2' = min(p201)
      replace p201 = `ncode2'

   }

   * Saving file for each panel

   capture drop __*
   compress
   sa panel`panel', replace

}
}

****************************************************************
*End of Do file
****************************************************************
