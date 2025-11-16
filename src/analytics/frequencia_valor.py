# %%
import pandas as pd
import sqlalchemy

import matplotlib.pyplot as plt
import seaborn as sns
from sklearn import cluster
from sklearn import preprocessing

# %%
def import_query(path: str) -> str:
    with open(path) as f:
        query = f.read()
    
    return query

def get_engine(db_path: str) -> sqlalchemy.engine.base.Engine:
    engine = sqlalchemy.create_engine(f"sqlite:///{db_path}")
    return engine

# %%
engine_app = get_engine("../../data/loyalty_system/database.db")
query = import_query("frequencia_valor.sql")

df = pd.read_sql(query, engine_app)
df.head()

df = df[df['qtdePontosPos'] < 4000]

# %%
plt.plot(df["qtdeFrequencia"], df["qtdePontosPos"], "o")
plt.xlabel("Frequencia (Últimos 28 dias)")
plt.ylabel("Valor")
plt.grid()
plt.show()

# %%
minmax = preprocessing.MinMaxScaler()

X = minmax.fit_transform(df[['qtdeFrequencia', 'qtdePontosPos']])

kmean = cluster.KMeans(n_clusters=5, random_state=42, max_iter=1000)
kmean.fit(X)

df['cluster_calc'] = kmean.labels_

# %%
df.groupby(by='cluster_calc')['IdCliente'].count()

#%%
sns.scatterplot(
    data=df,
    x='qtdeFrequencia',
    y='qtdePontosPos',
    hue='cluster_calc',
    palette='deep'
)

plt.hlines(y=1500, xmin=0, xmax=25, colors='black')
plt.hlines(y=750, xmin=0, xmax=25, colors='black')

plt.vlines(x=4, ymin=0, ymax=750, colors='black')
plt.vlines(x=10, ymin=0, ymax=3000, colors='black')

plt.grid()
# %%
sns.scatterplot(
    data=df,
    x='qtdeFrequencia',
    y='qtdePontosPos',
    hue='cluster',
    palette='deep'
)

plt.hlines(y=1500, xmin=0, xmax=25, colors='black')
plt.hlines(y=750, xmin=0, xmax=25, colors='black')

plt.vlines(x=4, ymin=0, ymax=750, colors='black')
plt.vlines(x=10, ymin=0, ymax=3000, colors='black')

plt.grid()
# %%
