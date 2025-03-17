-- Vedlegg 1:

-- Flyplasser
INSERT INTO Flyplass (FlyplassKode, Navn, Sted) VALUES ('BOO', 'Bodø Lufthavn', 'Bodø');
INSERT INTO Flyplass (FlyplassKode, Navn, Sted) VALUES ('BGO', 'Bergen lufthavn', 'Flesland');
INSERT INTO Flyplass (FlyplassKode, Navn, Sted) VALUES ('OSL', 'Oslo lufthavn', 'Gardermoen');
INSERT INTO Flyplass (FlyplassKode, Navn, Sted) VALUES ('SVG', 'Stavanger lufthavn', 'Sola');
INSERT INTO Flyplass (FlyplassKode, Navn, Sted) VALUES ('TRD', 'Trondheim lufthavn', 'Værnes');

-- Vedlegg 2: 

-- Flyselskap
INSERT INTO Flyselskap (FlyselskapsKode, Navn) VALUES ('DY', 'Norwegian');
INSERT INTO Flyselskap (FlyselskapsKode, Navn) VALUES ('SK', 'SAS');
INSERT INTO Flyselskap (FlyselskapsKode, Navn) VALUES ('WF', 'Widerøe');

-- Flyprodusenter
INSERT INTO Flyprodusent (Navn, StiftelsesÅr) VALUES ('The Boeing Company', 1916);
INSERT INTO Flyprodusent (Navn, StiftelsesÅr) VALUES ('Airbus Group', 1970);
INSERT INTO Flyprodusent (Navn, StiftelsesÅr) VALUES ('De Havilland Canada', 1928);

-- Nasjonaliteter
INSERT INTO Nasjonalitet (Produsent, Land) VALUES ('The Boeing Company', 'USA');
INSERT INTO Nasjonalitet (Produsent, Land) VALUES ('Airbus Group', 'Frankrike');
INSERT INTO Nasjonalitet (Produsent, Land) VALUES ('Airbus Group', 'Tyskland');
INSERT INTO Nasjonalitet (Produsent, Land) VALUES ('Airbus Group', 'Spania');
INSERT INTO Nasjonalitet (Produsent, Land) VALUES ('Airbus Group', 'Storbritannia');
INSERT INTO Nasjonalitet (Produsent, Land) VALUES ('De Havilland Canada', 'Canada');

-- Flytyper
INSERT INTO Flytype (Navn, Produsent, FørsteProduksjonsÅr, SisteProduksjonsÅr) VALUES ('Boeing 737 800', 'The Boeing Company', 1997, 2020);
INSERT INTO Flytype (Navn, Produsent, FørsteProduksjonsÅr) VALUES ('Airbus a320neo', 'Airbus Group', 2016);
INSERT INTO Flytype (Navn, Produsent, FørsteProduksjonsÅr, SisteProduksjonsÅr) VALUES ('Dash-8 100', 'De Havilland Canada', 1984, 2005);

-- Norwegian flyr med Boeing 737 800
INSERT INTO Fly (Produsent, SerieNr, RegNr, SattIDrift, AvType, Eier)
VALUES ('The Boeing Company', '42069', 'LN-ENU', 2015, 'Boeing 737 800', 'DY');
INSERT INTO Fly (Produsent, SerieNr, RegNr, SattIDrift, Navn, AvType, Eier)
VALUES ('The Boeing Company', '42093', 'LN-ENR', 2018, 'Jan Bålsrud', 'Boeing 737 800', 'DY');
INSERT INTO Fly (Produsent, SerieNr, RegNr, SattIDrift, Navn, AvType, Eier)
VALUES ('The Boeing Company', '39403', 'LN-NIQ', 2011, 'Max Manus', 'Boeing 737 800', 'DY');
INSERT INTO Fly (Produsent, SerieNr, RegNr, SattIDrift, AvType, Eier)
VALUES ('The Boeing Company', '42281', 'LN-ENS', 2017, 'Boeing 737 800', 'DY');

