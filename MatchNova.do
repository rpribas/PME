****************************************************************
* Building PME panel (new version)
* Rafael Perez Ribas and Sergei Suarez Dillon Soares
* August 16, 2008
****************************************************************

****************************************************************
* System parameters
****************************************************************

set mem 1g
set virtual on
set more off
cd "C:\PME\Nova\Bases_dta"


****************************************************************
* Building a pooled database and dividing it by panel
****************************************************************

qui foreach panel in A B C D E F G H I J K L {

   forvalues year = 2002/2008 {
      u pme`year' if v060 == "`panel'", clear
      tempfile `panel'`year'
      sa ``panel'`year'', replace
   }

   u ``panel'2002', clear

   forvalues year = 2003/2008 {
      append using ``panel'`year''
   }


   ****************************************************************
   * Matching of individuals
   ****************************************************************

   * Generating 'panel key' (order number in the panel)

   g p201 = v201 if v072 == 1 /* number defined based on the baseline */


   * Generating matching variables

   g back = . /* backward matched */

   g forw = . /* forward matched */


   * Matching by interview number 'i'

   forvalues i = 1/7 {


      ****************************************************************
      * Standard matching - if the birthday is correct
      ****************************************************************

      * Sorting individuals by their characteristics and month

      sort v035 v040 v050 v060 v063 v203 v204 v214 v224 v075 v070 v201


      * Loop to look for the same observation below in the database

      loc j = 1    /*j determines the rank of the observations below*/
      loc stop = 0 /*if stop=1, the loop stops*/
      loc count = 0

      while `stop' == 0 {
         loc lastcount = `count'
         count if p201 == . & v072 == `i'+1 /* observations not matched*/
         loc count = r(N)
         if `count' == `lastcount' {
            loc stop = 1 /*stop if there is no more observations to match*/
         }
         else {
            if r(N) != 0 {

               /* Giving to observations below the panel key */

               replace p201 = p201[_n - `j'] ///
                              if v035 == v035[_n - `j'] & ///
                                 v040 == v040[_n - `j'] & ///
                                 v050 == v050[_n - `j'] & ///
                                 v060 == v060[_n - `j'] & ///
                                 v063 == v063[_n - `j'] & ///
                                 v203 == v203[_n - `j'] & ///
                                 v072 == `i'+1 & v072[_n - `j'] == `i' ///
                                 & p201 ==. & forw[_n - `j'] != 1 & /*
                                 Other characteristics
   birth day */                  v204 == v204[_n - `j'] & /*
   birth month */                v214 == v214[_n - `j'] & /*
   birth year */                 v224 == v224[_n - `j'] & /*
   non-missing bith date */      v204!=99 & v214!=99 & v224!=9999


               /* Identifying forward matching*/

               replace forw = 1 if v035 == v035[_n + `j'] & ///
                                   v040 == v040[_n + `j'] & ///
                                   v050 == v050[_n + `j'] & ///
                                   v060 == v060[_n + `j'] & ///
                                   v063 == v063[_n + `j'] & ///
                                   p201 == p201[_n + `j'] & ///
                                   v072 == `i' & v072[_n + `j'] == `i'+1 ///
                                   & forw != 1

               loc j = `j' + 1 /*going to the next observation below*/
            }
            else {
               loc stop = 1 /*stop if there is no more observations to match*/
            }
         }
      }

      *Fulfill matching variables

      replace back = p201 !=. if v072 == `i'+1
      replace forw = 0 if forw != 1 & v072 == `i'


      ****************************************************************
      * Advanced matching - if the gender or birthyear is not correct
      ****************************************************************

      tempvar aux


      * Isolating matched observations

      g `aux' = (forw==1 & (v072==1 | back==1)) | (back==1 & v072==8)


      * Sorting individuals by household, month and their characteristics

      sort `aux' v035 v040 v050 v060 v063 v204 v214 v201 v075 v070


      * Loop to look for the same observation below in the database

      loc j = 1
      loc stop = 0
      loc count = 0

      while `stop' == 0 {
         loc lastcount = `count'
         count if p201==. & v072==`i'+1
         loc count = r(N)
         if `count' == `lastcount' {
            loc stop = 1
         }
         else {
            if r(N) != 0 {

               /* Giving to observations below the panel key */

               replace p201 = p201[_n - `j'] ///
                              if v035 == v035[_n - `j'] & ///
                                 v040 == v040[_n - `j'] & ///
                                 v050 == v050[_n - `j'] & ///
                                 v060 == v060[_n - `j'] & ///
                                 v063 == v063[_n - `j'] & ///
                                 v072 == `i'+1 & v072[_n - `j'] == `i' ///
                                 & p201 ==. & forw[_n - `j'] != 1 & /*
                                 Other characteristics
   birth day */                  v204 == v204[_n - `j'] & /*
   birth month */                v214 == v214[_n - `j'] & /*
   the same order number */      v201 == v201[_n - `j'] & /*
   non-missing bith date */      v204!=99 & v214!=99


               /* Identifying forward matching*/

               replace forw = 1 if v035 == v035[_n + `j'] & ///
                                   v040 == v040[_n + `j'] & ///
                                   v050 == v050[_n + `j'] & ///
                                   v060 == v060[_n + `j'] & ///
                                   v063 == v063[_n + `j'] & ///
                                   p201 == p201[_n + `j'] & ///
                                   v072 == `i' & v072[_n + `j'] == `i'+1 ///
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

      g `ager' = cond(v234>=25 & v234<999, exp(v234/30), 2)


      * Isolating matched observations

      g `aux' = (forw==1 & (v072==1 | back==1)) | (back==1 & v072==8)


      * Sorting individuals by household, month and their characteristics

      sort `aux' v035 v040 v050 v060 v063 v203 v075 v070 v234 vdae1 v201


      * Loop to look for the same observation below in the database

      loc j = 1
      loc stop = 0
      loc count = 0

      while `stop' == 0 {
         loc lastcount = `count'
         count if p201==. & v072==`i'+1 & (v205<=2 | (v205==3 & v234>=25 ///
               & v234<999))
         loc count = r(N)
         if `count' == `lastcount' {
            loc stop = 1
         }
         else {
            if r(N) != 0 {

               /* Giving to observations below the panel key */

               replace p201 = p201[_n - `j'] ///
                              if v035 == v035[_n - `j'] & ///
                                 v040 == v040[_n - `j'] & ///
                                 v050 == v050[_n - `j'] & ///
                                 v060 == v060[_n - `j'] & ///
                                 v063 == v063[_n - `j'] & ///
                                 v203 == v203[_n - `j'] & ///
                                 v072 == `i'+1 & v072[_n - `j'] == `i' ///
                                 & p201 ==. & forw[_n - `j'] != 1 & /*
                                 Other characteristics
   age difference = f(age) */    abs(v234 - v234[_n - `j'])<=`ager' & ///
                                 v234!=999 & /*
   heads and spouses */          ((v205<=2 & v205[_n - `j']<=2) | /*
   or offspring older than 25 */ (v234>=25 & v234[_n - `j']>=25 & ///
                                 v205==3 & v205[_n - `j']==3)) & /*
   until 4 days of error */      ((abs(v204 - v204[_n - `j'])<=4 & /*
   until 2 months of error */    abs(v214 - v214[_n - `j'])<=2 & /*
   non-missing birth date */     v204!=99 & v214!=99) /*
   or */                         | /*
   1 school level error */       (abs(vdae1 - vdae1[_n - `j'])<=1 /*
   and */                        & /*
   until 2 months of error */    ((abs(v214 - v214[_n - `j'])<=2 & /*
   non-missing birth month */    v214!=99 & (v204==99 | v204[_n - `j']==99)) /*
   or */                         | /*
   until 4 days of error */      (abs(v204 - v204[_n - `j'])<=4 & /*
   non-missing birth day */      v204!=99 & (v214==99 | v214[_n - `j']==99)) /*
   or */                         | /*
   nothing */                    ((v204==99 | v204[_n - `j']==99) & ///
                                 (v214==99 | v214[_n - `j']==99)))))


               /* Identifying forward matching */

               replace forw = 1 if v035 == v035[_n + `j'] & ///
                                   v040 == v040[_n + `j'] & ///
                                   v050 == v050[_n + `j'] & ///
                                   v060 == v060[_n + `j'] & ///
                                   v063 == v063[_n + `j'] & ///
                                   p201 == p201[_n + `j'] & ///
                                   v072 == `i' & v072[_n + `j'] == `i'+1 ///
                                   & forw != 1

               loc j = `j' + 1
            }
            else {
               loc stop = 1
            }
         }
      }

      *Fulfill matching variables

      replace back = p201 !=. if v072 == `i'+1
      replace forw = 0 if forw != 1 & v072 == `i'


      ****************************************************************
      * Advanced matching - just for individuals in matched households
      ****************************************************************

      * Count how many people have been matched in the household

      tempvar dom
      bys v075 v070 v035 v040 v050 v060 v063: egen `dom' = sum(back)


      * Matching rules in the order:

      foreach w in /* the same age */ "0" /* age difference = 1 */ "1" /*
         age difference = 2 */ "2" /* age difference = f(age) */ "`ager'" /*
         age difference = 2*f(age) */ "2*`ager' & v234>=25" {


         * Isolating matched observations

         tempvar aux
         g `aux' = (forw==1 & (v072==1 | back==1)) | (back==1 & v072==8) | ///
                   (`dom'==0 & v072==`i'+1)


         * Sorting individuals by household, month and their characteristics

         sort `aux' v035 v040 v050 v060 v063 v203 v075 v070 v234 vdae1 v201

         loc j = 1
         loc stop = 0
         loc count = 0

         while `stop' == 0 {
            loc lastcount = `count'
            count if p201 == . & v072 == `i'+1 & `dom'>0 & `dom'!=.
            loc count = r(N)
            if `count' == `lastcount' {
               loc stop = 1
            }
            else {
               if r(N) != 0 {

                  /* Giving to observations below the panel key */

                  replace p201 = p201[_n - `j'] ///
                                 if v035 == v035[_n - `j'] & ///
                                    v040 == v040[_n - `j'] & ///
                                    v050 == v050[_n - `j'] & ///
                                    v060 == v060[_n - `j'] & ///
                                    v063 == v063[_n - `j'] & ///
                                    v203 == v203[_n - `j'] & ///
                                    v072 == `i'+1 & v072[_n - `j'] == `i' ///
                                    & p201 ==. & forw[_n - `j'] != 1 & /*
                                    Other characteristics
   Matching rules defined above */  `dom' > 0 & `dom'!=. & ///
                                    ((abs(v234-v234[_n - `j'])<=`w' & ///
                                    v234!=999) | (vdae1==vdae1[_n - `j'] & ///
                                    v205==v205[_n - `j'] & (v234==999 | ///
                                    v234[_n - `j']==999)))


                  /* Identifying forward matching */

                  replace forw = 1 if v035 == v035[_n + `j'] & ///
                                      v040 == v040[_n + `j'] & ///
                                      v050 == v050[_n + `j'] & ///
                                      v060 == v060[_n + `j'] & ///
                                      v063 == v063[_n + `j'] & ///
                                      p201 == p201[_n + `j'] & ///
                                      v072 == `i' & v072[_n + `j'] == `i'+1 ///
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

      replace back = p201 !=. if v072 == `i'+1
      replace forw = 0 if forw != 1 & v072 == `i'


      * New panel key for the absent in the last interview

      replace p201 = `i'00 + v201 if p201 == . & v072 == `i'+1

   }


   ****************************************************************
   * Attrited returning
   ****************************************************************

   tempvar fill
   g `fill' = forw

   foreach i in 7 6 5 4 3 2 1 {

      tempvar ncode1 ncode2 aux max ager

      g `ager' = cond(v234>=25 & v234<999, exp(v234/30), 2)

      bys v035 v040 v050 v060 v063 p201: g `ncode1' = 1000+p201

      g `aux' = ((`fill'==1 & (v072==1 | back==1)) | (back==1 & v072==8))

      bys v035 v040 v050 v060 v063 p201: egen `max' = max(v072)

      sort `aux' v035 v040 v050 v060 v063 v203 v072 v201 p201

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
                              if v035 == v035[_n - `j'] & ///
                                 v040 == v040[_n - `j'] & ///
                                 v050 == v050[_n - `j'] & ///
                                 v060 == v060[_n - `j'] & ///
                                 v063 == v063[_n - `j'] & ///
                                 v203 == v203[_n - `j'] & ///
                                 p201>`i'00 & p201<`i'99 & ///
                                 back==0 & `fill'[_n - `j']!=1 & ///
                                 `max'[_n - `j']<`i' & ///
                                 p201[_n - `j']<`i'00-100 & ///
                                 ((abs(v234 - v234[_n - `j'])<=`ager' & ///
                                 v234!=999 & ((abs(v204 - v204[_n - `j'])<=4 & ///
                                 abs(v214 - v214[_n - `j'])<=2 & v204!=99 & ///
                                 v214!=99) | (abs(vdae1 - vdae1[_n - `j'])<=1 & ///
                                 ((abs(v214 - v214[_n - `j'])<=2 & v214!=99 & ///
                                 (v204==99 | v204[_n - `j']==99)) | ///
                                 (abs(v204 - v204[_n - `j'])<=4 & ///
                                 v204!=99 & (v214==99 | v214[_n - `j']==99)) | ///
                                 ((v204==99 | v204[_n - `j']==99) & ///
                                 (v214==99 | v214[_n - `j']==99)))))) | ///
                                 (vdae1==vdae1[_n - `j'] & v205==v205[_n - `j'] ///
                                 & (v234==999 | v234[_n - `j']==999)))

               replace `fill' = 1 if v035 == v035[_n + `j'] & ///
                                     v040 == v040[_n + `j'] & ///
                                     v050 == v050[_n + `j'] & ///
                                     v060 == v060[_n + `j'] & ///
                                     v063 == v063[_n + `j'] & ///
                                     p201 == p201[_n + `j'] & ///
                                     `fill' == 0 & `max'<`i' & ///
                                     (v072[_n + `j'] - v072)>=2

               loc j = `j' + 1
            }
            else {
               loc stop = 1
            }
         }
      }

      bys v035 v040 v050 v060 v063 `ncode1': egen `ncode2' = min(p201)
      replace p201 = `ncode2'

   }

   * Saving file for each panel

   capture drop __*
   compress
   sa panel`panel', replace
}

****************************************************************
*End of Do file
****************************************************************
