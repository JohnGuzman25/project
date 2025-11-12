# Chapter 14: DNS Fundamentals

**Understanding the Domain Name System**

---

## Learning Objectives

By the end of this chapter, you'll be able to:
- ✅ Understand what DNS is and how it works
- ✅ Explain DNS record types (A, AAAA, CNAME, TXT, MX)
- ✅ Understand DNS propagation
- ✅ Know how DNS relates to web hosting
- ✅ Understand subdomains and wildcards
- ✅ Grasp DNS security concepts

**Time Required:** 30-40 minutes

**Note:** This is theory. Chapter 15 covers hands-on domain configuration.

---

## What is DNS?

### The Phone Book of the Internet

**DNS = Domain Name System**

**The problem it solves:**
```
Computers: Use IP addresses (192.0.2.100)
Humans: Prefer names (mywebclass.org)
DNS: Translates names to IP addresses
```

**Real-world analogy:**
- **Phone book** = DNS system
- **Person's name** = Domain name
- **Phone number** = IP address
- **Looking up a number** = DNS query

---

### Without DNS

**Imagine browsing the internet without DNS:**

```
Want to visit Google?
Type: http://142.250.185.46

Want to check Facebook?
Type: http://157.240.241.35

Want to read news?
Type: http://151.101.193.164
```

**Impossible to remember!**

---

### With DNS

**Much better:**

```
Want to visit Google?
Type: google.com
DNS translates to: 142.250.185.46

Want to check Facebook?
Type: facebook.com
DNS translates to: 157.240.241.35
```

**Easy to remember!**

---

## How DNS Works

### The DNS Query Process

**When you type `mywebclass.org` in your browser:**

```
1. Browser: "What's the IP for mywebclass.org?"
   ↓
2. Local DNS Cache: "Let me check... not found"
   ↓
3. ISP DNS Server: "Let me ask..."
   ↓
4. Root DNS Server: "Try .org servers"
   ↓
5. .org DNS Server: "Try mywebclass.org nameservers"
   ↓
6. Nameserver: "45.55.209.47"
   ↓
7. Browser: "Thanks! Connecting to 45.55.209.47"
```

**This happens in milliseconds!**

---

### DNS Hierarchy

**DNS is hierarchical:**

```
                    Root (.)
                       |
        ┌──────────────┼──────────────┐
        |              |              |
      .com           .org           .net
        |              |              |
    google.com   mywebclass.org   example.net
        |              |
    www.google.com   www.mywebclass.org
                     db.mywebclass.org
```

**Reading domains right to left:**
- `www.mywebclass.org.` (note the final dot!)
- `.` = Root
- `.org` = Top-level domain (TLD)
- `.mywebclass` = Second-level domain (your domain)
- `www` = Subdomain

---

### Nameservers

**Nameservers = DNS servers that know about your domain**

**When you buy a domain:**
1. Registrar (like Namecheap) stores your nameservers
2. Nameservers store your DNS records
3. DNS queries go to nameservers

**Common nameserver providers:**
- Namecheap's nameservers
- Cloudflare
- DigitalOcean DNS
- AWS Route 53
- Google Cloud DNS

**We'll use your domain registrar's nameservers.**

---

## DNS Record Types

### A Record (Address)

**Maps domain to IPv4 address**

**Format:**
```
mywebclass.org    →    45.55.209.47
```

**Use cases:**
- Point domain to server
- Point subdomain to server
- Most common record type

**Example:**
```
Name:  mywebclass.org
Type:  A
Value: 45.55.209.47
TTL:   3600
```

---

### AAAA Record (IPv6 Address)

**Maps domain to IPv6 address**

**Format:**
```
mywebclass.org    →    2001:db8::1
```

**IPv6 addresses are longer:**
- IPv4: 192.0.2.100 (32 bits)
- IPv6: 2001:0db8:85a3:0000:0000:8a2e:0370:7334 (128 bits)

**Use if your server has IPv6 address.**

---

### CNAME Record (Canonical Name)

