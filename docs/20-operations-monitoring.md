# Chapter 20: Operations and Monitoring

**Managing Your Production Infrastructure**

---

## Learning Objectives

By the end of this chapter, you'll be able to:
- ✅ Monitor system health and performance
- ✅ Manage application logs effectively
- ✅ Perform database backups and restores
- ✅ Update applications and infrastructure
- ✅ Monitor disk space and resources
- ✅ Handle SSL certificate renewal
- ✅ Troubleshoot production issues
- ✅ Implement monitoring best practices
- ✅ Plan for scaling and growth

**Time Required:** 60-90 minutes

**Prerequisites:**
- All infrastructure deployed (Chapters 16-17)
- Applications running (Chapters 18-19)
- System working end-to-end

---

## Production Infrastructure Overview

### What You've Built

**Your complete stack:**
```
Internet
   ↓
DNS Resolution
   ↓
Server (45.55.209.47)
   ├─ UFW Firewall (ports 80, 443, SSH)
   ├─ Fail2Ban (intrusion prevention)
   ├─ Docker Engine
   │   ├─ Caddy (reverse proxy, HTTPS)
   │   ├─ PostgreSQL (database)
   │   ├─ pgAdmin (database management)
   │   ├─ Static Site (Nginx)
   │   └─ Backend API (Node.js)
   └─ System monitoring and updates
```

**Now we maintain it!**

---

## System Monitoring

### Check Overall System Health

**Create health check script:**
```bash
nano ~/check-system.sh
```

**Add content:**
```bash
#!/bin/bash

echo "========================================="
echo "System Health Check"
echo "========================================="
echo "Date: $(date)"
echo ""

# System uptime
echo "=== System Uptime ==="
uptime
echo ""

# Disk usage
echo "=== Disk Usage ==="
df -h / | tail -n 1
echo ""

# Memory usage
echo "=== Memory Usage ==="
free -h | grep -E "Mem|Swap"
echo ""

# Docker status
echo "=== Docker Containers ==="
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
echo ""

# Docker resource usage
echo "=== Container Resources ==="
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}"
echo ""

# Check services responding
echo "=== Service Health ==="
echo -n "Caddy (HTTPS): "
curl -s -o /dev/null -w "%{http_code}" https://www.mywebclass.org/ --max-time 5 && echo " ✓" || echo " ✗"

echo -n "Backend API: "
curl -s -o /dev/null -w "%{http_code}" https://api.mywebclass.org/health --max-time 5 && echo " ✓" || echo " ✗"

echo -n "pgAdmin: "
curl -s -o /dev/null -w "%{http_code}" https://db.mywebclass.org/ --max-time 5 && echo " ✓" || echo " ✗"

echo ""
echo "========================================="
```

---

**Make executable:**
```bash
chmod +x ~/check-system.sh
```

**Run it:**
```bash
~/check-system.sh
```

---

**Example output:**
```
=========================================
System Health Check
=========================================
Date: Tue Nov 12 17:00:00 UTC 2024

=== System Uptime ===
 17:00:00 up 5 days,  3:15,  1 user,  load average: 0.15, 0.20, 0.18

=== Disk Usage ===
/dev/vda1        50G   12G   36G  25% /

=== Memory Usage ===
              total        used        free      shared  buff/cache   available
Mem:          3.8Gi       1.2Gi       1.5Gi        15Mi       1.1Gi       2.4Gi
Swap:            0B          0B          0B

=== Docker Containers ===
NAMES        STATUS              PORTS
backend      Up 2 days          3000/tcp
static-site  Up 2 days          80/tcp
pgadmin      Up 5 days          80/tcp
caddy        Up 5 days          0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp
postgres     Up 5 days          5432/tcp

=== Container Resources ===
NAME         CPU %   MEM USAGE
backend      0.15%   75.2MiB / 3.84GiB
static-site  0.01%   5.2MiB / 3.84GiB
pgadmin      0.08%   125MiB / 3.84GiB
caddy        0.05%   12.5MiB / 3.84GiB
postgres     0.12%   45.2MiB / 3.84GiB

=== Service Health ===
Caddy (HTTPS): 200 ✓
Backend API: 200 ✓
pgAdmin: 200 ✓

=========================================
```

