# BTP Deploy Guide — Mapped to Course Docs (04–13)

This guide maps the **SAP BTP course documentation** to **healthcare-audit-assistant** and gives the exact deploy + Joule steps.

---

## Course doc → Your project status

| Doc | Topic | Your project |
|-----|--------|--------------|
| **04** Add Custom Logic | `srv/*.js` handlers | ✅ `srv/medicare-service.js` + `srv/lib/audit-agent.js` |
| **05** Local Launch Page | `app/launchpage.html` | ✅ Added — all Task 1–3 apps |
| **06** Authorization | XSUAA + mocked users | ✅ `xs-security.json` + dev users in `package.json` |
| **07** Prepare for Production | HANA + XSUAA | ✅ `[production]` → `auth: xsuaa`, `db: hana` |
| **08** Application Router | `app/router/xs-app.json` | ✅ OData + HTML5 repo routes |
| **09** Set Up Launchpad | Portal + CommonDataModel | ⏳ **Optional** — HTML5 repo only (no Work Zone portal yet) |
| **10** Deploy & Test | `mbt build` + `cf deploy` | 👉 **You are here** |
| **11** AI Analytics | Fiori action + AI endpoint | ✅ Replaced by Task 4 OData actions (better for Joule) |
| **13** Joule Skill Setup | SAP Build skill + destination | 👉 After deploy |

---

## Part A — Local dev (Docs 04–06)

### Custom logic (Doc 04)
Already implemented — Joule actions on `MedicareService`:
- `investigateAnomalies`
- `getRegionalBillingOutliers`
- `getProviderClaimDetails`
- `getSpecialtyPeerOutliers`
- `listAuditYears`

### Local dev on BAS (avoid dual `@sap/cds` error)

BTP Application Studio often has a **global** `@sap/cds` under `/extbin/globals/bun/...`. Running bare `cds watch` loads **both** global and project copies → error.

**Use project-local CAP only:**

```bash
cd ~/projects/healthcare-audit-assistant
npm ci --include=dev
npm run watch-audit-home    # 9-card OVP dashboard
# or: npm run watch
```

Do **not** run `cds watch` directly. If you must, prepend local bin:

```bash
export PATH="$PWD/node_modules/.bin:$PATH"
cds watch
```

Open: `http://localhost:4004/com.medicare.audithome/index.html` (use BAS port-forward preview URL).

### Local launch page (Doc 05)

With `npm run watch` running, open:

```
http://localhost:4004/launchpage.html#Shell-home
```

On BTP Application Studio, use your port-4004 workspace URL + `/launchpage.html#Shell-home`.

### Local auth (Doc 06)

Dev users (mocked auth):

| User | Password | Role |
|------|----------|------|
| `audit.admin@tester.sap.com` | `initial` | admin |
| `audit.analyst@tester.sap.com` | `initial` | audit.read |

---

## Part B — Production prep (Doc 07)

Already configured in `package.json`:

```json
"[production]": {
  "auth": "xsuaa",
  "db": "hana"
}
```

Verify build:

```bash
npm ci
npx cds build --production
```

---

## Part C — Application Router (Doc 08)

`app/router/xs-app.json` routes:

| Route | Target |
|-------|--------|
| `/medicare/*` | CAP srv (OData + agent actions) |
| `/commedicare*/medicare/*` | CAP srv (fallback for nested HTML5 OData paths) |
| `/resources/*`, `/test-resources/*` | UI5 CDN |
| everything else | HTML5 Applications Repository runtime |

**Welcome file:** `/commedicareaudithome/index.html` (Audit Command Center dashboard).

---

## Part D — Launchpad (Doc 09) — simplified

Full **Portal service + CommonDataModel.json** is **not required** for Joule.

Your MTA uses **HTML5 Applications Repository**:
- `app-host` — stores built Fiori zips
- `app-runtime` — serves them via approuter

Currently packaged Fiori apps: **14 HTML5 modules** — main dashboard (OVP), three task overviews, ten ALP drill-down apps.

