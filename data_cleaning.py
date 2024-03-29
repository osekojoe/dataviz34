import pandas as pd

df_customers = pd.read_csv("./data/customers.csv")
df_orders = pd.read_csv("./data/orders.csv")
df_products = pd.read_csv("./data/products.csv")
df_regions = pd.read_csv("./data/regionss.csv")

col_products = df_products.columns
print(col_products)
