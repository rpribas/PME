****************************************************************
* Building PME database (new version)
* Rafael Perez Ribas and Sergei Suarez Dillon Soares
* August 16, 2008
****************************************************************

****************************************************************
* System parameters
****************************************************************

set mem 1g
set virtual on
set more off
cd "C:\PME\Nova"


****************************************************************
* Filter for each year
****************************************************************

qui forvalues year = 2002/2008 {

   if `year' == 2002 {

      loc num1 = "03 04 05 06 07 08 09 10 11 12"
      loc num2 = "03 04 05 06 07 08 09 10 11"

   }

   else if `year' == 2008 {

      loc num1 = "01 02 03"
      loc num2 = "01 02"

   }

   else {

      loc num1 = "01 02 03 04 05 06 07 08 09 10 11 12"
      loc num2 = "01 02 03 04 05 06 07 08 09 10 11"

   }

   cd `year'

   * The data are divided by month.
   * We run the filter by month and after we join each file.

   foreach month in `num1' {

      #d ;

      infix v035 1-2            v040 3-10           v050 11-15
            v055 16             str1 v060 17        v063 18
            v070 19-20          v075 21-24          v072 25
            v104 26             v106 28-30          double v107 31-43
            double v108 44-58   v109 59-62          v110 63-68
            v111 69-72          v112 73-78          v113 79-83
            v114 84-92          v115 93-101         v201 102-103
            v203 104            v204 105-106        v214 107-108
            v224 109-112        v234 113-116        v205 117
            v206 118            v207 119            v208 120
            v209 121-122        v210 123-124        v211 125-131
            v215 132-138        v301 149            v302 150
            v303 151-152        v304 153            v305 154
            v306 155            v307 156-157        v308 158
            v309 159            v310 160            v311 161
            v312 162            v313 163            v314 164
            v401 165            v402 166            v403 167
            v404 168-169        v405 170            v4051 171-172
            v4052 173-174       v4053 175-176       v4054 177-178
            v406 179            v407a 180-182       v408a 183-184
            v409 185            v410 186            v411 187
            v412 188            v4121 189           v4122 190-191
            v413 192            v414 193            v415 194
            v416 195            v417 196            v418 197
            v4182 198-206       vi4182 207-215      v4191 216-224
            vi4191 225-233      v420 234            v421 235
            v422 236            v4221 237           v4222 238-239
            v4231 240-248       vi4231 249-257      v4241 258-266
            vi4241 267-275      v425 276            v426 277
            v4261 278           v4262 279-280       v427 281
            v4271 282-283       v4272 284-285       v4273 286-287
            v4275 288-289       v4274 290-291       v428 292-294
            v429 295-297        v430 298            v4302 299-307
            vi4302 308-316      v431 317            v4312 318-326
            vi4312 327-335      v432 336            v433 337-338
            v434 339-340        v435 341            v436 342
            v437 343            v438 344-345        v439 346
            v440 347            v441 348            v442 349
            v443 350            v444 351            v445a 352-354
            v446a 355-356       v447 357            v448 358
            v449 359            v450 360            v451 361
            v452 362            v4521 363-364       v4522 365-366
            v4523 367-368       v4524 369-370       v453 371
            v454 372            v4541 373-374       v4542 375-376
            v4543 377-378       v4544 379-380       v455 381
            v456 382            v457 383-384        v458 385
            v459 386            v460 387-388        v461 389-390
            v471 391-392        v481 393-396        v462 397-398
            v463 399            v4631 400-401       v4632 402-403
            v4633 404-405       v4634 406-407       v4635 408-409
            v464 410            v465 411            v466 412
            v467 413-415        v468 416            vd1 417
            vd2 418             vd3 419             vd4 420
            vd5 421             vd6 422             vd7 423
            vd8 424             vd9 425             vd10 426
            vd11 427            vd12 428            vd13 429
            vd14 430            vd15 431            vd16 432
            vd17 433            vd18 434            vd19 435
            vd20 436            vd21 437            vd22 438
            vd23 439-447        vd24 448-456        vd25 457-465
            vd26 466-474        vd27 475-477        vd28 478-480
            vdae1 481           vdae2 482
      using PMEnova.`month'`year'.txt, clear;

      #d cr

      * Saving temporary file

      compress
      tempfile t`month'`year'
      sa `t`month'`year'', replace

   }


   * Joining the data from consecutive months

   foreach month in `num2' {

      append using `t`month'`year''

   }

   cd ..

   cd Bases_dta

   * Saving the database by year

   sa pme`year', replace

   cd ..
}

****************************************************************
*End of Do file
****************************************************************
