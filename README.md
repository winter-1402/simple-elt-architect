# Hướng Dẫn Chạy Pentaho ETL - Local & Docker
## 📋 Mục Lục
1. [Yêu Cầu Hệ Thống](#yêu-cầu-hệ-thống)
2. [Cách 1: Chạy Pentaho Trên Máy Local](#cách-1-chạy-pentaho-trên-máy-local)
3. [Cách 2: Chạy Pentaho Trong Docker](#cách-2-chạy-pentaho-trong-docker)
4. [Chạy ETL Job (etl.kjb)](#chạy-etl-job)
5. [Troubleshooting](#troubleshooting)
---
## 🖥️ Yêu Cầu Hệ Thống
### Local
- **Java 11+**: [Download JDK 11](https://www.oracle.com/java/technologies/javase/jdk11-archive-downloads.html)
- **PostgreSQL 16+**: [Download PostgreSQL](https://www.postgresql.org/download/)
- **RAM**: ≥ 4GB

### Docker
- **Docker**: [Download Docker Desktop](https://www.docker.com/products/docker-desktop)
- **Docker Compose**: Included với Docker Desktop

---

## 🚀 Cách 1: Chạy Pentaho Trên Máy Local
### Bước 1: Tải Pentaho Kettle Community Edition
```bash
# Download từ SourceForge
https://sourceforge.net/projects/pentaho/files/Pentaho%209.0/client-tools/
# Chọn file: pdi-ce-9.0.0.0-423.zip
```
### Bước 2: Giải nén

```bash
# Windows
# Giải nén vào C:\Pentaho hoặc nơi bạn muốn
# Cấu trúc sẽ là: C:\Pentaho\data-integr-9.0.0.0-423\

# Linux/Mac
unzip pdi-ce-9.0.0.0-423.zip
mv data-integr-9.0.0.0-423 ~/Pentaho
```
### Bước 3: Cấu Hình PostgreSQL
```sql
-- Kết nối tới PostgreSQL
psql -U postgres
-- Tạo database
CREATE DATABASE dw_db;
CREATE USER dw_user WITH PASSWORD 'dw_password';
ALTER ROLE dw_user WITH CREATEDB;
GRANT ALL PRIVILEGES ON DATABASE dw_db TO dw_user;
-- Import dữ liệu (chạy script SQL)
psql -U dw_user -d dw_db -f create_tables_and_load_data.sql
```

### Bước 4: Chạy Pentaho UI (Optional)

```bash
# Windows
cd C:\Pentaho\data-integr-9.0.0.0-423
spoon.bat
# Linux/Mac
./spoon.sh
```

**Spoon** là giao diện GUI để tạo/chỉnh sửa ETL jobs.

### Hoặc chạy ETL Job từ Command Line

```bash
# Windows
cd C:\Pentaho\data-integr-9.0.0.0-423
kitchen.bat -file= {/path/to/etl.kjb} ^
  -param:DB_HOST=localhost ^
  -param:DB_PORT=5432 ^
  -param:DB_NAME=dw_db ^
  -param:DB_USER=dw_user ^
  -param:DB_PASSWORD=dw_password

# Linux/Mac
cd ~/Pentaho/data-integr-9.0.0.0-423
./kitchen.sh -file=/path/to/etl.kjb \
  -param:DB_HOST=localhost \
  -param:DB_PORT=5432 \
  -param:DB_NAME=dw_db \
  -param:DB_USER=dw_user \
  -param:DB_PASSWORD=dw_password
```

---

## 🐳 Cách 2: Chạy Pentaho Trong Docker
### Bước 1: Kiểm Tra Docker
```bash
docker --version
docker compose --version
```

### Bước 2: Chạy PostgreSQL Container

```bash
cd E:\hc\DW & DSS\btl\etl
docker compose up -d postgres
```

Chờ PostgreSQL khởi động (10-15 giây).
### Bước 3: Kiểm Tra Kết Nối
```bash
# Kiểm tra PostgreSQL sẵn sàng
docker compose ps
# Xem logs
docker compose logs postgres
```
### Bước 4: Chạy ETL Job trong Docker
```bash
# Cách 1: Chạy một lần (Khuyến nghị)
docker compose run --rm pentaho-job
# Cách 2: Chạy trong background
docker compose up -d pentaho-job
# Xem logs của job
docker logs btl-pentaho-job
# Xem logs real-time
docker logs -f btl-pentaho-job
```
### Dừng Containers
```bash
# Dừng tất cả
docker compose down
# Dừng và xóa dữ liệu
docker compose down -v
```
---

## 📊 Chạy ETL Job

### Cấu Trúc File

```
etl/
├── docker-compose.yaml        # Docker configuration
├── create_tables_and_load_data.sql
├── etl.kjb                    # ETL Job chính
├── create dim data input.ktr
├── create fact data input.ktr
└── README.md
```

### ETL Job Flow

```
etl.kjb chứa:
├── create dim data input.ktr  (Tạo Dimension Tables)
└── create fact data input.ktr (Tạo Fact Tables)
```

### Chạy Từng Transformation (Optional)

```bash
# Chạy riêng dimension input
C:\Pentaho\data-integr-9.0.0.0-423\pan.bat ^
  -file= /path/to/create dim data input.ktr ^
  -param:DB_HOST=localhost

# Chạy riêng fact input
C:\Pentaho\data-integr-9.0.0.0-423\pan.bat ^
  -file=/path/to/create fact data input.ktr ^
  -param:DB_HOST=localhost
```
---

## ✅ Xác Thực Thành Công

### 1. Kiểm Tra Job Chạy Thành Công

```bash
# Xem logs
docker logs btl-pentaho-job

# Tìm "Execution finished" hoặc "Job finished"
```

### 2. Kiểm Tra Dữ Liệu Đã Load

```bash
# Kết nối PostgreSQL
psql -U dw_user -d dw_db

# Chạy query
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public';

# Kiểm tra số dòng
SELECT COUNT(*) FROM dim_category;
SELECT COUNT(*) FROM fact_price;
```

### 3. Kết Quả Mong Đợi

```
dim_category      ✓
dim_currency      ✓
dim_delivery      ✓
dim_image         ✓
dim_product       ✓
dim_seller        ✓
dim_video         ✓
fact_delivery_and_offers  ✓
fact_price        ✓
fact_rating       ✓
```

---

## 📝 NOTES

1. **Local vs Docker**: 
   - Local nhanh hơn, không cần download image
   - Docker dễ share, không phụ thuộc máy local

2. **Environment Variables**:
   - PostgreSQL mặc định: `dw_user:dw_password@localhost:5432/dw_db`
   - Thay đổi trong `docker-compose.yaml` hoặc ETL parameters

3. **Backup Dữ Liệu**:
   ```bash
   pg_dump -U dw_user dw_db > backup.sql
   ```

4. **Restart ETL**:
   ```bash
   # Xóa dữ liệu cũ
   docker compose down -v
   
   # Chạy lại
   docker compose up pentaho-job
   ```
---

**Cập nhật lần cuối**: April 22, 2026

