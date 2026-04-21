-- PostgreSQL Script for Data Warehouse
-- Create tables and load data from CSV files
-- Make sure to adjust the path to your CSV files accordingly

-- ============================================
-- DROP EXISTING TABLES (Optional - Comment out if you want to preserve existing data)
-- ============================================
DROP TABLE IF EXISTS fact_rating CASCADE;
DROP TABLE IF EXISTS fact_price CASCADE;
DROP TABLE IF EXISTS fact_delivery_and_offers CASCADE;
DROP TABLE IF EXISTS dim_product CASCADE;
DROP TABLE IF EXISTS dim_video CASCADE;
DROP TABLE IF EXISTS dim_image CASCADE;
DROP TABLE IF EXISTS dim_seller CASCADE;
DROP TABLE IF EXISTS dim_delivery CASCADE;
DROP TABLE IF EXISTS dim_currency CASCADE;
DROP TABLE IF EXISTS dim_category CASCADE;

-- ============================================
-- CREATE DIMENSION TABLES
-- ============================================

-- 1. Dimension Category
CREATE TABLE dim_category (
    category_index INT PRIMARY KEY,
    category VARCHAR(255) NOT NULL
);

-- 2. Dimension Currency
CREATE TABLE dim_currency (
    currency_index INT PRIMARY KEY,
    currency VARCHAR(10) NOT NULL
);

-- 3. Dimension Delivery
CREATE TABLE dim_delivery (
    delivery_index INT PRIMARY KEY,
    delivery_options TEXT
);

-- 4. Dimension Image
CREATE TABLE dim_image (
    image_index INT PRIMARY KEY,
    images TEXT
);

-- 5. Dimension Video
CREATE TABLE dim_video (
    video_index INT PRIMARY KEY,
    videos TEXT
);

-- 6. Dimension Seller
CREATE TABLE dim_seller (
    seller_index INT PRIMARY KEY,
    seller_name TEXT,
    seller_information TEXT
);

-- 7. Dimension Product
CREATE TABLE dim_product (
    product_index INT PRIMARY KEY,
    product_id BIGINT,
    image_index INT REFERENCES dim_image(image_index),
    video_index INT REFERENCES dim_video(video_index),
    title VARCHAR(255),
    product_description TEXT,
    product_specifications TEXT,
    product_details TEXT,
    sizes TEXT,
    breadcrumbs TEXT
);

-- ============================================
-- CREATE FACT TABLES
-- ============================================

-- 8. Fact Delivery and Offers
CREATE TABLE fact_delivery_and_offers (
    product_index INT REFERENCES dim_product(product_index),
    category_index INT REFERENCES dim_category(category_index),
    delivery_options TEXT,
    best_offer TEXT,
    more_offers TEXT,
    PRIMARY KEY (product_index, category_index)
);

-- 9. Fact Price
CREATE TABLE fact_price (
    product_index INT REFERENCES dim_product(product_index),
    category_index INT REFERENCES dim_category(category_index),
    seller_index INT REFERENCES dim_seller(seller_index),
    currency_index INT REFERENCES dim_currency(currency_index),
    initial_price INT,
    discount INT,
    final_price INT,
    apply_discount BOOLEAN,
    PRIMARY KEY (product_index, category_index, seller_index)
);

-- 10. Fact Rating
CREATE TABLE fact_rating (
    product_index INT REFERENCES dim_product(product_index),
    category_index INT REFERENCES dim_category(category_index),
    rating DECIMAL(3,1),
    ratings_count INT,
    star_1 INT,
    star_2 INT,
    star_3 INT,
    star_4 INT,
    star_5 INT,
    what_customers_said TEXT,
    PRIMARY KEY (product_index, category_index)
);