**Alias from one domain to another**

**Format:**
```
www.mywebclass.org    →    mywebclass.org
```

**Like a shortcut or redirect at DNS level.**

**Example:**
```
Name:  www
Type:  CNAME
Value: mywebclass.org
TTL:   3600
```

**When someone visits www.mywebclass.org:**
1. DNS: "www is CNAME to mywebclass.org"
2. DNS: "mywebclass.org is A record to 45.55.209.47"
3. Browser: "Connect to 45.55.209.47"

**⚠️ Important:** Can't use CNAME for root domain (mywebclass.org)

---

### TXT Record (Text)

**Stores text information**

**Use cases:**
- Domain verification (prove you own domain)
- Email security (SPF, DKIM, DMARC)
- Site verification (Google, etc.)
- Notes/documentation

**Example verification:**
```
Name:  @
Type:  TXT
Value: google-site-verification=abc123xyz789
TTL:   3600
```

---

### MX Record (Mail Exchange)

**Specifies email servers**

**Format:**
```
mywebclass.org    →    mail.mywebclass.org (priority 10)
```

**Example:**
```
Name:     @
Type:     MX
Value:    mail.mywebclass.org
Priority: 10
TTL:      3600
```

**Lower priority = preferred server**

**Not needed if you don't host email.**

---

### NS Record (Name Server)

**Specifies nameservers for domain**

**Example:**
```
Name:  @
Type:  NS
Value: ns1.namecheap.com
TTL:   3600
```

**Usually set by registrar.**
**Don't change unless moving DNS provider.**

---

### CAA Record (Certificate Authority Authorization)

**Specifies which CAs can issue SSL certificates**

**Example:**
```
Name:  @
Type:  CAA
Value: 0 issue "letsencrypt.org"
TTL:   3600
```

**Prevents unauthorized SSL certificate issuance.**
**Good for security!**

---

## Common DNS Patterns

### Root Domain

**The main domain:**
```
mywebclass.org
```

**A record:**
```
Name:  @ (or blank)
Type:  A
Value: 45.55.209.47
```

---

### WWW Subdomain

**Most common subdomain:**
```
www.mywebclass.org
```

**Option 1: A record (separate IP)**
```
Name:  www
Type:  A
Value: 45.55.209.47
```

**Option 2: CNAME (alias to root)**
```
Name:  www
Type:  CNAME
Value: mywebclass.org
```

**Both work! CNAME is more flexible.**

---

### Wildcard Subdomain

**Catch all subdomains:**
```
*.mywebclass.org
```

**A record:**
```
Name:  *
Type:  A
Value: 45.55.209.47
```

**This means:**
- anything.mywebclass.org → 45.55.209.47
- test.mywebclass.org → 45.55.209.47
- random.mywebclass.org → 45.55.209.47
- db.mywebclass.org → 45.55.209.47

**Very useful for dynamic subdomains!**

---

### Specific Subdomains

**For specific services:**
```
db.mywebclass.org       → pgAdmin
api.mywebclass.org      → API backend
blog.mywebclass.org     → Blog
shop.mywebclass.org     → E-commerce
```

**Each can point to:**
- Same IP (different paths)
- Different IPs (different servers)
- CNAME to main domain

---

## DNS and Web Hosting

### How It All Connects

**The flow:**
```
1. User types: mywebclass.org
   ↓
2. DNS lookup: mywebclass.org → 45.55.209.47
   ↓
3. Browser connects to: 45.55.209.47:443
   ↓
4. Caddy (reverse proxy) on server receives request
   ↓
5. Caddy: "Request is for mywebclass.org"
   ↓
6. Caddy: "Route to static-site container"
   ↓
7. Static site responds with HTML
   ↓
8. Browser displays website
```

---

### Multiple Domains, One Server

**You can host many domains on one server:**

**DNS records:**
```
mywebclass.org     → 45.55.209.47
example.com        → 45.55.209.47
test-site.net      → 45.55.209.47
```

**All point to same IP!**

