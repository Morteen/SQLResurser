/*Craete table kommando 
navn datatype og lengde på datatype
*/
CREATE TABLE Branche(
    branche_id int(4),
    branche_name VARCHAR(50),
    mgr_id int(4),
    mgr_starteDate DATETIME(6)
    
)
/* Insert statement*/
INSERT INTO client (client_id,client_name, branche_id)
VALUES
(400,'Dunmore Highschool',2)
/*

/*Hvordan velge bare en av hver forekomst i tabellen
*/
SELECT DISTINCT branch_id FROM employee
/*
Rekkefølgen  i SQL er 
spørringen må stå i denne rekke følgen

SELECT 
FROM 
WHERE
GROUP BY 
HAVING 
ORDER BY

Funksjoner for beregning av datoer
Funksjon i Microsoft sql server som konverterer datoer
DATENAME gir dette formatet:Friday 16 July 1993
*/
select 
FilmName
,FilmReleaseDate
,CONVERT(char(10),FilmReleaseDate,103)
,DATENAME(DW,FilmReleaseDate)+' '+
DATENAME(DD,FilmReleaseDate)+' '+
DATENAME(MM,FilmReleaseDate)+' '+
DATENAME(YY,FilmReleaseDate)
 

from tblFilm
/*
Funksjon i Microsoft sql server som regner avstand fra en dato til en annen
I tillegg er det en case statement som regner nøyaktig avstand  i år til dagen dato
*/
USE Movies
select 
FilmName
,FilmReleaseDate
,DATEDIFF(DD,FilmReleaseDate,GETDATE())
,DATEDIFF(YY,FilmReleaseDate,GETDATE())
,DATEADD(YY,DATEDIFF(YY,FilmReleaseDate,GETDATE()),FilmReleaseDate)
,	CASE 
		WHEN DATEADD(YY,DATEDIFF(YY,FilmReleaseDate,GETDATE()),FilmReleaseDate)>GETDATE()
		THEN DATEDIFF(YY,FilmReleaseDate,GETDATE())-1
		ELSE DATEDIFF(YY,FilmReleaseDate,GETDATE())
	END

from tblFilm
/*
GROUPING AND AGGREGRATING

Aggregating med vanlige funksjoner som sum(),avg(), osv
*/

USE Movies
select 

SUM(FilmRunTimeMinutes)AS 'Total spilletid for alle filmene'
,AVG(FilmRunTimeMinutes)AS 'Gjenomsnittlig spilletid for filmene'
,MAX(FilmRunTimeMinutes)AS 'Filmen med lengst spilletid'
,MIN(FilmRunTimeMinutes)AS 'Filmen med kortetst spilletid'
,COUNT(*) AS 'Antall filmer i databasen'
,SUM(CONVERT(BIGINT,FilmBoxOfficeDollars)) AS 'Summen av innspilte dollar for alle filmer'
/*Man bruker convert her fordi summen  er større enn vanlig int kan romme*/

from tblFilm
////////////////////////////////////////////////
USE Movies
select 

CountryName
,SUM(CONVERT(BIGINT,FilmBoxOfficeDollars))AS 'Total innspilt pr land'
,AVG(FilmRunTimeMinutes)AS 'AVG spilletid pr land'

from tblFilm As F
INNER JOIN tblCountry AS C
ON C.CountryID =F.FilmCountryID
GROUP BY CountryName
/*Group by gjør at man kan legge sammen eller finn  gjenomsinttet pr land*/
HAVING AVG(FilmRunTimeMinutes)>=125
ORDER BY CountryName ASC
/* Legger men til ' with rollup' legger man lager man en egen kolonne på toppen 
hvor man legger sammen totalen for alle
GROUP BY CountryName with rollup
HAVING brukes her på samme måte som WHERE, men kan brukes sammen med aggregated functions (SUM,AVG,MIN,MAX,osv)
*/

/*Sub queries og Correlated Subqueries
En sub query er en spørring på inn siden av en spørring hvor man bruker resultatet i en where  */
select
 C.CountryName,
 F.FilmName,
 F.FilmRunTimeMinutes
 FROM tblFilm AS F INNER JOIN tblCountry as C 
 ON C.CountryId= F.FilmCountryID
 WHERE F.FilmRunTimeMinutes =
	(
		SELECT MAX(FilmRunTimeMinutes)FROM tblFilm 
		
	)
