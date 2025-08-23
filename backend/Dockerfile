FROM python:3.11-slim AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

FROM python:3.11-slim
WORKDIR /app
RUN apt-get update && \
    apt-get install -y curl cron default-mysql-client procps && \
    rm -rf /var/lib/apt/lists/*
COPY --from=builder /usr/local/lib/python3.11 /usr/local/lib/python3.11
COPY --from=builder /usr/local/bin /usr/local/bin
RUN mkdir -p /app/backups
COPY cron-backup.sh /app/cron-backup.sh
RUN chmod +x /app/cron-backup.sh
COPY . .
RUN echo "0 3 * * * root /app/cron-backup.sh >> /var/log/cron.log 2>&1" > /etc/cron.d/backup-cron && \
    chmod 0644 /etc/cron.d/backup-cron && \
    touch /var/log/cron.log && \
    crontab /etc/cron.d/backup-cron
CMD ["sh", "-c", "cron && gunicorn -w 4 -b 0.0.0.0:5000 app:app"]