**Caddy handles routing:**
```
mywebclass.org     → Container A
example.com        → Container B
test-site.net      → Container C
```

**Caddy looks at hostname in HTTP request.**

---

### Multiple Servers, One Domain

**Large sites use multiple servers:**

**DNS with round-robin:**
```
mywebclass.org  →  45.55.209.47
mywebclass.org  →  192.0.2.100
mywebclass.org  →  198.51.100.50
```

**DNS returns different IPs (load balancing).**

**Or use load balancer:**
```
mywebclass.org           → Load Balancer (1.2.3.4)
Load Balancer            → Server 1 (45.55.209.47)
                         → Server 2 (192.0.2.100)
                         → Server 3 (198.51.100.50)
```

**Not needed for this course!**

---

## TTL (Time To Live)

### What is TTL?

**TTL = How long to cache DNS record**

**Example:**
```
Name:  www
Type:  A
Value: 45.55.209.47
TTL:   3600  ← seconds (1 hour)
```

**What it means:**
- DNS servers cache this record for 1 hour
- After 1 hour, they check for updates
- Lower TTL = faster changes, more queries
- Higher TTL = slower changes, less queries

---

### TTL Values

**Common values:**
```
300     = 5 minutes  (very low - before changes)
1800    = 30 minutes (low)
3600    = 1 hour     (standard)
14400   = 4 hours    (high)
86400   = 24 hours   (very high)
```

**When to use low TTL:**
- Before server migration
- Before IP changes
- During testing

**When to use high TTL:**
- Stable production
- After migration complete
- Reduce DNS queries

---

### TTL Strategy

**Before IP change:**
```
1. Lower TTL to 300 (5 minutes)
2. Wait for old TTL to expire (e.g., 24 hours)
3. Change IP address
4. Wait 5 minutes for propagation
5. Verify new IP works
6. Raise TTL back to 3600
```

**This minimizes downtime!**

---

## DNS Propagation

### What is Propagation?

**Propagation = Time for DNS changes to spread worldwide**

**When you update DNS record:**
```
1. You: Change A record to new IP
   ↓
2. Your nameserver: Updates immediately
   ↓
3. ISP DNS servers: Still have old cached record (until TTL expires)
   ↓
4. Eventually: All DNS servers update
```

**This can take:**
- 5 minutes to 1 hour (typically)
- Up to 48 hours (maximum, rare)
- Depends on TTL values

---

### Why Propagation Happens

**DNS uses caching for performance:**

**Without caching:**
```
Every website visit = DNS query
1 billion websites × 1000 visits = 1 trillion queries
DNS servers would collapse!
```

**With caching:**
```
First visit = DNS query (cached for TTL)
Next 1000 visits = Use cache
Much fewer queries = System works!
```

**Trade-off:** Performance vs. update speed

---

### Checking Propagation

**Check DNS from different locations:**

**Tools:**
- https://www.whatsmydns.net/
- https://dnschecker.org/
- `dig` command (covered in Chapter 15)
- `nslookup` command

**Example propagation check:**
```
Location          Result
─────────────────────────────────
New York, USA     45.55.209.47 ✓
London, UK        45.55.209.47 ✓
Tokyo, Japan      192.0.2.100  ✗ (old IP)
Sydney, Australia 45.55.209.47 ✓
```

**Tokyo DNS server still has old cached record.**

---

## DNS Security

### DNS Vulnerabilities

**1. DNS Spoofing/Cache Poisoning**
```
Attacker: Tricks DNS server into caching wrong IP
User: Thinks they're going to bank.com
Reality: Directed to attacker's fake site
```

**Protection:** DNSSEC (DNS Security Extensions)

---

**2. DNS Hijacking**
```
Attacker: Changes your nameserver settings
Result: All your domains point to attacker's servers
```

**Protection:**
- Strong registrar account password
- Two-factor authentication
- Registry lock

---

**3. DDoS on DNS**
```
Attacker: Floods nameservers with queries
Result: Legitimate queries can't get through
Your site: Appears offline (DNS doesn't resolve)
```

