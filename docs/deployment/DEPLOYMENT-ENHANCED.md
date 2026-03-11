# AgriVision Enhanced API Gateway - Deployment Guide

This guide covers deploying the AgriVision Enhanced API Gateway to production environments with proper security, monitoring, and scalability considerations.

## 🚀 Quick Deployment

### Local Development
```bash
# 1. Clone and setup
git clone <repository-url>
cd AgriVision

# 2. Run setup script
./start-enhanced-api.sh

# 3. Start development server
npm run dev
```

### Production Deployment
```bash
# 1. Install dependencies
npm ci --production

# 2. Configure environment
cp .env.enhanced .env
# Edit .env with production values

# 3. Start production server
NODE_ENV=production npm start
```

## 🐳 Docker Deployment

### Build Docker Image
```bash
# Build the image
docker build -t agrivision-api:latest .

# Run container
docker run -d \
  --name agrivision-api \
  -p 3000:3000 \
  --env-file .env \
  agrivision-api:latest
```

### Docker Compose
```yaml
version: '3.8'
services:
  api:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
    env_file:
      - .env
    volumes:
      - ./logs:/app/logs
    restart: unless-stopped
    
  redis:
    image: redis:alpine
    ports:
      - "6379:6379"
    restart: unless-stopped
    
  postgres:
    image: postgres:13
    environment:
      POSTGRES_DB: agrivision
      POSTGRES_USER: agrivision
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    restart: unless-stopped

volumes:
  postgres_data:
```

## ☁️ Cloud Deployment

### AWS Deployment

#### Using AWS ECS
```bash
# 1. Build and push to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-east-1.amazonaws.com
docker build -t agrivision-api .
docker tag agrivision-api:latest <account-id>.dkr.ecr.us-east-1.amazonaws.com/agrivision-api:latest
docker push <account-id>.dkr.ecr.us-east-1.amazonaws.com/agrivision-api:latest

# 2. Create ECS task definition
# 3. Create ECS service
# 4. Configure load balancer
```

#### Using AWS Lambda (Serverless)
```bash
# Install serverless framework
npm install -g serverless

# Deploy
serverless deploy --stage production
```

### Google Cloud Platform

#### Using Cloud Run
```bash
# Build and deploy
gcloud builds submit --tag gcr.io/PROJECT-ID/agrivision-api
gcloud run deploy --image gcr.io/PROJECT-ID/agrivision-api --platform managed
```

### Microsoft Azure

#### Using Container Instances
```bash
# Create resource group
az group create --name agrivision-rg --location eastus

# Deploy container
az container create \
  --resource-group agrivision-rg \
  --name agrivision-api \
  --image agrivision-api:latest \
  --ports 3000 \
  --environment-variables NODE_ENV=production
```

### Heroku Deployment
```bash
# Install Heroku CLI and login
heroku login

# Create app
heroku create agrivision-api

# Set environment variables
heroku config:set NODE_ENV=production
heroku config:set JWT_SECRET=your-secret-key
# ... set other environment variables

# Deploy
git push heroku main
```

## 🔧 Production Configuration

### Environment Variables
```bash
# Server Configuration
NODE_ENV=production
PORT=3000
JWT_SECRET=your-super-secure-jwt-secret-key-at-least-32-characters-long

# Database
DATABASE_URL=postgresql://username:password@host:5432/agrivision

# External Services
TWILIO_ACCOUNT_SID=your_production_twilio_sid
TWILIO_AUTH_TOKEN=your_production_twilio_token
MPESA_ENV=production
MPESA_CONSUMER_KEY=your_production_mpesa_key
MPESA_CONSUMER_SECRET=your_production_mpesa_secret

# Security
ALLOWED_ORIGINS=https://agrivision.com,https://app.agrivision.com
RATE_LIMIT_MAX_REQUESTS=1000
AI_RATE_LIMIT_MAX_REQUESTS=50

# Monitoring
SENTRY_DSN=your_sentry_dsn
LOG_LEVEL=info

# Features
ENABLE_AI_FEATURES=true
ENABLE_PAYMENT_FEATURES=true
ENABLE_COMMUNITY_FEATURES=true
ENABLE_ANALYTICS=true
```

### SSL/TLS Configuration
```nginx
# Nginx configuration
server {
    listen 443 ssl http2;
    server_name api.agrivision.com;
    
    ssl_certificate /path/to/certificate.crt;
    ssl_certificate_key /path/to/private.key;
    
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
```

## 📊 Monitoring & Logging

### Application Monitoring
```javascript
// Add to your production environment
const Sentry = require('@sentry/node');

Sentry.init({
  dsn: process.env.SENTRY_DSN,
  environment: process.env.NODE_ENV
});
```

### Log Management
```bash
# Using PM2 for process management
npm install -g pm2

# Start with PM2
pm2 start api-gateway-enhanced.js --name agrivision-api

# Monitor logs
pm2 logs agrivision-api

# Setup log rotation
pm2 install pm2-logrotate
```

