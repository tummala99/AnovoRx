IF (OBJECT_ID('dbo.usp_rpt_DashboardReview') IS NOT NULL)
	DROP PROCEDURE dbo.usp_rpt_DashboardReview
GO

CREATE PROCEDURE dbo.usp_rpt_DashboardReview
AS
/*
	Purpose: Consolidate and generate Dashboard Review Report data
	
	EXEC dbo.usp_rpt_DashboardReview

*/
BEGIN

/*
	--008 No Orders
*/
	IF(OBJECT_ID('tempdb..#008NoOrders') IS NOT NULL)
		DROP TABLE #008NoOrders

	SELECT P.mrn
	  INTO #008NoOrders
	  FROM dbo.[STG_DaybuePatients] P
	  LEFT JOIN dbo.[STG_DaybueOrders] O
	    ON P.mrn = O.[Anovo ID]
	 WHERE (O.[Anovo ID] IS NULL);

	--SELECT * FROM #008NoOrders -- 1099

/*******************************************************
--------- 007 Order Next Fill -----------------
********************************************************/
	IF(OBJECT_ID('tempdb..#004ActiveOrders') IS NOT NULL)
		DROP TABLE #004ActiveOrders

	SELECT [Anovo ID] AS MRN
		 , [status] AS [Order Status]
		 , [rank] AS [Rank]
	  INTO #004ActiveOrders
	  FROM dbo.[STG_DaybueOrders]
	 WHERE [status] = 'Active';

	IF(OBJECT_ID('tempdb..#003PendingOrders') IS NOT NULL)
		DROP TABLE #003PendingOrders
	SELECT [Anovo ID] AS MRN
		 , [status] AS [Order Status]
		 , [rank] AS [Rank]
	  INTO #003PendingOrders
	  FROM dbo.[STG_DaybueOrders]
	 WHERE [status] = 'Pending'
	
	IF(OBJECT_ID('tempdb..#005OrderNextFillActive') IS NOT NULL)
		DROP TABLE #005OrderNextFillActive
	
	SELECT AO.MRN
		 , O.[status] AS [Order Status]
		 , O.[Queue]
		 , O.[Order Last Event] AS [Last Event]
		 , O.[Last Event Date]
		 , O.[Ship Date] AS [Order Fill Date]
		 , O.[Next Fill Date] AS [Next Fill]
	  INTO #005OrderNextFillActive
	  FROM dbo.[STG_DaybueOrders] O
	 INNER JOIN #004ActiveOrders AO 
	    ON O.[Rank] = AO.[Rank]
	   AND O.[Anovo ID] = AO.MRN
	 WHERE AO.MRN IS NOT NULL
	   AND O.[status] <> 'DC''d'

	IF(OBJECT_ID('tempdb..#007OrderNextFill') IS NOT NULL)
		DROP TABLE #007OrderNextFill	
	
	SELECT * 
	  INTO #007OrderNextFill
	  FROM 
		(
			SELECT DISTINCT	AO.MRN
				 , O.[Status] AS [Order Status]
				 , O.[Queue] AS QUEUE
				 , O.[Order Last Event] AS [Last Event]
				 , O.[last event date] AS [Last Event Date]
				 , O.[Ship Date] AS [Order Fill Date]
				 , IIF(
						[Ship Date] >= GETDate(),
						[Ship Date],
						[Next Fill Date]
						) AS [Next Fill]
			  FROM dbo.[STG_DaybueOrders] O
			  LEFT JOIN #004ActiveOrders AO 
				ON O.[Anovo ID] = AO.MRN	
			   AND O.[Rank] = AO.[Rank]
			 WHERE AO.MRN IS NOT NULL
			   AND O.[status] <> 'DC''d' -- 831
			 UNION
			SELECT DISTINCT PO.MRN
				 , O.[status] AS [Order Status]
				 , O.[Queue] AS [QUEUE]
				 , O.[Order Last Event] AS [Last Event]
				 , O.[Last Event Date] AS [Last Event Date]
				 , O.[Ship Date] AS [Order Fill Date]
				 , IIF(
					[Ship Date] >= GETDATE(),
					[Ship Date],
					[Next Fill Date]
					) AS [Next Fill]
			  FROM dbo.[STG_DaybueOrders] O
			  LEFT JOIN #003PendingOrders PO 
				ON O.[Anovo ID] = PO.MRN
			   AND (O.[rank] = PO.[rank])	
			  LEFT JOIN #005OrderNextFillActive ONF 
				ON O.[Anovo ID] = ONF.MRN
			 WHERE PO.MRN IS NOT NULL
			   AND O.[Status] <> 'DC''d'
			   AND ONF.MRN IS NULL
		) AS T
	