| Layer | App ID | BTP path |
|-------|--------|----------|
| **Landing (9-card OVP)** | `com.medicare.audithome` | `/commedicareaudithome/index.html` |
| Task 1 OVP | `com.medicare.task1overview` | `/commedicaretask1overview/index.html` |
| Task 2 OVP | `com.medicare.task2overview` | `/commedicaretask2overview/index.html` |
| Task 3 OVP | `com.medicare.task3overview` | `/commedicaretask3overview/index.html` |
| 1.1 ALP | `com.medicare.11costanalysis` | `/commedicare11costanalysis/index.html` |
| 1.2 ALP | `com.medicare.12ruralanalysis` | `/commedicare12ruralanalysis/index.html` |
| 1.3 ALP | `com.medicare.13behavioralhelathrisk` | `/commedicare13behavioralhelathrisk/index.html` |
| 2.1 ALP | `com.medicare.21providerclassification` | `/commedicare21providerclassification/index.html` |
| 2.2a ALP | `com.medicare.22aspecialtyprofiling` | `/commedicare22aspecialtyprofiling/index.html` |
| 2.2b ALP | `com.medicare.22borganizationprofiling` | `/commedicare22borganizationprofiling/index.html` |
| 3.1 ALP | `com.medicare.31riskdynamics` | `/commedicare31riskdynamics/index.html` |
| 3.2 ALP | `com.medicare.32placeofservice` | `/commedicare32placeofservice/index.html` |
| 3.3 ALP | `com.medicare.33credentialdiscrepancies` | `/commedicare33credentialdiscrepancies/index.html` |
| Risk ALP | `com.medicare.riskanalysis` | `/commedicareriskanalysis/index.html` |

### Audit journey (native Fiori Elements OVP → ALP)

**Audit Home** is a single OVP with **9 cards** — one preview per audit view. Each card header links directly to its ALP drill-down app:

| Card | ALP app |
|------|---------|
| 1.1 State Cost Analysis | `/commedicare11costanalysis/index.html` |
| 1.2 Rural vs Urban | `/commedicare12ruralanalysis/index.html` |
| 1.3 Behavioral Health Risk | `/commedicare13behavioralhelathrisk/index.html` |
| 2.1 Provider Efficiency | `/commedicare21providerclassification/index.html` |
| 2.2a Specialty Peers | `/commedicare22aspecialtyprofiling/index.html` |
| 2.2b Entity Type | `/commedicare22borganizationprofiling/index.html` |
| 3.1 Risk Dynamics | `/commedicare31riskdynamics/index.html` |
| 3.2 Place of Service | `/commedicare32placeofservice/index.html` |
| 3.3 Credential Gaps | `/commedicare33credentialdiscrepancies/index.html` |

Each card uses **DataFieldWithUrl** (`UI.Identification` in CDS). All apps are **Fiori Elements** (OVP or ALP) — no custom UI5 views.

To add or reorder apps, edit `scripts/html5-apps.json` and run `npm run build` (regenerates `mta.yaml` HTML5 modules automatically).

---

## Part E — Deploy on BTP (Doc 10)

### Prerequisites (BTP Cockpit)

Entitlements for your subaccount:
- Cloud Foundry runtime
- **XSUAA** (application)
- **SAP HANA Cloud / HDI** (`hana` / `hdi-shared`)
- **HTML5 Application Repository** (`app-host` + `app-runtime`)
- **Destination** (lite)

### Build (on BTP terminal)

```bash
cd ~/projects/healthcare-audit-assistant

npm ci
npm install -g mbt          # once per BAS workspace — MTA build needs this binary
npm run build               # runs ensure-mbt, then mbt build
```

If `ensure-mbt` fails, link manually:

```bash
mkdir -p node_modules/mbt/unpacked_bin
ln -sf "$(which mbt)" node_modules/mbt/unpacked_bin/mbt
npm run build
```

Success:

```text
the MTA archive generated at: .../mta_archives/archive.mtar
```

### Login & deploy

```bash
cf api <YOUR-API-ENDPOINT>
cf login
cf target -o <ORG> -s <SPACE>

cf deploy mta_archives/archive.mtar --retries 1
```

