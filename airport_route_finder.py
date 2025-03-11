import sqlite3

#finner ruter for en bestemt flyplass, ukedag og retning (avganger/ankomster)
def airport_route_finder(db_name="flyselskap.db"):
    
    conn = sqlite3.connect(db_name)
    conn.row_factory = sqlite3.Row  
    cur = conn.cursor()
    
    try:
        cur.execute("SELECT FlyplassKode, Navn FROM Flyplass ORDER BY FlyplassKode")
        airports = cur.fetchall()
        
        if not airports:
            print("Ingen flyplasser funnet i databasen.")
            return
        
        # viser flyplasser
        print("\n=== Tilgjengelige Flyplasser ===")
        for i, airport in enumerate(airports, 1):
            print(f"{i}. {airport['FlyplassKode']} - {airport['Navn']}")
        
        while True:
            try:
                airport_idx = int(input("\nVelg flyplass (nummer): ")) - 1
                if 0 <= airport_idx < len(airports):
                    selected_airport = airports[airport_idx]['FlyplassKode']
                    break
                else:
                    print("Ugyldig valg. Prøv igjen.")
            except ValueError:
                print("Skriv inn et tall.")
        
        weekdays = {
            1: "Mandag",
            2: "Tirsdag", 
            3: "Onsdag", 
            4: "Torsdag", 
            5: "Fredag", 
            6: "Lørdag", 
            7: "Søndag"
        }
        
        print("\n=== Velg Ukedag ===")
        for day_num, day_name in weekdays.items():
            print(f"{day_num}. {day_name}")
        
        while True:
            try:
                day_num = int(input("\nVelg ukedag (nummer): "))
                if 1 <= day_num <= 7:
                    selected_day = str(day_num)
                    break
                else:
                    print("Ugyldig valg. Prøv igjen.")
            except ValueError:
                print("Skriv inn et tall mellom 1 og 7.")
        
        
        print("\n=== Velg Retning ===")
        print("1. Avganger")
        print("2. Ankomster")
        
        while True:
            try:
                direction = int(input("\nVelg retning (nummer): "))
                if direction in [1, 2]:
                    is_departure = direction == 1
                    break
                else:
                    print("Ugyldig valg. Prøv igjen.")
            except ValueError:
                print("Skriv inn et tall (1 eller 2).")
        
        # Bygger spørringen vi leaft joiner for og beholde alle som har sekvensnummer større enn eller lik sekvensnummeret til avgangen
        if is_departure:
            query = """
                SELECT 
                    fr.FlyruteNr,
                    rs.PlanlagtAvgangsTid,
                    rs.AvgangFra,
                    GROUP_CONCAT(rs_path.AnkomstTil, ' → ') AS Destinasjoner,
                    fs.Navn AS Flyselskap,
                    fr.FlysMed AS Flytype
                FROM 
                    Flyrute fr
                JOIN 
                    Rutesegment rs ON fr.FlyruteNr = rs.FlyruteNr AND rs.AvgangFra = ?
                JOIN
                    Flyselskap fs ON fr.FlysAv = fs.FlyselskapsKode
                LEFT JOIN
                    (SELECT rs2.FlyruteNr, rs2.AnkomstTil, rs2.SekvensNr
                     FROM Rutesegment rs2) rs_path
                    ON fr.FlyruteNr = rs_path.FlyruteNr AND rs_path.SekvensNr >= 
                       (SELECT MIN(SekvensNr) FROM Rutesegment WHERE FlyruteNr = fr.FlyruteNr AND AvgangFra = ?)
                WHERE 
                    instr(fr.UkedagsKode, ?) > 0
                GROUP BY 
                    fr.FlyruteNr
                ORDER BY 
                    rs.PlanlagtAvgangsTid
            """
            params = (selected_airport, selected_airport, selected_day)
        else:
            query = """
                SELECT 
                    fr.FlyruteNr,
                    rs.PlanlagtAnkomstTid,
                    rs.AnkomstTil,
                    GROUP_CONCAT(rs_path.AvgangFra, ' → ') AS Opprinnelser,
                    fs.Navn AS Flyselskap,
                    fr.FlysMed AS Flytype
                FROM 
                    Flyrute fr
                JOIN 
                    Rutesegment rs ON fr.FlyruteNr = rs.FlyruteNr AND rs.AnkomstTil = ?
                JOIN
                    Flyselskap fs ON fr.FlysAv = fs.FlyselskapsKode
                LEFT JOIN
                    (SELECT rs2.FlyruteNr, rs2.AvgangFra, rs2.SekvensNr
                     FROM Rutesegment rs2) rs_path
                    ON fr.FlyruteNr = rs_path.FlyruteNr AND rs_path.SekvensNr <= 
                       (SELECT MAX(SekvensNr) FROM Rutesegment WHERE FlyruteNr = fr.FlyruteNr AND AnkomstTil = ?)
                WHERE 
                    instr(fr.UkedagsKode, ?) > 0
                GROUP BY 
                    fr.FlyruteNr
                ORDER BY 
                    rs.PlanlagtAnkomstTid
            """
            params = (selected_airport, selected_airport, selected_day)
        

        cur.execute(query, params)
        routes = cur.fetchall()
        
        
        #fomatering av resultatet
        
        airport_name = [a['Navn'] for a in airports if a['FlyplassKode'] == selected_airport][0]
        direction_text = "Avganger fra" if is_departure else "Ankomster til"
        weekday_name = weekdays[int(selected_day)]
        
        print(f"\n=== {direction_text} {airport_name} ({selected_airport}) på {weekday_name} ===\n")
        
        if not routes:
            print(f"Ingen flyruter funnet for {airport_name} på {weekday_name}.")
            return
        
        if is_departure:
            print(f"{'Flyrute':<8} {'Tid':<6} {'Fra':<5} {'Til':<5} {'Mellomlandinger':<20} {'Flyselskap':<15} {'Flytype':<15}")
            print("-" * 90)
            for route in routes:
                destinations = route['Destinasjoner'].split(' → ') if route['Destinasjoner'] else []
                final_destination = destinations[-1] if destinations else ""
                intermediate = destinations[:-1] if len(destinations) > 1 else []
                intermediate_str = " → ".join(intermediate) if intermediate else "Direkte"
                
                print(f"{route['FlyruteNr']:<8} {route['PlanlagtAvgangsTid']:<6} {selected_airport:<5} {final_destination:<5} {intermediate_str:<20} {route['Flyselskap']:<15} {route['Flytype']:<15}")
        else:
            print(f"{'Flyrute':<8} {'Tid':<6} {'Fra':<5} {'Til':<5} {'Mellomlandinger':<20} {'Flyselskap':<15} {'Flytype':<15}")
            print("-" * 90)
            for route in routes:
                origins = route['Opprinnelser'].split(' → ') if route['Opprinnelser'] else []
                initial_origin = origins[0] if origins else ""
                intermediate = origins[1:] if len(origins) > 1 else []
                intermediate_str = " → ".join(intermediate) if intermediate else "Direkte"
                
                print(f"{route['FlyruteNr']:<8} {route['PlanlagtAnkomstTid']:<6} {initial_origin:<5} {selected_airport:<5} {intermediate_str:<20} {route['Flyselskap']:<15} {route['Flytype']:<15}")
        
    except Exception as e:
        print(f"En feil oppstod: {e}")
    finally:
        conn.close()

if __name__ == "__main__":
    airport_route_finder()