SELECT 
    fs.FlyselskapsKode AS "Flyselskap Kode",
    fs.Navn AS "Flyselskap Navn",
    f.AvType AS "Flytype",
    COUNT(*) AS "Antall Fly"
FROM 
    Flyselskap fs
JOIN 
    Fly f ON fs.FlyselskapsKode = f.Eier
GROUP BY 
    fs.FlyselskapsKode, fs.Navn, f.AvType
ORDER BY 
    fs.Navn, f.AvType;