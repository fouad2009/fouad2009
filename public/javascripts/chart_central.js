document.addEventListener("DOMContentLoaded", function () {
    Chart.register(ChartDataLabels);

    // 🔹 Récupération des données JSON
    const chartDataDiv = document.getElementById("chart-data");
    if (!chartDataDiv) return;
    const chartData = JSON.parse(chartDataDiv.textContent);

    // === 📊 CHRONOGRAMME (Bar Chart - Contrat) ===
    if (document.getElementById("chart-14")) {
        const labelsMapping = {
            "non_entamer": "Non entamé",
            "etude_en_cours": "Étude en cours",
            "etude_finalise": "Étude finalisée",
            "commission_cdc": "Commission CDC",
            "etablissement_cdc": "Établissement CDC",
            "cdc_approuve": "CDC Approuvé",
            "phase_consultation": "Phase de consultation",
            "visa_ccm_accordee": "Visa CCM accordée"
        };

        ;const colorsMapping = {
    "Non entamé": "#FFAAAA",        // Rouge clair
    "Étude en cours": "#FF8000",    // Orange
    "Étude finalisée": "#FFC04D",   // Orange clair
    "Commission CDC": "#B3FF66",    // Vert clair
    "Établissement CDC": "#66CC66", // Vert moyen clair
    "CDC Approuvé": "#33AA33",      // Vert moyen
    "Phase de consultation": "#008000", // Vert foncé
    "Visa CCM accordée": "#005500"    // Vert très foncé
};

        title = "Répartition par phase"
        const dataContrat = prepareChartData(chartData["Contrat"], labelsMapping);
        createBarChart("chart-14", dataContrat, colorsMapping, title);
    }


  // === PIE  CHART (Répartition Acquisition) ===
     if (document.getElementById("chart-13")) {
        const labelsMapping = {
            "en_negociation": "En négociation",
            "contrat_notifie": "Contrat notifié"
        };

        const colorsMapping = {
            "En négociation": "#B3FF66",    // vert clair
            "Contrat notifié": "#008000"  // vert foncé
        };
         title = "Etat Négociation";
        const filteredDataExecution = prepareChartData(chartData["Contrat"], labelsMapping);
        createPieChart("chart-13", filteredDataExecution, colorsMapping, title);
    }



 // === 📊 CHRONOGRAMME (Bar Chart - Contrat gre a gre ) ===
    if (document.getElementById("chart-23")) {
        const labelsMapping = {
            "non_entamer": "Non entamé",
            "etude_en_cours": "Étude en cours",
            "etude_finalise": "Étude finalisée",
            "commission_gre_a_gre": "Commission gré à gré",
            "etablissement_cdc": "Établissement CPT",
            "gre_a_gre_approuve": "Gré à gré approuvé",
            "phase_consultation": "Phase consultation",
            "contrat_notifie": "Contrat notifiée"
        };

        ;const colorsMapping = {
    "Non entamé": "#FFAAAA",        // Rouge clair
    "Étude en cours": "#FF8000",    // Orange
    "Étude finalisée": "#FFC04D",   // Orange clair
    "Commission gré à gré": "#B3FF66",    // Vert clair
    "Établissement CPT": "#66CC66", // Vert moyen clair
    "Gré à gré approuvé": "#33AA33",      // Vert moyen
    "Phase consultation": "#008000", // Vert foncé
    "Contrat notifiée": "#005500"    // Vert très foncé
};

        title = "Répartition par phase"
        const dataContrat = prepareChartData(chartData["Contrat_gre"], labelsMapping);
        createBarChart("chart-23", dataContrat, colorsMapping, title);
    }


 




    // === 🥧 PIE CHART (Répartition Acquisition) ===
     if (document.getElementById("chart-15")) {
        const labelsMapping = {
            "non_lancer": "Non entamé",
            "en_cours": "En cours",
            "achever": "Finalisé"
        };

        const colorsMapping = {
            "Non entamé": "#DC3912",    // Rouge
            "En cours": "#cbe256", // Vert
            "Finalisé":  "#66AA00"      // Orange
        };
         title = "Action parente: Repartition par Taux %";
        const filteredDataExecution = prepareChartData(chartData["Acquisition"], labelsMapping);
        createPieChart("chart-15", filteredDataExecution, colorsMapping, title);
    }




// === 🥧 PIE CHART POUR Exécution (chart-16) ===
    if (document.getElementById("chart-16")) {
        const labelsMapping = {
            "montant_notifier": "Montant notifié",
            "montant_engager": "Montant engagé"
        };

        const colorsMapping = {
               "Montant notifié": "#FF8C00", // Vert
            "Montant engagé":   "#66AA00"      // Orange
      };

      title = "Consomation budgétaire";
      const filteredDataExecution = prepareChartData(chartData["Acquisition"], labelsMapping);
        createBarChart("chart-16", filteredDataExecution, colorsMapping, title);

    }






    // === 🥧 PIE CHART POUR Exécution (chart-17) ===
    if (document.getElementById("chart-17")) {
        const labelsMapping = {
            "en_preparation": "En préparation",
            "pret_au_lancement": "Prêt au lancement",
            "en_execution": "En exécution",
            "receptionner": "Réceptionné"
        };

        const colorsMapping = {
            "En préparation": "#DC3912",    // Rouge
            "Prêt au lancement": "#66AA00", // Vert
            "En exécution": "#FF9900",      // Orange
            "Réceptionné": "#3366CC"        // Bleu
        };
        title = "Sous actions: répartition par statut";
        const filteredDataExecution = prepareChartData(chartData["Acquisition"], labelsMapping);
        createPieChart("chart-17", filteredDataExecution, colorsMapping, title);
    }


    // === 🥧 PIE CHART POUR Exécution (chart-17) ===
    if (document.getElementById("chart-19")) {
        const labelsMapping = {
            "non_lancer": "Non entamé",
            "en_cours": "En cours",
            "achever": "Finalisé"
        };

        const colorsMapping = {
            "Non entamé": "#DC3912",    // Rouge
            "En cours": "#cbe256", // Vert
            "Finalisé":  "#66AA00"      // Orange
        };
         title = "Action parente: répartition par Taux %";
        const filteredDataExecution = prepareChartData(chartData["Acquisition_realisation"], labelsMapping);
        createPieChart("chart-19", filteredDataExecution, colorsMapping, title);
    }


// === 🥧 PIE CHART POUR Exécution (chart-17) ===
    if (document.getElementById("chart-20")) {
        const labelsMapping = {
            "montant_notifier": "Montant notifié",
            "montant_engager": "Montant engagé"
        };

        const colorsMapping = {
             "Montant notifié": "#FF8C00", // Vert
            "Montant engagé":   "#228B22"      // Orange
        };

      title = "Consomation budgétaire";
      const filteredDataExecution = prepareChartData(chartData["Acquisition_realisation"], labelsMapping);
        createBarChart("chart-20", filteredDataExecution, colorsMapping, title);

    }

 // === 🥧 PIE CHART POUR Exécution (chart-17) ===
    if (document.getElementById("chart-21")) {
        const labelsMapping = {
            "bc_en_preparation": "En préparation",
            "bc_pret_au_lancemen": "Prêt au lancement",
            "bc_en_execution": "En exécution",
            "bc_receptionner": "Réceptionné"
        };

        const colorsMapping = {
            "En préparation": "#DC3912",    // Rouge
            "Prêt au lancement": "#66AA00", // Vert
            "En exécution": "#FF9900",      // Orange
            "Réceptionné": "#3366CC"        // Bleu
        };
        title = "Sous actions BC/Lot: répartition par statut";
        const filteredDataExecution = prepareChartData(chartData["Acquisition_realisation"], labelsMapping);
        createPieChart("chart-21", filteredDataExecution, colorsMapping, title);
    }





	// === 📌 Fonction pour préparer les données (générique) ===
    
 if (document.getElementById("chart-22")) {
        const labelsMapping = {
            "prestation_en_preparation": "En préparation",
            "prestation_pret_au_lancement": "Prêt au lancement",
            "prestation_en_execution": "En exécution",
            "prestation_achever": "Achevé"
        };

        const colorsMapping = {
            "En préparation": "#DC3912",    // Rouge
            "Prêt au lancement": "#66AA00", // Vert
            "En exécution": "#FF9900",      // Orange
            "Achevé": "#3366CC"        // Bleu
        };
        title = "Sous actions Prestation: Statut";
        const filteredDataExecution = prepareChartData(chartData["Acquisition_realisation"], labelsMapping);
        createPieChart("chart-22", filteredDataExecution, colorsMapping, title);
    }



	function prepareChartData(sourceData, labelsMapping) {
        return {
            labels: Object.values(labelsMapping),
            values: Object.keys(labelsMapping).map(key => sourceData?.[key] || 0)
        };
    }

    // === 📊 Fonction générique pour les graphiques BAR ===
   
function createBarChart(canvasId, dataStructure, colorMapping, chartTitle) {
    const canvas = document.getElementById(canvasId);
    if (!canvas) return;

    const backgroundColors = dataStructure.labels.map(label => colorMapping[label]);

    new Chart(canvas.getContext('2d'), {
        type: "bar",
        data: {
            labels: dataStructure.labels,
            datasets: [{
                label: "Nombre d'actions par statut",
                data: dataStructure.values,
                backgroundColor: backgroundColors,
                borderRadius: 8
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                title: { 
                    display: true, 
                    text: chartTitle, // 🔹 Titre dynamique
                    color: 'rgb(150, 148, 148)',
                    font: { size: 12, weight: 'bold' },
                    padding: { top: 2, bottom: 5 } // 🔹 Moins d'espace pour agrandir le Pie

                },
                legend: { display: false },
                datalabels: {
                    color: 'white',
                    anchor: 'center',  // 🔹 Valeur bien centrée dans la barre
                    align: 'center',
                    font: { size: 12, weight: 'bold' },
                    formatter: value => {
                        if (Number.isInteger(value)) {
                            return value; // 🔹 Garde les nombres entiers tels quels
                        } else {
                            return new Intl.NumberFormat('fr-FR', {
                                minimumFractionDigits: 2,
                                maximumFractionDigits: 2
                            }).format(value) + " KDA"; // 🔹 Format FR avec 'KDA'
                        }
                    }
                }
            },
            scales: { 
                x: { 
                    ticks: { font: { size: 11 } },
                    grid: { display: false } // 🔹 Désactiver les lignes de la grille X
                }, 
                y: { 
                    display: false, // 🔹 Masquer l'axe Y
                    grid: { display: false } // 🔹 Désactiver les lignes de la grille Y
                } 
            },
            layout: { padding: { top: 10 } } // 🔹 Ajoute de l'espace en haut
        }
    });
}


// === 🥧 Fonction générique pour les graphiques PIE ===
function createPieChart(canvasId, dataStructure, colorMapping, chartTitle) {
    const canvas = document.getElementById(canvasId);
    if (!canvas) return;

    const backgroundColors = dataStructure.labels.map(label => colorMapping[label]);

    new Chart(canvas.getContext('2d'), {
        type: "pie",
        data: {
            labels: dataStructure.labels,
            datasets: [{
                data: dataStructure.values,
                backgroundColor: backgroundColors,
                hoverBackgroundColor: backgroundColors,
                borderWidth: 0
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false, // 🔹 Permet au Pie de s'agrandir
            plugins: {
                title: {
                    display: true,
                    text: chartTitle, // 🔹 Titre dynamique
                    color: 'rgb(150, 148, 148)',
                    font: { size: 12, weight: 'bold' },
                    padding: { top: 2, bottom: 5 } // 🔹 Moins d'espace pour agrandir le Pie
                },
                legend: {
                    position: 'bottom', // 🔹 Affiche la légende en bas
                    align: 'center',
                    labels: {
                        boxWidth: 12,
                        boxHeight: 12,
                        padding: 10, // 🔹 Espace pour éviter que la légende réduise le Pie
                        font: { size: 11 }
                    }
                },
                datalabels: {
                    color: 'white',
                    font: { size: 12, weight: 'bold' },
                    formatter: (value, context) => {
                        if (value === 0) return ''; // 🔹 Ne pas afficher 0%
                        const total = context.dataset.data.reduce((a, b) => a + b, 0);
                        return `${value}`; // 🔹 Valeur - Pourcentage
                    },
                    anchor: 'center',
                    align: 'center',
                    padding: 5
                }
            },
            layout: { padding: { bottom: 0 } }, // 🔹 Supprime l'espace inutile en bas
            elements: {
                arc: {
                    borderWidth: 0
                }
            }
        }
    });
}


});

