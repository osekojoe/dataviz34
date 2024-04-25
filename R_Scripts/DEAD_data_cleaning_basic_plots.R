# Set working directory
# No scientific notation
options(scipen = 999)
dir <- "~/Documents/MScDS/Visualisation/DEAD"
setwd(dir)

# Load libraries
library(ggplot2) # For plotting
library(ggsci) # For color palettes
library(RColorBrewer) # For color palettes
library(wesanderson) # For color palettes
library(dplyr) # For data manipulation
library(tidyr) # For data tidying
library(treemap) # For tree mapping
library(circular) # For circular plots
library(viridis) # For color palettes
library(ggraph) # For plotting graphs
library(igraph) # For graph manipulation
library(tidyverse) # For data manipulation


# Load the data
customers <- read.csv("customers.csv")
regions <- read.csv("regions.csv")
products_all <- read.csv("products.csv") %>%
  # Rename Product.Name to Products for consistency
    rename(Products = Product.Name) %>%
  # remove all the leading and trailing white spaces
  mutate(Products = trimws(Products))

# Print data to check if loaded correctly
print(head(customers))
print(head(regions))
print(head(products_all))
print(head(orders))

# Check file paths
print(list.files())

# Separate CartPrice column
orders <- read.csv("orders.csv") %>%
  separate(CartPrice, into = c("CartPriceGP", "CartPriceSP", "CartPriceCP"), sep = "; ") %>%
  mutate(across(starts_with("CartPrice"), ~as.numeric(gsub("[^0-9.]", "", .)))) %>%
  # Merge with regions data
  merge(regions, by = "Territory") %>%
  select(OrderID, OrderDate, DeliveryDate, CustomerID, Territory, Nation, Region,
         Regional.Manager, Area, Area.Manager, Products, Quantities, ProductPricesInCP, CartPriceInCP, CartPriceGP, CartPriceSP,
         CartPriceCP) %>%
  arrange(OrderID) %>%
  # Calculate TotalProducts
  mutate(TotalProducts = lengths(strsplit(Products, "; "))) %>%
  # Calculate TotalQuantities
  mutate(TotalQuantities = sapply(strsplit(Quantities, ", "), function(x) sum(as.integer(x))))

# We can now focus on the Products, Quantities and Price for each Product columns
quantities <- orders %>%
  separate_rows(Quantities,  sep = ",") %>%
  mutate(Quantities = as.integer(Quantities)) %>% # Convert to integer
  select(OrderID, Quantities) %>% # Add index within each group of unique OrderID
  group_by(OrderID) %>%
  mutate(index = row_number()) %>%
  arrange(OrderID)

# Check dimensions
dim(quantities)
Products <- orders %>%
  separate_rows(Products,  sep = ";") %>%
  # remove all the leading and trailing white spaces
  mutate(Products = trimws(Products)) %>%
  select(OrderID, Products) %>%
  group_by(OrderID) %>%
  mutate(index = row_number()) %>%
  arrange(OrderID)

price <- orders %>%
  separate_rows(ProductPricesInCP,  sep = ",") %>%
  mutate(ProductPricesInCP = as.numeric(gsub("[^0-9.]", "", ProductPricesInCP))) %>% # Convert to numeric
  select(OrderID, ProductPricesInCP) %>%
  group_by(OrderID) %>%
  mutate(index = row_number())%>%
  arrange(OrderID)

# merge the data frames that have equal dimensions (by index and OrderID)
price_quantities <- left_join(quantities,price, by = c("OrderID", "index"))

# Merge by index and OrderID
Prod_price_quant <- left_join(Products, price_quantities %>%
  select(-OrderID), by = c("OrderID", "index")) %>%
  select(-index) %>%
  # Merge with the products_all data frame
  left_join(products_all, by = "Products") %>%
    select(OrderID, Products, Type, Subtype, Quantities, ProductPricesInCP) %>%
    distinct()%>%
  arrange(OrderID)


# Add merged data to the orders data frame
merged_orders <- left_join(orders %>% select(-c(Products, Quantities, ProductPricesInCP)),
                           Prod_price_quant, by = "OrderID") %>%
  # mutate the share of each product in the order against total products in each order
    mutate(Name = "DEAD",
           share = Quantities / TotalQuantities,
           OrderDate = as.Date(OrderDate),
           Year = lubridate::year(OrderDate),
           Month = lubridate::month(OrderDate),
           # Convert the month numbers to month names
           Month = factor(Month, levels = 1:12, labels = month.abb),
           Day = lubridate::day(OrderDate),
           DeliveryDate = as.Date(DeliveryDate),
           DeliveryTimeDays = as.numeric(DeliveryDate - OrderDate)) %>%
    select(Name, OrderID, Year, Month, Day, OrderDate, DeliveryDate, DeliveryTimeDays, CustomerID, Territory, Nation, Region, Area,
             Products, Type, Subtype, Quantities, share, TotalProducts, TotalQuantities, ProductPricesInCP,
             CartPriceInCP, CartPriceGP, CartPriceSP, CartPriceCP) %>%
    arrange(OrderID)
# Export to CSV
write.csv(merged_orders, "merged_orders.csv")
# PRELIMINARY PLOTS

# Calculate region-wise order quantities
region_order_quantities <- merged_orders %>%
  group_by(Region) %>%
  summarise(total_orders = n_distinct(OrderID)) %>%
  arrange(desc(total_orders))

