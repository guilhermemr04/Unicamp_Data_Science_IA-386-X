/* ==================================================================================
   Este código implementa as estatísticas descritivas utilizadas na análise dos dados
   como também os algoritmos de predição não supervisionados utilizados como reforço
   da análise estatística e para a conclusão do estudo. 
   ==================================================================================
*/

/* Calculando todas as correlações entre as variáveis da tabela Daily_Info para tentar 
   encontrar onde há maior correlação entre variáveis. */
ods graphics on;
PROC CORR data=PROJDATA.DAILY_INFO plots=matrix(histogram);
title 'Cálculo das Correlações entre as variáveis da tabela PROJDATA.DAILY_INFO';
run;
  
/* Usado o coeficiente de correlação de Pearson para entender se há alguma relação entre 
   as variações na queima de calorias com as variáveis TOTAL_STEPS, TOTAL_DISTANCE,
   VERY_ACTIVE_DISTANCE VERY_ACTIVE_MINUTES, MODERATE_ACTIVE_DISTANCE. */
ods noproctitle;
ods graphics / imagemap=on;
PROC CORR data=PROJDATA.DAILY_INFO pearson nosimple noprob 
		plots=scatter(ellipse=confidence alpha=0.05);
		title 'Correlação entre Calorias "Queimadas" Diárias e Niveis de Atividade';
	var TOTAL_STEPS TOTAL_DISTANCE VERY_ACTIVE_DISTANCE VERY_ACTIVE_MINUTES MODERATE_ACTIVE_DISTANCE;
	with CALORIES;
	freq ACTIVITY_DATE;
RUN;

PROC UNIVARIATE DATA=PROJDATA.daily_info NORMAL PLOT;
title 'Grafico Q-Q de distribuição normal para consumo calórico (Calories) em que 
       Very Active Minutes seja != 0';
VAR CALORIES;
WHERE VERY_ACTIVE_MINUTES ^= 0 AND CALORIES >=1125;
RUN;
