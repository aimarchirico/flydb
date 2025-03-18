import sqlite3
from datetime import datetime

# Finner ledige seter for en valgt flyvning for hvert segment
def available_seats_finder(db_name):
    output_lines = []
    output_file = "usecase8_output.txt"
    
    conn = sqlite3.connect(db_name)
    conn.row_factory = sqlite3.Row
    cur = conn.cursor()
    
    try:
        # Finner flyvninger 
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
            message = "Ingen flyvninger funnet i databasen."
            output_lines.append(message)
            print(message)
            return
        
        header = "\n=== Tilgjengelige flyvninger ==="
        output_lines.append(header)
        print(header)
        
        for i, flight in enumerate(flights, 1):
            flight_date = datetime.strptime(flight['Dato'], '%Y-%m-%d').strftime('%d.%m.%Y')
            line = f"{i}. {flight['FlysAv']}{flight['FlyruteNr']} {flight_date} - {flight['FraFlyplass']} ({flight['FraFlyplassNavn']}) → {flight['TilFlyplass']} ({flight['TilFlyplassNavn']})"
            output_lines.append(line)
            print(line)
        
        while True:
            try:
                flight_idx = int(input("\nVelg flyvning (nummer): ")) - 1
                if 0 <= flight_idx < len(flights):
                    selected_flight = flights[flight_idx]
                    break
                else:
                    print("Ugyldig valg. Prøv igjen.")
            except ValueError:
                print("Skriv inn et tall.")
        
        # Finner alle segmenter for valgt flyvning
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
        
        flight_header = f"\n=== Flyvning {selected_flight['FlysAv']}{selected_flight['FlyruteNr']} {selected_flight['Dato']} ==="
        output_lines.append(flight_header)
        print(flight_header)

        for segment in segments:
            segment_header = f"\nDelflyvning {segment['SekvensNr']}: {segment['AvgangFra']} ({segment['AvgangFraNavn']}) → {segment['AnkomstTil']} ({segment['AnkomstTilNavn']})"
            segment_times = f"Avgangstid: {segment['PlanlagtAvgangsTid']}, Ankomsttid: {segment['PlanlagtAnkomstTid']}"
            
            output_lines.append(segment_header)
            output_lines.append(segment_times)
            print(segment_header)
            print(segment_times)
            
            # Hent flytype for å hente seter
            cur.execute("""
                SELECT FlysMed FROM Flyrute WHERE FlyruteNr = ?
            """, (selected_flight['FlyruteNr'],))
            
            flytype = cur.fetchone()['FlysMed']
            
            # Henter alle seter med status (ledig/opptatt) i én SQL-spørring
            # Joiner på bilett og case when setter den til 0 hvis sete er ledig og 1 hvis opptatt
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
            
            seat_map_header = "\nSetekart:"
            output_lines.append(seat_map_header)
            print(seat_map_header)

            # Finn alle seter
            all_seat_letters = set()
            for seat in all_seats:
                all_seat_letters.add(seat['SeteID'][-1])

            # Finn hvilke side av midtgang
            left_letters = set()
            right_letters = set()
            for seat in all_seats:
                if seat['HøyreForMidtgang']:
                    right_letters.add(seat['SeteID'][-1])
                else:
                    left_letters.add(seat['SeteID'][-1])
                    
            # Sorter bokstaver
            left_letters = sorted(left_letters)
            right_letters = sorted(right_letters)
            left_width = len(left_letters) * 4 
                    
            # Gruppér etter rader
            seat_rows = {}
            for seat in all_seats:
                row_num = seat['SeteID'][:-1]  
                if row_num not in seat_rows:
                    seat_rows[row_num] = []
                seat_rows[row_num].append(seat)

            header_row = "Row   " 

            # Venstre side
            for letter in left_letters:
                header_row += f" {letter}  "  

            # Midtgang
            header_row += "|"

            # Høyre side
            for letter in right_letters:
                header_row += f" {letter}  "

            separator = "-" * len(header_row)
            
            output_lines.append(header_row)
            output_lines.append(separator)
            print(header_row)
            print(separator)

            # Print setekart
            for row_num in sorted(seat_rows.keys(), key=lambda x: int(x)):
                row_text = f"{row_num:>3}   "
                
                row_seats = {seat['SeteID'][-1]: seat for seat in seat_rows[row_num]}
             
                for letter in left_letters:
                    if letter in row_seats and not row_seats[letter]['HøyreForMidtgang']:
                        if row_seats[letter]['Opptatt'] == 1:
                            row_text += f"[{letter}] "
                        else:
                            row_text += f" {letter}  "
                    else:
                        row_text += "    "
                
                row_text += "|"
            
                for letter in right_letters:
                    if letter in row_seats and row_seats[letter]['HøyreForMidtgang']:
                        if row_seats[letter]['Opptatt'] == 1:
                            row_text += f"[{letter}] "
                        else:
                            row_text += f" {letter}  "
                    else:
                        row_text += "    "
                
                # Nødutgang
                if any(seat['Nødutgang'] for seat in seat_rows[row_num]):
                    row_text += "  (Nødutgang)"
                
                output_lines.append(row_text)
                print(row_text)

            legend1 = "\nTegnforklaring:"
            legend2 = "[ ] = Opptatt sete"
            legend3 = " A  = Ledig sete"
            
            output_lines.append(legend1)
            output_lines.append(legend2)
            output_lines.append(legend3)
            print(legend1)
            print(legend2)
            print(legend3)
            
            total_seats = len(all_seats)
            occupied_count = sum(1 for seat in all_seats if seat['Opptatt'] == 1)
            available_count = total_seats - occupied_count
            
            summary = f"\nTotalt {total_seats} seter: {available_count} ledige, {occupied_count} opptatt"
            output_lines.append(summary)
            print(summary)
        
        # Skriv til fil
        with open(output_file, "w", encoding="utf-8") as f:
            f.write('\n'.join(output_lines))
        print(f"\nResultatet er også skrevet til {output_file}")
            
    except Exception as e:
        error_msg = f"En feil oppstod: {e}"
        print(error_msg)
        with open(output_file, "w", encoding="utf-8") as f:
            f.write(error_msg)
    finally:
        conn.close()

if __name__ == "__main__":
    available_seats_finder()