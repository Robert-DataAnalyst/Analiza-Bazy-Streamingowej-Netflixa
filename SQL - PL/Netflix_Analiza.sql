--Utworzy�em baz� danych o nazwie Netflix Analiza, zaimportowa�em tabel� z pliku Excela dost�pnego w folderze, 
--i nazwa�em j� dbo.Netflix_G��wny
--Je�li kto� chcia�by wykona� kod, prosz� zrobi� to samo

--Poniewa� m�j komputer korzysta� z polskich ustawie� systemowych, nie by�em w stanie zaimportowa� danych z pliku CSV, 
--kt�ry zosta� stworzony u�ywaj�c angielskich ustawie� systemowych
--bez napotkania jakichkolwiek b��d�w lub brakuj�cych danych. 
--W tej sytuacji postanowi�em podzieli� warto�ci w pliku CSV i zamieni� go na plik Excel.
--Pozwoli�o to na prawid�owe za�adowanie danych do SQL, jednak pozostawi�o troch� wi�cej czyszczenia do wykonania. 

USE [Netflix Analiza]
SELECT *
FROM dbo.Netflix_G��wny

--PROSZ� ZWR�CI� UWAG�--
--Poni�szy kod czyszczenia danych mo�e nie dzia�a� zgodnie z oczekiwaniami w tym pliku SQL,
--poniewa� tabela zosta�a ju� przez niego zmodyfikowana
--Aby sprawdzi� dzia�anie ca�ego kodu, polecam utworzenie nowego pliku SQL, zaimportowanie pliku Excela, a nast�pnie 
--uruchomienie kodu. Wszystko poni�ej sekcji Obliczenia dzia�a poprawnie. 

---------CZYSZCZENIE DANYCH---------

--Sprawdzanie typu danych dla wszystkich kolumn
SELECT *
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'Netflix_G��wny'

--Przet�umaczenie kolumn 

EXEC sp_rename 'dbo.Netflix_G��wny.type', 'typ', 'COLUMN'
EXEC sp_rename 'dbo.Netflix_G��wny.director', 're�yser', 'COLUMN'
EXEC sp_rename 'dbo.Netflix_G��wny.country', 'kraj', 'COLUMN'
EXEC sp_rename 'dbo.Netflix_G��wny.date_added', 'data_dodania', 'COLUMN'
EXEC sp_rename 'dbo.Netflix_G��wny.listed_in', 'wymieniony_w', 'COLUMN'

--Usuwanie zb�dnych kolumn
ALTER TABLE dbo.Netflix_G��wny
DROP COLUMN show_id, title, cast, release_year, rating, duration, description

--Usuwanie spacji
UPDATE dbo.Netflix_G��wny
SET typ = TRIM(typ)

UPDATE dbo.Netflix_G��wny
SET re�yser = TRIM(re�yser)

UPDATE dbo.Netflix_G��wny
SET kraj = TRIM(kraj)

UPDATE dbo.Netflix_G��wny
SET data_dodania = TRIM(data_dodania)

UPDATE dbo.Netflix_G��wny
SET wymieniony_w = TRIM(wymieniony_w)

--Usuwanie przecink�w przed i po tek�cie
Update dbo.Netflix_G��wny SET 
typ = CASE WHEN typ LIKE ', %' THEN RIGHT(typ, LEN(typ)-2) ELSE typ END,
re�yser = CASE WHEN re�yser LIKE ', %' THEN RIGHT(re�yser, LEN(re�yser)-2) ELSE re�yser END,
kraj = CASE WHEN kraj LIKE ', %' THEN RIGHT(kraj, LEN(kraj)-2) ELSE kraj END,
data_dodania = CASE WHEN data_dodania LIKE ', %' THEN RIGHT(data_dodania, LEN(data_dodania)-2) ELSE data_dodania END,
wymieniony_w = CASE WHEN wymieniony_w LIKE ', %' THEN RIGHT(wymieniony_w, LEN(wymieniony_w)-2) ELSE wymieniony_w END

Update dbo.Netflix_G��wny SET 
typ = CASE WHEN typ LIKE ',%' THEN RIGHT(typ, LEN(typ)-1) ELSE typ END,
re�yser = CASE WHEN re�yser LIKE ',%' THEN RIGHT(re�yser, LEN(re�yser)-1) ELSE re�yser END,
kraj = CASE WHEN kraj LIKE ',%' THEN RIGHT(kraj, LEN(kraj)-1) ELSE kraj END,
data_dodania = CASE WHEN data_dodania LIKE ',%' THEN RIGHT(data_dodania, LEN(data_dodania)-1) ELSE data_dodania END,
wymieniony_w = CASE WHEN wymieniony_w LIKE ',%' THEN RIGHT(wymieniony_w, LEN(wymieniony_w)-1) ELSE wymieniony_w END

