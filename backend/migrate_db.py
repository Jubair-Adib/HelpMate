import sqlite3
import os

def migrate_database():
    """Add new fields to existing database tables"""
    db_path = 'helpmate.db'
    
    if not os.path.exists(db_path):
        print("Database file not found. Please run the application first to create the database.")
        return
    
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    try:
        # Remove booking_status column if it exists (we're reverting this change)
        cursor.execute("PRAGMA table_info(workers)")
        columns = [column[1] for column in cursor.fetchall()]
        
        if 'booking_status' in columns:
            print("Removing booking_status column from workers table...")
            # SQLite doesn't support DROP COLUMN directly, so we need to recreate the table
            cursor.execute("""
                CREATE TABLE workers_new (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    email TEXT UNIQUE NOT NULL,
                    full_name TEXT NOT NULL,
                    hashed_password TEXT NOT NULL,
                    phone_number TEXT,
                    address TEXT,
                    bio TEXT,
                    skills TEXT,
                    hourly_rate REAL,
                    experience_years INTEGER,
                    is_available BOOLEAN DEFAULT 1,
                    rating REAL DEFAULT 0.0,
                    total_reviews INTEGER DEFAULT 0,
                    is_verified BOOLEAN DEFAULT 0,
                    is_active BOOLEAN DEFAULT 1,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                )
            """)
            
            # Copy data from old table to new table
            cursor.execute("""
                INSERT INTO workers_new 
                SELECT id, email, full_name, hashed_password, phone_number, address, 
                       bio, skills, hourly_rate, experience_years, is_available, 
                       rating, total_reviews, is_verified, is_active, created_at, updated_at
                FROM workers
            """)
            
            # Drop old table and rename new table
            cursor.execute("DROP TABLE workers")
            cursor.execute("ALTER TABLE workers_new RENAME TO workers")
            print("✓ booking_status column removed from workers table")
        else:
            print("✓ booking_status column doesn't exist in workers table")
        
        # Check if payment_method column exists in orders table
        cursor.execute("PRAGMA table_info(orders)")
        columns = [column[1] for column in cursor.fetchall()]
        
        if 'payment_method' not in columns:
            print("Adding payment_method column to orders table...")
            cursor.execute("ALTER TABLE orders ADD COLUMN payment_method TEXT DEFAULT 'pay_in_person'")
            print("✓ payment_method column added to orders table")
        else:
            print("✓ payment_method column already exists in orders table")
        
        # Update existing orders to have pay_in_person payment method
        cursor.execute("UPDATE orders SET payment_method = 'pay_in_person' WHERE payment_method IS NULL")
        
        conn.commit()
        print("\n✓ Database migration completed successfully!")
        
    except Exception as e:
        print(f"Error during migration: {e}")
        conn.rollback()
    finally:
        conn.close()

if __name__ == "__main__":
    migrate_database() 