**Protection:**
- Use large DNS providers (Cloudflare, etc.)
- DDoS protection services
- Multiple nameservers

---

### DNSSEC

**DNSSEC = DNS Security Extensions**

**What it does:**
- Cryptographically signs DNS records
- Verifies records haven't been tampered with
- Prevents spoofing

**Like HTTPS for DNS!**

**Requirements:**
- Domain registrar support
- Nameserver support
- More complex setup

**Not required for this course, but good to know.**

---

### Best Practices

**✅ Do:**
- Use strong registrar passwords
- Enable 2FA on domain account
- Use reputable nameserver providers
- Monitor DNS changes
- Keep contact info updated

**❌ Don't:**
- Share registrar login
- Use weak passwords
- Ignore security emails
- Let domains expire
- Use unknown DNS providers

---

## Subdomains in Detail

### Subdomain Structure

**Anatomy:**
```
subdomain.domain.tld
    ↓        ↓    ↓
   www   mywebclass org
```

**Can be multiple levels:**
```
dev.api.mywebclass.org
 ↓   ↓       ↓      ↓
sub sub   domain   tld
```

---

### Subdomain Use Cases

**Separate services:**
```
www.mywebclass.org      → Main website
db.mywebclass.org       → Database admin
api.mywebclass.org      → API backend
docs.mywebclass.org     → Documentation
```

**Different environments:**
```
mywebclass.org          → Production
staging.mywebclass.org  → Staging server
dev.mywebclass.org      → Development
```

**User-specific:**
```
john.mywebclass.org     → John's subdomain
jane.mywebclass.org     → Jane's subdomain
```

**Geographic:**
```
us.mywebclass.org       → US server
eu.mywebclass.org       → Europe server
asia.mywebclass.org     → Asia server
```

---

### Subdomain vs. Path

**Option 1: Subdomain**
```
blog.mywebclass.org
api.mywebclass.org
shop.mywebclass.org
```

**Option 2: Path**
```
mywebclass.org/blog
mywebclass.org/api
mywebclass.org/shop
```

**Subdomains better for:**
- Different servers
- Different applications
- Independent scaling
- Separate SSL certificates (though not required with wildcards)

**Paths better for:**
- Same application
- Simpler setup
- Single domain management
- SEO (debatable)

---

## Our Course Setup

### DNS Records We'll Create

**For `mywebclass.org`:**

**1. Root domain (A record)**
```
Name:  @
Type:  A
Value: 45.55.209.47
TTL:   3600
```

**2. WWW subdomain (CNAME or A)**
```
Name:  www
Type:  CNAME
Value: mywebclass.org
TTL:   3600
```

**3. Wildcard (A record)**
```
Name:  *
Type:  A
Value: 45.55.209.47
TTL:   3600
```

**This allows:**
- mywebclass.org → Server
- www.mywebclass.org → Server
- db.mywebclass.org → Server (pgAdmin)
- anything.mywebclass.org → Server

---

### How Caddy Routes Traffic

**DNS points everything to server IP:**
```
mywebclass.org      → 45.55.209.47
www.mywebclass.org  → 45.55.209.47
db.mywebclass.org   → 45.55.209.47
```

**Caddy receives all requests and routes by hostname:**

**Caddyfile:**
```
www.mywebclass.org {
    reverse_proxy static-site:80
}

db.mywebclass.org {
    reverse_proxy pgadmin:80
}
```

**DNS gets request to server, Caddy routes to correct container.**

---

## DNS and SSL/TLS Certificates

### Let's Encrypt and DNS

**Let's Encrypt needs to verify you own domain.**

**Challenge methods:**