**All healthy! ✓**

---

### Monitor Disk Space

**Check disk usage:**
```bash
df -h
```

**Watch for:**
```
Filesystem      Size  Used Avail Use% Mounted on
/dev/vda1        50G   12G   36G  25% /
```

**If Use% > 80%, take action:**
- Clean Docker images
- Clean logs
- Expand disk

---

**Check Docker disk usage:**
```bash
docker system df
```

**Shows:**
```
TYPE            TOTAL     ACTIVE    SIZE      RECLAIMABLE
Images          8         5         2.5GB     800MB (32%)
Containers      5         5         150MB     0B (0%)
Local Volumes   4         4         1.2GB     0B (0%)
Build Cache     15        0         450MB     450MB (100%)
```

---

**Clean up unused Docker resources:**
```bash
# Remove stopped containers
docker container prune -f

# Remove unused images
docker image prune -a -f

# Remove build cache
docker builder prune -f

# Or all at once
docker system prune -a --volumes -f
```

**⚠️ Warning:** `--volumes` removes unused volumes (data loss possible!)

**Safe cleanup (no volumes):**
```bash
docker system prune -a -f
```

---

### Monitor Memory

**Check memory usage:**
```bash
free -h
```

**Output:**
```
              total        used        free      shared  buff/cache   available
Mem:          3.8Gi       1.2Gi       1.5Gi        15Mi       1.1Gi       2.4Gi
Swap:            0B          0B          0B
```

**Watch "available" column - should stay > 500MB.**

---

**If memory low, check what's using it:**
```bash
docker stats --no-stream
```

**Or:**
```bash
ps aux --sort=-%mem | head -10
```

---

### Monitor CPU

**Check load average:**
```bash
uptime
```

**Output:**
```
17:00:00 up 5 days,  3:15,  1 user,  load average: 0.15, 0.20, 0.18
```

**Load average explained:**
- First number: 1 minute average
- Second: 5 minute average
- Third: 15 minute average

**For 1 CPU core:**
- < 1.0 = Good
- 1.0-2.0 = Moderate
- > 2.0 = High load

**For 2 CPU cores, multiply by 2, etc.**

---

**Check top processes:**
```bash
top
```

**Press:**
- `Shift+P` - Sort by CPU
- `Shift+M` - Sort by memory
- `q` - Quit

---

## Log Management

### View Docker Logs

**View all infrastructure logs:**
```bash
cd ~/mywebclass_hosting/infrastructure
docker compose logs --tail=100
```

---

**View specific service:**
```bash
docker compose logs -f caddy
docker compose logs -f postgres
docker compose logs -f pgadmin
```

---

**View application logs:**
```bash
cd ~/mywebclass_hosting/projects/backend
docker compose logs -f
```

---

**View with timestamps:**
```bash
docker compose logs -t --tail=100
```

---

### Search Logs

**Search for errors:**
```bash
docker compose logs | grep -i error
```

**Search for specific status code:**
```bash
docker compose logs caddy | grep "502"
```

**Search by date:**
```bash
docker compose logs --since "2024-11-12" --until "2024-11-13"
```

**Last hour:**
```bash
docker compose logs --since 1h
```

---

### Log Rotation

**Docker logs can grow large!**

**Check log sizes:**
```bash
sudo du -sh /var/lib/docker/containers/*/*-json.log | sort -h | tail -10
```

---

**Configure log rotation:**
```bash
sudo nano /etc/docker/daemon.json
```

**Add:**
```json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
```

**Restart Docker:**
```bash
sudo systemctl restart docker
cd ~/mywebclass_hosting/infrastructure
docker compose up -d
cd ~/mywebclass_hosting/projects/backend
docker compose up -d
cd ~/mywebclass_hosting/projects/static-site
docker compose up -d
```

