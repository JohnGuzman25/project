# Chapter 15: Domain Configuration

**Connecting Your Domain to Your Server**

---

## Learning Objectives

By the end of this chapter, you'll be able to:
- ✅ Purchase or prepare a domain name
- ✅ Configure DNS A records
- ✅ Set up wildcard DNS
- ✅ Configure CNAME records
- ✅ Test DNS propagation
- ✅ Verify DNS configuration
- ✅ Troubleshoot common DNS issues

**Time Required:** 45-60 minutes (plus propagation wait time)

**Prerequisites:**
- Chapter 14 (DNS Fundamentals)
- Domain name (purchase if needed)
- Server IP address from DigitalOcean

---

## Before You Begin

### Do You Have a Domain?

**Option 1: You have a domain** ✓
- Perfect! We'll configure it
- Can be from any registrar
- Just need access to DNS settings

**Option 2: You need a domain**
- We'll show where to buy
- Cost: $5-15/year typically
- Use .com, .org, .net, or similar

**Option 3: You want to test first**
- Can use IP address temporarily
- But SSL/HTTPS won't work properly
- Recommend getting domain first

---

### What You'll Need

**Required information:**

1. **Your server IP address**
   ```
   Example: 45.55.209.47
   ```
   - From DigitalOcean droplet
   - Check droplet dashboard

2. **Your domain name**
   ```
   Example: mywebclass.org
   ```
   - Whatever domain you choose

3. **Access to domain DNS settings**
   - Login to domain registrar
   - Access to DNS management panel

---

### Choosing a Domain Name

**Good domain names:**
- ✅ Short and memorable
- ✅ Easy to spell
- ✅ Relevant to project
- ✅ Available (not taken)
- ✅ Reasonable price

**Tips:**
```
✅ mywebclass.org        (clear, relevant)
✅ johnsmith.dev         (personal portfolio)
✅ coolproject.com       (simple, memorable)

❌ my-super-long-domain-name-here.com  (too long)
❌ xzqpk.org                           (hard to remember)
❌ example.com                         (likely taken/expensive)
```

---

## Purchasing a Domain (Optional)

**If you already have a domain, skip to "Finding Your Server IP"**

### Popular Domain Registrars

**1. Namecheap (Recommended for beginners)**
- Website: https://www.namecheap.com
- Pros: Good UI, reasonable prices, good support
- Price: ~$8-13/year for .com
- Free WHOIS privacy

**2. Google Domains**
- Website: https://domains.google
- Pros: Simple interface, Google integration
- Price: ~$12/year for .com
- Free WHOIS privacy

**3. Cloudflare**
- Website: https://www.cloudflare.com/products/registrar/
- Pros: At-cost pricing, excellent DNS
- Price: ~$8-10/year for .com
- Requires Cloudflare account

**4. Porkbun**
- Website: https://porkbun.com
- Pros: Low prices, good features
- Price: ~$7-10/year for .com
- Free WHOIS privacy

**Avoid:**
- GoDaddy (upsells, complex)
- Very cheap unknown registrars

---

### Purchasing Steps (Namecheap Example)

**Step 1: Search for domain**
```
1. Go to namecheap.com
2. Enter desired domain in search box
3. Click "Search"
```

**Step 2: Check availability**
```
✓ mywebclass.org is available - $12.98/year
✗ example.com is taken
✓ mywebclass.dev is available - $14.98/year
```

**Step 3: Add to cart**
```
1. Click "Add to Cart" next to available domain
2. Choose registration period (1 year is fine)
3. Don't add unnecessary extras
```

**Step 4: Checkout**
```
1. Create account or login
2. Review cart
3. Auto-renewal: Your choice (recommended)
4. WHOIS privacy: Enable (free on Namecheap)
5. Complete payment
```

**Step 5: Confirm ownership**
```
1. Check email for verification
2. Click verification link
3. Domain now active!
```

**Domain ready! Now configure DNS.**

---

## Finding Your Server IP

### Get IP from DigitalOcean

**Step 1: Login to DigitalOcean**
```
https://cloud.digitalocean.com
```

