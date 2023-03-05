--Utworzy³em bazê danych o nazwie Netflix Analiza, zaimportowa³em tabelê z pliku Excela dostêpnego w folderze, 
--i nazwa³em j¹ dbo.Netflix_G³ówny
--Jeœli ktoœ chcia³by wykonaæ kod, proszê zrobiæ to samo

--Poniewa¿ mój komputer korzysta³ z polskich ustawieñ systemowych, nie by³em w stanie zaimportowaæ danych z pliku CSV, 
--który zosta³ stworzony u¿ywaj¹c angielskich ustawieñ systemowych
--bez napotkania jakichkolwiek b³êdów lub brakuj¹cych danych. 
--W tej sytuacji postanowi³em podzieliæ wartoœci w pliku CSV i zamieniæ go na plik Excel.
--Pozwoli³o to na prawid³owe za³adowanie danych do SQL, jednak pozostawi³o trochê wiêcej czyszczenia do wykonania. 

USE [Netflix Analiza]
SELECT *
FROM dbo.Netflix_G³ówny

--PROSZÊ ZWRÓCIÆ UWAGÊ--
--Poni¿szy kod czyszczenia danych mo¿e nie dzia³aæ zgodnie z oczekiwaniami w tym pliku SQL,
--poniewa¿ tabela zosta³a ju¿ przez niego zmodyfikowana
--Aby sprawdziæ dzia³anie ca³ego kodu, polecam utworzenie nowego pliku SQL, zaimportowanie pliku Excela, a nastêpnie 
--uruchomienie kodu. Wszystko poni¿ej sekcji Obliczenia dzia³a poprawnie. 

---------CZYSZCZENIE DANYCH---------

--Sprawdzanie typu danych dla wszystkich kolumn
SELECT *
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'Netflix_G³ówny'

--Przet³umaczenie kolumn 

EXEC sp_rename 'dbo.Netflix_G³ówny.type', 'typ', 'COLUMN'
EXEC sp_rename 'dbo.Netflix_G³ówny.director', 're¿yser', 'COLUMN'
EXEC sp_rename 'dbo.Netflix_G³ówny.country', 'kraj', 'COLUMN'
EXEC sp_rename 'dbo.Netflix_G³ówny.date_added', 'data_dodania', 'COLUMN'
EXEC sp_rename 'dbo.Netflix_G³ówny.listed_in', 'wymieniony_w', 'COLUMN'

--Usuwanie zbêdnych kolumn
ALTER TABLE dbo.Netflix_G³ówny
DROP COLUMN show_id, title, cast, release_year, rating, duration, description

--Usuwanie spacji
UPDATE dbo.Netflix_G³ówny
SET typ = TRIM(typ)

UPDATE dbo.Netflix_G³ówny
SET re¿yser = TRIM(re¿yser)

UPDATE dbo.Netflix_G³ówny
SET kraj = TRIM(kraj)

UPDATE dbo.Netflix_G³ówny
SET data_dodania = TRIM(data_dodania)

UPDATE dbo.Netflix_G³ówny
SET wymieniony_w = TRIM(wymieniony_w)

--Usuwanie przecinków przed i po tekœcie
Update dbo.Netflix_G³ówny SET 
typ = CASE WHEN typ LIKE ', %' THEN RIGHT(typ, LEN(typ)-2) ELSE typ END,
re¿yser = CASE WHEN re¿yser LIKE ', %' THEN RIGHT(re¿yser, LEN(re¿yser)-2) ELSE re¿yser END,
kraj = CASE WHEN kraj LIKE ', %' THEN RIGHT(kraj, LEN(kraj)-2) ELSE kraj END,
data_dodania = CASE WHEN data_dodania LIKE ', %' THEN RIGHT(data_dodania, LEN(data_dodania)-2) ELSE data_dodania END,
wymieniony_w = CASE WHEN wymieniony_w LIKE ', %' THEN RIGHT(wymieniony_w, LEN(wymieniony_w)-2) ELSE wymieniony_w END

