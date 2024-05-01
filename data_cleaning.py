import pandas as pd
df_merged = pd.read_csv("./data/merged_orders.csv")
aggregated_df = df_merged.groupby(['Type', 'Year']).agg({'Quantities': 'sum'}).reset_index()
aggregated_df = aggregated_df.rename(columns={'quantity': 'aggregated_quantity'})
aggregated_df.to_csv('./Tree_data.csv', index=False)