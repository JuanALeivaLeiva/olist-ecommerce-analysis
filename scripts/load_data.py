import sqlite3
from pathlib import Path
import pandas as pd

DATA_DIR = Path("data")
DB_PATH = Path("olist.db")

conn = sqlite3.connect(DB_PATH)

for csv in DATA_DIR.glob("*.csv"):
    table = csv.stem.replace("olist_", "").replace("_dataset", "")
    df = pd.read_csv(csv)
    df.to_sql(table, conn, if_exists="replace", index=False)
    print(f"{table}: {len(df):,} filas")

conn.close()