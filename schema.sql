PRAGMA foreign_keys = ON;

-- CREATE TABLES --

-- Bagasje
CREATE TABLE Bagasje (
    RegNr          TEXT NOT NULL,
    Vekt              NUMERIC NOT NULL,
    InnleveringsTid   TEXT NOT NULL,
    ReferanseNr       INTEGER NOT NULL,
    BillettNr         INTEGER NOT NULL,
    PRIMARY KEY(RegNr),
    FOREIGN KEY(ReferanseNr) REFERENCES Billettkjøp(ReferanseNr) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Billett
CREATE TABLE Billett (
    ReferanseNr	    INTEGER NOT NULL,
    BillettNr	        INTEGER NOT NULL,
    InnsjekkingsTid   TEXT,
    FlyruteNr	        INTEGER NOT NULL,
    LøpeNr	        INTEGER NOT NULL,
    KomboNr	        INTEGER NOT NULL,
    Type            TEXT NOT NULL,
    Sete		        TEXT,
    Kategori	        TEXT NOT NULL CHECK(Kategori IN ('økonomi', 'premium', 'budsjett')),
    Pris		        NUMERIC NOT NULL,
    PRIMARY KEY(ReferanseNr, BillettNr),
    FOREIGN KEY(FlyruteNr, KomboNr) REFERENCES Rutekombo(FlyruteNr, KomboNr) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY(FlyruteNr, LøpeNr) REFERENCES Flyvning(FlyruteNr, LøpeNr) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY(Type, Sete) REFERENCES Sete(Type, SeteID) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Billettkjøp
CREATE TABLE Billettkjøp (
    ReferanseNr  INTEGER NOT NULL,
    KundeNr      INTEGER NOT NULL,
    PRIMARY KEY (ReferanseNr),
    FOREIGN KEY (KundeNr) REFERENCES Kunde(KundeNr) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Delflyvning
CREATE TABLE Delflyvning (
    FlyruteNr	        INTEGER NOT NULL,
    LøpeNr	        INTEGER NOT NULL,
    SekvensNr	        INTEGER NOT NULL,
    FaktiskAvgangsTid	TEXT NOT NULL,
    FaktiskAnkomstTid	TEXT NOT NULL,
    PRIMARY KEY(FlyruteNr, LøpeNr, SekvensNr),
    FOREIGN KEY(FlyruteNr, LøpeNr) REFERENCES Flyvning(FlyruteNr, LøpeNr) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY(FlyruteNr, SekvensNr) REFERENCES Rutesegment(FlyruteNr, SekvensNr) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Fly
CREATE TABLE Fly (
    Produsent	    TEXT NOT NULL,
    SerieNr	    INTEGER NOT NULL,
    RegNr		    TEXT NOT NULL UNIQUE,
    SattIDrift	    INTEGER NOT NULL,
    Navn		    TEXT,
    AvType	    TEXT NOT NULL,
    Eier		    TEXT,
    PRIMARY KEY(Produsent, SerieNr),
    FOREIGN KEY(Eier) REFERENCES Flyselskap(FlyselskapsKode) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY(Produsent) REFERENCES Flyprodusent(Navn) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Flyplass
CREATE TABLE Flyplass (
    FlyplassKode	    TEXT NOT NULL,
    Navn		        TEXT NOT NULL UNIQUE,
    Sted              TEXT NOT NULL,
    PRIMARY KEY(FlyplassKode)
);

-- Flyprodusent
CREATE TABLE Flyprodusent (
    Navn		    TEXT NOT NULL,
    StiftelsesÅr	INTEGER NOT NULL,
    PRIMARY KEY(Navn)
);

-- Flyrute
CREATE TABLE Flyrute (
    FlyruteNr	    INTEGER NOT NULL,
    UkedagsKode	    TEXT NOT NULL,
    OppstartDato	    TEXT,
    SluttDato	    TEXT,
    FlysAv	    TEXT NOT NULL,
    FlysMed	    TEXT NOT NULL,
    PRIMARY KEY(FlyruteNr),
    FOREIGN KEY(FlysAv) REFERENCES Flyselskap(FlyselskapsKode) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY(FlysMed) REFERENCES Flytype(Navn) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Flyselskap
CREATE TABLE Flyselskap (
    FlyselskapsKode	    TEXT NOT NULL,
    Navn		            TEXT NOT NULL,
    PRIMARY KEY(FlyselskapsKode)
);

-- Flytype
CREATE TABLE Flytype (
    Navn       TEXT NOT NULL,
    FørsteProduksjonsÅr TEXT NOT NULL,
    SisteProduksjonsÅr TEXT,
    Produsent  TEXT NOT NULL,  
    PRIMARY KEY (Navn),
    FOREIGN KEY (Produsent) REFERENCES Flyprodusent(Navn) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Flyvning
CREATE TABLE Flyvning (
    FlyruteNr	    INTEGER NOT NULL,
    LøpeNr	    INTEGER NOT NULL,
    Dato		    TEXT NOT NULL,
    Status	    TEXT NOT NULL CHECK(Status IN ('planned', 'active', 'completed', 'cancelled')),
    Produsent	    TEXT NOT NULL,
    SerieNr	    INTEGER NOT NULL,
    UNIQUE(FlyruteNr, Dato),
    PRIMARY KEY(FlyruteNr, LøpeNr),
    FOREIGN KEY(Produsent, SerieNr) REFERENCES Fly(Produsent, SerieNr) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY(FlyruteNr) REFERENCES Flyrute(FlyruteNr) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Fordelsprogram
CREATE TABLE Fordelsprogram (
    KundeNr		        INTEGER NOT NULL,
    FlyselskapsKode	    TEXT NOT NULL,
    FordelsprogramRef	    TEXT NOT NULL,
    PRIMARY KEY(KundeNr, FlyselskapsKode),
    FOREIGN KEY(FlyselskapsKode) REFERENCES Flyselskap(FlyselskapsKode) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY(KundeNr) REFERENCES Kunde(KundeNr) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Kunde
CREATE TABLE Kunde (
    KundeNr		INTEGER NOT NULL,
    Navn		    TEXT NOT NULL,
    TelefonNr		TEXT NOT NULL,
    Epost		    TEXT NOT NULL,
    Nasjonalitet	TEXT NOT NULL,
    PRIMARY KEY(KundeNr)
);

-- Nasjonalitet
CREATE TABLE Nasjonalitet (
    Produsent	    TEXT NOT NULL,
    Land		    TEXT NOT NULL,
    PRIMARY KEY(Produsent, Land),
    FOREIGN KEY(Produsent) REFERENCES Flyprodusent(Navn) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Rutekombo
CREATE TABLE Rutekombo (
    FlyruteNr	            INTEGER NOT NULL,
    KomboNr	            INTEGER NOT NULL,
    NåværendeØkonomiPris	    NUMERIC NOT NULL,
    NåværendeBudsjettPris	    NUMERIC NOT NULL,
    NåværendePremiumPris	    NUMERIC NOT NULL,
    PRIMARY KEY(FlyruteNr, KomboNr),
    FOREIGN KEY(FlyruteNr) REFERENCES Flyrute(FlyruteNr) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Rutesegment
CREATE TABLE Rutesegment (
    FlyruteNr		    INTEGER NOT NULL,
    SekvensNr		    INTEGER NOT NULL,
    PlanlagtAvgangsTid	TEXT NOT NULL,
    PlanlagtAnkomstTid	TEXT NOT NULL,
    AvgangFra		    TEXT NOT NULL,
    AnkomstTil		    TEXT NOT NULL,
    PRIMARY KEY(FlyruteNr, SekvensNr),
    FOREIGN KEY(AnkomstTil) REFERENCES Flyplass(FlyplassKode) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY(AvgangFra) REFERENCES Flyplass(FlyplassKode) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY(FlyruteNr) REFERENCES Flyrute(FlyruteNr) ON DELETE CASCADE ON UPDATE CASCADE
);

-- SegmentIKombo
CREATE TABLE SegmentIKombo (
    FlyruteNr INTEGER NOT NULL,
    KomboNr   INTEGER NOT NULL,
    SekvensNr INTEGER NOT NULL,
    PRIMARY KEY (FlyruteNr, KomboNr, SekvensNr),
    FOREIGN KEY (FlyruteNr, KomboNr) REFERENCES Rutekombo(FlyruteNr, KomboNr) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (FlyruteNr, SekvensNr) REFERENCES Rutesegment(FlyruteNr, SekvensNr) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Sete
CREATE TABLE Sete (
    SeteID	TEXT NOT NULL,
    Type TEXT NOT NULL,
    Nødutgang	BOOLEAN NOT NULL,
    HøyreForMidtgang	BOOLEAN NOT NULL,
    PRIMARY KEY(Type, SeteID)
    FOREIGN KEY(Type) REFERENCES Flytype(Navn) ON DELETE CASCADE ON UPDATE CASCADE
);


-- CREATE TRIGGERS --

-- Generer delflyvning for hvert rutesegment til en flyvning med faktiske tider initielt satt lik planlagte tider
CREATE TRIGGER GenererDelflyvninger
AFTER INSERT ON Flyvning
FOR EACH ROW
BEGIN
    INSERT INTO Delflyvning (FlyruteNr, LøpeNr, SekvensNr, FaktiskAvgangsTid, FaktiskAnkomstTid)
    SELECT 
        rs.FlyruteNr, 
        NEW.LøpeNr, 
        rs.SekvensNr, 
        rs.PlanlagtAvgangsTid, 
        rs.PlanlagtAnkomstTid
    FROM Rutesegment AS rs
    WHERE rs.FlyruteNr = NEW.FlyruteNr;
END;

-- Sjekk at flyvning er planned for ny billett 
CREATE TRIGGER SjekkFlyPlanned
BEFORE INSERT ON Billett
FOR EACH ROW
BEGIN
    SELECT RAISE(ABORT, 'Flyvning må være i planned status')
    WHERE NOT EXISTS (
        SELECT 1
        FROM Flyvning
        WHERE Flyvning.FlyruteNr = NEW.FlyruteNr
          AND Flyvning.LøpeNr = NEW.LøpeNr
          AND Flyvning.Status = 'planned'
    );
END;

-- Sjekk at dato for flyvning samsvarer med Flyrute sin UkedagsKode
CREATE TRIGGER SjekkFlyruteDag
BEFORE INSERT ON Flyvning
FOR EACH ROW
BEGIN
    SELECT RAISE(ABORT, 'Datoen samsvarer ikke med Flyrute sin UkedagsKode')
    WHERE NOT EXISTS (
        SELECT 1
        FROM Flyrute
        WHERE Flyrute.FlyruteNr = NEW.FlyruteNr
          AND instr(
                Flyrute.UkedagsKode,
                CASE strftime('%w', NEW.Dato)
                     WHEN '0' THEN '7'
                     ELSE strftime('%w', NEW.Dato)
                END
              ) > 0
    );
END;

-- Sjekk at Flyrute flys av et fly som selskapet som flyr den eier
CREATE TRIGGER SjekkEierFlytype
BEFORE INSERT ON Flyrute
FOR EACH ROW
BEGIN
    SELECT RAISE(ABORT, 'Flyselskap eier ikke fly av den typen')
    WHERE NOT EXISTS (
        SELECT 1
        FROM Fly
        WHERE Fly.Eier = NEW.flysAv
          AND Fly.AvType = NEW.flysMed
    );
END;

-- Sjekk at pris og kategori matcher pris satt i Rutekombo
CREATE TRIGGER SjekkKategoriPris
BEFORE INSERT ON Billett
FOR EACH ROW
BEGIN
    SELECT RAISE(ABORT, 'Pris matcher ikke kategori for denne delreisen')
    WHERE NOT EXISTS (
        SELECT 1
        FROM Rutekombo
        WHERE Rutekombo.FlyruteNr = NEW.FlyruteNr
          AND Rutekombo.KomboNr = NEW.KomboNr
          AND (
              (NEW.Kategori = 'budsjett' AND NEW.Pris = NåværendeBudsjettPris)
           OR (NEW.Kategori = 'økonomi' AND NEW.Pris = NåværendeØkonomiPris)
           OR (NEW.Kategori = 'premium' AND NEW.Pris = NåværendePremiumPris)
          )
    );
END;

-- Sjekk at Sete for Billett ikke er opptatt
CREATE TRIGGER SjekkOpptattSete
BEFORE INSERT ON Billett
FOR EACH ROW
BEGIN
    SELECT RAISE(ABORT, 'Setet er allerede opptatt for flyvningen')
    WHERE EXISTS (
        SELECT 1
        FROM Billett AS b
        JOIN SegmentIKombo AS s_existing
          ON s_existing.FlyruteNr = b.FlyruteNr
         AND s_existing.KomboNr = b.KomboNr
        JOIN SegmentIKombo AS s_new
          ON s_new.FlyruteNr = NEW.FlyruteNr
         AND s_new.KomboNr = NEW.KomboNr
         AND s_new.SekvensNr = s_existing.SekvensNr
        WHERE b.FlyruteNr = NEW.FlyruteNr
          AND b.LøpeNr = NEW.LøpeNr
          AND b.Type = NEW.Type
          AND b.Sete = NEW.Sete
    );
END;

-- Tilsvarende sjekk for opptatt sete ved innsjekking i etterkant
CREATE TRIGGER SjekkOpptattSete_UPD
BEFORE UPDATE ON Billett
FOR EACH ROW
BEGIN
    SELECT RAISE(ABORT, 'Setet er allerede opptatt for flyvningen')
    WHERE EXISTS (
        SELECT 1
        FROM Billett AS b
        JOIN SegmentIKombo AS s_existing
          ON s_existing.FlyruteNr = b.FlyruteNr
         AND s_existing.KomboNr = b.KomboNr
        JOIN SegmentIKombo AS s_new
          ON s_new.FlyruteNr = NEW.FlyruteNr
         AND s_new.KomboNr = NEW.KomboNr
         AND s_new.SekvensNr = s_existing.SekvensNr
        WHERE b.FlyruteNr = NEW.FlyruteNr
          AND b.LøpeNr = NEW.LøpeNr
          AND b.Type = NEW.Type
          AND b.Sete = NEW.Sete
          AND b.ReferanseNr <> NEW.ReferanseNr 
    );
END;

-- Sjekk at flyvning flys av riktig flytype
CREATE TRIGGER SjekkFlytypeForFlyvning
BEFORE INSERT ON Flyvning
FOR EACH ROW
BEGIN
    SELECT RAISE(ABORT, 'Flyet har feil flytype for denne flyruten')
    WHERE NOT EXISTS (
        SELECT 1
        FROM Fly AS f
        JOIN Flyrute AS fr ON fr.FlyruteNr = NEW.FlyruteNr
        WHERE f.Produsent = NEW.Produsent
		  AND f.SerieNr = NEW.SerieNr
          AND f.AvType = fr.FlysMed
    );
END;

-- Sjekk at fly er satt i drift før flyvningens dato
CREATE TRIGGER SjekkFlySattIDriftFørFlyvning
BEFORE INSERT ON Flyvning
FOR EACH ROW
BEGIN
    SELECT RAISE(ABORT, 'Flyet kan ikke brukes før det er satt i drift')
    WHERE EXISTS (
        SELECT 1 
        FROM Fly 
        WHERE Fly.Produsent = NEW.Produsent
        AND Fly.SerieNr = NEW.SerieNr
        AND NEW.Dato < DATE(Fly.SattIDrift) 
    );
END;

-- Sjekk at flyvningens dato er innenfor flyrutens gydlighetsperiode
CREATE TRIGGER SjekkFlyvningDatoInnenforFlyrute
BEFORE INSERT ON Flyvning
FOR EACH ROW
BEGIN
    SELECT RAISE(ABORT, 'Flyvningens dato er utenfor flyrutens gyldighetsperiode')
    WHERE NOT EXISTS (
        SELECT 1 FROM Flyrute
        WHERE FlyruteNr = NEW.FlyruteNr
          AND (OppstartDato IS NULL OR DATE(NEW.Dato) >= DATE(OppstartDato)) 
          AND (SluttDato IS NULL OR DATE(NEW.Dato) <= DATE(SluttDato))
    );
END;

-- SJekk at flyrutens gyldighetsperiode ligger innfor produksjonsårene til flytypen
CREATE TRIGGER SjekkFlyruteDatoInnenforProduksjonsår
BEFORE INSERT ON Flyrute
FOR EACH ROW
BEGIN
    SELECT RAISE(ABORT, 'Flyrutens datoer matcher ikke produksjonsårene for flytypen')
    WHERE EXISTS (
        SELECT 1 FROM Flytype
        WHERE Navn = NEW.FlysMed
          AND (
                (NEW.OppstartDato IS NOT NULL AND strftime('%Y', NEW.OppstartDato) < FørsteProduksjonsÅr)
             OR (NEW.SluttDato IS NOT NULL AND SisteProduksjonsÅr IS NOT NULL 
                 AND strftime('%Y', NEW.SluttDato) > SisteProduksjonsÅr)
          )
    );
END;

-- Sjekk at fly er satt i drift etter flytypens første produksjonsår
CREATE TRIGGER SjekkFlySattIDriftEtterProduksjonsstart
BEFORE INSERT ON Fly
FOR EACH ROW
BEGIN
    SELECT RAISE(ABORT, 'Fly satt i drift før flytypens produksjonsstart')
    WHERE EXISTS (
        SELECT 1 FROM Flytype
        WHERE Navn = NEW.AvType
          AND NEW.SattIDrift < FørsteProduksjonsÅr
    );
END;

-- Sjekk at oppstartdato er før sluttdato for flyrute
CREATE TRIGGER SjekkFlyruteDatoer
BEFORE INSERT ON Flyrute
FOR EACH ROW
BEGIN
    SELECT RAISE(ABORT, 'OppstartDato må være før SluttDato')
    WHERE NEW.OppstartDato IS NOT NULL
      AND NEW.SluttDato IS NOT NULL
      AND DATE(NEW.OppstartDato) > DATE(NEW.SluttDato);
END;

-- Sjekk at første produksjonsår er før siste produksjonsår  
CREATE TRIGGER SjekkFlytypeProduksjonsår
BEFORE INSERT ON Flytype
FOR EACH ROW
BEGIN
    SELECT RAISE(ABORT, 'FørsteProduksjonsÅr må være før SisteProduksjonsÅr')
    WHERE NEW.SisteProduksjonsÅr IS NOT NULL 
      AND NEW.FørsteProduksjonsÅr > NEW.SisteProduksjonsÅr;
END;

-- Sjekk at bagasje ikke blir innlevert etter flyvningens dato 
CREATE TRIGGER SjekkBagasjeInnleveringsTid
BEFORE INSERT ON Bagasje
FOR EACH ROW
BEGIN
    SELECT RAISE(ABORT, 'Bagasje kan ikke leveres etter flyvningens dato')
    WHERE EXISTS (
        SELECT 1
        FROM Billett b
        JOIN Flyvning f ON b.FlyruteNr = f.FlyruteNr AND b.LøpeNr = f.LøpeNr
        WHERE b.ReferanseNr = NEW.ReferanseNr
          AND DATE(NEW.InnleveringsTid) > DATE(f.Dato)
    );
END;

-- Sjekk at billett ikke blir insjekket etter flyvningens dato 
CREATE TRIGGER SjekkInnsjekkingsTid
BEFORE INSERT ON Billett
FOR EACH ROW
BEGIN
    SELECT RAISE(ABORT, 'InnsjekkingsTid må være før flyvningens dato')
    WHERE DATE(NEW.InnsjekkingsTid) > (
        SELECT DATE(Dato) FROM Flyvning 
        WHERE FlyruteNr = NEW.FlyruteNr 
          AND LøpeNr = NEW.LøpeNr
    );
END;

-- Tilsvarende sjekk for innsjekkingstid når den settes i etterkant
CREATE TRIGGER SjekkInnsjekkingstid_UPD
BEFORE UPDATE ON Billett
FOR EACH ROW
BEGIN
    SELECT RAISE(ABORT, 'InnsjekkingsTid må være før flyvningens dato')
    WHERE DATE(NEW.InnsjekkingsTid) > (
        SELECT DATE(Dato) FROM Flyvning 
        WHERE FlyruteNr = NEW.FlyruteNr 
          AND LøpeNr = NEW.LøpeNr
    );
END;

-- Sjekk at rutesegmenter har sammenhengende sekvensnummer og flyplasser
CREATE TRIGGER SjekkSammenhengendeRutesegment
AFTER INSERT ON Rutesegment
FOR EACH ROW
BEGIN
    SELECT RAISE(ABORT, 'Rutesegmenter må ha sammenhengende sted og sekvensnummer')
    WHERE EXISTS (
        WITH ordered AS (
            SELECT 
                SekvensNr,
                AvgangFra,
                AnkomstTil,
                LAG(SekvensNr) OVER (ORDER BY SekvensNr) AS prev_SekvensNr,
                LAG(AnkomstTil) OVER (ORDER BY SekvensNr) AS prev_AnkomstTil
            FROM Rutesegment
            WHERE FlyruteNr = NEW.FlyruteNr
        )
        SELECT 1
        FROM ordered
        WHERE prev_SekvensNr IS NOT NULL
          -- Sjekk at sekvensnumrene er etterfølgende
          AND SekvensNr <> prev_SekvensNr + 1
          -- Sjekk at forriges ankomstflyplass matcher den nåværendes avgangsflyplass
          OR prev_AnkomstTil <> AvgangFra
    );
END;

-- Sjekk ledige seter i tilfelle hvor noen billetter ikke er innsjekket
CREATE TRIGGER SjekkLedigeSeter
BEFORE INSERT ON Billett
FOR EACH ROW
BEGIN
    SELECT RAISE(ABORT, 'Flyvningen har ikke nok ledige billetter for ett eller flere segmenter')
    WHERE EXISTS (
        WITH FlySeter AS (
            -- Finn antall seter for flyet
            SELECT COUNT(*) AS MaksSeter
            FROM Sete 
            WHERE Type = (SELECT FlysMed FROM Flyrute WHERE FlyruteNr = NEW.FlyruteNr)
        ),
        
        OpptatteSeter AS (
            -- Tell opptatte seter for hvert segment
            SELECT sik.SekvensNr, COUNT(*) AS Opptatte
            FROM Billett b
            JOIN SegmentIKombo sik 
              ON b.FlyruteNr = sik.FlyruteNr AND b.KomboNr = sik.KomboNr
            WHERE b.FlyruteNr = NEW.FlyruteNr 
              AND b.LøpeNr = NEW.LøpeNr
              AND sik.SekvensNr IN (
                  -- Select segmenter som inngår i rutekombo
                  SELECT SekvensNr FROM SegmentIKombo
                  WHERE FlyruteNr = NEW.FlyruteNr AND KomboNr = NEW.KomboNr
              )
            GROUP BY sik.SekvensNr
        )

        -- Sjekk om noen segmenter er utsolgt
        SELECT 1 FROM OpptatteSeter, FlySeter
        WHERE OpptatteSeter.Opptatte >= FlySeter.MaksSeter
    );
END;


-- Sjekk at et billettkjøp er for enten enveis eller tur-retur
CREATE TRIGGER SjekkMaksEnTurRetur
AFTER INSERT ON Billett
FOR EACH ROW
BEGIN
    SELECT RAISE(ABORT, 'Billettkjøpet kan kun bestå av én enveisreise eller én tur-retur')
    WHERE EXISTS (
        WITH ReiseInfo AS (
            SELECT 
                b.BillettNr,

                -- Finn første avgang til billettens rutekombo
                (SELECT AvgangFra FROM Rutesegment
                 WHERE FlyruteNr = b.FlyruteNr 
                 AND SekvensNr = (SELECT MIN(SekvensNr) FROM SegmentIKombo 
                                  WHERE FlyruteNr = b.FlyruteNr AND KomboNr = b.KomboNr)
                ) AS StartFlyplass,

                -- Finn siste ankosmt til billettens rutekombo
                (SELECT AnkomstTil FROM Rutesegment
                 WHERE FlyruteNr = b.FlyruteNr 
                 AND SekvensNr = (SELECT MAX(SekvensNr) FROM SegmentIKombo 
                                  WHERE FlyruteNr = b.FlyruteNr AND KomboNr = b.KomboNr)
                ) AS SluttFlyplass
            FROM Billett b
            WHERE b.ReferanseNr = NEW.ReferanseNr
        )

        -- Sjekk om flyplass dukker opp mer enn 2 ganger
        SELECT 1 FROM (
            SELECT Flyplass FROM (
                SELECT StartFlyplass AS Flyplass FROM ReiseInfo
                UNION ALL
                SELECT SluttFlyplass FROM ReiseInfo
            )
            GROUP BY Flyplass
            HAVING COUNT(*) > 2
        )
    );
END;

-- Sjekk at billetter i billettkjøp er for sammenhengende delreiser med tid og sted
CREATE TRIGGER SjekkSammenhengendeDelreiser
AFTER INSERT ON Billett
FOR EACH ROW
BEGIN
    SELECT RAISE(ABORT, 'Billettene i billettkjøpet må ha sammenhengende tid, sted og billettnummer')
    WHERE EXISTS (
        WITH RECURSIVE BeregnTider AS (
            -- Første segment for bilett
            SELECT 
                b.BillettNr,
                rs.FlyruteNr,
                rs.SekvensNr,

                -- Første segments avgangstid med dato
                datetime(fv.Dato || ' ' || rs.PlanlagtAvgangsTid) AS AvgangTid,

                -- Første segments ankomststid med dato
                datetime(fv.Dato || ' ' || rs.PlanlagtAnkomstTid,
                    CASE WHEN rs.PlanlagtAnkomstTid <= rs.PlanlagtAvgangsTid THEN '+1 day' ELSE '+0 day' END
                ) AS AnkomstTid,

                -- Første segments avgangsflyplass
                (SELECT AvgangFra FROM Rutesegment 
                 WHERE FlyruteNr = b.FlyruteNr 
                 AND SekvensNr = (SELECT MIN(SekvensNr) FROM SegmentIKombo 
                                  WHERE FlyruteNr = b.FlyruteNr AND KomboNr = b.KomboNr)
                ) AS StartFlyplass,

                -- Første segments ankomstflyplass
                (SELECT AnkomstTil FROM Rutesegment 
                 WHERE FlyruteNr = b.FlyruteNr 
                 AND SekvensNr = (SELECT MAX(SekvensNr) FROM SegmentIKombo 
                                  WHERE FlyruteNr = b.FlyruteNr AND KomboNr = b.KomboNr)
                ) AS SluttFlyplass

            FROM Billett b
            JOIN SegmentIKombo sik ON b.FlyruteNr = sik.FlyruteNr AND b.KomboNr = sik.KomboNr
            JOIN Rutesegment rs ON sik.FlyruteNr = rs.FlyruteNr AND sik.SekvensNr = rs.SekvensNr
            JOIN Flyvning fv ON fv.FlyruteNr = b.FlyruteNr AND fv.LøpeNr = b.LøpeNr
            WHERE b.ReferanseNr = NEW.ReferanseNr

            UNION ALL

            -- Håndter påfølgende segmenter for hver billett
            SELECT
                bt.BillettNr,
                rs.FlyruteNr,
                rs.SekvensNr,

				        -- Beregn neste avgangstid med dato basert på forrige segment
                datetime(bt.AnkomstTid,
                    '+' || CASE WHEN rs.PlanlagtAvgangsTid <= time(bt.AnkomstTid) THEN 1 ELSE 0 END || ' day',
                    time(rs.PlanlagtAvgangsTid)
                ) AS AvgangTid,
                
				        -- Beregn neste ankomsttid med dato basert på forrige segment
                datetime(
                    datetime(bt.AnkomstTid,
                        '+' || CASE WHEN rs.PlanlagtAvgangsTid <= time(bt.AnkomstTid) THEN 1 ELSE 0 END || ' day',
                        time(rs.PlanlagtAvgangsTid)
                    ),
                    CASE WHEN rs.PlanlagtAnkomstTid <= rs.PlanlagtAvgangsTid THEN '+1 day' ELSE '+0 day' END,
                    time(rs.PlanlagtAnkomstTid)
                ) AS AnkomstTid,

                bt.StartFlyplass,
                rs.AnkomstTil AS SluttFlyplass
            FROM BeregnTider bt
            JOIN Rutesegment rs ON rs.FlyruteNr = bt.FlyruteNr AND rs.SekvensNr = bt.SekvensNr + 1
        ),

        -- Sjekk at delreiser er sammenhengende og at billettnummer er sekvensielle
        OrdnetReise AS (
            SELECT *, 
                LAG(AnkomstTid) OVER (ORDER BY BillettNr) AS prev_AnkomstTid,
                LAG(SluttFlyplass) OVER (ORDER BY BillettNr) AS prev_SluttFlyplass,
                LAG(BillettNr) OVER (ORDER BY BillettNr) AS prev_BillettNr
            FROM BeregnTider
        )

        SELECT 1 FROM OrdnetReise
        WHERE prev_AnkomstTid IS NOT NULL
          AND (
                (BillettNr <> prev_BillettNr + 1) -- Sjekker at billettnumrene er sekvensielle
                OR prev_SluttFlyplass <> StartFlyplass -- Sjekker at flyplassene matcher
                OR prev_AnkomstTid >= AvgangTid -- Sjekker at tider ikke overlapper
            )
    );
END;

