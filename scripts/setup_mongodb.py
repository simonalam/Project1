#!/usr/bin/env python3
"""
MongoDB Setup Script
Loads supplier data from JSON file into MongoDB Atlas
"""

import pymongo
import json
import os

# MongoDB Atlas connection parameters
mongodb_args = {
    "user_name": "simonalam1234_db_user",
    "password": "GWXph3tW1aIUWdyr",
    "cluster_name": "cluster",
    "cluster_subnet": "axefz7f",
    "db_name": "retail_db"
}

# FIXED: Correct MongoDB Atlas connection string format
atlas_url = f"mongodb+srv://{mongodb_args['user_name']}:{mongodb_args['password']}@{mongodb_args['cluster_name']}.{mongodb_args['cluster_subnet']}.mongodb.net/{mongodb_args['db_name']}?retryWrites=true&w=majority"

print("="*60)
print("MongoDB Atlas Setup")
print("="*60)

try:
    # Connect to MongoDB Atlas
    print("\n1. Connecting to MongoDB Atlas...")
    client = pymongo.MongoClient(atlas_url)
    
    # Test connection
    client.server_info()
    print("   ✓ Connected successfully")
    
    # Access database and collection
    db = client[mongodb_args["db_name"]]
    collection = db["suppliers"]
    
    # Load JSON data
    print("\n2. Loading supplier data from JSON file...")
    json_path = "../data/mongo_source.json"
    
    if not os.path.exists(json_path):
        # Try alternative path
        json_path = "data/mongo_source.json"
    
    with open(json_path, 'r') as f:
        supplier_data = json.load(f)
    
    print(f"   ✓ Loaded {len(supplier_data)} suppliers from JSON")
    
    # Clear existing data
    print("\n3. Clearing existing supplier collection...")
    result = collection.delete_many({})
    print(f"   ✓ Deleted {result.deleted_count} existing records")
    
    # Insert new data
    print("\n4. Inserting supplier data...")
    result = collection.insert_many(supplier_data)
    print(f"   ✓ Inserted {len(result.inserted_ids)} supplier records")
    
    # Verify data
    print("\n5. Verifying data...")
    count = collection.count_documents({})
    print(f"   ✓ Total suppliers in collection: {count}")
    
    # Display sample data
    print("\n6. Sample supplier data:")
    for doc in collection.find().limit(2):
        del doc['_id']  # Remove MongoDB's internal ID
        print(f"   {doc}")
    
    print("\n" + "="*60)
    print("✅ MongoDB supplier collection initialized successfully!")
    print("="*60)
    print(f"\nDatabase: {mongodb_args['db_name']}")
    print(f"Collection: suppliers")
    print(f"Records: {count}")
    
except pymongo.errors.ServerSelectionTimeoutError:
    print("\n❌ Error: Could not connect to MongoDB Atlas")
    print("   Check your network connection and MongoDB Atlas settings:")
    print("   - Verify cluster is running")
    print("   - Check Network Access allows your IP (0.0.0.0/0)")
    print("   - Verify credentials are correct")
    
except FileNotFoundError:
    print(f"\n❌ Error: Could not find {json_path}")
    print("   Make sure mongo_source.json is in the data/ directory")
    
except Exception as e:
    print(f"\n❌ Error: {str(e)}")
    
finally:
    # Close connection
    if 'client' in locals():
        client.close()
        print("\n✓ MongoDB connection closed")
