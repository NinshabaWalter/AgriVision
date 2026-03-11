# Deployment Guide - Agricultural Intelligence Platform

This guide covers deployment options for the Agricultural Intelligence Platform across different environments.

## 🚀 Quick Start with Docker

### Prerequisites
- Docker and Docker Compose installed
- At least 4GB RAM and 20GB disk space
- Domain name (for production)

### Local Development
```bash
# Clone the repository
git clone <repository-url>
cd AgriculturalIntelligencePlatform

# Copy environment file
cp .env.example .env

# Edit .env with your API keys
nano .env

# Start all services
docker-compose up -d

# Check service status
docker-compose ps

# View logs
docker-compose logs -f backend
```

### Services will be available at:
- **Backend API**: http://localhost:8000
- **API Documentation**: http://localhost:8000/docs
- **Grafana Dashboard**: http://localhost:3000 (admin/admin)
- **Prometheus Metrics**: http://localhost:9090

## 🌐 Production Deployment

### AWS Deployment

#### 1. Infrastructure Setup
```bash
# Create VPC and subnets
aws ec2 create-vpc --cidr-block 10.0.0.0/16

# Create RDS PostgreSQL instance
aws rds create-db-instance \
  --db-instance-identifier agri-platform-db \
  --db-instance-class db.t3.micro \
  --engine postgres \
  --master-username agriuser \
  --master-user-password yourpassword \
  --allocated-storage 20

# Create ElastiCache Redis cluster
aws elasticache create-cache-cluster \
  --cache-cluster-id agri-platform-redis \
  --cache-node-type cache.t3.micro \
  --engine redis
```

#### 2. ECS Deployment
```bash
# Build and push Docker image
docker build -t your-account.dkr.ecr.region.amazonaws.com/agri-backend ./backend
docker push your-account.dkr.ecr.region.amazonaws.com/agri-backend

# Create ECS task definition
aws ecs register-task-definition --cli-input-json file://ecs-task-definition.json

# Create ECS service
aws ecs create-service \
  --cluster agri-platform \
  --service-name agri-backend \
  --task-definition agri-backend:1 \
  --desired-count 2
```

#### 3. Load Balancer Setup
```bash
# Create Application Load Balancer
aws elbv2 create-load-balancer \
  --name agri-platform-alb \
  --subnets subnet-12345 subnet-67890 \
  --security-groups sg-12345

# Create target group
aws elbv2 create-target-group \
  --name agri-backend-targets \
  --protocol HTTP \
  --port 8000 \
  --vpc-id vpc-12345
```

### Google Cloud Platform Deployment

#### 1. Setup GKE Cluster
```bash
# Create GKE cluster
gcloud container clusters create agri-platform \
  --zone us-central1-a \
  --num-nodes 3 \
  --machine-type e2-medium

# Get credentials
gcloud container clusters get-credentials agri-platform --zone us-central1-a
```

#### 2. Deploy with Kubernetes
```bash
# Apply Kubernetes manifests
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/secrets.yaml
kubectl apply -f k8s/postgres.yaml
kubectl apply -f k8s/redis.yaml
kubectl apply -f k8s/backend.yaml
kubectl apply -f k8s/ingress.yaml

# Check deployment status
kubectl get pods -n agri-platform
kubectl get services -n agri-platform
```

#### 3. Setup Cloud SQL
```bash
# Create Cloud SQL instance
gcloud sql instances create agri-platform-db \
  --database-version POSTGRES_13 \
  --tier db-f1-micro \
  --region us-central1

# Create database
gcloud sql databases create agricultural_platform \
  --instance agri-platform-db
```

## 📱 Mobile App Deployment

### Android Deployment

#### 1. Build Release APK
```bash
cd mobile

# Clean and get dependencies
flutter clean
flutter pub get

# Generate code
flutter packages pub run build_runner build

# Build release APK
flutter build apk --release --split-per-abi

# Build App Bundle for Play Store
flutter build appbundle --release
```

#### 2. Google Play Store
1. Create developer account
2. Upload app bundle to Play Console
3. Fill app information and screenshots
4. Submit for review

### iOS Deployment

#### 1. Build Release IPA
```bash
# Build for iOS
flutter build ios --release

# Open Xcode project
open ios/Runner.xcworkspace

# Archive and upload to App Store Connect
```

#### 2. App Store Connect
1. Create app in App Store Connect
2. Upload build using Xcode or Transporter
3. Fill app metadata
4. Submit for review

## 🔧 Configuration Management

### Environment Variables
```bash
# Production environment variables
export DATABASE_URL="postgresql://user:pass@prod-db:5432/agri_platform"
export REDIS_URL="redis://prod-redis:6379"
export SECRET_KEY="production-secret-key"
export OPENWEATHER_API_KEY="your-api-key"
export SENTRY_DSN="your-sentry-dsn"
```

### SSL Certificate Setup
```bash
# Using Let's Encrypt with Certbot
certbot --nginx -d api.agriplatform.com

# Or using AWS Certificate Manager
aws acm request-certificate \
  --domain-name api.agriplatform.com \
  --validation-method DNS
```

## 📊 Monitoring Setup

