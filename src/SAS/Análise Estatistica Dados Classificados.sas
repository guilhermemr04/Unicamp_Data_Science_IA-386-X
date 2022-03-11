LIBNAME PROJDATA '/folders/myfolders/bibliotecas/Cluster Data';

/* Importando os dados dos clusters formados a partir da análise das variáveis de % de 
   distancia percorrida com atividade e % de horas em atividade física dos participantes.
   O objetivo da clusterização é separar, na tabela de treinamento, os indivíduos
   sedentários (que realizam pouca ou nenhuma atividade física) e os indivíduoas que 
   realizam alguma atividade física.*/
PROC IMPORT OUT=PROJDATA.CLUSTER_DATA_2D 
	DATAFILE = '/folders/myfolders/bibliotecas/Cluster Data/individual_cluster.csv' DBMS=CSV
	replace;
	GETNAMES=YES;
	DATAROW=2;
RUN;

PROC IMPORT OUT=PROJDATA.CLUSTER_DATA_2D_MEAN 
	DATAFILE = '/folders/myfolders/bibliotecas/Cluster Data/mean_cluster.csv' DBMS=CSV
	replace;
	GETNAMES=YES;
	DATAROW=2;
RUN;

/* Análise da distribuição dos dados - verificando a normalidade para as variáveis Calories,
   __ACTIVE_MINUTES e __ACTIVE_DISTANCE.
*/
ods noproctitle;
ods graphics / imagemap=on;
proc univariate data=PROJDATA.CLUSTER_DATA_2D;
	ods select Histogram;
	var CALORIES __ACTIVE_MINUTES __ACTIVE_DISTANCE;
	class Cluster_label;
	histogram CALORIES __ACTIVE_MINUTES __ACTIVE_DISTANCE / normal kernel (k=normal);
run;
 
ods noproctitle;
ods graphics / imagemap=on;
proc univariate data=PROJDATA.CLUSTER_DATA_2D_MEAN;
	ods select Histogram;
	var CALORIES __ACTIVE_MINUTES __ACTIVE_DISTANCE;
	class Cluster_label;
	histogram CALORIES __ACTIVE_MINUTES __ACTIVE_DISTANCE / normal kernel (k=normal);
run;

Title'Análise ANOVA dos dados clusterizados.';
ods noproctitle;
ods graphics / imagemap=on;
proc glm data=PROJDATA.CLUSTER_DATA_2D;
	class Cluster_label;
	model CALORIES=Cluster_label;
	* means Cluster_label / welch plots=none; 
	means Cluster_Label / tukey cldiff alpha=.05;
	run;
quit;

Title 'Análise ANOVA da tabela das médias dos dados clusterizados.';
ods noproctitle;
ods graphics / imagemap=on;
proc glm data=PROJDATA.CLUSTER_DATA_2D_MEAN;
	class Cluster_label;
	model CALORIES=Cluster_label;
	* means Cluster_label / welch plots=none; 
	means Cluster_Label / tukey cldiff alpha=.05;
	*means Cluster_label / welch plots=none;
	*lsmeans Cluster_label / adjust=tukey pdiff alpha=.05;
	run;
quit;