**Now logs limited to 3 files × 10MB = 30MB max per container.**

---

### System Logs

**View system logs:**
```bash
sudo journalctl -u docker -n 100
```

**Follow system logs:**
```bash
sudo journalctl -u docker -f
```

**Check for errors:**
```bash
sudo journalctl -p err -n 50
```

---

## Database Backups

### Manual Backup

**Backup PostgreSQL database:**
```bash
cd ~/mywebclass_hosting/infrastructure

# Create backups directory
mkdir -p ~/backups

# Dump database
docker compose exec -T postgres pg_dump -U dbadmin mywebclass > ~/backups/mywebclass_$(date +%Y%m%d_%H%M%S).sql
```

**Creates timestamped backup:**
```
~/backups/mywebclass_20241112_170000.sql
```

---

**Verify backup:**
```bash
ls -lh ~/backups/
```

**Check file size (should be > 0):**
```
-rw-rw-r-- 1 john john 2.5K Nov 12 17:00 mywebclass_20241112_170000.sql
```

---

**View backup content:**
```bash
head -20 ~/backups/mywebclass_20241112_170000.sql
```

**Should see SQL statements:**
```sql
--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
...
```

---

### Automated Backups

**Create backup script:**
```bash
nano ~/backup-database.sh
```

**Add:**
```bash
#!/bin/bash

# Configuration
BACKUP_DIR=~/backups
RETENTION_DAYS=7
DATE=$(date +%Y%m%d_%H%M%S)

# Create backup directory
mkdir -p $BACKUP_DIR

# Backup database
echo "Starting database backup..."
cd ~/mywebclass_hosting/infrastructure
docker compose exec -T postgres pg_dump -U dbadmin mywebclass > $BACKUP_DIR/mywebclass_$DATE.sql

# Check if backup successful
if [ $? -eq 0 ]; then
    echo "Backup completed: $BACKUP_DIR/mywebclass_$DATE.sql"
    
    # Compress backup
    gzip $BACKUP_DIR/mywebclass_$DATE.sql
    echo "Backup compressed: $BACKUP_DIR/mywebclass_$DATE.sql.gz"
    
    # Delete backups older than retention period
    find $BACKUP_DIR -name "mywebclass_*.sql.gz" -mtime +$RETENTION_DAYS -delete
    echo "Old backups deleted (older than $RETENTION_DAYS days)"
    
    # List current backups
    echo "Current backups:"
    ls -lh $BACKUP_DIR/mywebclass_*.sql.gz
else
    echo "Backup failed!"
    exit 1
fi
```

---

**Make executable:**
```bash
chmod +x ~/backup-database.sh
```

**Test it:**
```bash
~/backup-database.sh
```

---

**Schedule daily backups with cron:**
```bash
crontab -e
```

**Add line (daily at 2 AM):**
```
0 2 * * * /home/yourusername/backup-database.sh >> /home/yourusername/backup.log 2>&1
```

**Backups now automatic! ✓**

---

### Restore from Backup

**Restore database from backup:**
```bash
# Stop backend app (prevents connections)
cd ~/mywebclass_hosting/projects/backend
docker compose stop

# Restore backup
cd ~/mywebclass_hosting/infrastructure
gunzip -c ~/backups/mywebclass_20241112_170000.sql.gz | docker compose exec -T postgres psql -U dbadmin mywebclass

# Restart backend
cd ~/mywebclass_hosting/projects/backend
docker compose start
```

---

**Or drop and recreate database:**
```bash
cd ~/mywebclass_hosting/infrastructure

# Drop database
docker compose exec postgres psql -U dbadmin postgres -c "DROP DATABASE mywebclass;"

# Recreate database
docker compose exec postgres psql -U dbadmin postgres -c "CREATE DATABASE mywebclass;"

# Restore
gunzip -c ~/backups/mywebclass_20241112_170000.sql.gz | docker compose exec -T postgres psql -U dbadmin mywebclass
```