-- SAS flyr med Airbus a320neo
INSERT INTO Fly (Produsent, SerieNr, RegNr, SattIDrift, Navn, AvType, Eier)
VALUES ('Airbus Group', '9518', 'SE-RUB', 2020, 'Birger Viking', 'Airbus a320neo', 'SK');
INSERT INTO Fly (Produsent, SerieNr, RegNr, SattIDrift, Navn, AvType, Eier)
VALUES ('Airbus Group', '11421', 'SE-DIR', 2023, 'Nora Viking', 'Airbus a320neo', 'SK');
INSERT INTO Fly (Produsent, SerieNr, RegNr, SattIDrift, Navn, AvType, Eier)
VALUES ('Airbus Group', '12066', 'SE-RUP', 2024, 'Ragnhild Viking', 'Airbus a320neo', 'SK');
INSERT INTO Fly (Produsent, SerieNr, RegNr, SattIDrift, Navn, AvType, Eier)
VALUES ('Airbus Group', '12166', 'SE-RZE', 2024, 'Ebbe Viking', 'Airbus a320neo', 'SK');

-- Widerøe flyr med Dash-8 100
INSERT INTO Fly (Produsent, SerieNr, RegNr, SattIDrift, Navn, AvType, Eier)
VALUES ('De Havilland Canada', '383', 'LN-WIH', 1994, 'Oslo', 'Dash-8 100', 'WF');
INSERT INTO Fly (Produsent, SerieNr, RegNr, SattIDrift, Navn, AvType, Eier)
VALUES ('De Havilland Canada', '359', 'LN-WIA', 1993, 'Nordland', 'Dash-8 100', 'WF');
INSERT INTO Fly (Produsent, SerieNr, RegNr, SattIDrift, Navn, AvType, Eier)
VALUES ('De Havilland Canada', '298', 'LN-WIL', 1995, 'Narvik', 'Dash-8 100', 'WF');

-- Seter

-- Boeing 737 800:
-- 31 rader med 6 seter per rad (A, B, C på den ene siden og D, E, F på den andre).
-- Rad 13 er nødutgang.
WITH RECURSIVE b737_rows(rownum) AS (
    SELECT 1
    UNION ALL
    SELECT rownum + 1 FROM b737_rows WHERE rownum < 31
)
INSERT INTO Sete (SeteID, Type, Nødutgang, HøyreForMidtgang)
SELECT CAST(rownum AS TEXT) || seat,
       'Boeing 737 800',
       CASE WHEN rownum = 13 THEN 1 ELSE 0 END,
       CASE WHEN seat IN ('D','E','F') THEN 1 ELSE 0 END
FROM b737_rows,
     (SELECT 'A' AS seat UNION SELECT 'B' UNION SELECT 'C' UNION SELECT 'D' UNION SELECT 'E' UNION SELECT 'F');

-- Airbus a320neo:
-- 30 rader med 6 seter per rad (A, B, C på den ene siden og D, E, F på den andre).
-- Rad 11 og 12 er nødutganger.
WITH RECURSIVE a320_rows(rownum) AS (
    SELECT 1
    UNION ALL
    SELECT rownum + 1 FROM a320_rows WHERE rownum < 30
)
INSERT INTO Sete (SeteID, Type, Nødutgang, HøyreForMidtgang)
SELECT CAST(rownum AS TEXT) || seat,
       'Airbus a320neo',
       CASE WHEN rownum IN (11,12) THEN 1 ELSE 0 END,
       CASE WHEN seat IN ('D','E','F') THEN 1 ELSE 0 END
FROM a320_rows,
     (SELECT 'A' AS seat UNION SELECT 'B' UNION SELECT 'C' UNION SELECT 'D' UNION SELECT 'E' UNION SELECT 'F');

-- Dash-8 100:
-- Totalt 10 rader.

-- Rad 1 har kun 2 seter (C og D).
INSERT INTO Sete (SeteID, Type, Nødutgang, HøyreForMidtgang)
VALUES ('1C', 'Dash-8 100', 0, 1),
       ('1D', 'Dash-8 100', 0, 1);

-- Rad 2-10 har 4 seter per rad (A, B, C og D). Rad 5 er nødutgang.
WITH RECURSIVE d8_rows(rownum) AS (
    SELECT 2
    UNION ALL
    SELECT rownum + 1 FROM d8_rows WHERE rownum < 10
)
INSERT INTO Sete (SeteID, Type, Nødutgang, HøyreForMidtgang)
SELECT CAST(rownum AS TEXT) || seat,
       'Dash-8 100',
       CASE WHEN rownum = 5 THEN 1 ELSE 0 END,
       CASE WHEN seat IN ('C','D') THEN 1 ELSE 0 END
