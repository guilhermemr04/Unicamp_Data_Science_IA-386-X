/* ==================================================================================
   Este código realiza o upload dos dados para as tabelas do SAS e realiza o tratamento
   dos dados encontrados, para mantê-los com a mesma formatação nos casos necessários
   (como datas) e a mesma periodicidade (em dias - como no caso do valor do Consumo
   Metabólico, o Metabolic Equivalents - MET). 
   Cria a tabela principal, PROJDATA.DATA_INFO, que contém todos os registros relevantes
   e diários dos voluntários utilizados nesse estudo.
   ==================================================================================
*/

LIBNAME PROJDATA '/folders/myfolders/bibliotecas/';

PROC IMPORT OUT=PROJDATA.DAILY_ACTIVITY 
	DATAFILE = '/folders/myfolders/dataset/Training Data/dailyActivity_merged.csv' DBMS=CSV
	replace;
	GETNAMES=YES;
	DATAROW=2;
RUN;

/* Obtendo os registros do Consumo Metabólico (MET - Metabolic Equivalents) por minuto */
PROC IMPORT OUT=PROJDATA.MINUTEMETS 
		DATAFILE='/folders/myfolders/dataset/Training Data/minuteMETsNarrow_merged.csv' DBMS=CSV 
		replace;
	GETNAMES=YES;
	DATAROW=2;
RUN;

/* Extraindo do campo data-hora "ActivityMinute" a data e formatando essa data para
selecionar a seguir o MET do dia*/
DATA PROJDATA.MINUTE_MET_DAY;
	SET PROJDATA.MINUTEMETS;
	FORMAT REF_DAY MMDDYY10.;
	/* Coletando somente as datas e ajustando a formatação para manter a mesma formatação e 
	o mesmo intervalo de tempo das demais tabelas */
	IF ((MONTH(DATEPART(ActivityMinute))=4) &
    			(DAY(DATEPART(ActivityMinute))=12)) THEN
		REF_DAY=mdy(12, 4, 2016);

	IF ((MONTH(DATEPART(ActivityMinute))=4) &
    			(DAY(DATEPART(ActivityMinute)) >= 12)) THEN
		REF_DAY=mdy(MONTH(DATEPART(ActivityMinute)), DAY(DATEPART(ActivityMinute)), 
			2016);
	ELSE IF (MONTH(DATEPART(ActivityMinute)) > 4) THEN
		REF_DAY=mdy(DAY(DATEPART(ActivityMinute)), MONTH(DATEPART(ActivityMinute)), 
			2016);
	ELSE REF_DAY=mdy(DAY(DATEPART(ActivityMinute)), MONTH(DATEPART(ActivityMinute)), 
			2016);
	/*Criando a tabela que contém os METs médios diários calculados a partir dos METs/minuto 
  da tabela MINUTE_MET_DAY.*/
	PROC SQL;
	CREATE TABLE PROJDATA.DAILY_MET AS
	SELECT ID, REF_DAY, mean (METs) AS MEAN_MET format comma6.2,
	max (METs) AS MAX_MET format comma6.2
	FROM PROJDATA.MINUTE_MET_DAY
	GROUP BY ID, REF_DAY
	ORDER BY ID, REF_DAY;
RUN;

/* Criando tabela que agrega as informações de atividade diária e a média do Consumo Metabólico
(MET - Metabolic Equivalents) diário de cada participante - LEFT JOIN.*/
PROC SQL;
	CREATE TABLE PROJDATA.DAILY_INFO AS 
	SELECT DAILY_ACTIVITY.Id AS ID, 
		DAILY_ACTIVITY.ActivityDate AS ACTIVITY_DATE, 
		DAILY_ACTIVITY.TotalSteps as TOTAL_STEPS, 
		DAILY_ACTIVITY.TotalDistance AS TOTAL_DISTANCE, 
		DAILY_MET.MEAN_MET AS MEAN_DAILY_MET,
		DAILY_MET.MAX_MET AS MAX_DAILY_MET,
		DAILY_ACTIVITY.Calories AS CALORIES, 
		DAILY_ACTIVITY.VeryActiveDistance AS VERY_ACTIVE_DISTANCE, 
		DAILY_ACTIVITY.ModeratelyActiveDistance AS MODERATE_ACTIVE_DISTANCE, 
		DAILY_ACTIVITY.LightActiveDistance AS LIGHT_ACTIVE_DIST, 
		DAILY_ACTIVITY.SedentaryActiveDistance AS SEDENTARY_ACTIVE_DIST, 
		DAILY_ACTIVITY.VeryActiveMinutes AS VERY_ACTIVE_MINUTES, 
		DAILY_ACTIVITY.FairlyActiveMinutes AS FAIRLY_ACTIVE_MINUTES, 
		DAILY_ACTIVITY.LightlyActiveMinutes AS LIGHT_ACTIVE_MINUTES, 
		DAILY_ACTIVITY.SedentaryMinutes AS SEDENTARY_ACTIVE_MINUTES 
		FROM PROJDATA.DAILY_ACTIVITY AS DAILY_ACTIVITY LEFT JOIN PROJDATA.DAILY_MET AS DAILY_MET 
		ON DAILY_ACTIVITY.Id = DAILY_MET.ID AND DAILY_ACTIVITY.ActivityDate = DAILY_MET.REF_DAY
		Where DAILY_ACTIVITY.ActivityDate not in 
		(SELECT DM.REF_DAY FROM PROJDATA.DAILY_MET DM WHERE ^(DM.REF_DAY=DAILY_MET.REF_DAY))
		GROUP BY DAILY_ACTIVITY.Id, DAILY_MET.REF_DAY
		ORDER BY DAILY_ACTIVITY.Id, ACTIVITY_DATE, DAILY_MET.REF_DAY;
QUIT;