**Step 2: View droplets**
```
1. Click "Droplets" in left sidebar
2. See your droplet listed
```

**Step 3: Copy IP address**
```
Droplet Name: ubuntu-hosting
IP Address:   45.55.209.47  ← This one!
Status:       Active
```

**Write this down!** You'll need it for DNS configuration.

---

### IP Address Types

**IPv4 (most common):**
```
45.55.209.47
```
- 4 numbers separated by dots
- 0-255 range per number
- This is what we'll use

**IPv6 (optional):**
```
2001:0db8:85a3:0000:0000:8a2e:0370:7334
```
- Longer format
- Can also configure (AAAA record)
- Not required for this course

**We'll use IPv4 (A records).**

---

## Accessing DNS Settings

### Finding DNS Management

**Different registrars, similar process:**

**Namecheap:**
```
1. Login to namecheap.com
2. Click "Domain List" in left sidebar
3. Click "Manage" next to your domain
4. Click "Advanced DNS" tab
```

**Google Domains:**
```
1. Login to domains.google
2. Click on your domain
3. Click "DNS" in left menu
4. Click "Manage Custom Records"
```

**Cloudflare:**
```
1. Login to cloudflare.com
2. Select your domain
3. Click "DNS" tab
4. See DNS records
```

**Porkbun:**
```
1. Login to porkbun.com
2. Click "Domain Management"
3. Click your domain
4. Click "DNS"
```

---

### Understanding DNS Panel

**Typical DNS management panel:**

```
┌─────────────────────────────────────────────────────┐
│ DNS Records for: mywebclass.org                     │
├──────┬────────────┬──────────────────┬─────┬────────┤
│ Type │ Host/Name  │ Value            │ TTL │ Action │
├──────┼────────────┼──────────────────┼─────┼────────┤
│  A   │ @          │ 192.0.2.100      │ 300 │ Delete │
│  A   │ www        │ 192.0.2.100      │ 300 │ Delete │
│ CNAME│ blog       │ mywebclass.org   │ 300 │ Delete │
└──────┴────────────┴──────────────────┴─────┴────────┘

[+ Add New Record]
```

**Columns:**
- **Type:** A, AAAA, CNAME, TXT, etc.
- **Host/Name:** Subdomain (@ = root, www = www subdomain)
- **Value:** IP address or target
- **TTL:** Cache time (seconds)
- **Action:** Edit/Delete buttons

---

## Configuring DNS Records

### Strategy

**We'll create 3 records:**

1. **Root domain (A record)**
   - mywebclass.org → Server IP

2. **WWW subdomain (CNAME)**
   - www.mywebclass.org → mywebclass.org

3. **Wildcard (A record)**
   - *.mywebclass.org → Server IP

**This covers all bases!**

---

### Record 1: Root Domain (A Record)

**What it does:**
```
mywebclass.org  →  45.55.209.47
```

**Steps to add:**

**1. Click "Add New Record" or "+" button**

**2. Fill in form:**
```
Type:   A Record
Host:   @ (or leave blank, means root)
Value:  45.55.209.47 (your server IP)
TTL:    300 (5 minutes for now)
```

**3. Click "Save" or "Add Record"**

**Record now added:**
```
Type: A
Host: @
Value: 45.55.209.47
TTL:  300
```

---

### Record 2: WWW Subdomain (CNAME)

**What it does:**
```
www.mywebclass.org  →  mywebclass.org  →  45.55.209.47
```

**Steps to add:**

**1. Click "Add New Record" or "+" again**

**2. Fill in form:**
```
Type:   CNAME Record
Host:   www
Value:  mywebclass.org (or @ if that's an option)
TTL:    300
```

**Note:** Some registrars want `mywebclass.org`, others want `@`, others want `mywebclass.org.` (with trailing dot). Try what works for your registrar.

**3. Click "Save" or "Add Record"**

**Record now added:**
```
Type: CNAME
Host: www
Value: mywebclass.org
TTL:  300
```

---

### Alternative: WWW as A Record

**Some prefer WWW as separate A record:**