**1. HTTP-01 Challenge (we'll use this)**
```
Let's Encrypt: "Put this file at http://mywebclass.org/.well-known/acme-challenge/token"
Caddy: "Done!"
Let's Encrypt: "I can access it, domain verified!"
Certificate issued ✓
```

**Requires:**
- Port 80 open (firewall allows it)
- DNS points to your server
- Server responds to HTTP requests

---

**2. DNS-01 Challenge (alternative)**
```
Let's Encrypt: "Add this TXT record to DNS"
You: Add TXT record
Let's Encrypt: "I see the TXT record, domain verified!"
Certificate issued ✓
```

**Requires:**
- DNS API access (automation)
- More complex setup

**We use HTTP-01 (simpler).**

---

### Wildcard Certificates

**Covers all subdomains:**
```
Certificate for: *.mywebclass.org

Covers:
- www.mywebclass.org ✓
- db.mywebclass.org ✓
- api.mywebclass.org ✓
- anything.mywebclass.org ✓

Doesn't cover:
- mywebclass.org ✗ (need separate cert)
```

**Get both:**
- Certificate for: mywebclass.org
- Certificate for: *.mywebclass.org

**Or use SAN (Subject Alternative Name) certificate.**

**Caddy handles this automatically!**

---

## Common Misconceptions

### Myth 1: DNS = Hosting

**Wrong:**
```
DNS: Phone book (name → number)
Hosting: The actual house at that address
```

**You need both:**
- Domain registrar (controls DNS)
- Hosting provider (where files live)

**They can be different companies!**

---

### Myth 2: Changing DNS is Instant

**Wrong:**
```
DNS changes take time (propagation)
Old records cached for TTL duration
Can take minutes to hours
```

**Plan DNS changes ahead of time!**

---

### Myth 3: WWW is Required

**Wrong:**
```
www.mywebclass.org   → Optional
mywebclass.org       → Just as valid
```

**Both work, just configure both in DNS!**

---

### Myth 4: More Nameservers = Better

**Wrong:**
```
2 nameservers: Fine
4 nameservers: Fine
10 nameservers: Overkill, no benefit
```

**2-4 nameservers is standard.**

---

## Key Takeaways

**Remember:**

1. **DNS translates names to IPs**
   - Humans use domain names
   - Computers use IP addresses
   - DNS bridges the gap

2. **Common record types**
   - A = Domain to IPv4
   - AAAA = Domain to IPv6
   - CNAME = Alias to another domain
   - TXT = Text information

3. **TTL controls caching**
   - Lower TTL = Faster updates
   - Higher TTL = Less DNS queries
   - Adjust before changes

4. **Propagation takes time**
   - Not instant
   - Usually < 1 hour
   - Up to 48 hours maximum
   - Plan accordingly

5. **Subdomains are flexible**
   - Separate services
   - Same or different servers
   - Wildcard for dynamic subdomains

6. **DNS security matters**
   - Strong passwords
   - Two-factor authentication
   - Reputable providers
   - Monitor changes

---

## Next Steps

**You now understand:**
- ✅ What DNS is and how it works
- ✅ DNS record types and their uses
- ✅ TTL and propagation
- ✅ Subdomains and wildcards
- ✅ DNS security basics

**In Chapter 15:**
- Buy/configure domain name
- Set up DNS records
- Point domain to your server
- Verify DNS configuration
- Test subdomain routing

**Then you'll be ready to deploy infrastructure with real domain names!**

---

## Quick Reference

### Common Record Types

```
A       Domain to IPv4 address
AAAA    Domain to IPv6 address
CNAME   Alias to another domain
TXT     Text information
MX      Mail server
NS      Nameserver
CAA     Certificate authority
```

### DNS Hierarchy

```
. (root)
└── .org (TLD)
    └── mywebclass.org (your domain)
        ├── www.mywebclass.org (subdomain)
        ├── db.mywebclass.org (subdomain)
        └── *.mywebclass.org (wildcard)
```

### TTL Values

```
300    = 5 minutes (before changes)
3600   = 1 hour (standard)
86400  = 24 hours (stable production)
```

---

[← Previous: Chapter 13 - Docker Installation](13-docker-installation.md) | [Next: Chapter 15 - Domain Configuration →](15-domain-configuration.md)