### Prometheus Configuration
```yaml
# prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'agri-backend'
    static_configs:
      - targets: ['backend:8000']
    metrics_path: '/metrics'
```

### Grafana Dashboards
```bash
# Import pre-built dashboards
curl -X POST \
  http://admin:admin@localhost:3000/api/dashboards/db \
  -H 'Content-Type: application/json' \
  -d @monitoring/grafana/dashboards/backend-metrics.json
```

### Log Aggregation with ELK
```yaml
# docker-compose.elk.yml
version: '3.8'
services:
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:7.15.0
    environment:
      - discovery.type=single-node
    ports:
      - "9200:9200"

  logstash:
    image: docker.elastic.co/logstash/logstash:7.15.0
    volumes:
      - ./elk/logstash.conf:/usr/share/logstash/pipeline/logstash.conf

  kibana:
    image: docker.elastic.co/kibana/kibana:7.15.0
    ports:
      - "5601:5601"
    depends_on:
      - elasticsearch
```

## 🔒 Security Hardening

### Backend Security
```bash
# Update system packages
apt update && apt upgrade -y

# Install fail2ban
apt install fail2ban -y

# Configure firewall
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw enable

# Setup SSL/TLS
certbot --nginx -d api.agriplatform.com
```

### Database Security
```sql
-- Create read-only user for analytics
CREATE USER analytics_user WITH PASSWORD 'secure_password';
GRANT SELECT ON ALL TABLES IN SCHEMA public TO analytics_user;

-- Enable row-level security
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
CREATE POLICY user_policy ON users FOR ALL TO app_user USING (id = current_user_id());
```

## 📈 Scaling Strategies

### Horizontal Scaling
```bash
# Scale backend services
docker-compose up -d --scale backend=3

# Kubernetes scaling
kubectl scale deployment backend --replicas=5 -n agri-platform
```

### Database Scaling
```sql
-- Setup read replicas
CREATE PUBLICATION agri_platform_pub FOR ALL TABLES;

-- On replica
CREATE SUBSCRIPTION agri_platform_sub 
CONNECTION 'host=master-db port=5432 user=replicator dbname=agricultural_platform' 
PUBLICATION agri_platform_pub;
```

### CDN Setup
```bash
# AWS CloudFront
aws cloudfront create-distribution \
  --distribution-config file://cloudfront-config.json

# Configure origin for API and static files
```

## 🚨 Disaster Recovery

### Backup Strategy
```bash
# Database backup
pg_dump -h localhost -U agri_user agricultural_platform > backup_$(date +%Y%m%d).sql

# Automated backup script
#!/bin/bash
BACKUP_DIR="/backups"
DATE=$(date +%Y%m%d_%H%M%S)
pg_dump -h $DB_HOST -U $DB_USER $DB_NAME | gzip > $BACKUP_DIR/backup_$DATE.sql.gz

# Upload to S3
aws s3 cp $BACKUP_DIR/backup_$DATE.sql.gz s3://agri-platform-backups/
```

### Recovery Procedures
```bash
# Restore from backup
gunzip -c backup_20240101_120000.sql.gz | psql -h localhost -U agri_user agricultural_platform

# Point-in-time recovery
pg_basebackup -h master-db -D /var/lib/postgresql/recovery -U replicator -v -P -W
```

## 📋 Health Checks

### Application Health
```python
# Health check endpoint
@app.get("/health")
async def health_check():
    return {
        "status": "healthy",
        "timestamp": datetime.utcnow(),
        "version": "1.0.0",
        "database": await check_database(),
        "redis": await check_redis(),
        "external_apis": await check_external_apis()
    }
```

### Infrastructure Monitoring
```bash
# Setup monitoring alerts
curl -X POST http://localhost:9093/api/v1/alerts \
  -H 'Content-Type: application/json' \
  -d @alerts/high-cpu-usage.json
```

## 🔄 CI/CD Pipeline

### GitHub Actions
```yaml
# .github/workflows/deploy.yml
name: Deploy to Production

on:
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Run tests
        run: |
          cd backend
          python -m pytest tests/

  deploy:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - name: Deploy to AWS
        run: |
          aws ecs update-service \
            --cluster agri-platform \
            --service agri-backend \
            --force-new-deployment
```

## 📞 Support & Troubleshooting

### Common Issues

#### Database Connection Issues
```bash
# Check database connectivity
pg_isready -h localhost -p 5432

# Check connection pool
SELECT count(*) FROM pg_stat_activity WHERE state = 'active';
```

#### High Memory Usage
```bash
# Monitor memory usage
docker stats

# Optimize PostgreSQL
# postgresql.conf
shared_buffers = 256MB
effective_cache_size = 1GB
work_mem = 4MB
```

#### API Performance Issues
```bash
# Check API response times
curl -w "@curl-format.txt" -o /dev/null -s http://localhost:8000/api/v1/health

# Monitor with APM
pip install elastic-apm
```

### Getting Help
- **Documentation**: Check `/docs` endpoint
- **Logs**: `docker-compose logs -f service-name`
- **Metrics**: Grafana dashboard at port 3000
- **Support**: Create issue in repository

---

**Deployment completed! Your Agricultural Intelligence Platform is ready to serve farmers across East Africa! 🌾🚀**