Update dbo.Netflix_G��wny SET 
typ = CASE WHEN typ LIKE '% ,' THEN LEFT(typ, LEN(typ)-2) ELSE typ END,
re�yser = CASE WHEN re�yser LIKE '% ,' THEN LEFT(re�yser, LEN(re�yser)-2) ELSE re�yser END,
kraj = CASE WHEN kraj LIKE '% ,' THEN LEFT(kraj, LEN(kraj)-2) ELSE kraj END,
data_dodania = CASE WHEN data_dodania LIKE '% ,' THEN LEFT(data_dodania, LEN(data_dodania)-2) ELSE data_dodania END,
wymieniony_w = CASE WHEN wymieniony_w LIKE '% ,' THEN LEFT(wymieniony_w, LEN(wymieniony_w)-2) ELSE wymieniony_w END

Update dbo.Netflix_G��wny SET 
typ = CASE WHEN typ LIKE '%,' THEN LEFT(typ, LEN(typ)-1) ELSE typ END,
re�yser = CASE WHEN re�yser LIKE '%,' THEN LEFT(re�yser, LEN(re�yser)-1) ELSE re�yser END,
kraj = CASE WHEN kraj LIKE '%,' THEN LEFT(kraj, LEN(kraj)-1) ELSE kraj END,
data_dodania = CASE WHEN data_dodania LIKE '%,' THEN LEFT(data_dodania, LEN(data_dodania)-1) ELSE data_dodania END,
wymieniony_w = CASE WHEN wymieniony_w LIKE '%,' THEN LEFT(wymieniony_w, LEN(wymieniony_w)-1) ELSE wymieniony_w END

--Zmiana typu danych na dat�
ALTER TABLE dbo.Netflix_G��wny
ALTER COLUMN data_dodania DATE

--Usuwanie warto�ci Null z kolumny klucza - data_dodania
DELETE FROM dbo.Netflix_G��wny
WHERE data_dodania IS NULL

--Dodawanie nowych kolumn na podstawie kolumny data_dodania
ALTER TABLE dbo.Netflix_G��wny
ADD dzie� AS DATEPART(dd, data_dodania)

ALTER TABLE dbo.Netflix_G��wny
ADD miesi�c AS DATEPART(mm, data_dodania)

ALTER TABLE dbo.Netflix_G��wny
ADD rok AS DATEPART(yyyy, data_dodania)

--Tworzenie dodatkowych tabel, a tak�e usuwanie spacji, zmiana nazw kolumn i usuwanie warto�ci null.

--KRAJ--
SELECT *
INTO Netflix_Kraj
FROM dbo.Netflix_G��wny
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
FROM dbo.Netflix_G��wny
CROSS APPLY STRING_SPLIT(wymieniony_w, ',')

ALTER TABLE dbo.Netflix_Kategoria
DROP COLUMN wymieniony_w

EXEC sp_rename 'dbo.Netflix_Kategoria.value', 'wymieniony_w', 'COLUMN'

UPDATE dbo.Netflix_Kategoria
SET wymieniony_w = TRIM(wymieniony_w)

DELETE FROM dbo.Netflix_Kategoria
WHERE wymieniony_w IS NULL

--RE�YSER--
SELECT *
INTO Netflix_Re�yser
FROM dbo.Netflix_G��wny
CROSS APPLY STRING_SPLIT(re�yser, ',')

ALTER TABLE dbo.Netflix_Re�yser
DROP COLUMN re�yser

EXEC sp_rename 'dbo.Netflix_Re�yser.value', 're�yser', 'COLUMN'

UPDATE dbo.Netflix_Re�yser
SET re�yser = TRIM(re�yser)

DELETE FROM dbo.Netflix_Re�yser
WHERE re�yser IS NULL

--Wszystkie tabele po stworzeniu

SELECT *
FROM dbo.Netflix_G��wny

SELECT *
FROM dbo.Netflix_Kraj

SELECT *
FROM dbo.Netflix_Kategoria

SELECT *
FROM dbo.Netflix_Re�yser

---------KALKULACJE---------

----------FILMY----------

--Liczba film�w dodawanych rok po roku
SELECT rok, COUNT(*) AS 'Liczba Film�w' 
FROM dbo.Netflix_G��wny
WHERE typ = 'Movie'
GROUP BY rok
ORDER BY rok


--Najcz�stszy/e kraj/e produkcji rok po roku
SELECT rok, kraj, [Liczba Film�w/Kraj]
FROM
(
	SELECT rok, kraj, COUNT(*) AS 'Liczba Film�w/Kraj',
	MAX(COUNT(*)) OVER (PARTITION BY rok) AS 'Max. Liczba Film�w/Rok'
	FROM dbo.Netflix_Kraj
	WHERE typ = 'Movie'
	GROUP BY rok, kraj
) AS Liczba_i_Max
WHERE [Liczba Film�w/Kraj] = [Max. Liczba Film�w/Rok]
ORDER BY rok


--Najcz�stszy/e kraj/e produkcji og�lnie
SELECT TOP (1) kraj, COUNT(*) AS 'Liczba'
FROM dbo.Netflix_Kraj
WHERE typ = 'Movie'
GROUP BY kraj
ORDER BY Liczba DESC