FROM d8_rows,
     (SELECT 'A' AS seat UNION SELECT 'B' UNION SELECT 'C' UNION SELECT 'D');


-- Vedlegg 3:

-- Flyruter

-- SK888: TRD-BGO-SVG
INSERT INTO Flyrute (FlyruteNr, UkedagsKode, FlysAv, FlysMed)
VALUES (888, '12345', 'SK', 'Airbus a320neo');

-- Rutesegmenter
INSERT INTO Rutesegment (FlyruteNr, SekvensNr, PlanlagtAvgangsTid, PlanlagtAnkomstTid, AvgangFra, AnkomstTil)
VALUES (888, 1, '10:00', '11:10', 'TRD', 'BGO');
INSERT INTO Rutesegment (FlyruteNr, SekvensNr, PlanlagtAvgangsTid, PlanlagtAnkomstTid, AvgangFra, AnkomstTil)
VALUES (888, 2, '11:40', '12:10', 'BGO', 'SVG');

-- Rutekomboer

-- Kombo 1: TRD-BGO (bare segment 1)
INSERT INTO Rutekombo (FlyruteNr, KomboNr, NåværendeØkonomiPris, NåværendeBudsjettPris, NåværendePremiumPris)
VALUES (888, 1, 1500, 800, 2000);
INSERT INTO SegmentIKombo (FlyruteNr, KomboNr, SekvensNr)
VALUES (888, 1, 1);

-- Kombo 2: BGO-SVG (bare segment 2)
INSERT INTO Rutekombo (FlyruteNr, KomboNr, NåværendeØkonomiPris, NåværendeBudsjettPris, NåværendePremiumPris)
VALUES (888, 2, 700, 350, 1000);
INSERT INTO SegmentIKombo (FlyruteNr, KomboNr, SekvensNr)
VALUES (888, 2, 2);

-- Kombo 3: TRD-SVG (segment 1+2 kombinert)
INSERT INTO Rutekombo (FlyruteNr, KomboNr, NåværendeØkonomiPris, NåværendeBudsjettPris, NåværendePremiumPris)
VALUES (888, 3, 1700, 1000, 2200);
INSERT INTO SegmentIKombo (FlyruteNr, KomboNr, SekvensNr)
VALUES (888, 3, 1);
INSERT INTO SegmentIKombo (FlyruteNr, KomboNr, SekvensNr)
VALUES (888, 3, 2);

-- WF1311: TRD-BOO
INSERT INTO Flyrute (FlyruteNr, UkedagsKode, FlysAv, FlysMed)
VALUES (1311, '12345', 'WF', 'Dash-8 100');

-- Rutesegment
INSERT INTO Rutesegment (FlyruteNr, SekvensNr, PlanlagtAvgangsTid, PlanlagtAnkomstTid, AvgangFra, AnkomstTil)
VALUES (1311, 1, '15:15', '16:20', 'TRD', 'BOO');

-- Rutekombo
INSERT INTO Rutekombo (FlyruteNr, KomboNr, NåværendeØkonomiPris, NåværendeBudsjettPris, NåværendePremiumPris)
VALUES (1311, 1, 899, 599, 2018);
INSERT INTO SegmentIKombo (FlyruteNr, KomboNr, SekvensNr)
VALUES (1311, 1, 1);

-- WF1302: BOO-TRD
INSERT INTO Flyrute (FlyruteNr, UkedagsKode, FlysAv, FlysMed)
VALUES (1302, '12345', 'WF', 'Dash-8 100');

-- Rutesegment
INSERT INTO Rutesegment (FlyruteNr, SekvensNr, PlanlagtAvgangsTid, PlanlagtAnkomstTid, AvgangFra, AnkomstTil)
VALUES (1302, 1, '07:35', '08:40', 'BOO', 'TRD');

-- Rutekombo: 
INSERT INTO Rutekombo (FlyruteNr, KomboNr, NåværendeØkonomiPris, NåværendeBudsjettPris, NåværendePremiumPris)
VALUES (1302, 1, 899, 599, 2018);
INSERT INTO SegmentIKombo (FlyruteNr, KomboNr, SekvensNr)
VALUES (1302, 1, 1);

-- DY753: TRD-OSL
INSERT INTO Flyrute (FlyruteNr, UkedagsKode, FlysAv, FlysMed)
VALUES (753, '1234567', 'DY', 'Boeing 737 800');

