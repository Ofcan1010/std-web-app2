FROM python:3.11-slim AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

FROM python:3.11-slim
WORKDIR /app

# mysqldump için mysql client
RUN apt-get update \
 && apt-get install -y default-mysql-client \
 && rm -rf /var/lib/apt/lists/*

# Uygulama dosyaları
COPY . .

# Python bağımlılıkları (builder katmanından)
COPY --from=builder /usr/local/lib/python3.11 /usr/local/lib/python3.11
COPY --from=builder /usr/local/bin /usr/local/bin

# Uygulama
CMD ["gunicorn","-w","4","-b","0.0.0.0:5000","app:app"]