---

### Backup Docker Volumes

**Backup PostgreSQL data volume:**
```bash
docker run --rm \
  -v infrastructure_postgres_data:/data:ro \
  -v ~/backups:/backup \
  alpine tar czf /backup/postgres_volume_$(date +%Y%m%d_%H%M%S).tar.gz /data
```

**Creates compressed volume backup.**

---

**Restore volume:**
```bash
# Stop PostgreSQL
cd ~/mywebclass_hosting/infrastructure
docker compose stop postgres

# Restore volume
docker run --rm \
  -v infrastructure_postgres_data:/data \
  -v ~/backups:/backup \
  alpine sh -c "cd / && tar xzf /backup/postgres_volume_20241112_170000.tar.gz"

# Start PostgreSQL
docker compose start postgres
```

---

## Updating Applications

### Update Static Site

**Make changes to static site:**
```bash
nano ~/mywebclass_hosting/projects/static-site/public/index.html
```

**Rebuild and deploy:**
```bash
cd ~/mywebclass_hosting/projects/static-site
docker compose up -d --build
```

**Zero downtime! Old container replaced with new one.**

---

### Update Backend

**Update code:**
```bash
nano ~/mywebclass_hosting/projects/backend/src/index.js
```

**Rebuild and deploy:**
```bash
cd ~/mywebclass_hosting/projects/backend
docker compose up -d --build
```

**Brief downtime during container restart (~2-3 seconds).**

---

### Update Infrastructure

**Update Caddyfile:**
```bash
nano ~/mywebclass_hosting/infrastructure/Caddyfile
```

**Reload Caddy (no downtime!):**
```bash
cd ~/mywebclass_hosting/infrastructure
docker compose exec caddy caddy reload --config /etc/caddy/Caddyfile
```

---

**Update docker-compose.yml:**
```bash
nano ~/mywebclass_hosting/infrastructure/docker-compose.yml
```

**Apply changes:**
```bash
docker compose up -d
```

**Only changed services restart.**

---

### Update Docker Images

**Update to latest Caddy:**
```bash
cd ~/mywebclass_hosting/infrastructure
docker compose pull caddy
docker compose up -d caddy
```

---

**Update PostgreSQL (⚠️ risky, test first!):**
```bash
# Backup first!
~/backup-database.sh

# Update image
docker compose pull postgres
docker compose up -d postgres
```

---

**Update all images:**
```bash
cd ~/mywebclass_hosting/infrastructure
docker compose pull
docker compose up -d
```

---

### Update System Packages

**Update Ubuntu packages:**
```bash
sudo apt update
sudo apt upgrade -y
```

**Reboot if kernel updated:**
```bash
sudo reboot
```

**After reboot, start services:**
```bash
cd ~/mywebclass_hosting/infrastructure && docker compose up -d
cd ~/mywebclass_hosting/projects/backend && docker compose up -d
cd ~/mywebclass_hosting/projects/static-site && docker compose up -d
```

---

## SSL Certificate Management

### Certificate Renewal

**Caddy auto-renews certificates! ✓**

**Check certificate expiration:**
```bash
echo | openssl s_client -servername www.mywebclass.org -connect www.mywebclass.org:443 2>/dev/null | openssl x509 -noout -dates
```

**Shows:**
```
notBefore=Nov 12 16:00:00 2024 GMT
notAfter=Feb 10 16:00:00 2025 GMT
```

**Valid for 90 days, auto-renews at 30 days.**

---

**Check Caddy logs for renewals:**
```bash
cd ~/mywebclass_hosting/infrastructure
docker compose logs caddy | grep -i certificate | tail -20
```

**Look for:**
```
{"level":"info","msg":"certificate renewed successfully"}
```

---

**Force renewal (testing):**
```bash
docker compose exec caddy caddy reload --config /etc/caddy/Caddyfile
```

