# Railway Snapshot Timeout - Manual Fix Instructions

## Problem
Railway GitHub integration keeps failing with "Repository snapshot operation timed out" even though the repository is only 9.2MB after cleanup.

## Root Cause
This is likely a **Railway platform issue** with the GitHub integration, not your repository size. Railway's snapshot mechanism is timing out before even attempting to clone.

## Solutions (Try in order)

### Solution 1: Disconnect and Reconnect GitHub Integration (RECOMMENDED)

**Steps:**
1. Go to Railway Dashboard → Your Outfit service
2. Click on **Settings** tab
3. Scroll to **Source** section
4. Click **Disconnect** to disconnect the GitHub repository
5. Wait 30 seconds
6. Click **Connect Repo** button
7. Select **MarcoBlch/Outfit** repository
8. Select **master** branch
9. Click **Deploy Now**

**Why this works:** Forces Railway to re-establish the GitHub integration and clear any cached snapshot state.

---

### Solution 2: Create New Service with Empty Service + Railway CLI

Since Railway CLI installation requires sudo (which isn't available), you'll need to:

**Steps:**
1. Go to Railway Dashboard
2. Create **New Service** → **Empty Service**
3. Name it "Outfit-CLI" or similar
4. On your local machine, install Railway CLI:
   ```bash
   sudo curl -fsSL https://railway.com/install.sh | sh
   ```
5. Authenticate:
   ```bash
   railway login
   ```
6. Link your project:
   ```bash
   cd /home/marc/code/MarcoBlch/Outfit
   railway link
   ```
   - Select your project
   - Select the "Outfit-CLI" service
7. Deploy:
   ```bash
   railway up --detach
   ```

**Why this works:** Bypasses the GitHub integration entirely and uploads your code directly via CLI.

---

### Solution 3: Use GitHub Actions to Deploy via Railway CLI

**Create file:** `.github/workflows/railway-deploy.yml`

```yaml
name: Deploy to Railway

on:
  push:
    branches: [master]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Install Railway CLI
        run: npm install -g @railway/cli

      - name: Deploy to Railway
        run: railway up --detach
        env:
          RAILWAY_TOKEN: ${{ secrets.RAILWAY_TOKEN }}
```

**Setup:**
1. Get Railway API token from Railway Dashboard → Account Settings → Tokens
2. Add token to GitHub Secrets: Settings → Secrets → New secret named `RAILWAY_TOKEN`
3. Push this workflow file
4. GitHub Actions will deploy to Railway on every push

**Why this works:** Uses Railway CLI in GitHub Actions, avoiding Railway's GitHub integration entirely.

---

### Solution 4: Switch to Docker Image Deployment

**Create file:** `.github/workflows/docker-deploy.yml`

```yaml
name: Build and Deploy Docker Image

on:
  push:
    branches: [master]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Log in to GitHub Container Registry
        uses: docker/login-action@v2
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Build and push Docker image
        uses: docker/build-push-action@v4
        with:
          context: .
          push: true
          tags: ghcr.io/${{ github.repository }}:latest

      - name: Deploy to Railway
        run: |
          # Railway will pull the image from ghcr.io
          curl -X POST https://backboard.railway.app/graphql/v2 \
            -H "Authorization: Bearer ${{ secrets.RAILWAY_TOKEN }}" \
            -H "Content-Type: application/json" \
            -d '{
              "query": "mutation { serviceInstanceDeploy(serviceId: \"${{ secrets.RAILWAY_SERVICE_ID }}\") { id } }"
            }'
```

**Setup:**
1. In Railway Dashboard, change your service source to **Docker Image**
2. Set image source to: `ghcr.io/MarcoBlch/Outfit:latest`
3. Add `RAILWAY_TOKEN` and `RAILWAY_SERVICE_ID` to GitHub Secrets
4. Push workflow file

**Why this works:** Railway pulls a pre-built Docker image instead of cloning your repository.

---

### Solution 5: Contact Railway Support (If all else fails)

Railway's snapshot operation should not timeout on a 9.2MB repository. This indicates a platform issue.

**Steps:**
1. Go to [Railway Help Station](https://station.railway.com/)
2. Create a new question with:
   - Title: "Repository snapshot operation timed out for 9.2MB repository"
   - Include your service ID
   - Mention you've cleaned up .git from 248MB to 828KB
   - Mention repository is only 9.2MB deployable size
   - Reference deployment ID: `18c83844`

**Include this diagnostic info:**
```
Repository size: 9.2MB (excluding .git, node_modules, vendor)
.git size: 828KB
Tracked files: 327
Largest file: 41KB (PRODUCT_ROADMAP_v2.md)
Dockerfile-based deployment
Error: "Repository snapshot operation timed out"
Occurs at: Initialization > Snapshot code (before build starts)
```

---

## Recommended Immediate Action

**Try Solution 1 first** (Disconnect/Reconnect GitHub). It's the quickest and most likely to resolve the issue.

If that doesn't work within 2 deployments, **implement Solution 3** (GitHub Actions + Railway CLI) as it's the most robust long-term solution for production deployments.

---

## Why Your Repository Is Fine

After all our optimizations:
- ✅ .git: 828KB (was 248MB) - **99.7% reduction**
- ✅ Deployable size: 9.2MB (was 1.3GB) - **99.3% reduction**
- ✅ Largest file: 41KB (PRODUCT_ROADMAP_v2.md)
- ✅ No binaries, no large assets
- ✅ .dockerignore properly excludes node_modules, vendor, .venv

**Your repository is optimally configured.** The snapshot timeout is a Railway platform issue, not a repository size issue.

---

## Sources

- [Railway: Disconnect/Reconnect GitHub](https://station.railway.com/questions/cannot-reconnect-to-github-repo-bf845bd2)
- [Railway: Using the CLI](https://docs.railway.com/guides/cli)
- [Railway: GitHub Actions Deployment](https://docs.railway.com/guides/deployment-actions)
- [Railway: Controlling GitHub Autodeploys](https://docs.railway.com/guides/github-autodeploys)
