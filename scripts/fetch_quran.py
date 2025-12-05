import json
import urllib.request
import os
import sys

def fetch_json(url):
    print(f"Downloading {url}...")
    req = urllib.request.Request(
        url, 
        data=None, 
        headers={
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
        }
    )
    with urllib.request.urlopen(req) as response:
        return json.loads(response.read().decode('utf-8'))

def main():
    # 1. Fetch Arabic Text (Uthmani)
    print("Fetching Arabic text...")
    try:
        arabic_data = fetch_json("http://api.alquran.cloud/v1/quran/quran-uthmani")
    except Exception as e:
        print(f"Failed to fetch Arabic text: {e}")
        return

    # 2. Fetch Turkish Translation (Diyanet)
    print("Fetching Turkish translation...")
    try:
        tr_data = fetch_json("http://api.alquran.cloud/v1/quran/tr.diyanet")
    except Exception as e:
        print(f"Failed to fetch Turkish translation: {e}")
        return

    # 3. Fetch Transliteration (English based as fallback)
    print("Fetching Transliteration...")
    trans_data = None
    try:
        trans_data = fetch_json("http://api.alquran.cloud/v1/quran/en.transliteration")
    except Exception as e:
        print(f"Transliteration fetch failed, continuing without it: {e}")

    if arabic_data['code'] != 200 or tr_data['code'] != 200:
        print("Error response from API")
        return

    surahs_arabic = arabic_data['data']['surahs']
    surahs_tr = tr_data['data']['surahs']
    surahs_trans = trans_data['data']['surahs'] if trans_data else []

    output_surahs = []

    # Manual map for some Turkish names if needed, otherwise use EnglishName
    # We can refine this later.
    
    for i in range(114):
        s_ar = surahs_arabic[i]
        s_tr = surahs_tr[i]
        s_trans = surahs_trans[i] if (surahs_trans and i < len(surahs_trans)) else None

        # Basic info
        number = s_ar['number']
        name_ar = s_ar['name'] # Arabic name
        name_en = s_ar['englishName'] # English name e.g. Al-Fatiha
        
        # Simple cleanup for name
        name_display = name_en
        
        revelation_type = s_ar['revelationType'] # Meccan / Medinan
        revelation_place = "Mekke" if revelation_type == "Meccan" else "Medine"

        verses_list = []
        count = len(s_ar['ayahs'])

        for j in range(count):
            v_ar = s_ar['ayahs'][j]
            v_tr = s_tr['ayahs'][j]
            v_trans = s_trans['ayahs'][j] if (s_trans and j < len(s_trans['ayahs'])) else None

            verse_obj = {
                "arabic": v_ar['text'],
                "transliteration": v_trans['text'] if v_trans else "",
                "meaning": v_tr['text'],
                "verseNumber": v_ar['numberInSurah']
            }
            verses_list.append(verse_obj)

        surah_obj = {
            "number": number,
            "name": name_display,
            "nameArabic": name_ar,
            "verseCount": count,
            "revelationPlace": revelation_place,
            "verses": verses_list
        }
        output_surahs.append(surah_obj)

    final_json = {"surahs": output_surahs}

    # Go up one level from scripts to root, then assets/data
    # Assuming script is run from root or scripts folder. 
    # Let's use absolute path based on current working dir if possible, or relative.
    # The user workspace is c:\Users\Asus\Downloads\mirac_prayer_assistant\mirac_prayer_assistant
    
    target_dir = os.path.join(os.getcwd(), "assets", "data")
    if not os.path.exists(target_dir):
        # Try relative to script location if cwd is wrong
        script_dir = os.path.dirname(os.path.abspath(__file__))
        target_dir = os.path.join(script_dir, "..", "assets", "data")
    
    os.makedirs(target_dir, exist_ok=True)
    output_path = os.path.join(target_dir, "quran_full.json")
    
    print(f"Writing to {output_path}...")
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(final_json, f, ensure_ascii=False, indent=2)
    
    print("Done! Quran data saved.")

if __name__ == "__main__":
    main()
