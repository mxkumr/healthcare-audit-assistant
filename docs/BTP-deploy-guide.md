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

### Local launch page (Doc 05)

With `cds watch` running, open:

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
| `/resources/*`, `/test-resources/*` | UI5 CDN |
| everything else | HTML5 Applications Repository runtime |

---

## Part D — Launchpad (Doc 09) — simplified

Full **Portal service + CommonDataModel.json** is **not required** for Joule.

Your MTA uses **HTML5 Applications Repository**:
- `app-host` — stores built Fiori zips
- `app-runtime` — serves them via approuter

Currently packaged Fiori apps: **1.1 Cost Analysis**, **1.3 BH Risk**.

To add more apps later: duplicate the `commedicare11costanalysis` module pattern in `mta.yaml`.

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

# mbt binary fix (if needed on BAS)
mkdir -p node_modules/mbt/unpacked_bin
ln -sf "$(which mbt)" node_modules/mbt/unpacked_bin/mbt

rm -rf resources mta_archives
mbt build --mtar archive
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
- Fiori: `https://<approuter-url>/commedicare11costanalysis`
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
| `rimraf: not found` | Use `rm -rf resources mta_archives && mbt build` |
| `mbt/unpacked_bin/mbt: not found` | Global mbt + symlink (see Part E) |
| `Not logged in` | `cf login` |
| 401 on `/medicare` | Assign admin or audit_analyst role |
| White Fiori screen | Check `$metadata` + browser console |
| HTML5 app 404 | Confirm `html5-runtime` service bound to approuter |
| Empty agent data | Check db-deployer logs: `cf logs healthcare-audit-assistant-db-deployer --recent` |

---

## Quick command cheat sheet

```bash
# Local
npm ci && cds watch
# → http://localhost:4004/launchpage.html#Shell-home

# Build
npm ci && mbt build --mtar archive

# Deploy
cf login && cf deploy mta_archives/archive.mtar --retries 1

# Verify
cf apps
cf oauth-token
curl https://<approuter>/medicare/$metadata -H "Authorization: Bearer $(cf oauth-token | sed 's/bearer //')"
```

See also: [4.1-autonomous-audit-agent.md](./4.1-autonomous-audit-agent.md)
