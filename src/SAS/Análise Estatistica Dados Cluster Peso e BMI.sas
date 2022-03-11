/* Análise Estatística com Peso e BMI de um voluntário sedentário e de um voluntário ativo */

LIBNAME PROJDATA '/folders/myfolders/bibliotecas/Cluster Data';

PROC IMPORT OUT=PROJDATA.CLUSTER_DATA_WEIGHT 
	DATAFILE = '/folders/myfolders/bibliotecas/Cluster Data/CLUSTER_CALORIES_AND_WEIGHT_V2.csv' DBMS=CSV
	replace;
	GETNAMES=YES;
	DATAROW=2;
RUN;

/* Análise da distribuição dos dados - verificando a normalidade para as variáveis Calories,
   WEIGHT_KG e BMI. */
ods noproctitle;
ods graphics / imagemap=on;
proc univariate data=PROJDATA.CLUSTER_DATA_WEIGHT;
	ods select Histogram;
	var CALORIES WEIGHT_KG BMI;
	class Cluster_label;
	histogram CALORIES WEIGHT_KG BMI / normal kernel (k=normal);
run;

title;
ods noproctitle;
ods graphics / imagemap=on;
proc glm data=PROJDATA.CLUSTER_DATA_WEIGHT plot(only)=(ancovaplot);
	class Cluster_Label;
	model BMI=Cluster_Label VERY_ACTIVE_MINUTES VERY_ACTIVE_MINUTES * Cluster_Label;
	lsmeans Cluster_Label / adjust=tukey pdiff alpha=.05;
quit;

title;
ods noproctitle;
ods graphics / imagemap=on;
proc glm data=PROJDATA.CLUSTER_DATA_WEIGHT plot(only)=(ancovaplot);
	class Cluster_Label; 
	model BMI=Cluster_Label Calories Calories * Cluster_Label;
	lsmeans Cluster_Label / adjust=tukey pdiff alpha=.05;
quit; 

ods noproctitle;
ods graphics / imagemap=on;
proc sgplot data=PROJDATA.CLUSTER_DATA_WEIGHT;
	title height=14pt "Análise Gráfica do BMI no Tempo";
	series x=ACTIVITY_DATE y=BMI / group=Cluster_Label curvelabel 
		curvelabelpos=max name="cluster";
	xaxis grid;
	yaxis grid max=26; 
   /*keylegend "cluster" /  location=inside position=bottomright; */
run;

ods noproctitle;
ods graphics / imagemap=on;
proc sgplot data=PROJDATA.CLUSTER_DATA_WEIGHT;
	title height=14pt "Análise Gráfica do Peso no Tempo";
	series x=ACTIVITY_DATE y=Weight_Kg / group=Cluster_Label curvelabel 
		curvelabelpos=max name="cluster";
	xaxis grid;
	yaxis grid max=86; 
run;

ods noproctitle;
ods graphics / imagemap=on;
proc sgplot data=PROJDATA.CLUSTER_DATA_WEIGHT;
	title height=14pt "Análise Gráfica do Consumo Calórico no Tempo";
	series x=ACTIVITY_DATE y=Calories / group=Cluster_Label curvelabel 
		curvelabelpos=max;
	xaxis grid;
	yaxis grid;
run;

proc sgplot data=PROJDATA.CLUSTER_DATA_WEIGHT 
(where=(ACTIVITY_DATE >= mdy(4, 12, 2016) and ACTIVITY_DATE <= mdy(5, 13, 2016) 
and Cluster_Label=0));
   title "Calorias gastas do sedentário";
   vbar ACTIVITY_DATE / response=Calories;
   yaxis max=4000;
   *vline ACTIVITY_DATE / response=close y2axis;
run;
proc sgplot data=PROJDATA.CLUSTER_DATA_WEIGHT 
(where=(ACTIVITY_DATE >= mdy(4, 12, 2016) and ACTIVITY_DATE <= mdy(5, 13, 2016) 
and Cluster_Label=1));
   title "Calorias gastas do ativo";
   vbar ACTIVITY_DATE / response=Calories;
run;

proc sgplot data=PROJDATA.CLUSTER_DATA_WEIGHT 
(where=(ACTIVITY_DATE >= mdy(4, 12, 2016) and ACTIVITY_DATE <= mdy(5, 13, 2016) 
and Cluster_Label=0));
   title "Minutos em alta atividade do sedentário";
   vbar ACTIVITY_DATE / response=VERY_ACTIVE_MINUTES;
   yaxis max=125;
   *vline ACTIVITY_DATE / response=close y2axis;
run;
proc sgplot data=PROJDATA.CLUSTER_DATA_WEIGHT 
(where=(ACTIVITY_DATE >= mdy(4, 12, 2016) and ACTIVITY_DATE <= mdy(5, 13, 2016) 
and Cluster_Label=1));
   title "Minutos em alta atividade do ativo";
   vbar ACTIVITY_DATE / response=VERY_ACTIVE_MINUTES;
run;

proc sgplot data=PROJDATA.CLUSTER_DATA_WEIGHT 
(where=(ACTIVITY_DATE >= mdy(4, 12, 2016) and ACTIVITY_DATE <= mdy(5, 13, 2016) 
and Cluster_Label=0));
   title "Variação de peso do sedentário";
   vbar ACTIVITY_DATE / response=WEIGHT_KG;
   yaxis max=63;
   *vline ACTIVITY_DATE / response=close y2axis;
run;
proc sgplot data=PROJDATA.CLUSTER_DATA_WEIGHT 
(where=(ACTIVITY_DATE >= mdy(4, 12, 2016) and ACTIVITY_DATE <= mdy(5, 13, 2016) 
and Cluster_Label=1));
   title "Variação de peso do ativo";
   vbar ACTIVITY_DATE / response=WEIGHT_KG;
run;

proc sgplot data=PROJDATA.CLUSTER_DATA_WEIGHT 
(where=(ACTIVITY_DATE >= mdy(4, 12, 2016) and ACTIVITY_DATE <= mdy(5, 13, 2016) 
and Cluster_Label=0));
   title "Variação de BMI do sedentário";
   vbar ACTIVITY_DATE / response=BMI;
   *vline ACTIVITY_DATE / response=close y2axis;
run;
proc sgplot data=PROJDATA.CLUSTER_DATA_WEIGHT 
(where=(ACTIVITY_DATE >= mdy(4, 12, 2016) and ACTIVITY_DATE <= mdy(5, 13, 2016) 
and Cluster_Label=1));
   title "Variação de BMI do ativo";
   vbar ACTIVITY_DATE / response=BMI;
run;

/*ods noproctitle;
ods graphics / imagemap=on;
proc corr data=PROJDATA.CLUSTER_DATA_WEIGHT pearson cov plots=scatter(ellipse=none) nomiss;
	var BMI WEIGHT_KG;
	with CALORIES;
	freq ACTIVITY_DATE;
	by Cluster_Label;
run;*/
