****************************************************************
* Imputation of non-labor income at PME
* Rafael Perez Ribas and Ana Flávia Machado
* August 18, 2008
****************************************************************

****************************************************************
* System parameters
****************************************************************

clear
set mem 1g
set maxvar 20000
set matsize 5000
set virtual on
set more off
cd "C:\PME\Nova\Bases_dta"

capture log close
log using "c:\Users\Rafael\Documents\Imputação PME\log pnad\stepwise.log", replace


loc pa

foreach uf in 26 29 31 33 35 43 {

   qui est drop _all

   *******************************************************************
   * Base - PNAD, UF = `uf'
   *******************************************************************

   qui use transfpnad, clear
   qui gen rtrabpc = rtrabdom/membros
   qui bys ano: quantiles rtrabpc if chefe==1 [w=v4729], gen(points) n(10)

   qui forvalues year = 2002/2006 {
      su rtrabpc if chefe==1 & ano==`year' & points==6 [w=v4729]
      sca cut`year' = r(max)
   }

   qui keep if UF==`uf'

   *******************************************************************
   * Stepwise - PNAD, UF = `uf'
   *******************************************************************

   forvalues year = 2002/2006 {

      di "Aposentadoria - Probabilidade, ANO = `year', UF = `uf'"
      qui {
         tempvar prob xb y e e2 A lne2 r
         g `prob' = lnrapos>0 if lnrapos!=.
      }
      sw, pe(.05) forw loc: probit `prob' ///
         (condact1 outtrabalhadores) lnmembros estendida conjuge ///
         pidativa criancas criancas2 adolesc1 adolesc2 idosos homem ///
         branco idade idade2 idade40 idade50 idade65 casado ///
         (educ2-educ8) condact2 tevetrab tempotant tempodesocup ///
         contribui tempotrab posocup2 skill2 skill3 lnrtrab ///
         lnrtrabdom2 desempregados eramocupados mais1ano2 adulmed ///
         adulsup trabmedios trabsuper formais contribuintes ///
         trabinfantil analf analfunc adulfund adulfund2 ///
         if idade>=30 & UF==`uf' & ano==`year' [pw=v4729]
      est store pap`uf'`year'

      qui {
         predict `xb', xb
         g mills = normalden(`xb')/normal(`xb')
      }

      di "Aposentadoria - Média, ANO = `year', UF = `uf'"
      sw, pe(.05) forw loc: reg lnrapos (mills ///
         condact1 outtrabalhadores) lnmembros estendida conjuge ///
         pidativa criancas criancas2 adolesc1 adolesc2 idosos homem ///
         branco idade idade2 idade40 idade50 idade65 casado ///
         (educ2-educ8) condact2 tevetrab tempotant tempodesocup ///
         contribui tempotrab posocup2 skill2 skill3 lnrtrab ///
         lnrtrabdom2 desempregados eramocupados mais1ano2 adulmed ///
         adulsup trabmedios trabsuper formais contribuintes ///
         trabinfantil analf analfunc adulfund adulfund2 ///
         if lnrapos>0 & idade>=30 & UF==`uf' & ano==`year' ///
         [aw=v4729]
      est store yap`uf'`year'

      qui {
         predict `y' if e(sample)
         predict `e' if e(sample), r
         gen `e2' = `e'^2
         qui su `e2'
         sca Aap`uf'`year' = 1.05*r(max)
         gen `lne2' = ln(`e2'/(Aap`uf'`year' - `e2'))
      }

      di "Aposentadoria - Variância, ANO = `year', UF = `uf'"
      sw, pe(.05) forw loc: reg `lne2' ///
         (condact1 outtrabalhadores) lnmembros estendida conjuge ///
         pidativa criancas criancas2 adolesc1 adolesc2 idosos homem ///
         branco idade idade2 idade40 idade50 idade65 casado ///
         (educ2-educ8) condact2 tevetrab tempotant tempodesocup ///
         contribui tempotrab posocup2 skill2 skill3 lnrtrab ///
         lnrtrabdom2 desempregados eramocupados mais1ano2 adulmed ///
         adulsup trabmedios trabsuper formais contribuintes ///
         trabinfantil analf analfunc adulfund adulfund2 [aw=v4729]
      est store eap`uf'`year'

      qui {
         predict `r', r
         su `r' [aw=v4729]
         sca rap`uf'`year' = r(Var)
         drop __* mills
      }

      di "Pensão - Probabilidade, ANO = `year', UF = `uf'"
      qui {
         tempvar prob xb y e e2 A lne2 r
         g `prob' = lnrpens>0 if lnrpens!=.
      }
      sw, pe(.05) forw loc: probit `prob' ///
         (condact1 outtrabalhadores) lnmembros estendida conjuge ///
         pidativa criancas criancas2 adolesc1 adolesc2 idosos homem ///
         branco idade idade2 idade40 idade50 idade65 casado ///
         (educ2-educ8) condact2 tevetrab tempotant tempodesocup ///
         contribui tempotrab posocup2 skill2 skill3 lnrtrab ///
         lnrtrabdom2 desempregados eramocupados mais1ano2 adulmed ///
         adulsup trabmedios trabsuper formais contribuintes ///
         trabinfantil analf analfunc adulfund adulfund2 ///
         if UF==`uf' & ano==`year' [pw=v4729]
      est store ppe`uf'`year'

      qui {
         predict `xb', xb
         g mills = normalden(`xb')/normal(`xb')
      }

      di "Pensão - Média, ANO = `year', UF = `uf'"
      sw, pe(.05) forw loc: reg lnrpens (mills ///
         condact1 outtrabalhadores) lnmembros estendida conjuge ///
         pidativa criancas criancas2 adolesc1 adolesc2 idosos homem ///
         branco idade idade2 idade40 idade50 idade65 casado ///
         (educ2-educ8) condact2 tevetrab tempotant tempodesocup ///
         contribui tempotrab posocup2 skill2 skill3 lnrtrab ///
         lnrtrabdom2 desempregados eramocupados mais1ano2 adulmed ///
         adulsup trabmedios trabsuper formais contribuintes ///
         trabinfantil analf analfunc adulfund adulfund2 ///
         if lnrpens>0 & UF==`uf' & ano==`year' [aw=v4729]
      est store ype`uf'`year'

      qui {
         predict `y' if e(sample)
         predict `e' if e(sample), r
         gen `e2' = `e'^2
         qui su `e2'
         sca Ape`uf'`year' = 1.05*r(max)
         gen `lne2' = ln(`e2'/(Ape`uf'`year' - `e2'))
      }

      di "Pensão - Variância, ANO = `year', UF = `uf'"
      sw, pe(.05) forw loc: reg `lne2' ///
         (condact1 outtrabalhadores) lnmembros estendida conjuge ///
         pidativa criancas criancas2 adolesc1 adolesc2 idosos homem ///
         branco idade idade2 idade40 idade50 idade65 casado ///
         (educ2-educ8) condact2 tevetrab tempotant tempodesocup ///
         contribui tempotrab posocup2 skill2 skill3 lnrtrab ///
         lnrtrabdom2 desempregados eramocupados mais1ano2 adulmed ///
         adulsup trabmedios trabsuper formais contribuintes ///
         trabinfantil analf analfunc adulfund adulfund2 [aw=v4729]
      est store epe`uf'`year'

      qui {
         predict `r', r
         su `r' [aw=v4729]
         sca rpe`uf'`year' = r(Var)
         drop __* mills
      }

      di "Outras rendas dos mais pobres - Probabilidade, ANO = `year', UF = `uf'"
      qui {
         tempvar prob xb y e e2 A lne2 r
         g `prob' = lnroutras>0 if lnroutras!=.
      }
      sw, pe(.05) forw loc: probit `prob' ///
         (trabalhadores)lnmembros estendida conjuge pidativa criancas ///
         criancas2 adolesc1 adolesc2 idosos chefehomem chefebranco ///
         idadechefe idadechefe2 idadch40 idadch50 idadch65 ///
         (educhefe2-educhefe8) lnrtrabdom desempregados eramocupados ///
         trabalhadores2 mais1ano trabmedios trabsuper formais ///
         contribuintes adulfund adulfund2 adulmed adulsup ///
         analf analfunc trabinfantil ///
         if chefe==1 & rtrabpc<=cut`year' & UF==`uf' & ano==`year' [pw=v4729]
      est store pop`uf'`year'

      qui {
         predict `xb', xb
         g mills = normalden(`xb')/normal(`xb')
      }

      di "Outras rendas dos mais pobres - Média, ANO = `year', UF = `uf'"
      sw, pe(.05) forw loc: reg lnroutras (mills ///
         trabalhadores)lnmembros estendida conjuge pidativa criancas ///
         criancas2 adolesc1 adolesc2 idosos chefehomem chefebranco ///
         idadechefe idadechefe2 idadch40 idadch50 idadch65 ///
         (educhefe2-educhefe8) lnrtrabdom desempregados eramocupados ///
         trabalhadores2 mais1ano trabmedios trabsuper formais ///
         contribuintes adulfund adulfund2 adulmed adulsup ///
         analf analfunc trabinfantil ///
         if lnroutras>0 & chefe==1 & rtrabpc<=cut`year' & UF==`uf' & ///
         ano==`year' [aw=v4729]
      est store yop`uf'`year'

      qui {
         predict `y' if e(sample)
         predict `e' if e(sample), r
         gen `e2' = `e'^2
         qui su `e2'
         sca Aop`uf'`year' = 1.05*r(max)
         gen `lne2' = ln(`e2'/(Aop`uf'`year' - `e2'))
      }

      di "Outras rendas dos mais pobres - Variância, ANO = `year', UF = `uf'"
      sw, pe(.05) forw loc: reg `lne2' ///
         (trabalhadores) lnmembros estendida conjuge pidativa criancas ///
         criancas2 adolesc1 adolesc2 idosos chefehomem chefebranco ///
         idadechefe idadechefe2 idadch40 idadch50 idadch65 ///
         (educhefe2-educhefe8) lnrtrabdom desempregados eramocupados ///
         trabalhadores2 mais1ano trabmedios trabsuper formais ///
         contribuintes adulfund adulfund2 adulmed adulsup ///
         analf analfunc trabinfantil [aw=v4729]
      est store eop`uf'`year'

      qui {
         predict `r', r
         su `r' [aw=v4729]
         sca rop`uf'`year' = r(Var)
         drop __* mills
      }

      di "Outras rendas dos mais ricos - Probabilidade, ANO = `year', UF = `uf'"
      qui {
         tempvar prob xb y e e2 A lne2 r
         g `prob' = lnroutras>0 if lnroutras!=.
      }
      sw, pe(.05) forw: probit `prob' ///
         lnmembros estendida conjuge pidativa criancas ///
         criancas2 adolesc1 adolesc2 idosos chefehomem chefebranco ///
         idadechefe idadechefe2 idadch40 idadch50 idadch65 ///
         (educhefe3-educhefe8) lnrtrabdom desempregados eramocupados ///
         trabalhadores2 mais1ano trabmedios trabsuper formais ///
         contribuintes adulfund adulfund2 adulmed adulsup ///
         analfunc ///
         if chefe==1 & rtrabpc>cut`year' & rtrabpc!=. & UF==`uf' & ///
         ano==`year' [pw=v4729]
      est store por`uf'`year'

      qui {
         predict `xb', xb
         g mills = normalden(`xb')/normal(`xb')
      }

      di "Outras rendas dos mais ricos - Média, ANO = `year', UF = `uf'"
      sw, pe(.05) forw: reg lnroutras (mills) ///
         lnmembros estendida conjuge pidativa criancas ///
         criancas2 adolesc1 adolesc2 idosos chefehomem chefebranco ///
         idadechefe idadechefe2 idadch40 idadch50 idadch65 ///
         (educhefe3-educhefe8) lnrtrabdom desempregados eramocupados ///
         trabalhadores2 mais1ano trabmedios trabsuper formais ///
         contribuintes adulfund adulfund2 adulmed adulsup ///
         analfunc ///
         if lnroutras>0 & chefe==1 & rtrabpc>cut`year' & rtrabpc!=. & ///
         UF==`uf' & ano==`year' [aw=v4729]
      est store yor`uf'`year'

      qui {
         predict `y' if e(sample)
         predict `e' if e(sample), r
         gen `e2' = `e'^2
         qui su `e2'
         sca Aor`uf'`year' = 1.05*r(max)
         gen `lne2' = ln(`e2'/(Aor`uf'`year' - `e2'))
      }

      di "Outras rendas dos mais ricos - Variância, ANO = `year', UF = `uf'"
      sw, pe(.05) forw: reg `lne2' ///
         lnmembros estendida conjuge pidativa criancas ///
         criancas2 adolesc1 adolesc2 idosos chefehomem chefebranco ///
         idadechefe idadechefe2 idadch40 idadch50 idadch65 ///
         (educhefe3-educhefe8) lnrtrabdom desempregados eramocupados ///
         trabalhadores2 mais1ano trabmedios trabsuper formais ///
         contribuintes adulfund adulfund2 adulmed adulsup ///
         analfunc [aw=v4729]
      est store eor`uf'`year'

      qui {
         predict `r', r
         su `r' [aw=v4729]
         sca ror`uf'`year' = r(Var)
         drop __* mills
      }
   }

   ****************************************************************
   * Building the specific database, UF = `uf'
   ****************************************************************

   qui foreach p in A B C D E F G H I J K L {

      u panel`p' if v035==`uf', clear

      drop if v205>=6

      sort v063 v035 v040 v050 v075 v070 v201
      gen chefe = v205==1
      gen iddom = sum(chefe)

      bysort iddom: gen membros = _N
      gen lnmembros = ln(membros)

      * Anos de estudo
      g educ = 0 if (v302==2 & v306==2) | v303==6 | v303==7 | v307==7 | v307==8 | ///
                    ((v303==1 | v303==3) & ((v304==2 & v301==2) | v305==1)) | ///
                    ((v307==1 | v307==4) & v309==2) | (v307==4 & v308==2 & v311==2)
      replace educ = 1 if ((v303==1 | v303==3) & ((v304==2 & v301==1) | v305==2)) | ///
                          ((v307==1 | v307==4) & v310==1)
      replace educ = 2 if ((v303==1 | v303==3) & v305==3) | ///
                          ((v307==1 | v307==4) & v310==2)
      replace educ = 3 if ((v303==1 | v303==3) & v305==4) | ///
                          ((v307==1 | v307==4) & v310==3)
      replace educ = 4 if ((v303==1 | v303==3) & v305==5) | ///
                          ((v307==1 | v307==4) & v310==4) | ///
                          (v307==2 & v308==2 & v311==2) | (v307==2 & v309==2)
      replace educ = 5 if ((v303==1 | v303==3) & v305==6) | ///
                          ((v307==1 | v307==4) & v310==5) | (v307==2 & v310==1)
      replace educ = 6 if ((v303==1 | v303==3) & v305==7) | ///
                          ((v307==1 | v307==4) & v310==6) | (v307==2 & v310==2)
      replace educ = 7 if ((v303==1 | v303==3) & v305==8) | (v307==4 & v310==7) | ///
                          (v307==2 & v310==3)
      replace educ = 8 if (v303==2 & v305==1) | v303==4 | ///
                          (v307==2 & ((v308==2 & v311==1) | ///
                          v310==4)) | (v307==4 & v311==1) | ///
                          ((v307==3 | v307==5) & (v309==2 | (v308==2 & v311==2)))
      replace educ = 9 if (v303==2 & v305==2) | (v307==2 & v310==5) | ///
                          ((v307==3 | v307==5) & v310==1)
      replace educ = 10 if (v303==2 & v305==3) | ((v307==3 | v307==5) & v310==2)
      replace educ = 11 if (v303==2 & v305==4) | v303==8 | (v303==5 & v305==1) | ///
                           ((v307==3 | v307==5) & ((v308==2 & v311==1) | ///
                           v310==3 | v310==4)) | (v307==6 & v309==2)
      replace educ = 12 if (v303==5 & v305==2) | (v307==6 & v310==1)
      replace educ = 13 if (v303==5 & v305==3) | (v307==6 & v310==2 & v311==2)
      replace educ = 14 if (v303==5 & v305>=4 & v305<=6) | ///
                           (v307==6 & v310>=3 & v310<=6 & v311==2)
      replace educ = 15 if v303==9 | (v307==6 & v311==1) | v307==9

      *recodificação de sexo e anos de estudo
      recode v203 2=0, g(homem)
      recode educ (2 3 = 1) (6 7 = 5) (10 = 9) (12/14 = 11)
      tab educ, g(educ)

      *recodificação de cor
      recode v208 (3=1) (2 4 5=0) (9=.), g(branco)

      *variáveis de idade
      gen idade = v234 if v234<121
      gen idade2 = idade^2
      gen idade40 = idade>=40 if idade!=.
      gen idade50 = idade>=50 if idade!=.
      gen idade65 = idade>=65 if idade!=.

      *condição de atividade
      recode vd1 (1=1 "Working") (2=2 "Seeking") (3=3 "Inactive"), g(condact)
      ta condact, g(condact)

      *já teve um emprego (se é desocupado)
      gen tevetrab = v442==1 | v444==1

      *mais de 1 ano que saiu do último emprego
      gen tempodesocup = v4543!=. | v4542!=.

      *mais de um ano no trabalho anterior
      gen tempotant = v4523!=.

      *contribuição para previdência
      g contribui = vd21==1

      *tempo no trabalho - mais de um ano no emprego
      g tempotrab = v4274!=.

      *Separando os conta-própria dos profissionais liberais
      gen vcp = v407a!=101 | v407a!=102 | v407a!=26 if vd15==2

      * Posição na ocupação
      g posocup = v415==1 | vd17==5 | (vd15==3 & v422>1 & v422<=3) | vcp==0
      recode posocup 0=2 if vd1==1
      ta posocup, g(posocup)
      drop vcp

      * Qualificação dos trabalhadores
       recode v407a (1/5 11/13 26 51 77 78 91 99 100/102 = 1 "superior") ///
                    (103/104 30/42 95 = 2 "médio") ///
                    (105/112 61/76 81/89 = 3 "manual") ///
                    (. = 0 "desocupado"), g(skill)
       ta skill, g(skill)

      * Status marital
      bysort iddom v207: egen conj = total(v206==2)
      gen casado = v206==1 & conj>0
      drop conj

      *Rendimentos do trabalho individual e no domicílio
      recode vd25 (.=0), g(rtrab)
      bysort iddom: egen rtrabdom = total(rtrab)
      gen rtrabdom2 = rtrabdom - rtrab
      recode rtrab rtrabdom rtrabdom2 (999000000/max=.)
      gen lnrtrab = cond(rtrab>0, ln(rtrab),0) if rtrab<999000000
      gen lnrtrabdom = cond(rtrabdom>0, ln(rtrabdom),0) if rtrabdom<999000000
      gen lnrtrabdom2 = cond(rtrabdom2>0, ln(rtrabdom2),0) if rtrabdom2<999000000

      *Soma de trabalhadores manuais, informais e desempregados no domicílio
      bysort iddom: egen manuais = total(skill==3)
      bysort iddom: egen informais = total(posocup==2)
      bysort iddom: egen desempregados = total(condact==2)
      recode desempregados (2/max = 1)
      bysort iddom: egen eramocupados = total(tevetrab==1)
      recode eramocupados (2/max = 1)

      *Soma dos contribuintes
      bysort iddom: egen contribuintes = total(contribui)
      recode contribuintes (2/max = 1)

      *Presença de trabalhadores com mais de 1 ano no emprego
      bysort iddom: egen mais1ano = total(tempotrab==1)
      gen mais1ano2 = mais1ano - tempotrab
      recode mais1ano (2/max = 1)
      recode mais1ano2 (2/max = 1)

      *número de famílias
      bysort iddom: egen familias = max(v207)
      recode familias (1=0) (2/max=1), g(estendida)

      *presença de conjuge
      bysort iddom: egen conjuge = total(v205==2)
      replace conjuge = 1 if conjuge>1

      *proporção em idade ativa
      bysort iddom: egen idadeativa = total(v234>=18 & v234<=65)
      gen pidativa = idadeativa/membros>.5

      *adultos analfabetos
      bysort iddom: egen analf = total(v234>=18 & v234<121 & v301==2)
      recode analf (0=1) (1/max=0)
      bysort iddom: egen analfunc = total(v234>=18 & v234<121 & educ<4)
      recode analfunc (0=1) (1/max=0)

      *adultos com fundamental completo
      bysort iddom: egen adulfund = total(v234>=18 & v234<121 & educ>=8 & educ!=.)
      recode adulfund (1 = 0) (2/max = 1), g(adulfund2)
      recode adulfund (2/max = 1)

      *adultos com médio completo
      bysort iddom: egen adulmed = total(v234>=18 & v234<121 & educ>=11 & educ!=.)
      recode adulmed (2/max = 1)

      *adultos com superior completo
      bysort iddom: egen adulsup = total(v234>=18 & v234<121 & educ>=15 & educ!=.)
      recode adulsup (2/max = 1)

      *trabalhadores médios
      bysort iddom: egen trabmedios = total(skill==2)
      recode trabmedios (2/max = 1)

      *trabalhadores superiores
      bysort iddom: egen trabsuper = total(skill==1)
      recode trabsuper (2/max = 1)

      *trabalhadores formais
      bysort iddom: egen formais = total(posocup==1)
      recode formais (2/max = 1)

      *número de trabalhadores
      bysort iddom: egen trabalhadores = total(condact==1)
      gen outtrabalhadores = cond(condact==1, trabalhadores - 1, trabalhadores)
      recode trabalhadores (1 = 0) (2/max = 1), g(trabalhadores2)
      recode trabalhadores (2/max = 1)
      recode outtrabalhadores (2/max = 1)

      *número de trabalhadores entre 10 e 16 anos
      bysort iddom: egen trabinfantil = total(v234>=10 & v234<=16 & condact==1)
      recode trabinfantil (0=1) (1/max=0)

      *cor do chefe
      /* Parentêsis indica que a variável participa da ordenação
      mas não do grupo definido */
      bysort iddom (v201): gen chefebranco = branco[1]

      *educaridade do chefe
      bysort iddom (v201): gen educhefe = educ[1]
      tab educhefe, g(educhefe)

      *sexo do chefe
      bysort iddom (v201): gen chefehomem = homem[1]

      *idade do chefe
      bysort iddom (v201): gen idadechefe = idade[1]
      gen idadechefe2 = idadechefe^2
      gen idadch40 = idadechefe>=40 if idadechefe!=.
      gen idadch50 = idadechefe>=50 if idadechefe!=.
      gen idadch65 = idadechefe>=65 if idadechefe!=.

      *dummies para crianças, adolesc1, adoles2 e idosos
      bysort iddom: egen criancas = total(v234<=9)
      recode criancas (0 1 = 1) (2/max = 0), g(criancas2)
      recode criancas (0 = 1) (1/max = 0)
      bysort iddom: egen idosos = total(v234>=65 & v234<121)
      recode idosos (2/max = 1)
      bysort iddom: egen adolesc1 = total(v234>=10 & v234<=14)
      recode adolesc1 (0 = 1) (1/max = 0)
      bysort iddom: egen adolesc2 = total(v234>=15 & v234<=17)
      recode adolesc2 (0 = 1) (1/max = 0)

      keep v035-v115 v2* p201 chefe-adolesc2

      ************************************************************************
      * Imputação
      ************************************************************************

      gen anoeq = 2002 if (v070>=3 & v075==2002) | (v070<4 & v075==2003)
      replace anoeq = 2003 if (v070>=4 & v075==2003) | (v070<5 & v075==2004)
      replace anoeq = 2004 if (v070>=5 & v075==2004) | (v070<5 & v075==2005)
      replace anoeq = 2005 if (v070>=5 & v075==2005) | (v070<4 & v075==2006)
      replace anoeq = 2006 if (v070>=4 & v075==2006) | v075>2006

      su anoeq
      loc min = r(min)
      loc max = r(max)


      * Aposentadoria

      g papon = .
      g lnyapon = .

      forvalues year = `min'/`max' {

         tempvar u pr pxb xb za AB _1B var desv e

         * Probabilidade
         gen `u' = invnormal(uniform()) if v035==`uf' & anoeq==`year' & ///
            idade>=30 & idade!=.

         est restore pap`uf'`year'
         predict `pr' if v035==`uf' & anoeq==`year' & idade>=30 & idade!=.
         replace papon = invnormal(`pr') + `u' if v035==`uf' & anoeq==`year' & ///
            idade>=30 & idade!=.

         * Inversa de Mills
         predict `pxb' if v035==`uf' & anoeq==`year' & idade>=30 & idade!=., xb
         g mills = normalden(`pxb')/normal(`pxb')

         * Valor predito da renda
         est restore yap`uf'`year'
         predict `xb' if v035==`uf' & anoeq==`year' & idade>=30 & idade!=.

         * Resíduo
         est restore eap`uf'`year'
         predict `za' if v035==`uf' & anoeq==`year' & idade>=30 & idade!=., xb
         gen `AB' = Aap`uf'`year'*exp(`za')
         gen `_1B' = 1 + exp(`za')
         gen `var' = (`AB'/`_1B') + ((rap`uf'`year'/2)*(`AB'*`_1B'/((`_1B')^3)))
         gen `desv' = `var'^.5
         gen `e' = invnormal(uniform())*`desv'

         * Renda imputada
         replace lnyapon = `xb' + `e' if v035==`uf' & anoeq==`year' & ///
            idade>=30 & idade!=.

         drop __* mills
      }
      g yapon = cond(papon>0, exp(lnyapon), 0)


      * Pensão

      g ppens = .
      g lnypens = .

      forvalues year = `min'/`max' {

         tempvar u pr pxb xb za AB _1B var desv e

         * Probabilidade
         gen `u' = invnormal(uniform()) if v035==`uf' & anoeq==`year'

         est restore ppe`uf'`year'
         predict `pr' if v035==`uf' & anoeq==`year'
         replace ppens = invnormal(`pr') + `u' if v035==`uf' & anoeq==`year'

         * Inversa de Mills
         predict `pxb' if v035==`uf' & anoeq==`year', xb
         g mills = normalden(`pxb')/normal(`pxb')

         * Valor predito da renda
         est restore ype`uf'`year'
         predict `xb' if v035==`uf' & anoeq==`year'

         * Resíduo
         est restore epe`uf'`year'
         predict `za' if v035==`uf' & anoeq==`year', xb
         gen `AB' = Ape`uf'`year'*exp(`za')
         gen `_1B' = 1 + exp(`za')
         gen `var' = (`AB'/`_1B') + ((rpe`uf'`year'/2)*(`AB'*`_1B'/((`_1B')^3)))
         gen `desv' = `var'^.5
         gen `e' = invnormal(uniform())*`desv'

         * Renda imputada
         replace lnypens = `xb' + `e' if v035==`uf' & anoeq==`year'

         drop __* mills

      }
      g ypens = cond(ppens>0, exp(lnypens), 0)


      * Outras rendas

      gen rtrabpc = rtrabdom/membros

      g poutras = .
      g lnyoutras = .


         * Pobres

      forvalues year = `min'/`max' {

         tempvar u pr pxb xb za AB _1B var desv e

         * Probabilidade
         gen `u' = invnormal(uniform()) if v035==`uf' & anoeq==`year' & ///
            chefe==1 & rtrabpc<=cut`year'

         est restore pop`uf'`year'
         predict `pr' if v035==`uf' & anoeq==`year' & chefe==1 & rtrabpc<=cut`year'
         replace poutras = invnormal(`pr') + `u' if v035==`uf' & ///
            anoeq==`year' & chefe==1 & rtrabpc<=cut`year'

         * Inversa de Mills
         predict `pxb' if v035==`uf' & anoeq==`year' & chefe==1 & ///
            rtrabpc<=cut`year', xb
         g mills = normalden(`pxb')/normal(`pxb')

         * Valor predito da renda
         est restore yop`uf'`year'
         predict `xb' if v035==`uf' & anoeq==`year' & chefe==1 & rtrabpc<=cut`year'

         * Resíduo
         est restore eop`uf'`year'
         predict `za' if v035==`uf' & anoeq==`year' & chefe==1 & ///
            rtrabpc<=cut`year', xb
         gen `AB' = Aop`uf'`year'*exp(`za')
         gen `_1B' = 1 + exp(`za')
         gen `var' = (`AB'/`_1B') + ((rop`uf'`year'/2)*(`AB'*`_1B'/((`_1B')^3)))
         gen `desv' = `var'^.5
         gen `e' = invnormal(uniform())*`desv'

         * Renda imputada
         replace lnyoutras = `xb' + `e' if v035==`uf' & anoeq==`year' & ///
            chefe==1 & rtrabpc<=cut`year'

         drop __* mills

      }

         * Ricos

      forvalues year = `min'/`max' {

         tempvar u pr pxb xb za AB _1B var desv e

         * Probabilidade
         gen `u' = invnormal(uniform()) if v035==`uf' & anoeq==`year' & ///
            chefe==1 & rtrabpc>cut`year'

         est restore por`uf'`year'
         predict `pr' if v035==`uf' & anoeq==`year' & chefe==1 & rtrabpc>cut`year'
         replace poutras = invnormal(`pr') + `u' if v035==`uf' & ///
            anoeq==`year' & chefe==1 & rtrabpc>cut`year'

         * Inversa de Mills
         predict `pxb' if v035==`uf' & anoeq==`year' & chefe==1 & ///
            rtrabpc>cut`year', xb
         g mills = normalden(`pxb')/normal(`pxb')

         * Valor predito da renda
         est restore yor`uf'`year'
         predict `xb' if v035==`uf' & anoeq==`year' & chefe==1 & rtrabpc>cut`year'

         * Resíduo
         est restore eor`uf'`year'
         predict `za' if v035==`uf' & anoeq==`year' & chefe==1 & ///
            rtrabpc>cut`year', xb
         gen `AB' = Aor`uf'`year'*exp(`za')
         gen `_1B' = 1 + exp(`za')
         gen `var' = (`AB'/`_1B') + ((ror`uf'`year'/2)*(`AB'*`_1B'/((`_1B')^3)))
         gen `desv' = `var'^.5
         gen `e' = invnormal(uniform())*`desv'

         * Renda imputada
         replace lnyoutras = `xb' + `e' if v035==`uf' & anoeq==`year' & ///
            chefe==1 & rtrabpc>cut`year'

         drop __* mills

      }

      g youtras = cond(poutras>0, exp(lnyoutras), 0)


      ************************************************************************
      * Calculando a renda domiciliar
      ************************************************************************

      * Somar as rendas não-trabalho dos domicílios
      bysort iddom: egen aposentadorias = total(yapon)
      bysort iddom: egen pensoes = total(ypens)
      bysort iddom: egen outras = max(youtras)


      * Merge das linhas de pobreza e deflatores
      joinby v035 v070 v075 using povline, unm(b)


      replace anoeq = 2002 if (v070>=3 & v075==2002) | (v070<4 & v075==2003)
      replace anoeq = 2003 if (v070>=4 & v075==2003) | (v070<5 & v075==2004)
      replace anoeq = 2004 if (v070>=5 & v075==2004) | (v070<5 & v075==2005)
      replace anoeq = 2005 if (v070>=5 & v075==2005) | (v070<4 & v075==2006)
      replace anoeq = 2006 if (v070>=4 & v075==2006) | v075>2006


      * Correção dos valores de outras rendas de setembro
      gen def09 = deflator if v070==9 & v075<=2006
      bys anoeq: egen def = max(def09)
      bys anoeq (v075): replace def = def[1]

      replace aposentadorias = aposentadorias*deflator/def
      replace pensoes = pensoes*deflator/def
      replace outras = outras*deflator/def
      drop if _merge==2
      drop def def09 _merge


      * Renda domiciliar total e per capita
      g income = rtrabdom + aposentadorias + pensoes + outras
      g incpc = income/membros


      * Código para identificar a entrada da família no painel
      bys v063 v035 v040 v050 v075 v070: egen code = min(p201)
      replace code = round((code + 100)/100, 1)


      * Manter somente domicílios na base
      keep if v205 == 1

      keep v0* v1* v215 iddom membros lnmembros condact tevetrab ///
      tempodesocup tempotant contribui tempotrab posocup skill ///
      rtrabdom lnrtrabdom manuais-idadechefe2 criancas-anoeq ///
      rtrabpc aposentadorias-code

      compress

      sa `p'`uf', replace
   }
}

u A26, clear

qui foreach p in A B C D E F G H I J K L {
    if "`p'" == "A" {
        foreach uf in 29 31 33 35 43 {
            append using `p'`uf'
        }
    }
    else {
        foreach uf in 26 29 31 33 35 43 {
            append using `p'`uf'
        }
    }
}

recode posocup (0 = 3) if condact==2
la def posocup 0 "inativo" 1 "formal" 2 "informal" 3 "desempregado"
la val posocup posocup

g poor = incpc<povline if incpc!=.
g epoor = incpc<extline if incpc!=.

bys v060 v063 v035 v040 v050 code (v072): g posocup_f = posocup[_n + 1] if v072!=4 & v072!=8 & (v072[_n + 1] - v072)==1
bys v060 v063 v035 v040 v050 code (v072): g poor_f = poor[_n + 1] if v072!=4 & v072!=8 & (v072[_n + 1] - v072)==1


sa pmeimput, replace

****************************************************************
*End of Do file
****************************************************************
