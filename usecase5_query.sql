-- BRUKSTILFELLE 5:

-- Finner flyselskap (kode og navn), 
-- hvilke flytyper selskapet har, 
-- og antall fly selskapet har av hver flytype
SELECT 
    fs.FlyselskapsKode AS "Flyselskapskode",
    fs.Navn AS "Flyselskapsnavn",
    f.AvType AS "Flytype",
    COUNT(*) AS "Antall fly"
FROM 
    Flyselskap fs
JOIN 
    Fly f ON fs.FlyselskapsKode = f.Eier
GROUP BY 
    fs.FlyselskapsKode, fs.Navn, f.AvType
ORDER BY 
    fs.Navn, f.AvType;