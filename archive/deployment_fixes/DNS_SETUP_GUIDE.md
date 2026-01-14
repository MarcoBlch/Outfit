# DNS Setup Guide for outfitmaker.ai

## Railway Configuration: ✅ COMPLETE

Railway has been configured with your custom domain `outfitmaker.ai`.

---

## DNS Configuration: ⏳ ACTION REQUIRED

You need to add DNS records at your domain registrar (where you purchased outfitmaker.ai).

### Step-by-Step Instructions:

#### 1. Log in to Your Domain Registrar

Common registrars include:
- GoDaddy
- Namecheap
- Google Domains
- Cloudflare
- Route 53 (AWS)
- Hover
- Porkbun
- etc.

#### 2. Navigate to DNS Settings

Look for one of these sections:
- "DNS Management"
- "DNS Settings"
- "Manage DNS"
- "DNS Records"
- "Advanced DNS"

#### 3. Add the CNAME Record

**Add this exact record:**

```
Type:   CNAME
Name:   @ (or leave blank, or use "outfitmaker.ai")
Value:  u0awjxny.up.railway.app
TTL:    Auto (or 3600)
```

**Important Notes:**
- **Name field variations**: Different registrars use different formats:
  - Some use `@` for root domain
  - Some want it blank/empty
  - Some want the full domain `outfitmaker.ai`
  - Some want just `www`

- **Root Domain CNAME Issue**: Some DNS providers don't allow CNAME records on the root domain (@). If you get an error:

  **Option A - Use Cloudflare (Recommended)**:
  - Transfer your DNS to Cloudflare (free)
  - Cloudflare supports CNAME flattening for root domains
  - Steps:
    1. Sign up at https://cloudflare.com
    2. Add your domain
    3. Update nameservers at your registrar to Cloudflare's nameservers
    4. Add the CNAME record in Cloudflare

  **Option B - Use a Subdomain**:
  - Instead of root domain, use `app.outfitmaker.ai` or `www.outfitmaker.ai`
  - Run: `railway domain app.outfitmaker.ai`
  - This will give you new DNS instructions

#### 4. Verify DNS Propagation

After adding the DNS record, you can check if it's propagated:

**Using command line:**
```bash
dig outfitmaker.ai CNAME
# or
nslookup outfitmaker.ai
```

**Using online tools:**
- https://www.whatsmydns.net/
- https://dnschecker.org/

#### 5. Wait for SSL Certificate

Once DNS propagates (usually 15 minutes to 2 hours):
- Railway will automatically detect the DNS change
- Railway will provision a free SSL certificate
- Your site will be accessible at https://outfitmaker.ai

---

## Troubleshooting

### "CNAME not allowed on root domain"

**Solution**: Use Cloudflare or switch to a subdomain (app.outfitmaker.ai)

### "DNS not propagating"

**Check**:
1. Verify the record was saved correctly
2. Wait longer (can take up to 72 hours, usually much faster)
3. Clear your DNS cache: `sudo dscacheutil -flushcache` (Mac) or `ipconfig /flushdns` (Windows)

### "Still seeing Railway's default domain"

**Check**:
1. DNS propagation (use whatsmydns.net)
2. Clear browser cache
3. Try incognito/private browsing mode

---

## Current Status

- ✅ Railway configured with domain: `outfitmaker.ai`
- ✅ DNS records provided: CNAME @ → `u0awjxny.up.railway.app`
- ⏳ **Next step**: Add CNAME record at your domain registrar
- ⏳ **Then**: Wait for DNS propagation (15 min - 2 hours typically)
- ⏳ **Finally**: Railway auto-provisions SSL certificate

---

## Which Domain Registrar Are You Using?

Common registrar-specific guides:

### GoDaddy
1. Go to: https://dcc.godaddy.com/manage/
2. Select your domain
3. Click "DNS" → "Manage Zones"
4. Add CNAME record

### Namecheap
1. Go to: https://ap.www.namecheap.com/domains/list/
2. Click "Manage" next to your domain
3. Click "Advanced DNS"
4. Add CNAME record

### Cloudflare
1. Go to: https://dash.cloudflare.com/
2. Select your domain
3. Click "DNS" tab
4. Add CNAME record
5. Set "Proxy status" to "DNS only" (gray cloud)

### Google Domains
1. Go to: https://domains.google.com/
2. Click your domain
3. Click "DNS" in left menu
4. Scroll to "Custom resource records"
5. Add CNAME record

---

## Questions?

If you encounter issues:
1. Let me know which registrar you're using
2. Share any error messages you see
3. I can provide registrar-specific instructions
