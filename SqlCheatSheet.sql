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
