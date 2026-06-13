sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/ui/model/json/JSONModel",
    "sap/m/MessageToast"
], function (Controller, JSONModel, MessageToast) {
    "use strict";

    var YEAR = "2023";
    var PREV = "2022";

    // Sequential blue palette (light → dark) for the choropleth.
    var BLUES = ["#cfe3f5", "#9ecae1", "#6baed6", "#3182bd", "#08519c"];
    var NO_DATA = "#3a4a5e";

    return Controller.extend("com.medicare.auditdashboard.controller.App", {

        onInit: function () {
            this._oModel = new JSONModel({
                kpi: {},
                providerType: [],
                ruralUrban: [],
                riskDist: [],
                outliers: []
            });
            this.getView().setModel(this._oModel, "dash");

            this._styleCharts();
            this._loadMapGeometry().then(this._loadAll.bind(this));
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
                    var data = rows.map(function (r) {
                        return { name: r.ProviderType || "Unknown", value: (parseFloat(r.TotalPaid) || 0) / 1e9 };
                    }).sort(function (a, b) { return b.value - a.value; }).slice(0, 10);
                    that._oModel.setProperty("/providerType", data);
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
        },

        // ── Choropleth map ─────────────────────────────────────────────────
        _loadMapGeometry: function () {
            var that = this;
            return fetch("data/us-states-paths.json")
                .then(function (r) { return r.json(); })
                .then(function (j) { that._oMap = j; })
                .catch(function () { /* map optional */ });
        },

        _loadMap: function () {
            var that = this;
            this._get("/medicare/CostByStateProviderType?$apply=filter(Year eq '" + YEAR +
                "')/groupby((State),aggregate(TotalPaid))")
                .then(function (rows) {
                    var m = {};
                    rows.forEach(function (r) {
                        var v = parseFloat(r.TotalPaid) || 0;
                        if (r.State && v > 0) { m[r.State] = v; }
                    });
                    that._renderMap(m);
                });
        },

        _renderMap: function (mValues) {
            var oHtml = this.byId("mapHtml");
            var oMap = this._oMap;
            if (!oHtml || !oMap) { return; }

            var inset = ["AK", "HI", "PR"];
            var vals = Object.keys(mValues).map(function (s) { return mValues[s]; })
                .sort(function (a, b) { return a - b; });
            var q = function (p) { return vals.length ? vals[Math.floor((vals.length - 1) * p)] : 0; };
            var cut = [q(0.2), q(0.4), q(0.6), q(0.8)];
            var color = function (v) {
                if (!v) { return NO_DATA; }
                for (var i = 0; i < cut.length; i++) { if (v <= cut[i]) { return BLUES[i]; } }
                return BLUES[4];
            };
            var fmt = function (v) {
                return v >= 1e9 ? "$" + (v / 1e9).toFixed(1) + "B"
                    : v >= 1e6 ? "$" + (v / 1e6).toFixed(0) + "M" : "$" + Math.round(v);
            };

            this._tips = {};
            var svg = ["<svg xmlns='http://www.w3.org/2000/svg' viewBox='" + oMap.viewBox +
                "' width='100%' style='display:block'>"];

            var addPath = function (st, d, sw, tf) {
                var v = mValues[st];
                this._tips[st] = v ? st + ": " + fmt(v) : st + ": no data";
                svg.push("<path d='" + d + "' " + (tf ? "transform='" + tf + "' " : "") +
                    "data-state='" + st + "' fill='" + color(v) +
                    "' stroke='#1c2733' stroke-width='" + sw + "' style='cursor:pointer'/>");
            }.bind(this);

            Object.keys(oMap.states).forEach(function (st) {
                if (inset.indexOf(st) < 0) { addPath(st, oMap.states[st], "0.7"); }
            });
            var lbl = { AK: [18, 415], HI: [18, 495], PR: [800, 465] };
            inset.forEach(function (st) {
                var d = oMap.states[st], ins = oMap.insets[st];
                if (!d || !ins) { return; }
                svg.push("<text x='" + lbl[st][0] + "' y='" + lbl[st][1] +
                    "' font-size='11' fill='#9fb0c3'>" + st + "</text>");
                addPath(st, d, "1.2", "translate(" + ins.tx + "," + ins.ty + ") scale(" + ins.sx + "," + ins.sy + ")");
            });

            // Legend (High → Low gradient bar)
            svg.push("<g transform='translate(862,150)'>");
            svg.push("<text x='26' y='-8' font-size='11' fill='#c2cedd'>High</text>");
            for (var i = 0; i < BLUES.length; i++) {
                svg.push("<rect x='0' y='" + (i * 22) + "' width='18' height='22' fill='" + BLUES[4 - i] + "'/>");
            }
            svg.push("<text x='26' y='" + (BLUES.length * 22) + "' font-size='11' fill='#c2cedd'>Low</text>");
            svg.push("</g>");

            svg.push("</svg>");
            oHtml.setContent("<div style='position:relative;width:100%'>" + svg.join("") + "</div>");
            oHtml.attachEventOnce("afterRendering", this._wireMapTip, this);
        },

        _wireMapTip: function () {
            var oHtml = this.byId("mapHtml");
            var dom = oHtml && oHtml.getDomRef();
            var box = dom && dom.querySelector("div");
            var svg = dom && dom.querySelector("svg");
            if (!box || !svg) { return; }

            var tip = document.createElement("div");
            tip.setAttribute("style", "position:absolute;pointer-events:none;background:rgba(8,16,28,0.92);" +
                "color:#fff;padding:4px 8px;border-radius:4px;font:12px Arial;white-space:nowrap;" +
                "transform:translate(-50%,-140%);display:none;z-index:5;border:1px solid #2b3a4d");
            box.appendChild(tip);

            var tips = this._tips || {};
            var active = null;
            svg.addEventListener("mousemove", function (e) {
                var st = e.target && e.target.getAttribute && e.target.getAttribute("data-state");
                if (!st) { tip.style.display = "none"; if (active) { active.style.filter = ""; active = null; } return; }
                if (active && active !== e.target) { active.style.filter = ""; }
                active = e.target;
                e.target.style.filter = "brightness(1.25)";
                var r = box.getBoundingClientRect();
                tip.textContent = tips[st] || st;
                tip.style.left = (e.clientX - r.left) + "px";
                tip.style.top = (e.clientY - r.top) + "px";
                tip.style.display = "block";
            });
            svg.addEventListener("mouseleave", function () {
                tip.style.display = "none"; if (active) { active.style.filter = ""; active = null; }
            });
        }
    });
});