**Caddy checks certificates on reload.**

---

### Certificate Storage

**Certificates stored in Docker volume:**
```bash
docker volume inspect infrastructure_caddy_data
```

**Shows:**
```json
"Mountpoint": "/var/lib/docker/volumes/infrastructure_caddy_data/_data"
```

---

**Backup certificates:**
```bash
docker run --rm \
  -v infrastructure_caddy_data:/data:ro \
  -v ~/backups:/backup \
  alpine tar czf /backup/caddy_certs_$(date +%Y%m%d).tar.gz /data
```

---

## Monitoring Best Practices

### Create Monitoring Dashboard

**Install htop for better monitoring:**
```bash
sudo apt install htop -y
```

**Run it:**
```bash
htop
```

**Interactive, colorful process monitor!**

---

### Set Up Alerts

**Create alert script:**
```bash
nano ~/check-alerts.sh
```

**Add:**
```bash
#!/bin/bash

# Check disk space
DISK_USAGE=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
if [ $DISK_USAGE -gt 80 ]; then
    echo "ALERT: Disk usage is ${DISK_USAGE}%"
fi

# Check memory
MEM_FREE=$(free | grep Mem | awk '{print int($7/$2 * 100)}')
if [ $MEM_FREE -lt 20 ]; then
    echo "ALERT: Low memory - only ${MEM_FREE}% available"
fi

# Check containers
DOWN_CONTAINERS=$(docker ps -a --filter "status=exited" --format '{{.Names}}' | wc -l)
if [ $DOWN_CONTAINERS -gt 0 ]; then
    echo "ALERT: ${DOWN_CONTAINERS} containers are down"
    docker ps -a --filter "status=exited" --format '{{.Names}}'
fi

# Check services
for url in "https://www.mywebclass.org" "https://api.mywebclass.org/health" "https://db.mywebclass.org"; do
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$url" --max-time 10)
    if [ "$STATUS" != "200" ]; then
        echo "ALERT: $url returned $STATUS"
    fi
done
```

---

**Make executable:**
```bash
chmod +x ~/check-alerts.sh
```

**Run periodically:**
```bash
crontab -e
```

**Add (check every 5 minutes):**
```
*/5 * * * * /home/yourusername/check-alerts.sh >> /home/yourusername/alerts.log 2>&1
```

---

### Monitor Application Metrics

**Add metrics endpoint to backend:**
```javascript
// In src/index.js
app.get('/api/metrics', async (req, res) => {
  const metrics = {
    uptime: process.uptime(),
    memory: process.memoryUsage(),
    cpu: process.cpuUsage(),
    connections: {
      total: pool.totalCount,
      idle: pool.idleCount,
      waiting: pool.waitingCount
    }
  };
  res.json(metrics);
});
```

**Rebuild:**
```bash
cd ~/mywebclass_hosting/projects/backend
docker compose up -d --build
```

**Check metrics:**
```bash
curl https://api.mywebclass.org/api/metrics
```

---

## Troubleshooting Production Issues

### Service Down

**Check which services are down:**
```bash
docker ps -a
```

**Restart specific service:**
```bash
cd ~/mywebclass_hosting/infrastructure
docker compose restart caddy
```

**Or restart all:**
```bash
docker compose restart
```

---

### High CPU Usage

**Find culprit:**
```bash
docker stats --no-stream
```

**Check logs:**
```bash
docker compose logs --tail=100 backend
```

**Restart service:**
```bash
docker compose restart backend
```

---

### High Memory Usage

**Check memory:**
```bash
free -h
```

**Find heavy processes:**
```bash
docker stats --no-stream
```

**Restart container:**
```bash
docker compose restart postgres
```

**Or increase droplet size (DigitalOcean dashboard).**

---

### Database Connection Issues

**Check PostgreSQL running:**
```bash
docker ps | grep postgres
```

