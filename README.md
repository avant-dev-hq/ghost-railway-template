# Ghost on Railway — Production Template

Deploy Ghost CMS on Railway with zero setup hell. This template encodes every lesson from a real production incident.

## What's included

| File | Purpose |
|------|--------|
| `config.production.json` | Correct Ghost config for Railway (CSRF + healthcheck + trustProxy) |
| `railway.json` | TCP-only healthcheck (no HTTP redirect issues) |
| `Dockerfile` | Minimal Ghost Docker build |

---

## Deploy in 5 minutes

### 1. Fork this repo

### 2. Create Railway project
- New Project → Deploy from GitHub repo → select this fork
- Add MySQL database service

### 3. Set Ghost environment variables

```
database__client          = mysql
database__connection__host     = ${{MySQL.MYSQL_HOST}}
database__connection__user     = ${{MySQL.MYSQL_USER}}
database__connection__password = ${{MySQL.MYSQL_PASSWORD}}
database__connection__database = ${{MySQL.MYSQL_DATABASE}}
database__connection__port     = ${{MySQL.MYSQL_PORT}}
NODE_ENV                  = production
server__port              = 8080
```

> ⚠️ Use Railway reference variables (`${{MySQL.xxx}}`). Never hardcode credentials.

### 4. Update config.production.json

Replace `YOUR_APP` with your actual Railway subdomain:

```json
"url": "https://your-app.up.railway.app",
"admin": { "url": "https://your-app.up.railway.app" }
```

Or set your custom domain if you have one.

### 5. Deploy → open `/ghost` → create your user

---

## Why these configs? (The hard-learned reasons)

### config.production.json

**`url` = https://**  
Ghost generates all asset/page URLs from `config.url`. If `http://`, browser loads https page with http assets → mixed content → broken styles.

**`admin.url` = https://**  
Ghost CSRF protection validates the browser `Origin` header against `[config.url, config.admin.url]`. Browser connects via `https://` → without `admin.url`, Ghost only checks `config.url` → mismatch → `400 Bad Request` on ALL admin API calls. You can never log in.

**`trustProxy: true`**  
Railway edge proxy terminates SSL and passes `X-Forwarded-Proto: https`. Ghost needs this to generate correct URLs and handle sessions.

### railway.json

**No `healthcheckPath`**  
Railway healthchecks hit the container via plain HTTP (no TLS). Ghost redirects HTTP→HTTPS with 301. Railway does NOT follow redirects — it requires `200 OK`. Without a path, Railway uses TCP healthcheck (port open = healthy). Ghost is running, TCP confirms it. ✅

---

## Setup wizard not appearing?

Ghost may have completed setup in a failed boot. Run in Railway MySQL Query UI:

```sql
SET FOREIGN_KEY_CHECKS = 0;
DELETE FROM roles_users;
DELETE FROM users;
SET FOREIGN_KEY_CHECKS = 1;
UPDATE settings SET value='false' WHERE settings.key='setup_completed';
```

Restart Ghost service → wizard appears.

---

## Known non-critical warnings (safe to ignore)

| Warning | Meaning |
|---------|--------|
| `Missing mail.from config` | Configure SMTP in Settings → Email |
| `No webhook secret found` | ActivityPub feature not deployed (optional) |
| `/.ghost/activitypub 404` | Same as above |
| `punycode deprecated` | Node.js internal, harmless |
| `Tinybird not configured` | Analytics feature, optional |

---

## ActivityPub (Ghost Network)

Ghost 6.x includes a social network feature (follow/be followed via ActivityPub protocol). The `No webhook secret` warning appears because it requires a separate ActivityPub service deployment. It does NOT affect core Ghost functionality.

To enable: Ghost Admin → Settings → Labs → Enable Ghost Network (requires additional setup).

---

Maintained by [Avant.Dev](https://avant.dev)
