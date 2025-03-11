import sqlite3
import os

#  SSetter opp databasen med skjema og data fra SQL-filer (overskriver eksisterende database hvis den finnes)

def setup_database(db_name="flyselskap.db"):
    
    
    if os.path.exists(db_name):
        os.remove(db_name)
    
    conn = sqlite3.connect(db_name)
    
    try:
        
        # Read schema SQL from files
        with open('schema.sql', 'r', encoding='utf-8') as schema_file:
            schema_sql = schema_file.read()
        
        with open('data.sql', 'r', encoding='utf-8') as data_file:
            data_sql = data_file.read()
        
        conn.executescript(schema_sql)
        print("Schema created successfully")
        
        conn.executescript(data_sql)
        print("Data inserted successfully")
        
        conn.commit()
        print(f"Database '{db_name}' set up successfully")
        
    except Exception as e:
        print(f"Error setting up database: {e}")
    finally:
        conn.close()

if __name__ == "__main__":
    setup_database()
    print("Database setup complete")