**Check logs:**
```bash
cd ~/mywebclass_hosting/infrastructure
docker compose logs postgres | tail -50
```

**Test connection:**
```bash
docker compose exec postgres psql -U dbadmin mywebclass -c "SELECT 1;"
```

**Restart if needed:**
```bash
docker compose restart postgres
```

---

### SSL Certificate Issues

**Check certificate:**
```bash
echo | openssl s_client -servername www.mywebclass.org -connect www.mywebclass.org:443 2>/dev/null | openssl x509 -noout -dates
```

**Check Caddy logs:**
```bash
cd ~/mywebclass_hosting/infrastructure
docker compose logs caddy | grep -i certificate
```

**Reload Caddy:**
```bash
docker compose exec caddy caddy reload --config /etc/caddy/Caddyfile
```

**Restart if needed:**
```bash
docker compose restart caddy
```

---

## Performance Optimization

### Enable Caching

**Add caching headers in Caddyfile:**
```
www.mywebclass.org {
    header {
        Cache-Control "public, max-age=3600"
    }
    reverse_proxy static-site:80
}
```

**Reload:**
```bash
docker compose exec caddy caddy reload --config /etc/caddy/Caddyfile
```

---

### Optimize Database

**Run VACUUM:**
```bash
docker compose -f ~/mywebclass_hosting/infrastructure/docker-compose.yml exec postgres psql -U dbadmin mywebclass -c "VACUUM ANALYZE;"
```

**Check slow queries:**
```sql
-- In pgAdmin or psql
SELECT query, calls, total_time, mean_time
FROM pg_stat_statements
ORDER BY mean_time DESC
LIMIT 10;
```

---

### Monitor Response Times

**Add timing to backend logs:**
```javascript
// In src/index.js
const morgan = require('morgan');
app.use(morgan(':method :url :status :response-time ms'));
```

**Check logs:**
```bash
docker compose logs backend | grep "GET /api/users"
```

**Shows:**
```
GET /api/users 200 15.234 ms
```

---

## Scaling Considerations

### Vertical Scaling

**Upgrade droplet (more CPU/RAM):**
1. Backup everything
2. DigitalOcean dashboard → Droplet → Resize
3. Power off droplet
4. Select new size
5. Resize
6. Power on
7. Verify services start

---

### Horizontal Scaling

**Add more servers:**
```
Load Balancer
   ├─→ Server 1 (www.mywebclass.org)
   ├─→ Server 2 (www.mywebclass.org)
   └─→ Server 3 (www.mywebclass.org)

Separate Database Server
   └─→ PostgreSQL (high-performance instance)
```

**Beyond this course, but architecture supports it!**

---

## Disaster Recovery

### Backup Checklist

**What to backup:**
```
✓ PostgreSQL database (SQL dumps)
✓ Docker volumes (especially postgres_data)
✓ Caddy certificates (caddy_data)
✓ Application code (git repository)
✓ .env files (securely!)
✓ Caddyfile
✓ docker-compose.yml files
```

---

### Restoration Plan

**If server lost:**

1. **Create new droplet**
2. **Configure server** (Chapters 5-11)
3. **Install Docker** (Chapter 13)
4. **Configure DNS** (point to new IP)
5. **Clone repository**
6. **Restore .env files**
7. **Deploy infrastructure**
8. **Restore database backup**
9. **Deploy applications**
10. **Verify everything working**

**With good backups: ~2-3 hours to restore.**

---

## Regular Maintenance Schedule

### Daily

```
✓ Check ~/check-system.sh
✓ Review alerts.log
✓ Verify backups completed
✓ Check disk space
```

---

### Weekly

```
✓ Review all logs for errors
✓ Update system packages
✓ Test restore from backup
✓ Check certificate expiration dates
✓ Review resource usage trends
```

---

### Monthly

```
✓ Update Docker images
✓ Review security (Fail2Ban logs)
✓ Clean old Docker images/volumes
✓ Review and update documentation
✓ Test disaster recovery plan
```

