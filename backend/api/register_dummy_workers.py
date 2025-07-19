import requests
import random
import time

# Backend API base URL
BASE_URL = 'http://localhost:8000/api/v1'
REGISTER_URL = f'{BASE_URL}/auth/register/worker'
CATEGORIES_URL = f'{BASE_URL}/categories/'

# Provided names
NAMES = [
    "Arik Islam",
    "Abdullah Evne Masood",
    "Md. Akram Khan",
    "Dipta Bhattacharjee",
    "Aditto Raihan",
    "Istiak Ahammed Rhyme",
    "Shakin Alam Kabbo",
    "Mir Md. Ishrak Faisal",
    "H. M. Mehedi Hasan",
    "Md.Sharif",
    "Srabon Aich",
    "Swapon Chandra Roy",
    "Md. Ashif Mahmud Kayes",
    "Mehedi Hasan",
    "Jubayer Ahmed Sojib",
    "Jobaer Hossain Tamim",
    "Md. Shahriar Hasan Jony",
    "Md. Sadman Sakib",
    "Dibbajothy Sarker",
    "Md. Mohosin kamal",
    "MD. Mahmudur Rahman Moin",
    "Jotish Biswas",
    "Saad Bin Ashad",
    "Sharfraz Khan Hridue",
    "Abdullah-Ash-Sakafy",
    "Farhan Bin Rabbani",
    "Md. Sadman Shihab",
    "Ahnaf Mahbub Khan",
    "Tamal Kanti Sarker",
    "Md. Rushan Jamil",
    "S.M. Shamiun Ferdous",
    "Md. Nadim Mahmud Chowdhury Sizan",
    "Md. Ariful Islam",
    "Ahil Islam Aurnob",
    "Md. Abu Bakar Siddique",
    "Biplob pal",
    "Abul Hasan Anik",
    "Chowdhury Shafahid Rahman",
    "N. M Rashidujjaman Masum"
]

# Map category names to example skills
CATEGORY_SKILLS = {
    "Babysitting": ["child care", "first aid", "patience"],
    "AC Repair": ["AC maintenance", "cooling systems", "diagnostics"],
    "Tutoring": ["math", "science", "teaching", "communication"],
    "Physician": ["diagnosis", "patient care", "medical knowledge"],
    "Cleaner": ["house cleaning", "organization", "attention to detail"],
    "Plumber": ["pipe fitting", "leak repair", "installation"],
    "Electrician": ["wiring", "circuit repair", "safety"],
    "Carpenter": ["woodwork", "furniture making", "precision"],
    "Gardener": ["plant care", "landscaping", "pruning"],
    "Cook": ["cooking", "menu planning", "food safety"],
    "Driver": ["safe driving", "navigation", "vehicle maintenance"],
    "Security": ["surveillance", "emergency response", "crowd control"]
}

# Example addresses and bios
ADDRESSES = [
    "Dhaka, Bangladesh",
    "Chittagong, Bangladesh",
    "Khulna, Bangladesh",
    "Rajshahi, Bangladesh",
    "Sylhet, Bangladesh",
    "Barisal, Bangladesh",
    "Rangpur, Bangladesh",
    "Mymensingh, Bangladesh"
]
BIOS = [
    "Passionate and experienced professional.",
    "Dedicated to providing the best service.",
    "Reliable and skilled in my field.",
    "Committed to customer satisfaction."
]

def get_categories():
    resp = requests.get(CATEGORIES_URL)
    resp.raise_for_status()
    return resp.json()

def name_to_email(name):
    base = name.lower().replace(" ", ".").replace(",", "").replace("-", "").replace(".", "")
    unique = str(random.randint(10000, 99999))
    return f"{base}{unique}@example.com"

def random_phone():
    return f"017{random.randint(10000000, 99999999)}"

def main():
    categories = get_categories()
    names = NAMES.copy()
    random.shuffle(names)
    name_idx = 0
    workers_per_category = 3
    for cat in categories:
        cat_name = cat["name"]
        cat_id = cat["id"]
        skills = CATEGORY_SKILLS.get(cat_name, ["service", "professional"])
        print(f"Registering workers for category: {cat_name}")
        for i in range(workers_per_category):
            if name_idx >= len(names):
                print("No more names left!")
                return
            name = names[name_idx]
            name_idx += 1
            email = name_to_email(name)
            payload = {
                "email": email,
                "password": "password123",
                "full_name": name,
                "phone_number": random_phone(),
                "address": random.choice(ADDRESSES),
                "bio": random.choice(BIOS),
                "skills": skills,
                "hourly_rate": round(random.uniform(5, 20), 2),
                "experience_years": random.randint(1, 10),
                "category_id": cat_id
            }
            try:
                resp = requests.post(REGISTER_URL, json=payload)
                if resp.status_code == 201:
                    print(f"  [OK] {name} registered as {cat_name}")
                else:
                    print(f"  [FAIL] {name} ({cat_name}): {resp.status_code} {resp.text}")
            except Exception as e:
                print(f"  [ERROR] {name} ({cat_name}): {e}")
            time.sleep(0.2)  # avoid spamming the server

if __name__ == "__main__":
    main() 