-- Rutesegment
INSERT INTO Rutesegment (FlyruteNr, SekvensNr, PlanlagtAvgangsTid, PlanlagtAnkomstTid, AvgangFra, AnkomstTil)
VALUES (753, 1, '10:20', '11:15', 'TRD', 'OSL');

-- Rutekombo
INSERT INTO Rutekombo (FlyruteNr, KomboNr, NåværendeØkonomiPris, NåværendeBudsjettPris, NåværendePremiumPris)
VALUES (753, 1, 1000, 500, 1500);
INSERT INTO SegmentIKombo (FlyruteNr, KomboNr, SekvensNr)
VALUES (753, 1, 1);

-- Brukstilfelle 4: Flyvninger

-- WF1302 (BOO-TRD) med fly av riktig type og eier
INSERT INTO Flyvning (FlyruteNr, LøpeNr, Dato, Status, Produsent, SerieNr)
SELECT 1302, 1, '2025-04-01', 'planned', Produsent, SerieNr
FROM Fly f
JOIN Flyrute fr ON fr.FlyruteNr = 1302
WHERE f.AvType = fr.FlysMed
AND f.Eier = fr.FlysAv    
LIMIT 1;

-- DY753 (TRD-OSL) med fly av riktig type og eier
INSERT INTO Flyvning (FlyruteNr, LøpeNr, Dato, Status, Produsent, SerieNr)
SELECT 753, 1, '2025-04-01', 'planned', Produsent, SerieNr
FROM Fly f
JOIN Flyrute fr ON fr.FlyruteNr = 753
WHERE f.AvType = fr.FlysMed
AND f.Eier = fr.FlysAv    
LIMIT 1;

-- SK888 (TRD-BGO-SVG) med fly av riktig type og eier
INSERT INTO Flyvning (FlyruteNr, LøpeNr, Dato, Status, Produsent, SerieNr)
SELECT 888, 1, '2025-04-01', 'planned', Produsent, SerieNr
FROM Fly f
JOIN Flyrute fr ON fr.FlyruteNr = 888
WHERE f.AvType = fr.FlysMed
AND f.Eier = fr.FlysAv    
LIMIT 1;

-- Brukstilfelle 7: Bestilling

-- Kunde
INSERT INTO Kunde (KundeNr, Navn, TelefonNr, Epost, Nasjonalitet)
VALUES (1, 'Ola Nordmann', '12345678', 'ola.nordmann@example.com', 'NO');

-- 10 billetkjøp (bestillinger)
INSERT INTO Billettkjøp (ReferanseNr, KundeNr)
VALUES 
(1, 1),
(2, 1),
(3, 1),
(4, 1),
(5, 1),
(6, 1),
(7, 1),
(8, 1),
(9, 1),
(10, 1);

-- 10 billetter for WF1302 (BOO-TRD) med reserverte seter registrert på samme kunde
INSERT INTO Billett (ReferanseNr, BillettNr, InnsjekkingsTid, FlyruteNr, LøpeNr, KomboNr, Type, Sete, Kategori, Pris)
VALUES 
(1, 1, '2025-04-01', 1302, 1, 1, 'Dash-8 100', '7D', 'økonomi', 899),
(2, 1, '2025-04-01',1302, 1, 1, 'Dash-8 100', '8D', 'økonomi', 899),
(3, 1, '2025-04-01',1302, 1, 1, 'Dash-8 100', '1C', 'økonomi', 899),
(4, 1, '2025-04-01',1302, 1, 1, 'Dash-8 100', '2A', 'økonomi', 899),
(5, 1, '2025-04-01',1302, 1, 1, 'Dash-8 100', '2B', 'økonomi', 899),
(6, 1, '2025-04-01',1302, 1, 1, 'Dash-8 100', '2C', 'økonomi', 899),
(7, 1, '2025-04-01',1302, 1, 1, 'Dash-8 100', '3A', 'økonomi', 899),
(8, 1, '2025-04-01',1302, 1, 1, 'Dash-8 100', '3B', 'økonomi', 899),
(9, 1, '2025-04-01',1302, 1, 1, 'Dash-8 100', '3C', 'økonomi', 899),
(10, 1, '2025-04-01',1302, 1, 1, 'Dash-8 100', '4A', 'økonomi', 899);