```
Type:   A Record
Host:   www
Value:  45.55.209.47
TTL:    300
```

**Pros:**
- Simpler (no CNAME indirection)
- One less DNS lookup

**Cons:**
- If IP changes, update two records
- CNAME is more flexible

**Either works! Choose one approach.**

---

### Record 3: Wildcard (A Record)

**What it does:**
```
*.mywebclass.org  →  45.55.209.47

Covers:
- db.mywebclass.org
- api.mywebclass.org
- test.mywebclass.org
- anything.mywebclass.org
```

**Steps to add:**

**1. Click "Add New Record" or "+" again**

**2. Fill in form:**
```
Type:   A Record
Host:   *
Value:  45.55.209.47 (your server IP)
TTL:    300
```

**3. Click "Save" or "Add Record"**

**Record now added:**
```
Type: A
Host: *
Value: 45.55.209.47
TTL:  300
```

**Now all subdomains point to your server!**

---

### Final DNS Configuration

**Your DNS panel should look like:**

```
┌─────────────────────────────────────────────────────┐
│ DNS Records for: mywebclass.org                     │
├──────┬────────────┬──────────────────┬─────┬────────┤
│ Type │ Host       │ Value            │ TTL │ Action │
├──────┼────────────┼──────────────────┼─────┼────────┤
│  A   │ @          │ 45.55.209.47     │ 300 │ Edit   │
│  A   │ *          │ 45.55.209.47     │ 300 │ Edit   │
│ CNAME│ www        │ mywebclass.org   │ 300 │ Edit   │
└──────┴────────────┴──────────────────┴─────┴────────┘
```

**Perfect! DNS configured.**

---

## Verifying DNS Configuration

### Wait for Propagation

**After saving DNS records:**
```
1. Records saved to nameserver
2. DNS cache expires (5 minutes with TTL 300)
3. New records propagate worldwide
4. Usually takes 5-30 minutes
5. Can take up to 48 hours (rare)
```

**Be patient!** DNS isn't instant.

---

### Test 1: Using dig Command

**On your local computer (Mac/Linux):**

**Check root domain:**
```bash
dig mywebclass.org A +short
```

**Expected output:**
```
45.55.209.47
```

**Check www subdomain:**
```bash
dig www.mywebclass.org A +short
```

**Expected output:**
```
mywebclass.org.
45.55.209.47
```
(Shows CNAME then resolved IP)

**Check wildcard subdomain:**
```bash
dig db.mywebclass.org A +short
```

**Expected output:**
```
45.55.209.47
```

---

**On Windows:**

**Use nslookup instead:**
```cmd
nslookup mywebclass.org
```

**Expected output:**
```
Server:  UnKnown
Address:  192.168.1.1

Non-authoritative answer:
Name:    mywebclass.org
Address:  45.55.209.47
```

---

### Test 2: Online DNS Checker

**Use online tools:**

**1. Go to: https://www.whatsmydns.net/**

**2. Enter your domain:**
```
Domain: mywebclass.org
Record type: A
```

**3. Click "Search"**

**4. See results worldwide:**
```
Location           Status  Result
──────────────────────────────────────
New York, USA      ✓       45.55.209.47
London, UK         ✓       45.55.209.47
Tokyo, Japan       ✓       45.55.209.47
Sydney, Australia  ✓       45.55.209.47
```

**Green checkmarks = Propagated!**

**Red X marks = Still propagating (wait longer)**

---

**Test multiple records:**
```
1. Check: mywebclass.org (A record)
2. Check: www.mywebclass.org (CNAME or A)
3. Check: db.mywebclass.org (wildcard)
```

**All should point to your server IP.**

---

### Test 3: Browser Test

**Try accessing in browser:**

**Root domain:**
```
http://mywebclass.org
```

