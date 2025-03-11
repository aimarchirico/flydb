import sqlite3
import os
import sys

# Import functions from other modules (assuming they're in the same directory)
from setup_database import setup_database
from airport_route_finder import airport_route_finder
from available_seats_finder import available_seats_finder

def run_sql_query(db_name, query_file):
    """Run an SQL query from a file"""
    if not os.path.exists(query_file):
        print(f"Error: Query file {query_file} not found")
        return
    
    with open(query_file, 'r', encoding='utf-8') as f:
        query = f.read()
    
    conn = sqlite3.connect(db_name)
    try:
        cursor = conn.cursor()
        cursor.execute(query)
        
        # Fetch and display results
        column_names = [description[0] for description in cursor.description]
        rows = cursor.fetchall()
        
        # Print header
        header = " | ".join(column_names)
        print("\n" + header)
        print("-" * len(header))
        
        # Print rows
        for row in rows:
            print(" | ".join(str(item) for item in row))
        
        print(f"\n{len(rows)} rows returned")
        
    except sqlite3.Error as e:
        print(f"Database error: {e}")
    finally:
        conn.close()

def main_menu():
    """Display main menu and handle user choices"""
    db_name = "flyselskap.db"
    
    while True:
        print("\n=== Flyselskap Database System ===")
        print("1. Sett opp database med skjema og data")
        print("2. Vis flyselskap, flytyper og antall fly")
        print("3. Søk etter flyruter for en flyplass")
        print("4. Finn ledige seter for en flygning")
        print("0. Avslutt programmet")
        
        choice = input("\nVelg en handling (0-4): ")
        
        if choice == '0':
            print("Programmet avsluttes...")
            sys.exit(0)
        elif choice == '1':
            setup_database(db_name)
        elif choice == '2':
            if not os.path.exists(db_name):
                print("Database finnes ikke. Opprett den først.")
                continue
            
            query_file = "usecase5_query.sql"
            # Create the query file if it doesn't exist
            if not os.path.exists(query_file):
                query = """
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
                """
                with open(query_file, 'w', encoding='utf-8') as f:
                    f.write(query)
            
            run_sql_query(db_name, query_file)
        elif choice == '3':
            if not os.path.exists(db_name):
                print("Database finnes ikke. Opprett den først.")
                continue
            airport_route_finder(db_name)
        elif choice == '4':
            if not os.path.exists(db_name):
                print("Database finnes ikke. Opprett den først.")
                continue
            available_seats_finder(db_name)
        else:
            print("Ugyldig valg. Prøv igjen.")

if __name__ == "__main__":
    main_menu()