/*En Correlated Subqueries er en subqueriy med en where inni 
I dette eksempelet gjør den at man kan finne den lengste filmen for hvert land isteden for bare den 
lengste filmen i databasen
Man henter her data fra tblFilm to ganger. Det er veldig viktig å ha forskjellige aliaser på dem*/
select
 C.CountryName,
 F.FilmName,
 F.FilmRunTimeMinutes
 FROM tblFilm AS F INNER JOIN tblCountry as C 
 ON C.CountryId= F.FilmCountryID
 WHERE F.FilmRunTimeMinutes =
	(
		SELECT MAX(FilmRunTimeMinutes)FROM tblFilm AS G
		WHERE G.FilmCountryID= F.FilmCountryID
	)

/*/////////////////////////////////////////////////////////*/


/*VIEWS
Views er utsnitt av tabeller i en database
Man kan sette sammen views med joins for å lette spørringen 
*/
CREATE VIEW viewFilmCountryDirector AS
SELECT  [FilmName] AS 'Filmname',[FilmReleaseDate]AS 'Release date',[FilmOscarNominations]AS 'Oscar Nominations',[FilmOscarWins] As 'Oscarwins',[CountryName],[DirectorName]
FROM tblFilm
INNER JOIN tblCountry As C on C.[CountryID]= tblFilm.FilmCountryID
Inner JOIN tblDirector AS D on d.DirectorID= tblFilm.FilmDirectorID
/*

Man kan simpelten bruke SELECT * i et customview  isteden for 
Inner Join table A on tableB*/
SELECT * FROM viewFilmCountryDirector
/*///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////           sql PROGRAMMERING                 ////////////////////////////////////////////////////////////////////////////////////////////////////////////*/

--Variabler i sql 
/*Man kan deklarere  variabler i sql  med syntaksen*/
DECLARE @tablename  NVARCHAR(128)
--Verdien setter man ved å 
SET @tablename='MinTabel'

--Eksempel
DECLARE @tablename  NVARCHAR(128)
DECLARE @SQLquery  NVARCHAR(MAX)

SET @tablename = N'tblfilm'
SET @SQLquery =  N'select * from '+  @tablename

--STORED PROCEDURE
EXEC SP_EXECUTESQL @SQLquery



--Dynamisk sql
EXECUTE('select * from tblfilm')
--STORED PROCEDURE
EXEC SP_EXECUTESQL N'select * from tblfilm'

/* Man lager en stored procedure ved å bruke CREATE PROC navn, sql koden og så kjøre koden proseduren er nå lagret 
Åpne et nytt vindu og kjør EXCE  procedurenavnet og parametere 
EXEC spFilmYears '2000,2001'
*/
--Eksempel
USE Movies
GO
ALTER PROC spFilmCriteria
	(
		@MinLength AS INT =NULL,
		@MaxLength AS INT = NULL,
		@Title AS  VARCHAR(MAX)
	)
AS
BEGIN
	SELECT FilmName, FilmRunTimeMinutes 
	FROM tblFilm
	WHERE 
	(@MinLength IS NULL OR FilmRunTimeMinutes>=@MinLength)AND 
	(@MaxLength IS NULL OR FilmRunTimeMinutes<=@MaxLength)AND 
	FilmName LIKE '%' + @Title + '%'
	ORDER BY FilmRunTimeMinutes ASC
END
--Nytt eksempel
CREATE PROC spFilmYears
(
 @YearList NVARCHAR(MAX)
)

AS
BEGIN
	DECLARE @SQLstring NVARCHAR(MAX)
	SET @SQlstring =
	N'SELECT * FROM tblFilm
	WHERE YEAR(tblFilm.FilmReleaseDate) IN(' + @YearList + N')
	ORDER BY tblFilm.FilmReleaseDate'
	

	EXEC SP_EXECUTESQL @SQLstring
END
/* CASTING AV VERDIER TIL ANDRE VERDIER*/
 'Number of films '+cast(@NumFilms AS VARCHAR)
 /*Her blir @Numfilms som er en INT omgjort til VARCHAR*/