Update dbo.Netflix_G³ówny SET 
typ = CASE WHEN typ LIKE ',%' THEN RIGHT(typ, LEN(typ)-1) ELSE typ END,
re¿yser = CASE WHEN re¿yser LIKE ',%' THEN RIGHT(re¿yser, LEN(re¿yser)-1) ELSE re¿yser END,
kraj = CASE WHEN kraj LIKE ',%' THEN RIGHT(kraj, LEN(kraj)-1) ELSE kraj END,
data_dodania = CASE WHEN data_dodania LIKE ',%' THEN RIGHT(data_dodania, LEN(data_dodania)-1) ELSE data_dodania END,
wymieniony_w = CASE WHEN wymieniony_w LIKE ',%' THEN RIGHT(wymieniony_w, LEN(wymieniony_w)-1) ELSE wymieniony_w END

Update dbo.Netflix_G³ówny SET 
typ = CASE WHEN typ LIKE '% ,' THEN LEFT(typ, LEN(typ)-2) ELSE typ END,
re¿yser = CASE WHEN re¿yser LIKE '% ,' THEN LEFT(re¿yser, LEN(re¿yser)-2) ELSE re¿yser END,
kraj = CASE WHEN kraj LIKE '% ,' THEN LEFT(kraj, LEN(kraj)-2) ELSE kraj END,
data_dodania = CASE WHEN data_dodania LIKE '% ,' THEN LEFT(data_dodania, LEN(data_dodania)-2) ELSE data_dodania END,
wymieniony_w = CASE WHEN wymieniony_w LIKE '% ,' THEN LEFT(wymieniony_w, LEN(wymieniony_w)-2) ELSE wymieniony_w END

Update dbo.Netflix_G³ówny SET 
typ = CASE WHEN typ LIKE '%,' THEN LEFT(typ, LEN(typ)-1) ELSE typ END,
re¿yser = CASE WHEN re¿yser LIKE '%,' THEN LEFT(re¿yser, LEN(re¿yser)-1) ELSE re¿yser END,
kraj = CASE WHEN kraj LIKE '%,' THEN LEFT(kraj, LEN(kraj)-1) ELSE kraj END,
data_dodania = CASE WHEN data_dodania LIKE '%,' THEN LEFT(data_dodania, LEN(data_dodania)-1) ELSE data_dodania END,
wymieniony_w = CASE WHEN wymieniony_w LIKE '%,' THEN LEFT(wymieniony_w, LEN(wymieniony_w)-1) ELSE wymieniony_w END

--Zmiana typu danych na datê
ALTER TABLE dbo.Netflix_G³ówny
ALTER COLUMN data_dodania DATE

--Usuwanie wartoœci Null z kolumny klucza - data_dodania
DELETE FROM dbo.Netflix_G³ówny
WHERE data_dodania IS NULL

--Dodawanie nowych kolumn na podstawie kolumny data_dodania
ALTER TABLE dbo.Netflix_G³ówny
ADD dzieñ AS DATEPART(dd, data_dodania)

ALTER TABLE dbo.Netflix_G³ówny
ADD miesi¹c AS DATEPART(mm, data_dodania)

ALTER TABLE dbo.Netflix_G³ówny
ADD rok AS DATEPART(yyyy, data_dodania)

--Tworzenie dodatkowych tabel, a tak¿e usuwanie spacji, zmiana nazw kolumn i usuwanie wartoœci null.

--KRAJ--
SELECT *
INTO Netflix_Kraj
FROM dbo.Netflix_G³ówny
CROSS APPLY STRING_SPLIT(kraj, ',')

ALTER TABLE dbo.Netflix_Kraj
DROP COLUMN kraj

EXEC sp_rename 'dbo.Netflix_Kraj.value', 'kraj', 'COLUMN'

UPDATE dbo.Netflix_Kraj
SET kraj = TRIM(kraj)

DELETE FROM dbo.Netflix_Kraj
WHERE kraj IS NULL