# Calculate region-wise order value
region_order_value <- merged_orders %>%
  group_by(Region) %>%
  summarise(total_order_value = sum(CartPriceInCP)) %>%
  arrange(desc(total_order_value))

# Define your own color palette with 15 colors
my_colors <- c("#1f77b4", "#ff7f0e", "#2ca02c", "#d62728", "#9467bd",
               "#8c564b", "#e377c2", "#7f7f7f", "#bcbd22", "#17becf",
               "#aec7e8", "#ffbb78", "#98df8a", "#ff9896", "#c5b0d5")
ggplot(merged_orders, aes(x = Region, fill = Region)) +
  geom_bar() +
  coord_flip() +
  scale_fill_manual(values = my_colors) +  # Use the manually defined colors
  geom_text(data = region_order_quantities, aes(label = paste0("", total_orders), y = total_orders),
            size = 3, hjust = -0.1) +
    labs(x = "Region", y = "Number of Orders", title = "Flow of Products Ordered by Region") +
    theme_bw()

# Calculate share of different products in each order
pal <- wes_palette("Zissou1", 10, type = "continuous") # https://github.com/karthik/wesanderson
treemap(merged_orders, index=c("Type", "Subtype"),
        vSize="share", type="index",
        # Show percentage of share
        vColor="share",
        fontsize.labels=c(13,10),                # size of labels. Give the size per level of aggregation: size for group, size for subgroup, sub-subgroups...
        fontcolor.labels=c("white", "Black"),    # Color of labels
        fontface.labels=c(2,1),                  # Font of labels: 1,2,3,4 for normal, bold, italic, bold-italic...
        bg.labels=c("transparent"),              # Background color of labels
        align.labels=list(
          c("center", "center"),
          c("center", "centre")),                                   # Where to place labels in the rectangle?
        overlap.labels=0.5,                      # number between 0 and 1 that determines the tolerance of the overlap between labels. 0 means that labels of lower levels are not printed if higher level labels overlap, 1  means that labels are always printed. In-between values, for instance the default value .5, means that lower level labels are printed if other labels do not overlap with more than .5  times their area size.
        inflate.labels=F,                        # If true, labels are bigger when rectangle is bigger.
        #palette.HCL.options=palette.HCL.options), # Options for the HCL palette
        # palete must be from wandersen
        palette="RdPu",                             # Color palette
        range=c(-20000,30000),           # this is shown in the legend
        mapping=c(-30000, 10000, 40000)) # Rd is mapped to -30k, Yl to 10k, and Gn to 40k

# Calculate demand for each product, type, or subtype over 5 years
demand_trend <- merged_orders %>%
  group_by(Region, Year, Type, Subtype) %>%
  summarise(total_quantity = sum(Quantities))

# Plot trend in demand for product, type, or subtype over 5 years
ggplot(demand_trend, aes(x = Year, y = total_quantity, size = total_quantity, color = Region), alpha = 0.6) +
  geom_point() +
  scale_size_continuous(range = c(1, 10), name = "Demand") +  # Added name argument to scale_size_continuous
  labs(x = "Year", y = "Demand", color = "Region") +  # Changed color legend title to "Region"
  theme_bw() +
  scale_color_manual(values = my_colors) +  # Fixed the function call to scale_color_manual
  theme(legend.position = "right")  # Adjusted legend position to be on the right

# Assuming merged_orders is your final merged data frame
# Make sure 'Year', 'Month', 'Products', and 'Quantities' columns are available

# Summarize the total quantities of each product per year
product_demand <- merged_orders %>%
  group_by(Region, Year, Type) %>%
  summarize(Total_Quantities = sum(Quantities))
# Create a circular plot
ggplot(product_demand, aes(x = Year, y = Total_Quantities, fill = Region)) +
  geom_bar(stat = "identity", width = 1, color = "black") +
  coord_polar(start = 0) +
  scale_fill_manual(values = my_colors) +
  theme_minimal() +
  facet_wrap(~Type) +
  theme(axis.text.x = element_text(angle = 0, hjust = 1)) +
  labs(title = "Trend of Product Demand Over Five Years",
       x = "Year",
       y = "Total Demand",
       fill = "Product")

# Calculate average delivery time per region
delivery_time <- merged_orders %>%
  group_by(Region, Year, Month) %>%
  summarize(Avg_Delivery_Time = mean(DeliveryTimeDays, na.rm = TRUE))
# Create the heatmap
ggplot(delivery_time, aes(x = Year, Month, fill = Avg_Delivery_Time)) +
  geom_tile(color="white") +
  scale_fill_gradientn(colors = pal) +
  theme_minimal() +
  theme(legend.position = "bottom") +
  labs(title = "Average Delivery Time per Region",
       x = NULL,
       y = NULL,
       fill = "Avg Delivery Time (Days)")+ 
  facet_wrap(~Region)

# Plotting the trend of product demand over five years
ggplot(product_demand, aes(x = Year, y = Total_Quantities, color = Region)) +
  geom_line() +
  geom_point() +
  facet_wrap(~Type, ncol = 4) +
  theme_minimal() +
  scale_color_manual(values = my_colors) +
  labs(title = "Trend of Product Demand Over Five Years",
       x = "Year",
       y = "Total Demand",
       color = "Region") + 
  # add borders to the facet_wrap
  theme(strip.background = element_rect(colour = "black", fill = "white"),
        strip.text = element_text(size = 8, face = "bold"),
        # add border around the plot
        panel.border = element_rect(colour = "black", fill = NA, size = 1))
        )


