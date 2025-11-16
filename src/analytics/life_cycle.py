# %%
import pandas as pd
import sqlalchemy


# %%
def import_query(path: str) -> str:
    with open(path) as f:
        query = f.read()
    
    return query

# %%
def get_engine(db_path: str) -> sqlalchemy.engine.base.Engine:
    engine = sqlalchemy.create_engine(f"sqlite:///{db_path}")
    return engine

engine_app = get_engine("../../data/loyalty_system/database.db")
engine_analytical = get_engine("../../data/analytics/database.db")

# %%
query = import_query("life_cycle.sql")

start_year = 2024
start_month = 3

while f"{str(start_year)}-{str(start_month).zfill(2)}-01" <= "2025-09-01":
    
    date_analytical = f"{str(start_year)}-{str(start_month).zfill(2)}-01"
    with engine_analytical.connect() as conn:
        try:
            query_delete = f"DELETE FROM life_cycle WHERE dtRef = DATE('{date_analytical}', '-1 day')"
            conn.execute(sqlalchemy.text(query_delete))
            conn.commit()
        except Exception as err:
            print(err)

    df = pd.read_sql_query(query.format(date_analytical=date_analytical), engine_app)
    df.to_sql("life_cycle", engine_analytical, if_exists="append", index=False)
    
    if start_month == 12:
        start_month = 1
        start_year += 1
    else:
        start_month += 1

# %%