### Health Checks
```bash
# Setup health check monitoring
curl -f http://localhost:3000/health || exit 1

# Advanced health check with timeout
timeout 10s curl -f http://localhost:3000/health || exit 1
```

## 🔒 Security Hardening

### Firewall Configuration
```bash
# UFW (Ubuntu)
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw deny 3000/tcp  # Don't expose Node.js port directly
sudo ufw enable
```

### Security Headers
```javascript
// Already included in enhanced API gateway
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      scriptSrc: ["'self'"],
      imgSrc: ["'self'", "data:", "https:"],
    },
  },
  hsts: {
    maxAge: 31536000,
    includeSubDomains: true,
    preload: true
  }
}));
```

### API Key Management
```bash
# Use environment variables, never hardcode
export TWILIO_AUTH_TOKEN="your_token_here"

# Use secrets management services
# AWS Secrets Manager, Azure Key Vault, etc.
```

## 📈 Performance Optimization

### Caching Strategy
```javascript
// Redis caching for production
const redis = require('redis');
const client = redis.createClient(process.env.REDIS_URL);

// Cache weather data
const cacheWeatherData = async (key, data, ttl = 300) => {
  await client.setex(key, ttl, JSON.stringify(data));
};
```

### Database Optimization
```sql
-- Create indexes for frequently queried fields
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_transactions_user_id ON transactions(user_id);
CREATE INDEX idx_posts_created_at ON posts(created_at DESC);
```

### Load Balancing
```nginx
# Nginx load balancer
upstream agrivision_api {
    server 127.0.0.1:3000;
    server 127.0.0.1:3001;
    server 127.0.0.1:3002;
}

server {
    listen 80;
    server_name api.agrivision.com;
    
    location / {
        proxy_pass http://agrivision_api;
    }
}
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
      - uses: actions/setup-node@v2
        with:
          node-version: '16'
      - run: npm ci
      - run: npm test
      
  deploy:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Deploy to production
        run: |
          # Your deployment script here
          ./deploy.sh
```

### Deployment Script
```bash
#!/bin/bash
# deploy.sh

set -e

echo "Starting deployment..."

# Pull latest code
git pull origin main

# Install dependencies
npm ci --production

# Run database migrations (if applicable)
npm run migrate

# Restart application
pm2 restart agrivision-api

# Run health check
sleep 10
curl -f http://localhost:3000/health

echo "Deployment completed successfully!"
```

## 🚨 Backup & Recovery

### Database Backup
```bash
# PostgreSQL backup
pg_dump -h localhost -U agrivision agrivision > backup_$(date +%Y%m%d_%H%M%S).sql

# Automated backup script
#!/bin/bash
BACKUP_DIR="/backups"
DATE=$(date +%Y%m%d_%H%M%S)
pg_dump -h localhost -U agrivision agrivision | gzip > $BACKUP_DIR/agrivision_$DATE.sql.gz

# Keep only last 7 days of backups
find $BACKUP_DIR -name "agrivision_*.sql.gz" -mtime +7 -delete
```

### File Backup
```bash
# Backup logs and uploads
tar -czf backup_files_$(date +%Y%m%d).tar.gz logs/ uploads/

# Sync to cloud storage
aws s3 sync ./backups/ s3://agrivision-backups/
```

## 📋 Production Checklist

### Pre-deployment
- [ ] All environment variables configured
- [ ] SSL certificates installed
- [ ] Database migrations run
- [ ] External service API keys tested
- [ ] Security headers configured
- [ ] Rate limiting configured
- [ ] Monitoring setup
- [ ] Backup strategy implemented

### Post-deployment
- [ ] Health checks passing
- [ ] All endpoints responding
- [ ] Logs being generated
- [ ] Monitoring alerts configured
- [ ] Performance metrics baseline established
- [ ] Security scan completed
- [ ] Load testing performed

### Ongoing Maintenance
- [ ] Regular security updates
- [ ] Log rotation configured
- [ ] Database maintenance scheduled
- [ ] Backup verification
- [ ] Performance monitoring
- [ ] Cost optimization review

## 🆘 Troubleshooting

### Common Issues

#### High Memory Usage
```bash
# Check memory usage
free -h
ps aux --sort=-%mem | head

# Optimize Node.js memory
node --max-old-space-size=2048 api-gateway-enhanced.js
```

#### Database Connection Issues
```bash
# Check database connectivity
pg_isready -h localhost -p 5432

# Check connection pool
# Monitor active connections in your application
```

#### Rate Limiting Issues
```bash
# Check rate limit logs
grep "rate limit" logs/combined.log

# Adjust rate limits if needed
export RATE_LIMIT_MAX_REQUESTS=2000
```

### Log Analysis
```bash
# Check error logs
tail -f logs/error.log

# Search for specific errors
grep "ERROR" logs/combined.log | tail -20

# Monitor request patterns
grep "POST /api" logs/combined.log | wc -l
```

## 📞 Support

For deployment support:
1. Check the troubleshooting section
2. Review application logs
3. Verify environment configuration
4. Test individual services
5. Contact support team

---

**Ready for production deployment!** 🚀