Example API endpoints:
- EU10: `https://api.cf.eu10.hana.ondemand.com`
- US10: `https://api.cf.us10.hana.ondemand.com`

### After deploy — assign roles

BTP Cockpit → **Security → Role Collections** → assign **your user**:

1. `admin (healthcare-audit-assistant <org>-<space>)`
2. `audit_analyst (healthcare-audit-assistant <org>-<space>)` — for Joule/OData

### Get app URL

```bash
cf app healthcare-audit-assistant
```

Open in browser:
- **Dashboard (start here):** `https://<approuter-url>/commedicareaudithome/index.html`
- Task 1 OVP: `https://<approuter-url>/commedicaretask1overview/index.html`
- OData metadata: `https://<approuter-url>/medicare/$metadata`

### Test agent on BTP

```bash
TOKEN=$(cf oauth-token | sed 's/bearer //')
curl -X POST "https://<approuter-url>/medicare/investigateAnomalies" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"prompt":"CA Pain Management audit","year":"2022","state":"CA","specialty":"Pain Management","npi":"1003056821"}'
```

---

## Part F — Joule Skill (Doc 13)

After deploy succeeds:

### 1. Create destination (BTP Cockpit → Connectivity → Destinations)

| Field | Value |
|-------|--------|
| Name | `HealthcareAuditMedicare` |
| URL | `https://<approuter-url>/medicare` |
| Type | HTTP |
| Proxy Type | Internet |
| Authentication | OAuth2UserTokenExchange or OAuth2SAMLBearer |
| Forward Auth Token | Yes |

Use the XSUAA binding from your deployed app.

### 2. SAP Build → Create Joule Agent + Skill

1. **Create** → **Joule Agent and Skill**
2. Name: e.g. `HealthcareAuditAgent`
3. Add Skill: e.g. `InvestigateAnomalies`
4. Add step: **Call Action**
5. **Browse All Actions** → select **`investigateAnomalies`** from `MedicareService`
6. Create **Destination Variable** → point to `HealthcareAuditMedicare`
7. On **Success** → **Send Message** with bound fields:
   - `narrative`
   - `confidenceScore`
   - `flaggedNPIs`
8. On **Error 4XX** → **Send Message** with error text

### 3. Test & deploy skill

1. Control Tower → **Private Environment Active**
2. Skill editor → **Test** → select environment + destination
3. Prompt: *"Investigate CA Pain Management billing for NPI 1003056821 in 2022"*
4. **Release** → **Deploy** to your Joule tutorial environment

---

## Part G — AI Analytics (Doc 11) vs Task 4

Course doc 11 adds a Fiori **Evaluate AI** button calling SAP AI Core directly.

**Your project uses a better pattern for Joule:**
- OData **actions** with real CDS view grounding
- Structured response (`narrative`, `flaggedNPIs`, `reasoningSteps`)
- `AgentScratchpad` audit trail

No separate `.env` AI credentials needed for the Joule path.

---

## Troubleshooting

| Issue | Fix |
|-------|-----|
| `npm ci` fails — missing workspace in lock file | Run `npm install` locally, commit updated `package-lock.json`, then rebuild. Common after adding new apps under `app/*` workspaces (`audit-home`, `task3-overview`, etc.). |
| `rimraf: not found` | Use `rm -rf resources mta_archives && mbt build` |
| `cds watch` — @sap/cds loaded from two locations | BAS has a **global** `@sap/cds` (bun) plus project `node_modules`. Use **local only**: `npm ci --include=dev` then `npm run watch` (not bare `cds watch`). See **Local dev on BAS** below. |
| `mbt/unpacked_bin/mbt: not found` | Run `npm ci --include=dev && npm run ensure-mbt`. MTA `before-all` does this automatically. Fallback: `npm install -g mbt && npm run ensure-mbt` |
| `Not logged in` | `cf login` |
| 401 on `/medicare` | Assign admin or audit_analyst role |
| White Fiori screen (local `npm run watch`) | `index.html` must use **relative** `resources/sap-ui-core.js` (not `/resources/`). Root `/resources/` is 404 on cds watch; app path `/com.medicare.audithome/resources/` works. Restart watch after pull. |
| White Fiori screen (BTP) | See **White screen after login** below |
| HTML5 app 404 | Confirm `html5-runtime` service bound to approuter |
| Empty agent data | Check db-deployer logs: `cf logs healthcare-audit-assistant-db-deployer --recent` |
| Internal Server Error in Fiori | See **Internal Server Error (500)** below |
| db-deployer CSV load failed | Run `npm run sanitize-data` before build; see **HANA CSV deploy errors** below |