**Should:**
- Connect to your server
- Might show nginx welcome page or error (we haven't deployed apps yet)
- Key point: It connects! (not "site can't be reached")

---

**WWW subdomain:**
```
http://www.mywebclass.org
```

**Should connect to same place.**

---

**Wildcard subdomain:**
```
http://db.mywebclass.org
```

**Should also connect (might show error/welcome page).**

---

**⚠️ Important:** Don't worry about SSL errors yet!
```
"Your connection is not private"
"NET::ERR_CERT_AUTHORITY_INVALID"
```

**This is expected!** We haven't set up Caddy and Let's Encrypt yet. That's coming in Chapters 16-17.

**For now, just verify DNS points to your server.**

---

### Test 4: From Your Server

**SSH to your server:**
```bash
ssh yourusername@45.55.209.47
```

**Test DNS resolution from server:**
```bash
dig mywebclass.org +short
```

**Expected:**
```
45.55.209.47
```

**Test reverse DNS (IP to domain):**
```bash
dig -x 45.55.209.47 +short
```

**Might show:**
```
ubuntu-hosting.mywebclass.org
```
or your droplet name. Not critical for our setup.

---

## Troubleshooting DNS Issues

### Issue 1: DNS Not Resolving

**Problem:**
```bash
dig mywebclass.org +short
# No output
```

**Or browser shows:**
```
"This site can't be reached"
"DNS_PROBE_FINISHED_NXDOMAIN"
```

---

**Possible causes:**

**1. DNS records not saved**
```
Solution: Go back to DNS panel, verify records are there
```

**2. Wrong nameservers**
```
Check: dig mywebclass.org NS
Should show your registrar's nameservers
If wrong, update at registrar
```

**3. Domain not verified**
```
Check email for verification link
Click link to verify domain ownership
```

**4. Propagation still happening**
```
Wait longer (30 minutes to 2 hours)
Check with whatsmydns.net
```

**5. Typo in DNS record**
```
Double-check IP address
Make sure no extra spaces
Verify domain name spelling
```

---

### Issue 2: WWW Works, Root Doesn't (or vice versa)

**Problem:**
```
www.mywebclass.org  ✓ Works
mywebclass.org      ✗ Doesn't work
```

**Solution:**
```
1. Verify both DNS records exist:
   - A record for @ (root)
   - CNAME or A record for www

2. Check DNS:
   dig mywebclass.org +short
   dig www.mywebclass.org +short

3. Both should return IP address

4. If one is missing, add the record
```

---

### Issue 3: Wildcard Not Working

**Problem:**
```
mywebclass.org       ✓ Works
www.mywebclass.org   ✓ Works
db.mywebclass.org    ✗ Doesn't work
```

**Solution:**
```
1. Verify wildcard record exists:
   Type: A
   Host: *
   Value: 45.55.209.47

2. Check DNS:
   dig db.mywebclass.org +short
   Should return: 45.55.209.47

3. If not, verify wildcard record saved correctly

4. Some registrars require:
   - * (most common)
   - *.mywebclass.org
   - *. (trailing dot)
   Try different formats
```

---

### Issue 4: Old IP Address Still Showing

**Problem:**
```
Changed IP address, but DNS still shows old IP
```

**Solution:**
```
1. Check TTL:
   Old TTL might be 3600 (1 hour) or 86400 (24 hours)
   Must wait for TTL to expire

2. Check DNS record updated:
   Verify in DNS panel
   Should show new IP

3. Clear local DNS cache:
   
   Mac:
   sudo dscacheutil -flushcache
   sudo killall -HUP mDNSResponder
   
   Windows:
   ipconfig /flushdns
   
   Linux:
   sudo systemd-resolve --flush-caches

4. Try different DNS server:
   dig @8.8.8.8 mywebclass.org +short
   (Uses Google DNS directly)

5. Wait for propagation
   Can take up to 48 hours in worst case
```

---

### Issue 5: CNAME Chain Error

**Problem:**
```
CNAME points to another CNAME (not allowed)
```

**Example error:**
```
www → blog → mywebclass.org → IP
      ↑ Extra CNAME
```

**Solution:**
```
1. Simplify CNAME chain:
   www → mywebclass.org → IP
   (One CNAME, then A record)

2. Or use A record for www:
   www → 45.55.209.47 directly
   (No CNAME needed)
```

---

### Issue 6: DNS Panel Changes Not Saving

**Problem:**
```
Add record, click save, but record disappears
```

**Solutions:**
```
1. Check form validation:
   - TTL minimum (usually 60 or 300)
   - Valid IP address format
   - Correct record type selected

2. Try different browser:
   - DNS panels can be buggy
   - Try Chrome, Firefox, Safari

3. Disable browser extensions:
   - Ad blockers might interfere
   - Try incognito/private mode

4. Check account permissions:
   - Verify domain ownership
   - Check email for verification

5. Contact registrar support:
   - If all else fails
   - They can add records manually
```

---

## Advanced DNS Configuration

### Setting Up Email (Optional)

**If you want email @ your domain:**

**MX Records:**
```
Type:     MX
Host:     @
Value:    mail.mywebclass.org
Priority: 10
TTL:      3600
```

**A Record for mail server:**
```
Type:   A
Host:   mail
Value:  45.55.209.47 (or different mail server IP)
TTL:    3600
```

**SPF Record (TXT):**
```
Type:   TXT
Host:   @
Value:  v=spf1 mx ~all
TTL:    3600
```

**DKIM and DMARC:**
- More complex, beyond this course
- Required for production email
- Consider using email service (Google Workspace, etc.)

---

### Multiple Environments

**Separate subdomains for different environments:**

**Production:**
```
Type:   A
Host:   @
Value:  45.55.209.47
TTL:    3600
```

**Staging:**
```
Type:   A
Host:   staging
Value:  192.0.2.100 (different server)
TTL:    300 (lower TTL for changes)
```

**Development:**
```
Type:   A
Host:   dev
Value:  198.51.100.50 (another server)
TTL:    300
```

---

### Using Cloudflare (Optional)

**Cloudflare provides:**
- DDoS protection
- CDN (Content Delivery Network)
- SSL/TLS proxy
- Analytics
- Free plan available

**Setup:**
```
1. Create Cloudflare account
2. Add your domain
3. Cloudflare gives you nameservers:
   Example:
   ns1.cloudflare.com
   ns2.cloudflare.com

4. Update nameservers at registrar:
   Replace registrar's nameservers with Cloudflare's

5. Add DNS records in Cloudflare panel

6. Enable proxy (orange cloud) for protection
```

**Pros:**
- Better security
- Faster load times
- Free SSL

**Cons:**
- More complex
- Another service to manage
- Proxy can complicate debugging

**Not required for this course, but good to know!**

---

## Adjusting TTL After Setup

### Lower TTL for Testing

**During setup (current):**
```
TTL: 300 (5 minutes)
```

**Why:**
- Fast propagation
- Can fix mistakes quickly
- Good for testing

---

### Raise TTL for Production

**After everything works:**

**Step 1: Verify stability**
```
- DNS resolving correctly: ✓
- Website accessible: ✓
- SSL certificates working: ✓
- No IP changes planned: ✓
```

**Step 2: Edit DNS records**
```
1. Go to DNS panel
2. Edit each record
3. Change TTL to 3600 (1 hour) or 14400 (4 hours)
4. Save
```

**Benefits:**
- Fewer DNS queries
- Faster load times (cached)
- Less load on nameservers
- More resilient to DNS attacks

---

**When to use different TTLs:**
```
300     = During setup, testing, migration
1800    = Recently stable, might change
3600    = Stable production (recommended)
14400   = Very stable, rarely changes
86400   = Almost never changes (extreme)
```

---

## DNS Records Checklist

### Verification Checklist

**Run through this checklist:**

```
□ Server IP address obtained from DigitalOcean
□ Domain name purchased or available
□ Access to domain DNS management panel
□ A record created for root domain (@)
□ A record or CNAME created for www subdomain
□ Wildcard A record created (*)
□ Records saved in DNS panel
□ Waited 5-30 minutes for propagation
□ Tested with dig command - root domain resolves
□ Tested with dig command - www resolves
□ Tested with dig command - wildcard (db, api, etc.) resolves
□ Tested with online checker (whatsmydns.net)
□ Tested in browser - domain connects to server
□ TTL set to 300 for now (will increase later)
```

**If all checked, DNS is ready! ✓**

---

## Real-World DNS Examples

### Example 1: Simple Personal Site

**Domain:** johnsmith.dev
**Goal:** Personal portfolio

**DNS records:**
```
@ (root)    A      45.55.209.47
www         CNAME  johnsmith.dev
```

**That's it! Simple.**

---

### Example 2: Multiple Projects

**Domain:** myprojects.com
**Goal:** Host multiple projects on subdomains

**DNS records:**
```
@ (root)    A      45.55.209.47
www         CNAME  myprojects.com
*           A      45.55.209.47
```

**Allows:**
- myprojects.com → Portfolio
- blog.myprojects.com → Blog
- shop.myprojects.com → E-commerce
- app.myprojects.com → Web app

**All on one server, Caddy routes by subdomain!**

---

### Example 3: Geographic Distribution

**Domain:** myapp.com
**Goal:** Different servers in different regions

**DNS records:**
```
@ (root)    A      45.55.209.47 (US server)
www         CNAME  myapp.com
eu          A      192.0.2.100 (EU server)
asia        A      198.51.100.50 (Asia server)
```

**Users connect to:**
- myapp.com → US server (default)
- eu.myapp.com → Europe server (faster for EU users)
- asia.myapp.com → Asia server (faster for Asia users)

---

### Example 4: Separate Services

**Domain:** startup.io
**Goal:** Different services on different infrastructure

**DNS records:**
```
@ (root)    A      45.55.209.47 (marketing site)
www         CNAME  startup.io
app         A      192.0.2.100 (application server)
api         A      198.51.100.50 (API server)
db          A      198.51.100.51 (database admin)
docs        CNAME  startup.gitbook.io (external)
```

**Flexible routing to different infrastructure!**

---

## Common DNS Patterns

### Pattern 1: Root + WWW

**Most common pattern:**
```
mywebclass.org       →  Server
www.mywebclass.org   →  Server
```

**Implementation:**
```
@     A      45.55.209.47
www   CNAME  mywebclass.org
```

---

### Pattern 2: Root + WWW + Wildcard

**What we're using:**
```
mywebclass.org           →  Server
www.mywebclass.org       →  Server
anything.mywebclass.org  →  Server
```

**Implementation:**
```
@     A      45.55.209.47
www   CNAME  mywebclass.org
*     A      45.55.209.47
```

---

### Pattern 3: Specific Subdomains Only

**No wildcard, specific subdomains:**
```
mywebclass.org      →  Server
www.mywebclass.org  →  Server
db.mywebclass.org   →  Server
api.mywebclass.org  →  Server
```

**Implementation:**
```
@     A      45.55.209.47
www   A      45.55.209.47
db    A      45.55.209.47
api   A      45.55.209.47
```

**More control, but must add each subdomain manually.**

---

### Pattern 4: Redirect WWW to Root

**Some prefer no www:**
```
www.mywebclass.org  →  mywebclass.org  →  Server
```

**Implementation:**
```
DNS:
@     A      45.55.209.47
www   CNAME  mywebclass.org

Caddy handles HTTP redirect:
www.mywebclass.org {
    redir https://mywebclass.org{uri}
}
```

**User types www, redirected to non-www version.**

---

## Security Considerations

### DNS Security Checklist

**Protect your domain:**

```
✓ Strong password on registrar account
✓ Two-factor authentication enabled
✓ WHOIS privacy enabled (hides personal info)
✓ Auto-renewal enabled (don't lose domain!)
✓ Lock domain (prevents unauthorized transfers)
✓ Security email notifications enabled
✓ Regular password changes
✓ Don't share registrar login
✓ Use reputable nameserver provider
✓ Monitor DNS changes regularly
```

---

### Monitoring DNS

**Check periodically:**

**Weekly checks:**
```bash
# Verify DNS still correct
dig mywebclass.org +short

# Should always show your IP
45.55.209.47
```

**If IP changes unexpectedly:**
```
1. Check registrar account for unauthorized access
2. Review DNS change logs
3. Change registrar password immediately
4. Enable 2FA if not already
5. Contact registrar support
```

---

### Domain Expiration

**Don't let domain expire!**

**What happens if domain expires:**
```
Day 0:   Domain expires
Day 1:   Grace period (usually 30-45 days)
Day 30:  Domain suspended (DNS stops working)
Day 45:  Domain enters redemption period (expensive to recover)
Day 75:  Domain released to public (anyone can buy it!)
```

**Disaster scenario:**
```
Your domain expires → Someone else buys it → All your links dead!
```

**Prevention:**
```
✓ Enable auto-renewal
✓ Keep payment method updated
✓ Set calendar reminders
✓ Register for multiple years
✓ Check expiration date quarterly
```

---

## Next Steps

**DNS configured! Now you're ready to:**

1. **Deploy infrastructure (Chapter 16)**
   - Clone repository
   - Configure environment files
   - Understand docker-compose setup

2. **Deploy services (Chapter 17)**
   - Start Caddy, PostgreSQL, pgAdmin
   - Automatic HTTPS with Let's Encrypt
   - Access pgAdmin securely

3. **Deploy applications (Chapters 18-19)**
   - Static website
   - Backend application
   - Full stack working with real domain!

---

## Key Takeaways

**Remember:**

1. **DNS points domain to server**
   - A record = Domain to IP
   - CNAME = Alias to another domain
   - Wildcard = All subdomains to IP

2. **Three essential records**
   - Root domain (@ or blank)
   - WWW subdomain
   - Wildcard (*) for flexibility

3. **Propagation takes time**
   - 5-30 minutes typically
   - Up to 48 hours maximum
   - Use dig to check progress

4. **TTL controls caching**
   - 300 for testing
   - 3600+ for production
   - Lower before changes

5. **Security matters**
   - Strong passwords
   - Two-factor authentication
   - Domain lock
   - Auto-renewal

6. **Verification is important**
   - Test with dig command
   - Test with online tools
   - Test in browser
   - Test all subdomains

---

## Quick Reference

### Essential Commands

**Check DNS resolution:**
```bash
dig mywebclass.org +short
dig www.mywebclass.org +short
dig db.mywebclass.org +short
```

**Check specific record types:**
```bash
dig mywebclass.org A +short        # A record
dig mywebclass.org AAAA +short     # AAAA record
dig mywebclass.org MX +short       # MX records
dig mywebclass.org TXT +short      # TXT records
dig mywebclass.org NS +short       # Nameservers
```

**Check with specific DNS server:**
```bash
dig @8.8.8.8 mywebclass.org +short     # Google DNS
dig @1.1.1.1 mywebclass.org +short     # Cloudflare DNS
```

**Clear local DNS cache:**
```bash
# Mac
sudo dscacheutil -flushcache
sudo killall -HUP mDNSResponder

# Linux
sudo systemd-resolve --flush-caches

# Windows
ipconfig /flushdns
```

---

### DNS Records Summary

**Our configuration:**
```
Type    Host    Value            TTL     Purpose
────────────────────────────────────────────────────
A       @       45.55.209.47     300     Root domain
CNAME   www     mywebclass.org   300     WWW subdomain
A       *       45.55.209.47     300     All subdomains
```

---

### Troubleshooting Quick Checks

**DNS not resolving:**
```bash
1. dig mywebclass.org +short
   → Should show IP
   → If blank, check DNS records saved

2. dig mywebclass.org NS +short
   → Should show nameservers
   → If wrong, update at registrar

3. Wait 30 minutes, try again
   → Propagation takes time
```

**Only some locations work:**
```
→ Use whatsmydns.net to check globally
→ Still propagating, wait longer
```

**Wrong IP showing:**
```
→ Check TTL on old record
→ Wait for TTL to expire
→ Clear local DNS cache
```

---

[← Previous: Chapter 14 - DNS Fundamentals](14-dns-fundamentals.md) | [Next: Chapter 16 - Repository Setup →](16-repository-setup.md)