--KATEGORIA--
SELECT *
INTO Netflix_Kategoria
FROM dbo.Netflix_G³ówny
CROSS APPLY STRING_SPLIT(wymieniony_w, ',')

ALTER TABLE dbo.Netflix_Kategoria
DROP COLUMN wymieniony_w

EXEC sp_rename 'dbo.Netflix_Kategoria.value', 'wymieniony_w', 'COLUMN'

UPDATE dbo.Netflix_Kategoria
SET wymieniony_w = TRIM(wymieniony_w)

DELETE FROM dbo.Netflix_Kategoria
WHERE wymieniony_w IS NULL

--RE¯YSER--
SELECT *
INTO Netflix_Re¿yser
FROM dbo.Netflix_G³ówny
CROSS APPLY STRING_SPLIT(re¿yser, ',')

ALTER TABLE dbo.Netflix_Re¿yser
DROP COLUMN re¿yser

EXEC sp_rename 'dbo.Netflix_Re¿yser.value', 're¿yser', 'COLUMN'

UPDATE dbo.Netflix_Re¿yser
SET re¿yser = TRIM(re¿yser)

DELETE FROM dbo.Netflix_Re¿yser
WHERE re¿yser IS NULL

--Wszystkie tabele po stworzeniu

SELECT *
FROM dbo.Netflix_G³ówny

SELECT *
FROM dbo.Netflix_Kraj

SELECT *
FROM dbo.Netflix_Kategoria

SELECT *
FROM dbo.Netflix_Re¿yser

---------KALKULACJE---------

----------FILMY----------

--Liczba filmów dodawanych rok po roku
SELECT rok, COUNT(*) AS 'Liczba Filmów' 
FROM dbo.Netflix_G³ówny
WHERE typ = 'Movie'
GROUP BY rok
ORDER BY rok


--Najczêstszy/e kraj/e produkcji rok po roku
SELECT rok, kraj, [Liczba Filmów/Kraj]
FROM
(
	SELECT rok, kraj, COUNT(*) AS 'Liczba Filmów/Kraj',
	MAX(COUNT(*)) OVER (PARTITION BY rok) AS 'Max. Liczba Filmów/Rok'
	FROM dbo.Netflix_Kraj
	WHERE typ = 'Movie'
	GROUP BY rok, kraj
) AS Liczba_i_Max
WHERE [Liczba Filmów/Kraj] = [Max. Liczba Filmów/Rok]
ORDER BY rok


--Najczêstszy/e kraj/e produkcji ogólnie
SELECT TOP (1) kraj, COUNT(*) AS 'Liczba'
FROM dbo.Netflix_Kraj
WHERE typ = 'Movie'
GROUP BY kraj
ORDER BY Liczba DESC


--Najczêstsza/e kategoria/e rok po roku
SELECT rok, wymieniony_w, [Liczba Filmów/Kategoria]
FROM
(
	SELECT rok, wymieniony_w, COUNT(*) AS 'Liczba Filmów/Kategoria',
	MAX(COUNT(*)) OVER (PARTITION BY rok) AS 'Max. Liczba Filmów/Kategoria'
	FROM dbo.Netflix_Kategoria
	WHERE typ = 'Movie'
	GROUP BY rok, wymieniony_w
) AS Liczba_i_Max
WHERE [Liczba Filmów/Kategoria] = [Max. Liczba Filmów/Kategoria]
ORDER BY rok


--Najczêstsza/e kategoria/e ogólnie
SELECT TOP (1) wymieniony_w, COUNT(*) AS 'Liczba'
FROM dbo.Netflix_Kategoria
WHERE typ = 'Movie'
GROUP BY wymieniony_w
ORDER BY Liczba DESC


--Najczêstszy/si re¿yser/rzy rok po roku
SELECT rok, re¿yser, [Liczba Filmów/Re¿yser]
FROM
(
	SELECT rok, re¿yser, COUNT(*) AS 'Liczba Filmów/Re¿yser',
	MAX(COUNT(*)) OVER (PARTITION BY rok) AS 'Max. Liczba Filmów/Re¿yser'
	FROM dbo.Netflix_Re¿yser
	WHERE typ = 'Movie'
	GROUP BY rok, re¿yser
) AS Liczba_i_Max
WHERE [Liczba Filmów/Re¿yser] = [Max. Liczba Filmów/Re¿yser]
ORDER BY rok


