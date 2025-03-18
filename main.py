import sqlite3
import os
import sys

# Importerer funskjoner fra andre filer
from setup_database import setup_database
from usecase6_airports import airport_route_finder
from usecase8_seats import available_seats_finder


# Kjører sql query, printer resultatet og skriver det til output fil
def run_sql_query(db_name, query_file, output_file="output.txt"):
    if not os.path.exists(query_file):
        print(f"Error: Query-fil {query_file} eksisterer ikke")
        return

    with open(query_file, "r", encoding="utf-8") as f:
        query = f.read()

    conn = sqlite3.connect(db_name)

    try:
        # Kobler til databasen og kjører query
        cursor = conn.cursor()
        cursor.execute(query)
        column_names = [description[0] for description in cursor.description]
        rows = cursor.fetchall()

        header = " | ".join(column_names)
        separator = "-" * len(header)
        output_lines = ["\n" + header, separator]

        # Lagrer returnert data
        for row in rows:
            row_str = " | ".join(str(item) for item in row)
            output_lines.append(row_str)
        output_lines.append(f"\n{len(rows)} rader returnert")
        
        for line in output_lines:
            print(line)
        with open(output_file, "w", encoding="utf-8") as outfile:
            outfile.write("\n".join(output_lines))
        print(f"\nResultatet er også skrevet til {output_file}")

    except sqlite3.Error as e:
        error_msg = f"Database error: {e}"
        print(error_msg)
        with open(output_file, "w", encoding="utf-8") as outfile:
            outfile.write(error_msg)
    finally:
        conn.close()

# Sjekker at databasefilen eksisterer og ikke er tom
def check_database_ready(db_name):
    if not os.path.exists(db_name):
        print("Database finnes ikke. Opprett den først.")
        return False
    if os.path.getsize(db_name) == 0:
        print("Databasefilen er tom. Initialiser den først.")
        return False
    return True


# Hovedmeny hvor brukeren kan kjøre ulike script
def main_menu():
    db_name = "FlyDB.db"

    while True:
        print("\n=== FlyDB Database System ===")
        print("1. Sett opp database med skjema og data")
        print("2. Vis flyselskap, flytyper og antall fly")
        print("3. Søk etter flyruter for en flyplass")
        print("4. Finn ledige seter for en flyvning")
        print("0. Avslutt programmet")

        choice = input("\nVelg en handling (0-4): ")

        # Avslutter programmet
        if choice == "0":
            if os.path.exists(db_name):
                os.remove(db_name)
            open(db_name, 'w').close()
            print("Programmet avsluttes...")
            sys.exit(0)

        # Initaliserer databasen med skjema og data
        elif choice == "1":
            setup_database(db_name)

        # Brukstilfelle 5: Finner flyselskap, flytyper og antall fly
        elif choice == "2":
            if not check_database_ready(db_name):
                continue
            query_file = "usecase5_query.sql"
            run_sql_query(db_name, query_file, "usecase5_output.txt")
            
        # Brukstifelle 6: Finner flyruter for valgt flyplass på valgt dag
        elif choice == "3":
            if not check_database_ready(db_name):
                continue
            airport_route_finder(db_name)

        # Brukstilfelle 8: Finn ledig sete for flyvning    
        elif choice == "4":
            if not check_database_ready(db_name):
                continue
            available_seats_finder(db_name)
            
        else:
            print("Ugyldig valg. Prøv igjen.")


if __name__ == "__main__":
    main_menu()