---

### Quarterly

```
✓ Full security audit
✓ Review and update passwords
✓ Test scaling plan
✓ Review costs and optimization
```

---

## Congratulations!

**You've completed the course! 🎉**

**What you've built:**
- ✅ Secure Linux server on DigitalOcean
- ✅ Hardened with firewall and intrusion prevention
- ✅ Docker-based infrastructure
- ✅ Automatic HTTPS with Let's Encrypt
- ✅ PostgreSQL database with pgAdmin
- ✅ Static website with Nginx
- ✅ Backend API with Node.js/Express
- ✅ Full monitoring and backup strategy
- ✅ Production-ready hosting platform!

---

## What's Next?

### Continue Learning

**Expand your skills:**
- Add more applications
- Implement CI/CD pipeline
- Learn Kubernetes
- Add monitoring (Prometheus, Grafana)
- Implement Redis caching
- Add message queue (RabbitMQ)
- Learn advanced security

---

### Build Your Portfolio

**Use this infrastructure for:**
- Personal portfolio site
- Blog
- Projects showcase
- Side business
- Client work
- Resume builder

---

### Share Your Knowledge

**Help others:**
- Write blog posts
- Create tutorials
- Answer questions online
- Contribute to open source
- Teach what you learned

---

## Key Takeaways

**Remember:**

1. **Monitoring is crucial**
   - Check regularly
   - Set up alerts
   - Review logs
   - Track metrics

2. **Backups save lives**
   - Automate backups
   - Test restores
   - Store securely
   - Multiple locations

3. **Security never stops**
   - Update regularly
   - Monitor intrusions
   - Review access logs
   - Follow best practices

4. **Documentation matters**
   - Document changes
   - Keep runbooks
   - Write procedures
   - Update regularly

5. **Plan for growth**
   - Monitor resources
   - Plan capacity
   - Test scaling
   - Optimize continuously

---

## Quick Reference

### Essential Commands

**Health check:**
```bash
~/check-system.sh
```

**Backup database:**
```bash
~/backup-database.sh
```

**Check logs:**
```bash
cd ~/mywebclass_hosting/infrastructure && docker compose logs
cd ~/mywebclass_hosting/projects/backend && docker compose logs
```

**Restart services:**
```bash
cd ~/mywebclass_hosting/infrastructure && docker compose restart
```

**Update application:**
```bash
cd ~/mywebclass_hosting/projects/backend
docker compose up -d --build
```

**Clean Docker:**
```bash
docker system prune -a -f
```

---

### Emergency Procedures

**Service down:**
```bash
docker ps -a  # Check status
docker compose logs <service>  # Check logs
docker compose restart <service>  # Restart
```

**Out of disk space:**
```bash
docker system prune -a --volumes -f  # Clean everything
df -h  # Verify
```

**Database corrupted:**
```bash
~/backup-database.sh  # Backup current state
# Restore from good backup
gunzip -c ~/backups/mywebclass_YYYYMMDD_HHMMSS.sql.gz | \
  docker compose exec -T postgres psql -U dbadmin mywebclass
```

---

### Useful Resources

**Official Documentation:**
- Docker: https://docs.docker.com
- Caddy: https://caddyserver.com/docs
- PostgreSQL: https://www.postgresql.org/docs
- Let's Encrypt: https://letsencrypt.org/docs

**Community:**
- Stack Overflow
- Reddit: r/selfhosted, r/docker
- DigitalOcean Community
- Docker Forums

---

## Final Thoughts

**You've learned:**
- Linux system administration
- Server security hardening
- Docker containerization
- Reverse proxy configuration
- Database management
- Full-stack deployment
- DevOps best practices

**This is just the beginning!**

Keep learning, keep building, and most importantly:

**Keep shipping! 🚀**

---

[← Previous: Chapter 19 - Backend Application Deployment](19-backend-deployment.md) | [Next: Appendix A - Command Reference →](appendix-a-command-reference.md)
