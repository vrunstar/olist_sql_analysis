-- ============================================
-- Olist SQL Analysis
-- File: create_tables.sql
-- Description: Schema creation for all 5 tables
-- ============================================

CREATE DATABASE IF NOT EXISTS olist;
USE olist;

-- 1. Categories
CREATE TABLE IF NOT EXISTS categories (
    product_category_name         VARCHAR(100),
    product_category_name_english VARCHAR(100)
);

-- 2. Products
CREATE TABLE IF NOT EXISTS products (
    product_id                  VARCHAR(50),
    product_category_name       VARCHAR(100),
    product_name_length         INT,
    product_description_length  INT,
    product_photos_qty          INT,
    product_weight_g            INT,
    product_length_cm           INT,
    product_height_cm           INT,
    product_width_cm            INT
);

-- 3. Customers
CREATE TABLE IF NOT EXISTS customers (
    customer_id              VARCHAR(50),
    customer_unique_id       VARCHAR(50),
    customer_zip_code_prefix INT,
    customer_city            VARCHAR(100),
    customer_state           VARCHAR(10)
);

-- 4. Orders
CREATE TABLE IF NOT EXISTS orders (
    order_id                        VARCHAR(50),
    customer_id                     VARCHAR(50),
    order_status                    VARCHAR(20),
    order_purchase_timestamp        DATETIME,
    order_approved_at               DATETIME,
    order_delivered_carrier_date    DATETIME,
    order_delivered_customer_date   DATETIME,
    order_estimated_delivery_date   DATETIME
);

-- 5. Order Items
CREATE TABLE IF NOT EXISTS order_items (
    order_id             VARCHAR(50),
    order_item_id        INT,
    product_id           VARCHAR(50),
    seller_id            VARCHAR(50),
    shipping_limit_date  DATETIME,
    price                DECIMAL(10,2),
    freight_value        DECIMAL(10,2)
);