/*******************************************************
--------- 002 Last Dispense -----------------
********************************************************/
	IF(OBJECT_ID('tempdb..#002LastDispense') IS NOT NULL)
		DROP TABLE #002LastDispense

	SELECT D.[Anovo ID]
		 , CAST(D.[Ship Date] AS DATE) AS [Ship Date]
		 --, CAST([maxofship date] AS DATE) + CAST([dispense_therapy_days] AS INT) + 1 AS [Need by Date]
		 --, (CAST([Quantity Dispensed] AS INT) / CAST([dispense_therapy_days] AS INT)) * 10 AS [Daily Dose]
		 , DATEADD(DAY,CAST([dispense_therapy_days] AS INT) + 1,CAST([maxofship date] AS DATE)) AS [Need by Date]
		 , CASE WHEN ISNULL(NULLIF([dispense_therapy_days],''),0) > 0 THEN
				ROUND((CAST([Quantity Dispensed] AS float))/CAST([dispense_therapy_days] AS INT),2)
				ELSE 0
		   END AS [Daily Dose]
	  INTO #002LastDispense
	  FROM dbo.[STG_DaybueDispense] D
	 INNER JOIN (
				SELECT [Anovo ID]
					 , MAX([Ship Date]) AS [MaxOfShip Date]
				  FROM dbo.[STG_DaybueDispense]
				 GROUP BY [Anovo ID]
			) AS [001MaxDateDisp] 
	    ON D.[Anovo ID] = [001MaxDateDisp].[Anovo ID]
	   AND D.[Ship Date] = [001MaxDateDisp].[MaxOfShip Date]
	
	--SELECT ROUND((CAST([Quantity Dispensed] AS float))/ISNULL(NULLIF([dispense_therapy_days],''),0),2) FROM dbo.[STG_DaybueDispense] WHERE [dispense_therapy_days] != 0
	--SELECT [Quantity Dispensed],ISNULL([dispense_therapy_days],1) FROM dbo.[STG_DaybueDispense] WHERE [dispense_therapy_days] = 0

	/*******************************************************
	--------- 009 Dashboard -----------------
	********************************************************/
		IF(OBJECT_ID('tempdb..#009Dashboard') IS NOT NULL)
			DROP TABLE #009Dashboard

		SELECT P.patient_full_name
			 , P.mrn
			 , P.[HUB ID]
			 , P.patient_primary_icd10
			 , P.patient_primary_icd10_diagnosis
			 , P.patient_secondary_icd10
			 , P.patient_secondary_icd10_diagnosis
			 , P.patient_status
			 , #007OrderNextFill.[Order Status]
			 , P.primary_payer
			 , P.secondary_payer
			 , #007OrderNextFill.[Queue]
			 , #007OrderNextFill.[Last Event]
			 , #007OrderNextFill.[Last Event Date]
			 , #002LastDispense.[Ship Date] AS [Last Fill]
			 , #007OrderNextFill.[Next Fill]
			 , #002LastDispense.[Need by Date]
		  INTO #009Dashboard
		  FROM dbo.[STG_DaybuePatients]	P
		  LEFT JOIN #008NoOrders ON P.mrn = #008NoOrders.mrn
		  LEFT JOIN #007OrderNextFill ON P.mrn = #007OrderNextFill.MRN	
		  LEFT JOIN #002LastDispense ON P.mrn = #002LastDispense.[Anovo ID]
		 WHERE (((#008NoOrders.mrn) IS NULL))
		 ORDER BY #002LastDispense.[Need by Date]; -- 1065

/*******************************************************
--------- 010 Precall Format -----------------
********************************************************/
	IF(OBJECT_ID('tempdb..#010PrecallFormat') IS NOT NULL)
		DROP TABLE #010PrecallFormat

	SELECT [Dispensing ID] AS MRN
		 --,[External ID] AS MRN
		 , [Activity Completed Date] AS [Precall Completed Date]
		 , [Arrange ship date with caller Enter ship date] AS [Scheduled Ship Date]
		 , [What days supply of medication does the patient have on hand at this time?] AS DOH
	  INTO #010PrecallFormat
	  FROM dbo.[STG_DaybuePrecallDOH]

	--SELECT   [Dispensing ID],   Max([Activity Completed Date]) AS [MaxOfActivity Completed Date]
	--FROM   dbo.[STG_DaybuePrecallDOH]
	--GROUP BY   [Dispensing ID];

	  --SELECT MRN,MAX([Precall Completed Date]) AS [MaxOfActivity Completed Date]
	  --  FROM  #010PrecallFormat
	  -- GROUP BY MRN
	

	/*******************************************************
	--------- 012 Precall -----------------
	********************************************************/
	IF(OBJECT_ID('tempdb..#012Precall') IS NOT NULL)
		DROP TABLE #012Precall

		SELECT A.MRN
			 , MaxOfActivity.[MaxOfActivity Completed Date]
			 , A.[Scheduled Ship Date]
			 , A.DOH
			 , [DOH] + ' DOH on ' + [Precall Completed Date] + ' shipping ' + [scheduled Ship Date] AS [DOH Ship Date]
			 , [Precall completed date] + [doh] AS [Actual doh]
		  INTO #012Precall
		  FROM #010PrecallFormat A
		 INNER JOIN ( SELECT MRN,MAX([Precall Completed Date]) AS [MaxOfActivity Completed Date]
						FROM  #010PrecallFormat
					   GROUP BY MRN) AS MaxOfActivity
			ON (A.[Precall Completed Date] = MaxOfActivity.[MaxOfActivity Completed Date]
				)
		   AND (A.MRN = MaxOfActivity.[MRN]	)
		 WHERE (((A.[Scheduled Ship Date]) IS NOT NULL));

/*******************************************************
--------- 001 Late Shipment Notes Add -----------------
********************************************************/
	IF(OBJECT_ID('tempdb..#001LateShipmentNotesAdd') IS NOT NULL)
		DROP TABLE #001LateShipmentNotesAdd
		
	SELECT A.[Name]
		 , A.MRN
		 , A.patient_status
		 , A.[Order Status]
		 , A.[Queue]
		 , A.[Last Event]
		 , A.[Last Event Date]
		 , A.[Last Fill]
		 , A.[Need by Date]
		 , A.[Next Fill]
		 , A.Category
		 --, B.[Review Notes]
		 --, A.[Review Notes]
		 , ISNULL(B.[Review Notes] ,A.[Review Notes]) AS Notes
		 --, IIF(B.[Review Notes] IS NULL,A.[Review Notes], IIF (B.[Review Notes] IS NOT NULL,B.[Review Notes],'')				
			--  ) AS Notes
	  INTO #001LateShipmentNotesAdd
	  FROM dbo.[STG_100_Dashboard_Review] A
	  LEFT JOIN dbo.[STG_200_Late_Shipment] B 
	    ON A.MRN = B.MRN;
/*******************************************************
--------- 002 Early Shipment Notes Add -----------------
********************************************************/
	IF(OBJECT_ID('tempdb..#002EarlyShipmentNotesAdd') IS NOT NULL)
		DROP TABLE #002EarlyShipmentNotesAdd

	SELECT A.[Name]
		 , A.MRN
		 , A.patient_status
		 , A.[Order Status]
		 , A.[Queue]
		 , A.[Last Event]
		 , A.[Last Event Date]
		 , A.[Last Fill]
		 , A.[Next Fill]
		 , A.[Need by Date]
		 , A.Category
		 , ISNULL(B.[Review Notes],A.[Notes]) AS Notes		
	  INTO #002EarlyShipmentNotesAdd
	  FROM #001LateShipmentNotesAdd A
	  LEFT JOIN dbo.[STG_300_Early_Shipment] B 
	    ON A.MRN = B.mrn;

/*******************************************************
--------- 003 Days To Exhaust Notes Add -----------------
********************************************************/
	IF(OBJECT_ID('tempdb..#003DaysToExhaustNotesAdd') IS NOT NULL)
		DROP TABLE #003DaysToExhaustNotesAdd
	SELECT A.[Name]
		 , A.MRN
		 , A.patient_status
		 , A.[Order Status]
		 , A.[Queue]
		 , A.[Last Event]
		 , A.[Last Event Date]
		 , A.[Last Fill]
		 , A.[Need by Date]
		 , A.[Next Fill]
		 , A.Category
		 , ISNULL(B.[Review Notes],A.Notes) AS Notes
	  INTO #003DaysToExhaustNotesAdd
	  FROM #002EarlyShipmentNotesAdd A
	  LEFT JOIN dbo.[STG_400_Days_to_Exhaust] B
	    ON A.MRN = B.MRN;
/*******************************************************
--------- 004 New Rx Notes Add -----------------
********************************************************/
	IF(OBJECT_ID('tempdb..#004NewRxNotesAdd') IS NOT NULL)
		DROP TABLE #004NewRxNotesAdd
	SELECT A.[Name]
		 , A.MRN
		 , A.patient_status
		 , A.[Order Status]
		 , A.[Queue]
		 , A.[Last Event]
		 , A.[Last Event Date]
		 , A.[Last Fill]
		 , A.[Next Fill]
		 , A.[Need by Date]
		 , A.Category
		 ,ISNULL(B.[Review Notes],A.[Notes]) AS Notes
      INTO #004NewRxNotesAdd		 
	  FROM #003DaysToExhaustNotesAdd A
	  LEFT JOIN dbo.[STG_800_New_Rx] B
	    ON A.MRN = B.mrn;



/*******************************************************
--------- _100_Dashboard_Previous -----------------
********************************************************/
	IF(OBJECT_ID('tempdb..#_100_Dashboard_Previous') IS NOT NULL)
		DROP TABLE #_100_Dashboard_Previous

	SELECT A.[Name]
		 , A.MRN
		 , A.patient_status
		 , A.[Order Status]
		 , A.[Queue]
		 , A.[Last Event]
		 , A.[Last Event Date]
		 , A.[Last Fill]
		 , A.[Next Fill]
		 , A.[Need by Date]
		 , A.Category
		 , ISNULL(B.[Review Notes],A.[Notes]) AS Notes
	  INTO #_100_Dashboard_Previous
	  FROM #004NewRxNotesAdd A
	  LEFT JOIN dbo.[STG_900_Need_Rx] B
	    ON A.MRN = B.mrn;

	/*******************************************************
	--------- _100_Previous -----------------
	********************************************************/
	IF(OBJECT_ID('tempdb..#_100_Previous') IS NOT NULL)
		DROP TABLE #_100_Previous
	SELECT A.[Name]
		 , A.MRN
		 , A.patient_status
		 , A.[Order Status]
		 , A.[Queue]
		 , A.[Last Event]
		 , A.[Last Event Date]
		 , A.[Last Fill]
		 , A.[Next Fill]
		 , A.[Need by Date]
		 , A.Category
		 , ISNULL(B.[Follow Up Notes],A.[Notes]) AS Notes
	  INTO #_100_Previous		 
	  FROM #_100_Dashboard_Previous A
	  LEFT JOIN dbo.[STG_Afternoon_Review] B 
	    ON A.MRN = B.MRN;


	/********************Final***********************************
	--------- 100 Dashboard Review -----------------
	*************************************************************/



	SELECT A.patient_full_name AS [Name]
		 , A.mrn AS MRN
		 , A.[HUB ID]
		 , A.patient_status
		 , A.[Order Status]
		 , A.primary_payer AS Payer
		 , A.secondary_payer AS [Secondary]
		 , A.[Queue]
		 , A.[Last Event]
		 , A.[Last Event Date]
		 , A.[Last Fill]
		 , A.[Next Fill]
		 , A.[Need by Date]
		 , CASE WHEN (GETDATE() > A.[Need by Date] AND (A.[queue] LIKE 'B.%' OR A.[queue] LIKE 'A.%')) THEN 'Late Shipment'
				WHEN ((DATEADD(DAY,7,GETDATE())) > A.[need by date] AND ( A.[QUEUE] LIKE 'B.%' OR A.[Queue] LIKE 'A.%')) THEN	'<7 Days to Exhaust'
				WHEN ((DATEADD(DAY,3,B.[scheduled ship date]) < A.[Need by Date]) AND (A.[queue] LIKE 'C.%' OR A.[queue] LIKE 'E.%')) THEN 'Early Shipment'
				WHEN (A.[queue] LIKE 'I.%') THEN 'Need Rx'
				WHEN (A.[queue] LIKE '3%' OR A.[queue] LIKE '4%') THEN 'New Rx'
				ELSE ''
		   END AS Category
		 --, IIF (GETDATE() > A.[Need by Date] AND (A.[queue] LIKE 'B.%' OR A.[queue] LIKE 'A.%'), 'Late Shipment',
			--	IIF((DATEADD(DAY,7,GETDATE())) > A.[need by date] AND ( A.[QUEUE] LIKE 'B.%' OR A.[Queue] LIKE 'A.%'),	'<7 Days to Exhaust',
			--		IIf((DATEADD(DAY,3,B.[scheduled ship date]) < A.[Need by Date]) AND (A.[queue] LIKE 'C.%' OR A.[queue] LIKE 'E.%'),'Early Shipment',
			--			IIf(A.[queue] LIKE 'I.%','Need Rx',
			--				IIf(A.[queue] LIKE '3%' OR A.[queue] LIKE '4%','New Rx','')
			--				)
			--			)
			--		)
			--	) AS Category
		 , CASE WHEN C.[notes] IS NOT NULL THEN C.[notes]
				WHEN (C.[notes] IS NULL	AND (A.[queue] LIKE 'C.%'	OR A.[queue] LIKE 'E.%')) THEN B.[DOH Ship Date]
				ELSE ''
		   END AS [Review Notes]
		 --, IIF(C.[notes] IS NOT NULL,C.[notes],
			--	IIF(C.[notes] IS NULL	AND (A.[queue] LIKE 'C.%'	OR A.[queue] LIKE 'E.%'),B.[DOH Ship Date],'')
			--	) AS [Review Notes]
	  FROM [#009Dashboard] A
	  LEFT JOIN #012Precall B 
	    ON A.mrn = B.MRN	
	  LEFT JOIN #_100_Previous C 
	    ON A.mrn = C.MRN
	 ORDER BY A.[Next Fill];
END