### HANA CSV deploy errors

SQLite accepts empty strings (`""`) and `$1,234.56` in numeric CMS columns; **HANA rejects them**. Typical db-deployer errors:

| Error | Cause | Fix |
|-------|-------|-----|
| `cannot insert NULL: ID` | `ServiceDetails` had UUID key not in CSV | Fixed: composite key `Year+NPI+HCPCS+Place` |
| `invalid number string ''` | Empty quoted fields in `ProviderSummary` numeric columns | `npm run sanitize-data` before build |

The MTA build runs `node scripts/sanitize-csv-for-hana.js` automatically in `before-all`.

After pulling fixes:

```bash
npm ci && npm install -g mbt && npm run build
cf deploy mta_archives/archive.mtar --retries 1
cf logs healthcare-audit-assistant-db-deployer --recent   # expect "Deployment finished successfully"
```

### Internal Server Error (500)

The UI shell loads but data requests fail — the CAP **srv** or **HANA db-deployer** is the problem.

**1. Find the failing request (browser DevTools → Network)**

Look for red **500** on URLs like:
- `/medicare/CostAnalysisV2?...`
- `/medicare/CostAnalysisV2/$count?...`

Copy the full URL — it shows which query failed (KPI, chart, or table).

**2. Test the backend directly (BTP terminal)**

```bash
TOKEN=$(cf oauth-token | sed 's/bearer //')
APP=https://btplearning-btpailearning-student15-healthcare-audit-assistant.cfapps.us10.hana.ondemand.com

# Simple read — should return JSON rows, not 500
curl -s -o /dev/null -w "%{http_code}\n" \
  "$APP/medicare/CostAnalysisV2?\$top=1" \
  -H "Authorization: Bearer $TOKEN"
```

| Result | Meaning |
|--------|---------|
| **200** | Backend OK — likely a complex `$apply` / KPI query; pull latest annotation fixes and redeploy |
| **500** | Database or srv crash — check logs below |
| **401** | Role assignment needed |

**3. Check srv logs**

```bash
cf logs healthcare-audit-assistant-srv --recent
```

Look for SQL errors, `table not found`, HANA connection failures, or `$apply` translation errors.

**4. Check db-deployer (most common on student HANA)**

```bash
cf logs healthcare-audit-assistant-db-deployer --recent
```

The deployer runs once at deploy time. If CSV load failed (disk quota, timeout), tables are empty/missing → all data queries return **500**.

Redeploy to retry:

```bash
cf deploy mta_archives/archive.mtar --retries 1
```

**5. Confirm apps are running**

```bash
cf apps
```

| App | Expected state |
|-----|----------------|
| `healthcare-audit-assistant-srv` | **started** |
| `healthcare-audit-assistant` | **started** |
| `healthcare-audit-assistant-db-deployer` | **stopped** (normal after successful deploy) |

### White screen after login

Login works but the page stays blank — almost always **OData metadata or UI5 bootstrap failing** after auth.

**1. Open browser DevTools → Network** (after login) and look for:

| Request | Expected | If it fails |
|---------|----------|-------------|
| `/medicare/$metadata` | **200** XML | 404 → see **Metadata 404** below; 401/403 → roles; 502 → srv down |
| `/resources/sap-ui-core.js` | **200** JS | UI5 CDN blocked → index.html must use `/resources/` (approuter → ui5 destination) |
| `/commedicare11costanalysis/Component-preload.js` | **200** | HTML5 repo not deployed → rebuild MTA |

