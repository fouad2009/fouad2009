document.addEventListener("DOMContentLoaded", function () {

    if (typeof Chart === "undefined") {
        console.error("Chart.js n'est pas chargé !");
        return;
    }

    // Plugins
    Chart.register(ChartDataLabels);
    console.log("Zoom plugin :", Chart.registry.plugins.get('zoom'));

    const chartDataDiv = document.getElementById("chart-data_pa");
    if (!chartDataDiv) return;

    const rawData = JSON.parse(chartDataDiv.textContent);

    launchPAChart(rawData, "chart-23", "Avancement PA / HP", "nbr");
    launchPAChart(rawData, "chart-24", "Consistance PA / HP", "consistance");
});


// ==============================
// LANCEMENT D'UN CHART
// ==============================
function launchPAChart(data, idChart, title, valueType = "nbr") {
    const el = document.getElementById(idChart);
    if (!el) return;

    const normalized = buildPAStackedData(data, 6, valueType);
    createStackedBar(idChart, normalized, title);
}


// ==============================
// NORMALISATION DES DONNÉES
// ==============================
function buildPAStackedData(data, trackerId, valueType = "nbr") {
    const t = data[trackerId];
    if (!t) return null;

    const getValue = o => (o && o[valueType] ? o[valueType] : 0);

    const realiseTotal = getValue(t.realiser_pa) + getValue(t.realiser_rar);
    const totalPrevu  = getValue(t.prevue) + getValue(t.en_cours_rar) + getValue(t.realiser_rar);
    const resteTotal  = Math.max(totalPrevu - realiseTotal, 0);

    const realiseHP = getValue(t.realiser_hp);
    const prevuHP   = getValue(t.prevue_hp);
    const resteHP   = Math.max(prevuHP - realiseHP, 0);

    const realisePA = Math.max(realiseTotal - realiseHP, 0);
    const totalPA   = Math.max(totalPrevu - prevuHP, 0);
    const restePA   = Math.max(totalPA - realisePA, 0);

    const round = v => Math.round(v);

    return {
        labels: ["Total", "PA", "HP"],
        realise: [round(realiseTotal), round(realisePA), round(realiseHP)],
        reste:   [round(resteTotal),   round(restePA),   round(resteHP)],
        taux: [
            totalPrevu > 0 ? Math.round((realiseTotal / totalPrevu) * 100) : 0,
            totalPA > 0 ? Math.round((realisePA / totalPA) * 100) : 0,
            prevuHP > 0 ? Math.round((realiseHP / prevuHP) * 100) : 0
        ]
    };
}


// ==============================
// CHART BAR HORIZONTALE EMPILÉE
// ==============================
function createStackedBar(canvasId, data, title) {
    if (!data) return;

    const canvas = document.getElementById(canvasId);
    if (!canvas) return;

    const MIN_VISIBLE = 5;

    const displayRealise = data.realise.map(v =>
        v > 0 && v < MIN_VISIBLE ? MIN_VISIBLE : v
    );

    const displayReste = data.reste.map(v =>
        v > 0 && v < MIN_VISIBLE ? MIN_VISIBLE : v
    );

    const chart = new Chart(canvas.getContext("2d"), {
        type: "bar",
        data: {
            labels: data.labels,
            datasets: [
                {
                    label: "Réalisé",
                    data: displayRealise,
                    _real: data.realise,
                    backgroundColor: "#555555",
                    borderRadius: 6,
                    barThickness: 32
                },
                {
                    label: "Reste à réaliser",
                    data: displayReste,
                    _real: data.reste,
                    backgroundColor: "#BDBDBD",
                    borderRadius: 6,
                    barThickness: 32
                }
            ],
            _normalized: data
        },

        options: {
            indexAxis: "y",
            responsive: true,
            maintainAspectRatio: false,

            plugins: {
                title: {
                    display: true,
                    text: title,
                    font: { size: 12, weight: "bold" },
                    color: "#969494"
                },

                legend: {
                    position: "bottom"
                },

                tooltip: {
                    enabled: true
                },

                datalabels: {
                    clamp: true,
                    clip: false,
                    font: { weight: "bold", size: 11 },

                    color(context) {
                        const bar = context.chart
                            .getDatasetMeta(context.datasetIndex)
                            .data[context.dataIndex];
                        return bar.width < 45 ? "#555" : "#FFF";
                    },

                    anchor(context) {
                        const bar = context.chart
                            .getDatasetMeta(context.datasetIndex)
                            .data[context.dataIndex];
                        return bar.width < 45 ? "end" : "center";
                    },

                    align(context) {
                        const bar = context.chart
                            .getDatasetMeta(context.datasetIndex)
                            .data[context.dataIndex];
                        return bar.width < 45 ? "right" : "center";
                    },

                    offset(context) {
                        const bar = context.chart
                            .getDatasetMeta(context.datasetIndex)
                            .data[context.dataIndex];
                        return bar.width < 45 ? 8 : 0;
                    },

                    formatter(value, context) {
                        const realValue = context.dataset._real[context.dataIndex];
                        if (realValue <= 0) return "";

                        const chart = context.chart;
                        const meta0 = chart.getDatasetMeta(0).data[context.dataIndex];
                        const meta1 = chart.getDatasetMeta(1).data[context.dataIndex];

                        const totalWidth =
                            (meta0?.width || 0) + (meta1?.width || 0);

                        const MIN_TOTAL_WIDTH = 70;

                        // 🔒 Barre trop petite → afficher uniquement "Réalisé"
                        if (totalWidth < MIN_TOTAL_WIDTH) {
                            if (context.datasetIndex !== 0) return "";
                        }

                        if (context.datasetIndex === 0) {
                            const taux =
                                chart.data._normalized.taux[context.dataIndex];
                            return `${realValue} (${taux}%)`;
                        }

                        return realValue;
                    }
                },

                zoom: {
                    pan: {
                        enabled: true,
                        mode: "x",
                        threshold: 5
                    },
                    zoom: {
                        wheel: {
                            enabled: true,
                            speed: 0.05
                        },
                        pinch: {
                            enabled: true
                        },
                        mode: "x"
                    }
                }
            },

            scales: {
                x: {
                    stacked: true,
                    beginAtZero: true,
                    grid: { display: false }
                },
                y: {
                    stacked: true,
                    grid: { display: false }
                }
            }
        }
    });

    // Double-clic → reset zoom
    canvas.addEventListener("dblclick", () => chart.resetZoom());
}

