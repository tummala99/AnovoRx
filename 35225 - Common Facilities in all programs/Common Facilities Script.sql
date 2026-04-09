	--USE AC1UAT;
	--USE CT1UAT;
	--USE CT2UAT;
	--USE ZX1QA;
	/******************Common Facilities in all programs*****************/
	--SELECT * FROM AC1UAT.dbo.Products
	--SELECT * FROM CT1UAT.dbo.Products
	--SELECT * FROM CT2UAT.dbo.Products
	--SELECT * FROM ZX1QA.dbo.Products
	
	/***********************Firdapse***********************************/
	IF(OBJECT_ID('tempdb..#Daybue') IS NOT NULL)
		DROP TABLE #Daybue

	SELECT 'Daybue' AS ProgramName
		 , F.Id AS FacilityId
		 , TRIM(F.FacilityName) AS FacilityName
	     , TRIM(A.city) AS City
		 , A.StateId
		 , TRIM(A.Zip) AS Zip
		 , TRIM(A.Address1) AS Address1
		 , ISNULL(PC.PatientCount,0) AS PatientCount
	  INTO #Daybue 
	  FROM AC1UAT.dbo.Facilities F
	 INNER JOIN AC1UAT.dbo.AddressableAddresses AA 
	    ON aa.Addressable_Id=f.AddressableId
	 INNER JOIN AC1UAT.dbo.Addresses A 
	    ON A.Id = AA.Address_Id
	   AND A.IsDefault=1
	 OUTER APPLY	
			(
				 SELECT FacilityId
					  , COUNT(DISTINCT PatientId) AS PatientCount 
				   FROM AC1UAT.dbo.Cases C
				  WHERE C.FacilityId = F.Id
				  GROUP BY FacilityId
				 HAVING (COUNT(PatientId) > 0)
				  --ORDER BY FacilityId
			) AS PC
	 ORDER BY f.FacilityName,a.city ,A.Zip

	--SELECT * FROM #Daybue ORDER BY FacilityName,city ,Zip

	/***********************Firdapse***********************************/

	IF(OBJECT_ID('tempdb..#Firdapse') IS NOT NULL)
		DROP TABLE #Firdapse

	SELECT 'Firdapse' AS ProgramName
		 , F.Id AS FacilityId
		 , TRIM(F.FacilityName) AS FacilityName
	     , TRIM(A.city) AS City
		 , A.StateId
		 , TRIM(A.Zip) AS Zip
		 , TRIM(A.Address1) AS Address1
		 , ISNULL(PC.PatientCount,0) AS PatientCount
	  INTO #Firdapse
	  FROM CT1UAT.dbo.Facilities F
	 INNER JOIN CT1UAT.dbo.AddressableAddresses AA 
	    ON aa.Addressable_Id=f.AddressableId
	 INNER JOIN CT1UAT.dbo.Addresses A 
	    ON A.Id = AA.Address_Id
	   AND A.IsDefault=1
	 OUTER APPLY	
			(
				 SELECT FacilityId
					  , COUNT(DISTINCT PatientId) AS PatientCount 
				   FROM CT1UAT.dbo.Cases C
				  WHERE C.FacilityId = F.Id
				  GROUP BY FacilityId
				 HAVING (COUNT(PatientId) > 0)
				  --ORDER BY FacilityId
			) AS PC
	 ORDER BY f.FacilityName,a.city ,A.Zip

	--SELECT * FROM #Firdapse ORDER BY FacilityName,city ,Zip

	/***********************aGamree***********************************/

	IF(OBJECT_ID('tempdb..#Agamree') IS NOT NULL)
		DROP TABLE #Agamree

	SELECT 'Agamree' AS ProgramName
		 , F.Id AS FacilityId
		 , TRIM(F.FacilityName) AS FacilityName
	     , TRIM(A.city) AS City
		 , A.StateId
		 , TRIM(A.Zip) AS Zip
		 , TRIM(A.Address1) AS Address1
		 , ISNULL(PC.PatientCount,0) AS PatientCount
	  INTO #Agamree
	  FROM CT2UAT.dbo.Facilities F
	 INNER JOIN CT2UAT.dbo.AddressableAddresses AA 
	    ON aa.Addressable_Id=f.AddressableId
	 INNER JOIN CT2UAT.dbo.Addresses A 
	    ON A.Id = AA.Address_Id
	   AND A.IsDefault=1
	 OUTER APPLY	
			(
				 SELECT FacilityId
					  , COUNT(DISTINCT PatientId) AS PatientCount 
				   FROM CT2UAT.dbo.Cases C
				  WHERE C.FacilityId = F.Id
				  GROUP BY FacilityId
				 HAVING (COUNT(PatientId) > 0)
				  --ORDER BY FacilityId
			) AS PC
	 ORDER BY f.FacilityName,a.city ,A.Zip

	--SELECT * FROM #Agamree ORDER BY FacilityName,city ,Zip

	/***********************aGamree***********************************/

	IF(OBJECT_ID('tempdb..#Fintepla') IS NOT NULL)
		DROP TABLE #Fintepla

	SELECT 'Fintepla' AS ProgramName
		 , F.Id AS FacilityId
		 , TRIM(F.FacilityName) AS FacilityName
	     , TRIM(A.city) AS City
		 , A.StateId
		 , TRIM(A.Zip) AS Zip
		 , TRIM(A.Address1) AS Address1
		 , ISNULL(PC.PatientCount,0) AS PatientCount
	  INTO #Fintepla
	  FROM ZX1QA.dbo.Facilities F
	 INNER JOIN ZX1QA.dbo.AddressableAddresses AA 
	    ON aa.Addressable_Id=f.AddressableId
	 INNER JOIN ZX1QA.dbo.Addresses A 
	    ON A.Id = AA.Address_Id
	   AND A.IsDefault=1
	 OUTER APPLY	
			(
				 SELECT FacilityId
					  , COUNT(DISTINCT PatientId) AS PatientCount 
				   FROM ZX1QA.dbo.Cases C
				  WHERE C.FacilityId = F.Id
				  GROUP BY FacilityId
				 HAVING (COUNT(PatientId) > 0)
				  --ORDER BY FacilityId
			) AS PC
	 ORDER BY f.FacilityName,a.city ,A.Zip

	--SELECT * FROM #Fintepla ORDER BY FacilityName,city ,Zip

	/*******************************************/
	--SELECT * FROM #Daybue ORDER BY FacilityName,city ,Zip
	--SELECT * FROM #Firdapse ORDER BY FacilityName,city ,Zip
	--SELECT * FROM #Agamree ORDER BY FacilityName,city ,Zip
	--SELECT * FROM #Fintepla ORDER BY FacilityName,city ,Zip

	IF(OBJECT_ID('tempdb..#AllFacilities') IS NOT NULL)
		DROP TABLE #AllFacilities

	SELECT COALESCE(A.ProgramName,B.ProgramName,C.ProgramName,D.ProgramName) AS ProgramName
		 , COALESCE(A.FacilityName,B.FacilityName,C.FacilityName, D.FacilityName) AS FacilityName
		 , COALESCE(A.Zip,B.Zip, C.Zip, D.Zip) AS Zip
		 , ISNULL(A.PatientCount,0) AS DaybuePatientCount 
		 , ISNULL(B.PatientCount,0) AS FirdapsePatientCount		 		 
		 , ISNULL(C.PatientCount,0) AS AgamreePatientCount
		 , ISNULL(D.PatientCount,0) AS FinteplaPatientCount
	  INTO #AllFacilities		 
	  FROM #Daybue A
	  FULL OUTER JOIN #Firdapse B
	    ON CONVERT(VARCHAR(30),A.FacilityName)=CONVERT(VARCHAR(30),B.FacilityName)	
	   AND A.Zip = B.Zip
	  FULL OUTER JOIN #Agamree C
	    ON (CONVERT(VARCHAR(30),A.FacilityName)=CONVERT(VARCHAR(30),C.FacilityName) AND A.Zip = C.Zip)
	    OR (CONVERT(VARCHAR(30),B.FacilityName)=CONVERT(VARCHAR(30),C.FacilityName) AND B.Zip = C.Zip)		
	  FULL OUTER JOIN #Fintepla D
	    ON (CONVERT(VARCHAR(30),A.FacilityName)=CONVERT(VARCHAR(30),D.FacilityName) AND A.Zip = D.Zip)
	    OR (CONVERT(VARCHAR(30),B.FacilityName)=CONVERT(VARCHAR(30),D.FacilityName) AND B.Zip = D.Zip)
	    OR (CONVERT(VARCHAR(30),C.FacilityName)=CONVERT(VARCHAR(30),D.FacilityName) AND C.Zip = D.Zip)
	 WHERE (A.FacilityName IS NOT NULL AND B.FacilityName IS NOT NULL)
	    OR (A.FacilityName IS NOT NULL AND C.FacilityName IS NOT NULL)
		OR (A.FacilityName IS NOT NULL AND D.FacilityName IS NOT NULL)
		OR (B.FacilityName IS NOT NULL AND C.FacilityName IS NOT NULL)
		OR (B.FacilityName IS NOT NULL AND D.FacilityName IS NOT NULL)
		OR (C.FacilityName IS NOT NULL AND D.FacilityName IS NOT NULL)

	
	SELECT * FROM #AllFacilities