**2. Test OData from BTP terminal** (same user/session as browser):

```bash
TOKEN=$(cf oauth-token | sed 's/bearer //')
curl -s -o /dev/null -w "%{http_code}" \
  "https://<approuter-url>/medicare/\$metadata" \
  -H "Authorization: Bearer $TOKEN"
```

Expect `200`. If `401`, assign role collections (see Part E). If `404`, check `app/router/xs-app.json` medicare route.

**3. Try explicit app URL**

```
https://<approuter-url>/commedicare11costanalysis/index.html
https://<approuter-url>/commedicare13behavioralhelathrisk/index.html
```

### Metadata 404

In DevTools, check the **full URL** of the failing `$metadata` request:

| Failing URL | Cause | Fix |
|-------------|-------|-----|
| `/commedicare11costanalysis/medicare/$metadata` | HTML5 zip built with `relativePaths: true` — relative OData URI | Redeploy (see below). **Approuter fallback routes** in `xs-app.json` also forward this path to CAP srv. |
| `/medicare/$metadata` | CAP srv not reachable or wrong service path | `cf apps` — srv must be **started**. `cf logs healthcare-audit-assistant-srv --recent` |

**Redeploy (BTP terminal):**

```bash
git pull   # get relativePaths: false + approuter fallback routes
npm ci && npm run build
cf deploy mta_archives/archive.mtar --retries 1
```

**Verify after deploy:**

```bash
TOKEN=$(cf oauth-token | sed 's/bearer //')
curl -s -o /dev/null -w "%{http_code}\n" \
  "https://<approuter-url>/medicare/\$metadata" \
  -H "Authorization: Bearer $TOKEN"
```

Expect `200`. Then hard-refresh the Fiori app (private window).

**4. Root cause: `relativePaths: true` in `ui5-deploy.yaml`**

With a **standalone approuter** (not Work Zone), OData must use an **absolute** path `/medicare/` so requests hit the approuter medicare route. If the HTML5 zip is built with `relativePaths: true`, the URI becomes `medicare/` and the browser calls `/commedicare11costanalysis/medicare/$metadata` → **404** → white screen.

Fix in repo: `relativePaths: false` in both `ui5-deploy.yaml` files; keep `"uri": "/medicare/"` in manifest.

**5. Other code fixes** (redeploy after pull)

- `index.html` UI5 bootstrap: `src="/resources/sap-ui-core.js"` (via approuter ui5 destination)
- Approuter `welcomeFile`: `/commedicareaudithome/index.html`

**6. If `$metadata` is 200 but UI still blank**

Open Console tab — Fiori Elements fails silently when UI annotations are missing. Check metadata contains `CostAnalysisV2` and `UI.SelectionPresentationVariant` with qualifier `ALPDashboard`. CAP merges annotations from `app/services.cds` at `cds build --production` time.

**6. Role assignment without Security menu**

Ask instructor to assign your BTP user to:

- `admin (healthcare-audit-assistant BTPLearning_btpailearning-student15)`
- `audit_analyst (healthcare-audit-assistant BTPLearning_btpailearning-student15)`

Application: `healthcare-audit-assistant-BTPLearning_btpailearning-student15!t564356`

**7. Redeploy after fixes**

```bash
npm ci && npm run build
cf deploy mta_archives/archive.mtar --retries 1
```

---

## Quick command cheat sheet

```bash
# Local (BAS — use npm scripts, not bare cds watch)
npm ci --include=dev && npm run watch-audit-home
# → http://localhost:4004/com.medicare.audithome/index.html

# Build
npm ci && npm install -g mbt && npm run build

# Deploy
cf login && cf deploy mta_archives/archive.mtar --retries 1

# Verify
cf apps
cf oauth-token
curl https://<approuter>/medicare/$metadata -H "Authorization: Bearer $(cf oauth-token | sed 's/bearer //')"
```

See also: [4.1-autonomous-audit-agent.md](./4.1-autonomous-audit-agent.md)
