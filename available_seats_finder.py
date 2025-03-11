import sqlite3
from datetime import datetime

#finner ledige seter for en valgt flygning for hvert segment

def available_seats_finder(db_name="flyselskap.db"):
 
    conn = sqlite3.connect(db_name)
    conn.row_factory = sqlite3.Row
    cur = conn.cursor()
    
    try:
        # Finner flyvning 
        cur.execute("""
            SELECT 
                f.FlyruteNr, 
                f.Dato, 
                fr.FlysAv,
                fs.Navn AS FlyselskapsNavn,
                r_from.AvgangFra AS FraFlyplass,
                r_to.AnkomstTil AS TilFlyplass,
                fp_from.Navn AS FraFlyplassNavn,
                fp_to.Navn AS TilFlyplassNavn,
                r_from.PlanlagtAvgangsTid
            FROM 
                Flyvning f
            JOIN 
                Flyrute fr ON f.FlyruteNr = fr.FlyruteNr
            JOIN
                Flyselskap fs ON fr.FlysAv = fs.FlyselskapsKode
            JOIN
                (SELECT * FROM Rutesegment WHERE SekvensNr = 1) r_from ON fr.FlyruteNr = r_from.FlyruteNr
            JOIN
                Flyplass fp_from ON r_from.AvgangFra = fp_from.FlyplassKode
            JOIN
                (SELECT FlyruteNr, AnkomstTil FROM Rutesegment rs 
                 WHERE SekvensNr = (SELECT MAX(SekvensNr) FROM Rutesegment WHERE FlyruteNr = rs.FlyruteNr)
                ) r_to ON fr.FlyruteNr = r_to.FlyruteNr
            JOIN
                Flyplass fp_to ON r_to.AnkomstTil = fp_to.FlyplassKode
            ORDER BY 
                f.Dato DESC, r_from.PlanlagtAvgangsTid
        """)
        
        flights = cur.fetchall()
        
        if not flights:
            print("Ingen flygninger funnet i databasen.")
            return
        
        
        print("\n=== Tilgjengelige Flygninger ===")
        for i, flight in enumerate(flights, 1):
            flight_date = datetime.strptime(flight['Dato'], '%Y-%m-%d').strftime('%d.%m.%Y')
            print(f"{i}. {flight['FlysAv']}{flight['FlyruteNr']} {flight_date} - {flight['FraFlyplass']} ({flight['FraFlyplassNavn']}) → {flight['TilFlyplass']} ({flight['TilFlyplassNavn']})")
        
        
        while True:
            try:
                flight_idx = int(input("\nVelg flygning (nummer): ")) - 1
                if 0 <= flight_idx < len(flights):
                    selected_flight = flights[flight_idx]
                    break
                else:
                    print("Ugyldig valg. Prøv igjen.")
            except ValueError:
                print("Skriv inn et tall.")
        
        # Finner alle segmenter for valgt flygning
        cur.execute("""
            SELECT 
                rs.SekvensNr,
                rs.AvgangFra,
                fp_from.Navn AS AvgangFraNavn,
                rs.AnkomstTil,
                fp_to.Navn AS AnkomstTilNavn,
                rs.PlanlagtAvgangsTid,
                rs.PlanlagtAnkomstTid
            FROM 
                Rutesegment rs
            JOIN 
                Flyplass fp_from ON rs.AvgangFra = fp_from.FlyplassKode
            JOIN 
                Flyplass fp_to ON rs.AnkomstTil = fp_to.FlyplassKode
            WHERE 
                rs.FlyruteNr = ?
            ORDER BY 
                rs.SekvensNr
        """, (selected_flight['FlyruteNr'],))

        segments = cur.fetchall()

        print(f"\n=== Flygning {selected_flight['FlysAv']}{selected_flight['FlyruteNr']} {selected_flight['Dato']} ===")

        for segment in segments:
            print(f"\nSegment {segment['SekvensNr']}: {segment['AvgangFra']} ({segment['AvgangFraNavn']}) → {segment['AnkomstTil']} ({segment['AnkomstTilNavn']})")
            print(f"Avgangstid: {segment['PlanlagtAvgangsTid']}, Ankomsttid: {segment['PlanlagtAnkomstTid']}")
            
            # Får flytype for å hente seter
            cur.execute("""
                SELECT FlysMed FROM Flyrute WHERE FlyruteNr = ?
            """, (selected_flight['FlyruteNr'],))
            
            flytype = cur.fetchone()['FlysMed']
            
            # Henter alle seter med status (ledig/opptatt) i én SQL-spørring joiner på bilett og caase when setter den til 0 hvis sete er ledig og 1 hvis opptatt baser på leaft join
            cur.execute("""
                SELECT 
                    s.SeteID, 
                    s.Nødutgang,
                    s.HøyreForMidtgang,
                    CASE WHEN occupied.Sete IS NULL THEN 0 ELSE 1 END AS Opptatt
                FROM 
                    Sete s
                LEFT JOIN 
                    (SELECT DISTINCT b.Sete
                    FROM Billett b
                    JOIN SegmentIKombo sik ON b.FlyruteNr = sik.FlyruteNr AND b.KomboNr = sik.KomboNr
                    WHERE b.FlyruteNr = ? 
                    AND b.LøpeNr = 1
                    AND sik.SekvensNr = ?) AS occupied
                ON 
                    s.SeteID = occupied.Sete
                WHERE 
                    s.Type = ?
                ORDER BY
                    CAST(substr(s.SeteID, 1, length(s.SeteID)-1) AS INTEGER),
                    substr(s.SeteID, length(s.SeteID))
            """, (selected_flight['FlyruteNr'], segment['SekvensNr'], flytype))
            
            all_seats = cur.fetchall()
            
            # Setekart visning
            print("\nSetekart:")
            
            seat_rows = {}
            for seat in all_seats:
                row_num = seat['SeteID'][:-1]  
                if row_num not in seat_rows:
                    seat_rows[row_num] = []
                seat_rows[row_num].append(seat)
            
            for row_num in sorted(seat_rows.keys(), key=lambda x: int(x)):
                row_text = f"Rad {row_num:>2}: "
                
                seats = sorted(seat_rows[row_num], key=lambda s: s['SeteID'][-1])
                
                left_seats = [s for s in seats if not s['HøyreForMidtgang']]
                right_seats = [s for s in seats if s['HøyreForMidtgang']]
                
                for seat in left_seats:
                    seat_id = seat['SeteID']
                    if seat['Opptatt'] == 1:
                        row_text += f"[{seat_id[-1]}] "
                    else:
                        row_text += f" {seat_id[-1]}  "
                
                row_text += "| "
                
                for seat in right_seats:
                    seat_id = seat['SeteID']
                    if seat['Opptatt'] == 1:
                        row_text += f"[{seat_id[-1]}] "
                    else:
                        row_text += f" {seat_id[-1]}  "
                
                if any(seat['Nødutgang'] for seat in seats):
                    row_text += "  (Nødutgang)"
                
                print(row_text)
            
            print("\nTegnforklaring:")
            print("[ ] = Opptatt sete")
            print(" A  = Ledig sete")
            
            total_seats = len(all_seats)
            occupied_count = sum(1 for seat in all_seats if seat['Opptatt'] == 1)
            available_count = total_seats - occupied_count
            
            print(f"\nTotalt {total_seats} seter: {available_count} ledige, {occupied_count} opptatt")
    
    except Exception as e:
        print(f"En feil oppstod: {e}")
    finally:
        conn.close()

if __name__ == "__main__":
    available_seats_finder()