--Najcz�stsza/e kategoria/e rok po roku
SELECT rok, wymieniony_w, [Liczba Film�w/Kategoria]
FROM
(
	SELECT rok, wymieniony_w, COUNT(*) AS 'Liczba Film�w/Kategoria',
	MAX(COUNT(*)) OVER (PARTITION BY rok) AS 'Max. Liczba Film�w/Kategoria'
	FROM dbo.Netflix_Kategoria
	WHERE typ = 'Movie'
	GROUP BY rok, wymieniony_w
) AS Liczba_i_Max
WHERE [Liczba Film�w/Kategoria] = [Max. Liczba Film�w/Kategoria]
ORDER BY rok


--Najcz�stsza/e kategoria/e og�lnie
SELECT TOP (1) wymieniony_w, COUNT(*) AS 'Liczba'
FROM dbo.Netflix_Kategoria
WHERE typ = 'Movie'
GROUP BY wymieniony_w
ORDER BY Liczba DESC


--Najcz�stszy/si re�yser/rzy rok po roku
SELECT rok, re�yser, [Liczba Film�w/Re�yser]
FROM
(
	SELECT rok, re�yser, COUNT(*) AS 'Liczba Film�w/Re�yser',
	MAX(COUNT(*)) OVER (PARTITION BY rok) AS 'Max. Liczba Film�w/Re�yser'
	FROM dbo.Netflix_Re�yser
	WHERE typ = 'Movie'
	GROUP BY rok, re�yser
) AS Liczba_i_Max
WHERE [Liczba Film�w/Re�yser] = [Max. Liczba Film�w/Re�yser]
ORDER BY rok


--Najcz�stszy/si re�yser/rzy og�lnie
SELECT TOP (1) re�yser, COUNT(*) AS 'Liczba'
FROM dbo.Netflix_Re�yser
WHERE typ = 'Movie'
GROUP BY re�yser
ORDER BY Liczba DESC

----------PROGRAMY TELEWIZYJNE----------

--Liczba program�w telewizyjnych rok po roku
SELECT rok, COUNT(*) AS 'Liczba Program�w Telewizyjnych' 
FROM dbo.Netflix_G��wny
WHERE typ = 'TV Show'
GROUP BY rok
ORDER BY rok


--Najcz�stszy/e kraj/e produkcji rok po roku
SELECT rok, kraj, [Liczba Program�w Telewizyjnych/Kraj]
FROM
(
	SELECT rok, kraj, COUNT(*) AS 'Liczba Program�w Telewizyjnych/Kraj',
	MAX(COUNT(*)) OVER (PARTITION BY rok) AS 'Max. Liczba Program�w Telewizyjnych/Rok'
	FROM dbo.Netflix_Kraj
	WHERE typ = 'TV Show'
	GROUP BY rok, kraj
) AS Liczba_i_Max
WHERE [Liczba Program�w Telewizyjnych/Kraj] = [Max. Liczba Program�w Telewizyjnych/Rok]
ORDER BY rok


--Najcz�stszy/e kraj/e produkcji og�lnie
SELECT TOP (1) kraj, COUNT(*) AS 'Liczba'
FROM dbo.Netflix_Kraj
WHERE typ = 'TV Show'
GROUP BY kraj
ORDER BY Liczba DESC


--Najcz�stsza/e kategoria/e rok po roku
SELECT rok, wymieniony_w, [Liczba Program�w Telewizyjnych/Kategoria]
FROM
(
	SELECT rok, wymieniony_w, COUNT(*) AS 'Liczba Program�w Telewizyjnych/Kategoria',
	MAX(COUNT(*)) OVER (PARTITION BY rok) AS 'Max. Liczba Program�w Telewizyjnych/Rok'
	FROM dbo.Netflix_Kategoria
	WHERE typ = 'TV Show'
	GROUP BY rok, wymieniony_w
) AS Liczba_i_Max
WHERE [Liczba Program�w Telewizyjnych/Kategoria] = [Max. Liczba Program�w Telewizyjnych/Rok]
ORDER BY rok


--Najcz�stsza/e kategoria/e og�lnie
SELECT TOP (1) wymieniony_w, COUNT(*) AS 'Liczba'
FROM dbo.Netflix_Kategoria
WHERE typ = 'TV Show'
GROUP BY wymieniony_w
ORDER BY Liczba DESC


--Najcz�stszy/si Re�yser/rzy rok po roku
SELECT rok, re�yser, [Liczba Program�w Telewizyjnych/Re�yser]
FROM
(
	SELECT rok, re�yser, COUNT(*) AS 'Liczba Program�w Telewizyjnych/Re�yser',
	MAX(COUNT(*)) OVER (PARTITION BY rok) AS 'Max. Liczba Program�w Telewizyjnych/Rok'
	FROM dbo.Netflix_Re�yser
	WHERE typ = 'TV Show'
	GROUP BY rok, re�yser
) AS Liczba_i_Max
WHERE [Liczba Program�w Telewizyjnych/Re�yser] = [Max. Liczba Program�w Telewizyjnych/Rok]
ORDER BY rok


--Najcz�stszy/si Re�yser/rzy og�lnie
SELECT TOP (2) re�yser, COUNT(*) AS 'Liczba'
FROM dbo.Netflix_Re�yser
WHERE typ = 'TV Show'
GROUP BY re�yser
ORDER BY Liczba DESC