sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/ui/model/json/JSONModel",
    "sap/m/MessageToast",
    "sap/ui/vbm/AnalyticMap"
], function (Controller, JSONModel, MessageToast, AnalyticMap) {
    "use strict";

    var YEAR = "2023";
    var PREV = "2022";

    // Sequential blue palette (light → dark) for the choropleth.
    var BLUES = ["#cfe3f5", "#9ecae1", "#6baed6", "#3182bd", "#08519c"];
    var NO_DATA = "#34465c";

    // sap.ui.vbm needs the L1 (state-level) US region geometry. Pin it to the
    // same CDN version the app bootstraps from so it resolves standalone.
    AnalyticMap.GeoJSONURL =
        "https://sapui5.hana.ondemand.com/1.148.1/test-resources/sap/ui/vbm/demokit/media/analyticmap/L1_US.json";

    return Controller.extend("com.medicare.auditdashboard.controller.App", {

        onInit: function () {
            this._oModel = new JSONModel({
                kpi: {},
                providerType: [],
                ruralUrban: [],
                riskDist: [],
                outliers: [],
                riskAssoc: [],
                credGap: [],
                placeCharge: [],
                placeVolume: [],
                mapRegions: [],
                mapLegend: [],
                insights: {
                    cost:  [this._blankInsight(), this._blankInsight()],
                    pop:   [this._blankInsight(), this._blankInsight()],
                    assoc: [this._blankInsight(), this._blankInsight(), this._blankInsight()]
                }
            });
            this.getView().setModel(this._oModel, "dash");

            this._styleCharts();
            this._loadAll();
        },

        onMenuToggle: function () {
            var oTP = this.byId("toolPage");
            oTP.setSideExpanded(!oTP.getSideExpanded());
        },

        // ── Data orchestration ────────────────────────────────────────────
        _loadAll: function () {
            this._loadKpis();
            this._loadProviderType();
            this._loadRuralUrban();
            this._loadRiskDist();
            this._loadOutliers();
            this._loadMap();
            this._loadRiskAssoc();
            this._loadCredGap();
            this._loadPlaceAnalysis();
        },

        _get: function (sUrl) {
            return fetch(sUrl, { headers: { Accept: "application/json" } })
                .then(function (r) {
                    if (!r.ok) { throw new Error("HTTP " + r.status); }
                    return r.json();
                })
                .then(function (j) { return j.value || []; });
        },

        // ── KPI tiles ─────────────────────────────────────────────────────
        _loadKpis: function () {
            var that = this;
            var agg = "/aggregate(TotalPaid,ProviderCount,TotalBeneficiaries,AvgRiskScore)";
            var base = "/medicare/CostByStateProviderType?$apply=filter(Year eq ";
            Promise.all([
                this._get(base + "'" + YEAR + "')" + agg),
                this._get(base + "'" + PREV + "')" + agg)
            ]).then(function (aRes) {
                var cur = aRes[0][0] || {};
                var prv = aRes[1][0] || {};
                var k = {};

                var spend = parseFloat(cur.TotalPaid) || 0;
                var sc = that._scale(spend);
                k.spendNum = sc.num; k.spendScale = sc.unit;
                that._trend(k, "spend", spend, parseFloat(prv.TotalPaid) || 0, true);

                var prov = parseFloat(cur.ProviderCount) || 0;
                var pc = that._scale(prov);
                k.provNum = pc.num; k.provScale = pc.unit;
                that._trend(k, "prov", prov, parseFloat(prv.ProviderCount) || 0, true);

                var risk = parseFloat(cur.AvgRiskScore) || 0;
                k.riskNum = risk.toFixed(2);
                that._trend(k, "risk", risk, parseFloat(prv.AvgRiskScore) || 0, true);

                var bene = parseFloat(cur.TotalBeneficiaries) || 0;
                var bc = that._scale(bene);
                k.beneNum = bc.num; k.beneScale = bc.unit;
                that._trend(k, "bene", bene, parseFloat(prv.TotalBeneficiaries) || 0, true);

                that._oModel.setProperty("/kpi", k);
            }).catch(function (e) { MessageToast.show("KPI load failed: " + e.message); });
        },

        _scale: function (v) {
            if (v >= 1e9) { return { num: (v / 1e9).toFixed(1), unit: "B" }; }
            if (v >= 1e6) { return { num: (v / 1e6).toFixed(1), unit: "M" }; }
            if (v >= 1e3) { return { num: (v / 1e3).toFixed(1), unit: "K" }; }
            return { num: String(Math.round(v)), unit: "" };
        },

        _trend: function (k, key, cur, prev, upGood) {
            var pct = prev > 0 ? ((cur - prev) / prev) * 100 : 0;
            var up = pct >= 0;
            k[key + "Trend"] = (up ? "+" : "") + pct.toFixed(1) + "%";
            k[key + "Dir"] = up ? "Up" : "Down";
            k[key + "State"] = (up === !!upGood) ? "Good" : "Error";
        },

        // ── Cost by provider type (top 10), values in $B ───────────────────
        _loadProviderType: function () {
            var that = this;
            this._get("/medicare/CostByStateProviderType?$apply=filter(Year eq '" + YEAR +
                "')/groupby((ProviderType),aggregate(TotalPaid))")
                .then(function (rows) {
                    var full = rows.map(function (r) {
                        return { name: r.ProviderType || "Unknown", value: (parseFloat(r.TotalPaid) || 0) / 1e9 };
                    }).sort(function (a, b) { return b.value - a.value; });
                    that._oModel.setProperty("/providerType", full.slice(0, 10));
                    that._oModel.setProperty("/insights/cost/1",
                        that._insight("Cost · Provider Type", full, "name", "value",
                            function (v) { return that._fmtUsd(v * 1e9); }));
                });
        },

        _loadRuralUrban: function () {
            var that = this;
            this._get("/medicare/RuralUrbanDistribution?$apply=filter(Year eq '" + YEAR +
                "')/groupby((RuralUrban),aggregate(TotalBeneficiaries))")
                .then(function (rows) {
                    var data = rows.map(function (r) {
                        return { name: r.RuralUrban || "Unknown", value: parseFloat(r.TotalBeneficiaries) || 0 };
                    }).sort(function (a, b) { return b.value - a.value; });
                    that._oModel.setProperty("/ruralUrban", data);
                    that._oModel.setProperty("/insights/pop/0",
                        that._insight("Beneficiaries · Area", data, "name", "value", that._fmtNum.bind(that)));
                });
        },

        _loadRiskDist: function () {
            var that = this;
            this._get("/medicare/RiskScoreDistribution?$apply=filter(Year eq '" + YEAR +
                "')/groupby((RiskBand),aggregate(ProviderCount))")
                .then(function (rows) {
                    var data = rows.map(function (r) {
                        return { name: (r.RiskBand || "").replace(/^[0-9]+\s*-\s*/, ""), value: parseFloat(r.ProviderCount) || 0 };
                    }).sort(function (a, b) { return a.name.localeCompare(b.name); });
                    that._oModel.setProperty("/riskDist", data);
                    that._oModel.setProperty("/insights/pop/1",
                        that._insight("Providers · Risk Band", data, "name", "value", that._fmtNum.bind(that)));
                });
        },

        _loadOutliers: function () {
            var that = this;
            this._get("/medicare/ProviderCostEfficiency?$filter=Year eq '" + YEAR +
                "' and EfficiencyCategory eq 'Outlier'&$orderby=CostPerBeneficiary desc&$top=6" +
                "&$select=ProviderName,ProviderType,CostPerBeneficiary")
                .then(function (rows) {
                    var data = rows.map(function (r) {
                        return {
                            provider: r.ProviderName || "—",
                            specialty: r.ProviderType || "—",
                            cost: Math.round(parseFloat(r.CostPerBeneficiary) || 0).toLocaleString()
                        };
                    });
                    that._oModel.setProperty("/outliers", data);
                });
        },

        // ── Task 3 · Risk ↔ Payment association (bubble) ───────────────────
        // RiskPaymentAssociation is already one row per Year+Specialty, so the
        // ratio measures (PaidPerBene, AvgRiskScore) are exact at this grain.
        _loadRiskAssoc: function () {
            var that = this;
            this._get("/medicare/RiskPaymentAssociation?$apply=filter(Year eq '" + YEAR +
                "')/groupby((ProviderType),aggregate(AvgRiskScore,PaidPerBene,TotalBeneficiaries,TotalPaid))")
                .then(function (rows) {
                    var data = rows.map(function (r) {
                        return {
                            type: r.ProviderType || "Unknown",
                            risk: parseFloat(r.AvgRiskScore) || 0,
                            paid: parseFloat(r.PaidPerBene) || 0,
                            benes: parseFloat(r.TotalBeneficiaries) || 0,
                            _tot: parseFloat(r.TotalPaid) || 0
                        };
                    }).filter(function (d) { return d.risk > 0 && d.paid > 0; })
                      .sort(function (a, b) { return b._tot - a._tot; });
                    that._oModel.setProperty("/riskAssoc", data.slice(0, 15));
                    that._oModel.setProperty("/insights/assoc/0",
                        that._insight("Paid / Bene · Specialty", data, "type", "paid", that._fmtUsd.bind(that)));
                });
        },

        // ── Task 3 · Charge gap by credential (bar) ────────────────────────
        // One row per Year+Credential -> PaymentToChargePct / AllowedToChargePct
        // are exact ratio-of-sums at this grain.
        _loadCredGap: function () {
            var that = this;
            this._get("/medicare/CredentialChargeGap?$apply=filter(Year eq '" + YEAR +
                "')/groupby((Credential),aggregate(PaymentToChargePct,AllowedToChargePct,ProviderCount))")
                .then(function (rows) {
                    var full = rows.map(function (r) {
                        return {
                            cred: r.Credential || "Unspecified",
                            paidPct: parseFloat((parseFloat(r.PaymentToChargePct) || 0).toFixed(1)),
                            allowedPct: parseFloat((parseFloat(r.AllowedToChargePct) || 0).toFixed(1)),
                            _prov: parseFloat(r.ProviderCount) || 0
                        };
                    });
                    var data = full.slice().sort(function (a, b) { return b._prov - a._prov; }).slice(0, 8)
                        .sort(function (a, b) { return a.paidPct - b.paidPct; });
                    that._oModel.setProperty("/credGap", data);
                    // Only credentials with enough providers, so rare titles don't skew the high/low.
                    var sig = full.filter(function (d) { return d._prov >= 20; });
                    that._oModel.setProperty("/insights/assoc/1",
                        that._insight("Paid-to-Charge · Credential", sig, "cred", "paidPct", that._fmtPct.bind(that)));
                });
        },

        // ── Task 3 · Facility vs Office (volume-weighted charges + split) ──
        // Per-place averages are weighted by service volume across procedures so
        // the rollup honours the procedure-level (apples-to-apples) grain.
        _loadPlaceAnalysis: function () {
            var that = this;
            this._get("/medicare/ServicePlaceAnalysis?$apply=filter(Year eq '" + YEAR +
                "')/groupby((PlaceOfService,ProcedureCode),aggregate(" +
                "AvgSubmittedChrg,AvgAllowedAmt,AvgPaidAmt,TotalServices))")
                .then(function (rows) {
                    var acc = {};
                    rows.forEach(function (r) {
                        var p = r.PlaceOfService || "Other";
                        var svc = parseFloat(r.TotalServices) || 0;
                        if (!acc[p]) { acc[p] = { sub: 0, alw: 0, paid: 0, svc: 0 }; }
                        acc[p].sub += (parseFloat(r.AvgSubmittedChrg) || 0) * svc;
                        acc[p].alw += (parseFloat(r.AvgAllowedAmt) || 0) * svc;
                        acc[p].paid += (parseFloat(r.AvgPaidAmt) || 0) * svc;
                        acc[p].svc += svc;
                    });
                    var order = ["Facility", "Office", "Other"];
                    var charge = [], volume = [];
                    order.forEach(function (p) {
                        var a = acc[p];
                        if (!a || a.svc <= 0) { return; }
                        charge.push({
                            place: p,
                            submitted: +(a.sub / a.svc).toFixed(2),
                            allowed: +(a.alw / a.svc).toFixed(2),
                            paid: +(a.paid / a.svc).toFixed(2)
                        });
                        volume.push({ name: p, value: a.svc });
                    });
                    that._oModel.setProperty("/placeCharge", charge);
                    that._oModel.setProperty("/placeVolume", volume);
                    that._oModel.setProperty("/insights/assoc/2",
                        that._insight("Avg Paid / Service · Place", charge, "place", "paid", that._fmtUsd.bind(that)));
                });
        },

        // ── VizFrame dark-theme styling ────────────────────────────────────
        _styleCharts: function () {
            var common = {
                title: { visible: false },
                legendGroup: { layout: { position: "bottom" } }
            };

            var oBar = this.byId("vizProviderType");
            if (oBar) {
                oBar.setVizProperties(Object.assign({}, common, {
                    legend: { visible: false },
                    valueAxis: { title: { visible: false }, label: { formatString: "$#,##0.0" } },
                    categoryAxis: { title: { visible: false } },
                    plotArea: { dataLabel: { visible: true, formatString: "$#,##0.0'B'" }, colorPalette: ["#4db1ff"] }
                }));
            }
            var oDonut = this.byId("vizRuralUrban");
            if (oDonut) {
                oDonut.setVizProperties(Object.assign({}, common, {
                    legend: { visible: true },
                    plotArea: { dataLabel: { visible: true, type: "percentage" } }
                }));
            }
            var oCol = this.byId("vizRiskDist");
            if (oCol) {
                oCol.setVizProperties(Object.assign({}, common, {
                    legend: { visible: false },
                    valueAxis: { title: { visible: false } },
                    categoryAxis: { title: { visible: false } },
                    plotArea: { dataLabel: { visible: true }, colorPalette: ["#6f5bd6"] }
                }));
            }

            // ── Task 3 charts ──────────────────────────────────────────────
            var oBubble = this.byId("vizRiskPay");
            if (oBubble) {
                oBubble.setVizProperties(Object.assign({}, common, {
                    legend: { visible: true },
                    valueAxis:  { title: { visible: true, text: "Avg HCC Risk Score" } },
                    valueAxis2: { title: { visible: true, text: "Paid / Beneficiary ($)" }, label: { formatString: "$#,##0" } },
                    plotArea: { dataLabel: { visible: false } }
                }));
            }
            var oCred = this.byId("vizCredGap");
            if (oCred) {
                oCred.setVizProperties(Object.assign({}, common, {
                    legend: { visible: true },
                    valueAxis: { title: { visible: false }, label: { formatString: "#,##0'%'" } },
                    categoryAxis: { title: { visible: false } },
                    plotArea: { dataLabel: { visible: true, formatString: "#,##0.0'%'" }, colorPalette: ["#4db1ff", "#2d8a5e"] }
                }));
            }
            var oPlace = this.byId("vizPlace");
            if (oPlace) {
                oPlace.setVizProperties(Object.assign({}, common, {
                    legend: { visible: true },
                    valueAxis: { title: { visible: false }, label: { formatString: "$#,##0" } },
                    categoryAxis: { title: { visible: false } },
                    plotArea: { dataLabel: { visible: true, formatString: "$#,##0" }, colorPalette: ["#7e8aa2", "#4db1ff", "#2d8a5e"] }
                }));
            }
            var oPlaceVol = this.byId("vizPlaceVol");
            if (oPlaceVol) {
                oPlaceVol.setVizProperties(Object.assign({}, common, {
                    legend: { visible: true },
                    plotArea: { dataLabel: { visible: true, type: "percentage" }, colorPalette: ["#4db1ff", "#2d8a5e", "#7e8aa2"] }
                }));
            }
        },

        // ── Choropleth map (sap.ui.vbm.AnalyticMap, US state regions) ──────
        // We colour each US-XX region by Total Medicare Paid using quantile
        // bands, and feed the AnalyticMap via the bound /mapRegions array.
        _loadMap: function () {
            var that = this;
            this._get("/medicare/CostByStateProviderType?$apply=filter(Year eq '" + YEAR +
                "')/groupby((State),aggregate(TotalPaid))")
                .then(function (rows) {
                    var m = {};
                    rows.forEach(function (r) {
                        var v = parseFloat(r.TotalPaid) || 0;
                        if (r.State && /^[A-Z]{2}$/.test(r.State) && v > 0) { m[r.State] = v; }
                    });
                    that._buildRegions(m);
                });
        },

        _fmtUsd: function (v) {
            return v >= 1e9 ? "$" + (v / 1e9).toFixed(1) + "B"
                : v >= 1e6 ? "$" + (v / 1e6).toFixed(0) + "M"
                : "$" + Math.round(v).toLocaleString();
        },

        _fmtNum: function (v) {
            return v >= 1e6 ? (v / 1e6).toFixed(1) + "M"
                : v >= 1e3 ? (v / 1e3).toFixed(0) + "K"
                : Math.round(v).toLocaleString();
        },

        _fmtPct: function (v) { return (parseFloat(v) || 0).toFixed(1) + "%"; },

        // Placeholder shown until each loader resolves and fills the card.
        _blankInsight: function () {
            return {
                cat: "—",
                high: { label: "—", value: "—" },
                low:  { label: "—", value: "—" },
                avg:  { value: "—" }
            };
        },

        // Compute highest / lowest / average for one category. `arr` is a list of
        // objects; `kLabel`/`kVal` name the label and numeric fields; `fmt` formats
        // the value for display.
        _insight: function (sCat, arr, kLabel, kVal, fmt) {
            var rows = (arr || []).filter(function (r) {
                return r && isFinite(parseFloat(r[kVal]));
            });
            if (!rows.length) {
                var b = this._blankInsight();
                b.cat = sCat;
                return b;
            }
            var hi = rows[0], lo = rows[0], sum = 0;
            rows.forEach(function (r) {
                var v = parseFloat(r[kVal]);
                if (v > parseFloat(hi[kVal])) { hi = r; }
                if (v < parseFloat(lo[kVal])) { lo = r; }
                sum += v;
            });
            return {
                cat: sCat,
                high: { label: String(hi[kLabel]), value: fmt(parseFloat(hi[kVal])) },
                low:  { label: String(lo[kLabel]), value: fmt(parseFloat(lo[kVal])) },
                avg:  { value: fmt(sum / rows.length) }
            };
        },

        _buildRegions: function (mValues) {
            var states = Object.keys(mValues);
            var vals = states.map(function (s) { return mValues[s]; })
                .sort(function (a, b) { return a - b; });
            var q = function (p) { return vals.length ? vals[Math.floor((vals.length - 1) * p)] : 0; };
            var cut = [q(0.2), q(0.4), q(0.6), q(0.8)];
            var band = function (v) {
                for (var i = 0; i < cut.length; i++) { if (v <= cut[i]) { return i; } }
                return 4;
            };

            var regions = states.map(function (s) {
                var v = mValues[s];
                return {
                    code: "US-" + s,
                    color: BLUES[band(v)],
                    tooltip: s + " — " + this._fmtUsd(v)
                };
            }, this);

            // Legend: High → Low so the darkest (highest spend) sits on top.
            var bounds = [0].concat(cut);
            var legend = [];
            for (var i = 4; i >= 0; i--) {
                var lo = bounds[i];
                var label = (i === 4)
                    ? "> " + this._fmtUsd(cut[3])
                    : this._fmtUsd(lo) + " – " + this._fmtUsd(bounds[i + 1]);
                legend.push({ text: label, color: BLUES[i] });
            }

            this._oModel.setProperty("/mapRegions", regions);
            this._oModel.setProperty("/mapLegend", legend);

            var stateRows = states.map(function (s) { return { state: s, paid: mValues[s] }; });
            this._oModel.setProperty("/insights/cost/0",
                this._insight("Cost · State", stateRows, "state", "paid", this._fmtUsd.bind(this)));

            var oMap = this.byId("vbiMap");
            if (oMap && oMap.setVisualFrame) {
                oMap.setVisualFrame({ minLon: -130, maxLon: -64, minLat: 20, maxLat: 52, minLOD: 2 });
            }
        },

        onRegionClick: function (oEvt) {
            var sCode = oEvt.getParameter("code");
            var aReg = this._oModel.getProperty("/mapRegions") || [];
            var hit = aReg.filter(function (r) { return r.code === sCode; })[0];
            MessageToast.show(hit ? hit.tooltip : (sCode || "No data"));
        }
    });
});
