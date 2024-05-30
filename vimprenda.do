clear
set mem 500m

cd "I:\Ana Flávia Ribas\bases pnad"

qui forvalues year = 2002/2006 {  /* Para rodar todos os anos juntos */

	use pnad`year', clear
	
	* Seleção de áreas metropolitanas e membros do grupo doméstico
	keep if v4727==1 & (UF==26 | UF==29 | UF==31 | UF==33 | UF==35 | UF==43)
	drop if v0401>=6
	
	sort UF v0102 v0103 v0301 v0401
	gen chefe = v0401==1
	gen iddom = sum(chefe)
	
	bysort iddom: gen membros = _N
	label variable membros "Tamanho do domicílio"
	gen lnmembros = ln(membros)
	
	*recodificação de sexo e anos de estudo
	recode v0302 2=1 4=0, g(homem)
	gen educ = cond(v4703<17, v4703-1,.)
	recode educ (2 3 = 1) (6 7 = 5) (10 = 9) (12/14 = 11)
	tab educ, g(educ)
	
	*recodificação de cor
	recode v0404 (2 6 =1) (4 8=0) (9=.), g(branco)
	
	*variáveis de idade
	gen idade = v8005 if v8005<999
	gen idade2 = idade^2
	gen idade40 = idade>=40 if idade!=.
	gen idade50 = idade>=50 if idade!=.
	gen idade65 = idade>=65 if idade!=.
	
	*condição de atividade
	recode v4705 (1=1 "Working") (2=2 "Seeking") (.=3 "Inactive"), g(condact)
	replace condact=3 if v4704==2 | v8005<10
	label variable condact "Atividade econômica"
	ta condact, g(condact)
	
	*já teve um emprego (se é desocupado)
	gen tevetrab = v9067==1 | v9106==2 if v9067!=9 & v9106!=9
	
	*mais de 1 ano que saiu do último emprego
	recode v1091 (.=0) (2/max = 1) (99=.), g(tempodesocup)
	
	*mais de um ano no trabalho anterior
	recode v9861 (1 .=0) (2/98=1) (99=.), g(tempotant)
	
	*contribuição para previdência
	recode v4711 1=1 2=0 .=0 3=., g(contribui)  /*dúvida se há tal variável na PME*/
	
	*tempo no trabalho - mais de um ano no emprego
	recode v9611 (1 .=0) (2/98=1) (99=.), g(tempotrab)
	
	* Posição na ocupação
	recode v4706 (1/3 6 10 = 1 "formal") (4 5 7/9 11/13 = 2 "informal") (. = 0 "desocupado") (14 = .), g(posocup)
	label variable posocup "Posição na ocupação"
	
	    *Separando os conta-própria dos profissionais liberais
	gen vcp = (v9906>=2151 & v9906<=2153) | (v9906>=2311 & v9906<=2313) | (v9906>=2523 & v9906<=2524) ///
	   | (v9906>=2615 & v9906<=2617) | (v9906>=2621 & v9906<=2624) | (v9906>=3141 & v9906<=3144) ///
	   | (v9906>=3161 & v9906<=3163) | (v9906>=3210 & v9906<=3214) | (v9906>=3311 & v9906<=3313) ///
	   | (v9906>=3411 & v9906<=3413) | (v9906>=3421 & v9906<=3426) | (v9906>=3514 & v9906<=3516) ///
	   | (v9906>=3522 & v9906<=3525) | (v9906>=3541 & v9906<=3546) | (v9906>=3721 & v9906<=3723) ///
	   | (v9906>=3741 & v9906<=3743) | (v9906>=3761 & v9906<=3765) | (v9906>=3771 & v9906<=3773) ///
	   | (v9906>=4101 & v9906<=4201) | (v9906>=4221 & v9906<=4123) | (v9906>=5101 & v9906<=5103) ///
	   | (v9906>=5131 & v9906<=5134) | (v9906>=5165 & v9906<=5167) | (v9906>=5171 & v9906<=5174) ///
	   | (v9906>=5241 & v9906<=5243) | (v9906>=7111 & v9906<=7114) | (v9906>=7151 & v9906<=7157) ///
	   | (v9906>=7161 & v9906<=7166) | (v9906>=7211 & v9906<=7215) | (v9906>=7221 & v9906<=7224) ///
	   | (v9906>=7231 & v9906<=7233) | (v9906>=7241 & v9906<=7246) | (v9906>=7250 & v9906<=7257) ///
	   | (v9906>=7311 & v9906<=7313) | (v9906>=7521 & v9906<=7524) | (v9906>=7601 & v9906<=7606) ///
	   | (v9906>=7610 & v9906<=7614) | (v9906>=7620 & v9906<=7623) | (v9906>=7630 & v9906<=7633) ///
	   | (v9906>=7640 & v9906<=7643) | (v9906>=7650 & v9906<=7654) | (v9906>=7660 & v9906<=7664) ///
	   | (v9906>=7681 & v9906<=7683) | (v9906>=7731 & v9906<=7735) | (v9906>=7820 & v9906<=7828) ///
	   | (v9906>=8101 & v9906<=8103) | (v9906>=8111 & v9906<=8118) | (v9906>=8211 & v9906<=8214) ///
	   | (v9906>=8231 & v9906<=8233) | (v9906>=8411 & v9906<=8414) | (v9906>=8491 & v9906<=8493) ///
	   | (v9906>=8621 & v9906<=8625) | (v9906>=9111 & v9906<=9113) | (v9906>=9141 & v9906<=9144) ///
	   | (v9906>=9151 & v9906<=9154) | (v9906>=9191 & v9906<=9193) | (v9906>=9911 & v9906<=9914) ///
	   | v9906==1111 | v9906==1112 | v9906==1122 | v9906==1123 | v9906==1140 ///
	   | v9906==1210 | v9906==1219 | v9906==1220 | v9906==1230 | v9906==1310 | v9906==1320 ///
	   | v9906==2321 | v9906==2330 | v9906==2340 | v9906==2391 | v9906==2392 | v9906==2423 ///
	   | v9906==2611 | v9906==2627 | v9906==2631 | v9906==3001 | v9906==3003 | v9906==3117 ///
	   | v9906==3131 | v9906==3134 | v9906==3136 | v9906==3146 | v9906==3147 | v9906==3191 ///
	   | v9906==3192 | v9906==3231 | v9906==3232 | v9906==3252 | v9906==3281 | v9906==3517 ///
	   | v9906==3321 | v9906==3322 | v9906==3331 | v9906==3518 | v9906==3531 | v9906==3532 ///
	   | v9906==3547 | v9906==3548 | v9906==3713 | v9906==3731 | v9906==3732 | v9906==3751 ///
	   | v9906==3911 | v9906==3912 | v9906==4110 | v9906==4121 | v9906==4211 | v9906==4213 ///
	   | v9906==4131 | v9906==4132 | v9906==4141 | v9906==4142 | v9906==4151 | v9906==4212 ///
	   | v9906==4214 | v9906==4222 | v9906==4223 | v9906==4231 | v9906==5111 | v9906==5112 ///
	   | v9906==5114 | v9906==5121 | v9906==5141 | v9906==5142 | v9906==5161 | v9906==5162 ///
	   | v9906==5169 | v9906==5191 | v9906==5192 | v9906==5198 | v9906==5199 | v9906==5201 ///
	   | v9906==5211 | v9906==5221 | v9906==5231 | v9906==6110 | v9906==6129 | v9906==6139 ///
	   | v9906==6201 | v9906==6210 | v9906==6229 | v9906==6239 | v9906==6301 | v9906==6319 ///
	   | v9906==6329 | v9906==6410 | v9906==6420 | v9906==6430 | v9906==7101 | v9906==7102 ///
	   | v9906==7121 | v9906==7122 | v9906==7170 | v9906==7201 | v9906==7202 | v9906==7301 ///
	   | v9906==7321 | v9906==7401 | v9906==7411 | v9906==7421 | v9906==7501 | v9906==7502 ///
	   | v9906==7519 | v9906==7618 | v9906==7741 | v9906==7686 | v9906==7687 | v9906==7701 ///
	   | v9906==7711 | v9906==7721 | v9906==7751 | v9906==7764 | v9906==7771 | v9906==7772 ///
	   | v9906==7801 | v9906==7811 | v9906==7813 | v9906==7817 | v9906==7831 | v9906==7832 ///
	   | v9906==7841 | v9906==7842 | v9906==8121 | v9906==8181 | v9906==8201 | v9906==8202 ///
	   | v9906==8221 | v9906==8281 | v9906==8301 | v9906==8311 | v9906==8321 | v9906==8339 ///
	   | v9906==8401 | v9906==8416 | v9906==8417 | v9906==8421 | v9906==8423 | v9906==8429 ///
	   | v9906==8484 | v9906==8485 | v9906==8601 | v9906==8611 | v9906==8612 | v9906==8711 ///
	   | v9906==9101 | v9906==9102 | v9906==9109 | v9906==9131 | v9906==9501 | v9906==9513 ///
	   | v9906==9531 | v9906==9542 | v9906==9543 | v9906==9502 | v9906==9503 | v9906==9511 ///
	   | v9906==9541 | v9906==9921 | v9906==9922 if v4706==9
	
	replace posocup=2 if v9048>0 & v9048<8
	replace posocup=1 if vcp==0
	drop vcp
	ta posocup, g(posocup)
	
	* Qualificação dos trabalhadores
	recode v4817 (1 2 = 1 "superior") (3 4 9 = 2 "médio") (5/8 = 3 "manual") (. = 0 "desocupado") (10 = .), g(skill)
	replace skill=0 if condact!=1
	ta skill, g(skill)
	
	* Status marital
	bysort iddom v0403: egen conj = sum(v0402==2)
	gen casado = v0402==1 & conj>0
	drop conj
	
	*Rendimentos do trabalho individual e no domicílio
	recode v4719 (.=0), g(rtrab)
	bysort iddom: egen rtrabdom = sum(rtrab)
	gen rtrabdom2 = rtrabdom - rtrab
	recode rtrab rtrabdom rtrabdom2 (900000000000/max= .)
	gen lnrtrab = cond(rtrab>0, ln(rtrab),0)
	gen lnrtrabdom = cond(rtrabdom>0, ln(rtrabdom),0)
	gen lnrtrabdom2 = cond(rtrabdom2>0, ln(rtrabdom2),0)
	
	*Soma de trabalhadores manuais, informais e desempregados no domicílio
	bysort iddom: egen manuais=sum(skill==3)
	bysort iddom: egen informais=sum(posocup==2)
	bysort iddom: egen desempregados=sum(condact==2)
	recode desempregados (2/max = 1)
	bysort iddom: egen eramocupados=sum(tevetrab==1)
	recode eramocupados (2/max = 1)
	
	*Soma dos contribuintes
	bysort iddom: egen contribuintes=sum(contribui)
	recode contribuintes (2/max = 1)
	
	*Presença de trabalhadores com mais de 1 ano no emprego
	bysort iddom: egen mais1ano = sum(tempotrab==1)
	gen mais1ano2 = mais1ano - tempotrab
	recode mais1ano (2/max = 1)
	recode mais1ano2 (2/max = 1)
	
	*número de famílias
	bysort iddom: egen familias = max(v0403)
	recode familias (1=0) (2/max=1), g(estendida)
	
	*presença de conjuge
	bysort iddom: egen conjuge = sum(v0401==2)
	
	*proporção em idade ativa
	bysort iddom: egen idadeativa = sum(v8005>=18 & v8005<=65)
	gen pidativa = idadeativa/membros>.5
	
	*adultos analfabetos
	bysort iddom: egen analf = sum(v8005>=18 & v8005<999 & v0601==3)
	recode analf (0=1) (1/max=0)
	bysort iddom: egen analfunc = sum(v8005>=18 & v8005<999 & educ<4)
	recode analfunc (0=1) (1/max=0)
	
	*adultos com fundamental completo
	bysort iddom: egen adulfund = sum(v8005>=18 & v8005<999 & educ>=8 & educ!=.)
	recode adulfund (1 = 0) (2/max = 1), g(adulfund2)
	recode adulfund (2/max = 1)
	
	*adultos com médio completo
	bysort iddom: egen adulmed = sum(v8005>=18 & v8005<999 & educ>=11 & educ!=.)
	recode adulmed (2/max = 1)
	
	*adultos com superior completo
	bysort iddom: egen adulsup = sum(v8005>=18 & v8005<999 & educ>=15 & educ!=.)
	recode adulsup (2/max = 1)
	
	*trabalhadores médios
	bysort iddom: egen trabmedios = sum(skill==2)
	recode trabmedios (2/max = 1)
	
	*trabalhadores superiores
	bysort iddom: egen trabsuper = sum(skill==1)
	recode trabsuper (2/max = 1)
	
	*trabalhadores formais
	bysort iddom: egen formais = sum(posocup==1)
	recode formais (2/max = 1)
	
	*número de trabalhadores
	bysort iddom: egen trabalhadores = sum(condact==1)
	gen outtrabalhadores = cond(condact==1, trabalhadores - 1, trabalhadores)
	recode trabalhadores (1 = 0) (2/max = 1), g(trabalhadores2)
	recode trabalhadores (2/max = 1)
	recode outtrabalhadores (2/max = 1)
	
	*número de trabalhadores entre 10 e 16 anos
	bysort iddom: egen trabinfantil = sum(v8005>=10 & v8005<=16 & condact==1)
	recode trabinfantil (0=1) (1/max=0)
	
	*cor do chefe Parentêsis indica que a variável participa da ordenação mas não do grupo definido
	bysort iddom (v0301): gen chefebranco = branco[1]
	
	*escolaridade do chefe
	bysort iddom (v0301): gen educhefe = educ[1]
	tab educhefe, g(educhefe)
	
	*sexo do chefe
	bysort iddom (v0301): gen chefehomem = homem[1]
	
	*idade do chefe
	bysort iddom (v0301): gen idadechefe = idade[1]
	gen idadechefe2 = idadechefe^2
	gen idadch40 = idadechefe>=40 if idadechefe!=.
	gen idadch50 = idadechefe>=50 if idadechefe!=.
	gen idadch65 = idadechefe>=65 if idadechefe!=.
	
	*dummies para crianças, adolesc1, adoles2 e idosos
	bysort iddom: egen criancas=sum(v8005<=9)
	recode criancas (0 1 = 1) (2/max = 0), g(criancas2)
	recode criancas (0 = 1) (1/max = 0)
	bysort iddom: egen idosos=sum(v8005>=65 & v8005<999)
	recode idosos (2/max = 1)
	bysort iddom: egen adolesc1=sum(v8005>=10 & v8005<=14)
	recode adolesc1 (0 = 1) (1/max = 0)
	bysort iddom: egen adolesc2=sum(v8005>=15 & v8005<=17 )
	recode adolesc2 (0 = 1) (1/max = 0)
	
	
	*Variáveis de rendimentos não-trabalho
	
	recode v1252 v1258 v1255 v1261 (.=0), g(apos1 apos2 pens1 pens2)
	
	gen lnrapos = ln(apos1 + apos2) if apos1<900000000000 & apos2<900000000000
	replace lnrapos = 0 if apos1 + apos2 == 0       /*individual*/
	
	gen lnrpens = ln(pens1 + pens2) if pens1<900000000000 & pens2<900000000000
	replace lnrpens = 0 if pens1 + pens2 == 0       /*individual*/
	
	bysort iddom: egen alug = sum(v1267)
	bysort iddom: egen doac = sum(v1270)
	bysort iddom: egen outr = sum(v1273)

	gen lnroutras = ln(alug + doac + outr) if alug + doac + outr < 900000000000
	replace lnroutras = 0 if alug + doac + outr == 0 /*coletiva*/
	
	drop apos* pens* alug doac outr
	
	keep UF chefe-lnroutras v4729
	
	g ano = `year'

	save transfpnad`year', replace
	
}

qui forvalues year = 2002/2005 {
	append using transfpnad`year'
}
qui compress
qui sa transfpnad, replace
