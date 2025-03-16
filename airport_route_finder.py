import sqlite3

# Finner ruter for en bestemt flyplass, ukedag og retning (avganger/ankomster)
def airport_route_finder(db_name):
    output_file = "usecase6_output.txt"
    
    conn = sqlite3.connect(db_name)
    conn.row_factory = sqlite3.Row  
    cur = conn.cursor()
    
    try:
        cur.execute("SELECT FlyplassKode, Navn FROM Flyplass ORDER BY FlyplassKode")
        airports = cur.fetchall()
        
        if not airports:
            print("Ingen flyplasser funnet i databasen.")
            return
        
        # Viser flyplasser
        print("\n=== Velg flyplass ===")
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
        
        print("\n=== Velg ukedag ===")
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
        
        
        print("\n=== Velg retning ===")
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
        
        # Finner alle segmenter for ruten med større sekvensnummer enn segmentet som
        # inneholder valgt avgang for å finne flyplasser i ruten som skal besøkes etter avgang
        if is_departure:
            query = """
                SELECT 
                    fr.FlyruteNr,
                    rs.PlanlagtAvgangsTid,
                    rs.AvgangFra,
                    GROUP_CONCAT(rs_path.AnkomstTil, ' → ') AS Destinasjoner
                FROM 
                    Flyrute fr
                JOIN 
                    Rutesegment rs ON fr.FlyruteNr = rs.FlyruteNr AND rs.AvgangFra = ?
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
        
        # Finner alle segmenter for ruten med mindre sekvensnummer enn segmentet som
        # inneholder valgt ankomst for å finne flyplasser i ruten som skal besøkes før ankomst
        else:
            query = """
                SELECT 
                    fr.FlyruteNr,
                    rs.PlanlagtAnkomstTid,
                    rs.AnkomstTil,
                    GROUP_CONCAT(rs_path.AvgangFra, ' → ') AS Opprinnelser
                FROM 
                    Flyrute fr
                JOIN 
                    Rutesegment rs ON fr.FlyruteNr = rs.FlyruteNr AND rs.AnkomstTil = ?
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
        
        
        #Formater resultatet
        airport_name = [a['Navn'] for a in airports if a['FlyplassKode'] == selected_airport][0]
        direction_text = "Avganger fra" if is_departure else "Ankomster til"
        weekday_name = weekdays[int(selected_day)]
        
        output_lines = []
        output_lines.append(f"\n=== {direction_text} {airport_name} ({selected_airport}) på {weekday_name} ===\n")
        
        if not routes:
            no_routes_msg = f"Ingen flyruter funnet for {airport_name} på {weekday_name}."
            output_lines.append(no_routes_msg)
            print(no_routes_msg)
            with open(output_file, "w", encoding="utf-8") as f:
                f.write("\n".join(output_lines))
            print(f"\nResultatet er også skrevet til {output_file}")
            return
        
        # Formatering dersom avgang
        if is_departure:
            header = f"{'Flyrute':<8} {'Tid':<6} {'Fra':<5} {'Til':<5} {'Mellomlandinger':<20}"
            separator = "-" * 60
            output_lines.append(header)
            output_lines.append(separator)
            
            for route in routes:
                destinations = route['Destinasjoner'].split(' → ') if route['Destinasjoner'] else []
                final_destination = destinations[-1] if destinations else ""
                intermediate = destinations[:-1] if len(destinations) > 1 else []
                intermediate_str = " → ".join(intermediate) if intermediate else "Direkte"
                
                line = f"{route['FlyruteNr']:<8} {route['PlanlagtAvgangsTid']:<6} {selected_airport:<5} {final_destination:<5} {intermediate_str:<20}"
                output_lines.append(line)
        
        # Formatering dersom ankomst
        else:
            header = f"{'Flyrute':<8} {'Tid':<6} {'Fra':<5} {'Til':<5} {'Mellomlandinger':<20}"
            separator = "-" * 60
            output_lines.append(header)
            output_lines.append(separator)
            
            for route in routes:
                origins = route['Opprinnelser'].split(' → ') if route['Opprinnelser'] else []
                initial_origin = origins[0] if origins else ""
                intermediate = origins[1:] if len(origins) > 1 else []
                intermediate_str = " → ".join(intermediate) if intermediate else "Direkte"
                
                line = f"{route['FlyruteNr']:<8} {route['PlanlagtAnkomstTid']:<6} {initial_origin:<5} {selected_airport:<5} {intermediate_str:<20}"
                output_lines.append(line)
        
        output_lines.append(f"\n{len(routes)} rader returnert")
        
        # Print og skriv resultat til fil
        for line in output_lines:
            print(line)
        with open(output_file, "w", encoding="utf-8") as f:
            f.write("\n".join(output_lines))
        
        print(f"\nResultatet er også skrevet til {output_file}")
        
    except Exception as e:
        error_msg = f"En feil oppstod: {e}"
        print(error_msg)
        with open(output_file, "w", encoding="utf-8") as f:
            f.write(error_msg)
    finally:
        conn.close()

if __name__ == "__main__":
    airport_route_finder()