--Najczêstszy/si re¿yser/rzy ogólnie
SELECT TOP (1) re¿yser, COUNT(*) AS 'Liczba'
FROM dbo.Netflix_Re¿yser
WHERE typ = 'Movie'
GROUP BY re¿yser
ORDER BY Liczba DESC

----------PROGRAMY TELEWIZYJNE----------

--Liczba programów telewizyjnych rok po roku
SELECT rok, COUNT(*) AS 'Liczba Programów Telewizyjnych' 
FROM dbo.Netflix_G³ówny
WHERE typ = 'TV Show'
GROUP BY rok
ORDER BY rok


--Najczêstszy/e kraj/e produkcji rok po roku
SELECT rok, kraj, [Liczba Programów Telewizyjnych/Kraj]
FROM
(
	SELECT rok, kraj, COUNT(*) AS 'Liczba Programów Telewizyjnych/Kraj',
	MAX(COUNT(*)) OVER (PARTITION BY rok) AS 'Max. Liczba Programów Telewizyjnych/Rok'
	FROM dbo.Netflix_Kraj
	WHERE typ = 'TV Show'
	GROUP BY rok, kraj
) AS Liczba_i_Max
WHERE [Liczba Programów Telewizyjnych/Kraj] = [Max. Liczba Programów Telewizyjnych/Rok]
ORDER BY rok


--Najczêstszy/e kraj/e produkcji ogólnie
SELECT TOP (1) kraj, COUNT(*) AS 'Liczba'
FROM dbo.Netflix_Kraj
WHERE typ = 'TV Show'
GROUP BY kraj
ORDER BY Liczba DESC


--Najczêstsza/e kategoria/e rok po roku
SELECT rok, wymieniony_w, [Liczba Programów Telewizyjnych/Kategoria]
FROM
(
	SELECT rok, wymieniony_w, COUNT(*) AS 'Liczba Programów Telewizyjnych/Kategoria',
	MAX(COUNT(*)) OVER (PARTITION BY rok) AS 'Max. Liczba Programów Telewizyjnych/Rok'
	FROM dbo.Netflix_Kategoria
	WHERE typ = 'TV Show'
	GROUP BY rok, wymieniony_w
) AS Liczba_i_Max
WHERE [Liczba Programów Telewizyjnych/Kategoria] = [Max. Liczba Programów Telewizyjnych/Rok]
ORDER BY rok


--Najczêstsza/e kategoria/e ogólnie
SELECT TOP (1) wymieniony_w, COUNT(*) AS 'Liczba'
FROM dbo.Netflix_Kategoria
WHERE typ = 'TV Show'
GROUP BY wymieniony_w
ORDER BY Liczba DESC


--Najczêstszy/si Re¿yser/rzy rok po roku
SELECT rok, re¿yser, [Liczba Programów Telewizyjnych/Re¿yser]
FROM
(
	SELECT rok, re¿yser, COUNT(*) AS 'Liczba Programów Telewizyjnych/Re¿yser',
	MAX(COUNT(*)) OVER (PARTITION BY rok) AS 'Max. Liczba Programów Telewizyjnych/Rok'
	FROM dbo.Netflix_Re¿yser
	WHERE typ = 'TV Show'
	GROUP BY rok, re¿yser
) AS Liczba_i_Max
WHERE [Liczba Programów Telewizyjnych/Re¿yser] = [Max. Liczba Programów Telewizyjnych/Rok]
ORDER BY rok


--Najczêstszy/si Re¿yser/rzy ogólnie
SELECT TOP (2) re¿yser, COUNT(*) AS 'Liczba'
FROM dbo.Netflix_Re¿yser
WHERE typ = 'TV Show'
GROUP BY re¿yser
ORDER BY Liczba DESC