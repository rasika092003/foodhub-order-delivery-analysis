import pandas as pd 

df = pd.read_csv("C:\\Users\\rasik\\OneDrive\\Desktop\\foodhub_order.csv")

print(df.head())
df.info()

print("Missing values:")
print(df.isnull().sum())

# Clean Missing Values
df = df.dropna(subset=['cost_of_the_order'])

df['rating'] = pd.to_numeric(df['rating'], errors='coerce')
df['rating'] = df['rating'].fillna(df['rating'].mean())

# Remove duplicates
df = df.drop_duplicates()

# Fix Column Names
df.columns = df.columns.str.strip().str.lower().str.replace(" ", "_")

# Fix Text values
df['day_of_the_week'] = df['day_of_the_week'].str.strip().str.title()
df['restaurant_name'] = df['restaurant_name'].str.strip()

print(df['day_of_the_week'].unique())

# Remove invalid values
df = df[df['cost_of_the_order'] > 0]
df = df[df['delivery_time'] < 120]

# Detect outliers
q1 = df['cost_of_the_order'].quantile(0.25)
q3 = df['cost_of_the_order'].quantile(0.75)
iqr = q3 - q1

df = df[(df['cost_of_the_order'] >= q1 - 1.5 * iqr) &
        (df['cost_of_the_order'] <= q3 + 1.5 * iqr)]

# Export cleaned data
df.to_csv("foodhub_cleaned.csv", index=False)

print("Cleaned file saved successfully!")
print("Rows after cleaning:", len(df))