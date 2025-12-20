
function changeTab(evt, tabId) {
  // Cache tous les éléments avec la classe "tab-content"
  var tabContents = document.getElementsByClassName("tab-content");
  for (var i = 0; i < tabContents.length; i++) {
    tabContents[i].style.display = "none";
  }

  // Supprime la classe "active" de tous les éléments avec la classe "tab"
  var tabs = document.getElementsByClassName("tab");
  for (i = 0; i < tabs.length; i++) {
    tabs[i].className = tabs[i].className.replace(" active", "");
  }

  // Affiche le contenu de l'onglet actuel et ajoute la classe "active" à l'onglet actuel
  document.getElementById(tabId).style.display = "block";
  evt.currentTarget.className += " active";
}


const rows = document.querySelectorAll('.odn tbody tr');
/*const canvas = document.getElementById('graph1').getContext('2d');*/


function findRowWithValue() {
const etat = {}; // Initialiser le hash de hashes

for (const row of rows) {
  
  const firstCel = row.querySelector('td:first-of-type').textContent;
  const firstCell = firstCel.split(' ')[0];
  const tracker = firstCell;
  
  if (firstCell === 'ODN_Dev' || firstCell === 'ODN_Mod') { 
    
    // Si la première cellule contient 'ODN_Dev' ou 'ODN_Mod'
    const values = Array.from(row.querySelectorAll('td')).map(td => td.textContent);
    

    const formatCellule = (celluleHtml) => {
      return parseInt(celluleHtml.replace(/\s+/g, "").replace(",", ""));
    }
    
    const NbrObjectifPA = formatCellule(values[1].split("-")[0]);
    const ConsistanceObjectifPA = formatCellule(values[1].split("-")[1]);
    
    const NbrEtudeNonEntamer= formatCellule(values[2].split("-")[0]);
    const ConsistanceEtudeNonEntamer = formatCellule(values[2].split("-")[1]);
    
    const NbrEtudeEnCours= formatCellule(values[3].split("-")[0]);
    const ConsistanceEtudeEnCours = formatCellule(values[3].split("-")[1]);
    
    const NbrEtudeFinaliser= formatCellule(values[4].split("-")[0]);
    const ConsistanceEtudeFinaliser = formatCellule(values[4].split("-")[1]);
    
    const NbrEnCoursPA= formatCellule(values[7].split("-")[0]);
    const ConsistanceEnCoursPA = formatCellule(values[7].split("-")[1]);
    
    const NbrRealiserPA= formatCellule(values[8].split("-")[0]);
    const ConsistanceRealiserPA = formatCellule(values[8].split("-")[1]);
    
    const NbrEnCoursRAR= formatCellule(values[9].split("-")[0]);
    const ConsistanceEnCoursRAR = formatCellule(values[9].split("-")[1]);
    
    const NbrRealiserRAR= formatCellule(values[10].split("-")[0]);
    const ConsistanceRealiserRAR = formatCellule(values[10].split("-")[1]);
    
    // Ajouter les données de la ligne au hash de hashes
    etat[firstCell] = {
      tracker,
      NbrObjectifPA,
      ConsistanceObjectifPA,
      NbrEtudeNonEntamer,
      ConsistanceEtudeNonEntamer,
      NbrEtudeEnCours,
      ConsistanceEtudeEnCours,
      NbrEtudeFinaliser,
      ConsistanceEtudeFinaliser,
      NbrEnCoursPA,
      ConsistanceEnCoursPA,
      NbrRealiserPA,
      ConsistanceRealiserPA,
      NbrEnCoursRAR,
      ConsistanceEnCoursRAR,
      NbrRealiserRAR,
      ConsistanceRealiserRAR
    };
  } else { // Si la première cellule ne contient pas 'ODN_Dev' ou 'ODN_Mod'
    const values = Array.from(row.querySelectorAll('td')).map(td => td.textContent);
    const NbrObjectifPA = parseInt(values[1]);
    const NbrEtudeNonEntamer= parseInt(values[2]);
    const NbrEtudeEnCours= parseInt(values[3]);
    const NbrEtudeFinaliser= parseInt(values[4]);
    const NbrEnCoursPA= parseInt(values[7]);
    const NbrRealiserPA= parseInt(values[8]);
    const NbrEnCoursRAR= parseInt(values[9]);
    const NbrRealiserRAR= parseInt(values[10]);
    const ConsistanceObjectifPA = 0;
    const ConsistanceEtudeNonEntamer = 0;
    const ConsistanceEtudeEnCours = 0;
    const ConsistanceEtudeFinaliser = 0;
    const ConsistanceEnCoursPA = 0;
    const ConsistanceRealiserPA = 0;
    const ConsistanceEnCoursRAR = 0;
    const ConsistanceRealiserRAR = 0;

    // Ajouter les données de la ligne au hash de hashes
    etat[firstCell] = {
      tracker,
      NbrObjectifPA,
      ConsistanceObjectifPA,
      NbrEtudeNonEntamer,
      ConsistanceEtudeNonEntamer,
      NbrEtudeEnCours,
      ConsistanceEtudeEnCours,
      NbrEtudeFinaliser,
      ConsistanceEtudeFinaliser,
      NbrEnCoursPA,
      ConsistanceEnCoursPA,
      NbrRealiserPA,
      ConsistanceRealiserPA,
      NbrEnCoursRAR,
      ConsistanceEnCoursRAR,
      NbrRealiserRAR,
      ConsistanceRealiserRAR
    };
  }
}

return etat; // Retourner le hash de hashes
}
const report = findRowWithValue(); // Supposons que cette fonction renvoie vos données.



document.addEventListener("DOMContentLoaded", function() {
    Chart.register(ChartDataLabels);

    // Fonction qui dessine le graphique avec les données passées en paramètres.
    function drawChart(title, nonEntamees, enCours, finalisees, elementId) {
        const ctx = document.getElementById(elementId).getContext('2d');

        const config = {
            type: 'pie',
            data: {
                labels: ['Non entamée', 'En cours', 'Finalisée'],
                datasets: [{
                    data: [nonEntamees, enCours, finalisees],
                    backgroundColor: ['#DC3912', '#FF9900', '#66aa00'],
                    hoverBackgroundColor: ['#B22222', '#FFA500', '#32CD32'],
                    borderWidth: 0 // Supprime la bordure autour des sections du pie
                }]
            },
            options: {
                plugins: {
                    title: {
                        display: true,
                        text: title,
                        color: 'rgb(150, 148, 148)',
                        font: {
                            size: 11,
                            weight: 'bold'
                        },
                        padding: {
                            top: 10,
                            bottom: 10
                        }
                    },
                    legend: {
                        position: 'bottom',
                        align: 'start',
                        labels: {
                            boxWidth: 10,
                            boxHeight: 10,
                            padding: 5,
                            font: {
                                size: 9
                            }
                        }
                    },
                    datalabels: {
                        color: 'white',
                        font: {
                            size: 10,
                            weight: 'bold'
                        },
                        formatter: (value, context) => {
                            const total = context.dataset.data.reduce((a, b) => a + b, 0);
                            if (value === 0 || total === 0) return ''; // Masque les valeurs si égales à 0
                            const percentage = ((value / total) * 100).toFixed(1); // Calcule le pourcentage
                            return `${percentage}%`; // Affiche uniquement le pourcentage
                        }
                    }
                },
                layout: {
                    padding: 10
                }
            }
        };

        new Chart(ctx, config);
    }

    // Appel des fonctions pour dessiner les graphiques avec des données fictives.

    drawChart(
        'ODN Dev prévisions & étude',
        report['ODN_Dev']['NbrEtudeNonEntamer'],
        report['ODN_Dev']['NbrEtudeEnCours'],
        report['ODN_Dev']['NbrEtudeFinaliser'],
        'myChart'
    );

    drawChart(
        'ODN Mod prévisions & étude',
        report['ODN_Mod']['NbrEtudeNonEntamer'],
        report['ODN_Mod']['NbrEtudeEnCours'],
        report['ODN_Mod']['NbrEtudeFinaliser'],
        'modChart'
    );
});



function toggleFullScreen(element) {
  if (element.requestFullscreen) {
    element.requestFullscreen();
  } else if (element.webkitRequestFullscreen) {
    element.webkitRequestFullscreen();
  } else if (element.mozRequestFullScreen) {
    element.mozRequestFullScreen();
  } else if (element.msRequestFullscreen) {
    element.msRequestFullscreen(my_class);
  }
}

document.getElementById("graphiques-heading").addEventListener("click", function () {
  toggleFullScreen(document.querySelector('.partie_acces'));
});

document.addEventListener("fullscreenchange", function () {
  var fullscreenElement = document.fullscreenElement || document.webkitFullscreenElement || document.mozFullScreenElement || document.msFullscreenElement;
  if (fullscreenElement) {
    document.documentElement.classList.add("fullscreen");
  } else {
    document.documentElement.classList.remove("fullscreen");
  }
});


 // affichage des objectif ODN_Dev**************************

// récupérer les valeurs de report
var value1 = report['ODN_Dev']['ConsistanceObjectifPA'];
var value2 = report['ODN_Dev']['NbrObjectifPA'];
var value3 = report['ODN_Dev']['NbrEtudeFinaliser'];

var value4 = report['ODN_Mod']['ConsistanceObjectifPA'];
var value5 = report['ODN_Mod']['NbrObjectifPA'];
var value6 = report['ODN_Mod']['NbrEtudeFinaliser'];

var value7 = report['ODN_Dev']['ConsistanceEnCoursPA'];
var value8 = report['ODN_Dev']['ConsistanceRealiserPA'];

var value10 = report['ODN_Dev']['ConsistanceEnCoursRAR'];
var value11 = report['ODN_Dev']['ConsistanceRealiserRAR'];

var value13 = report['ODN_Mod']['ConsistanceEnCoursPA'];
var value14 = report['ODN_Mod']['ConsistanceRealiserPA'];

var value16 = report['ODN_Mod']['ConsistanceEnCoursRAR'];
var value17 = report['ODN_Mod']['ConsistanceRealiserRAR'];


// sélectionner l'élément HTML
var pElements1 = document.querySelectorAll('.text1 p');
var text1Element1 = pElements1[1]; 

var pElements2 = document.querySelectorAll('.text2 p');
var text1Element2 = pElements2[1];

var pElements3 = document.querySelectorAll('.text3 p');
var text1Element3 = pElements3[1];

text1Element1.textContent =  value1.toLocaleString('fr-FR') ;
text1Element2.textContent =  value2.toLocaleString('fr-FR') ;
text1Element3.innerHTML = (value3 === 0) ? 'N/A' : value3.toLocaleString('fr-FR') + '&nbsp;&nbsp<span class="percentage">' + (value3/value2*100).toFixed(0) + '%</span>';



// sélectionner l'élément HTML
var pElements4 = document.querySelectorAll('.text4 p');
var text1Element4 = pElements4[1]; 

var pElements5 = document.querySelectorAll('.text5 p');
var text1Element5 = pElements5[1];

var pElements6 = document.querySelectorAll('.text6 p');
var text1Element6 = pElements6[1];

text1Element4.textContent =  value4.toLocaleString('fr-FR') ;
text1Element5.textContent =  value5.toLocaleString('fr-FR') ;
text1Element6.innerHTML = (value6 === 0) ? '0' : value6.toLocaleString('fr-FR')  + '&nbsp;&nbsp<span class="percentage">' + (value6/value5*100).toFixed(0) + '%</span>';



// Realisation ODN DEV PA & RAR
var pElements7 = document.querySelectorAll('.pa-dev-container .en_cours p');
var text1Element7 = pElements7[1]; 

var pElements8 = document.querySelectorAll('.pa-dev-container .realiser p');
var text1Element8 = pElements8[1];

var pElements9 = document.querySelectorAll('.pa-dev-container .taux  p');
var text1Element9 = pElements9[1];

var pElements10 = document.querySelectorAll('.rar-dev-container .en_cours_rar p');
var text1Element10 = pElements10[1];

var pElements11 = document.querySelectorAll('.rar-dev-container .realiser_rar p');
var text1Element11 = pElements11[1];

var pElements12 = document.querySelectorAll('.rar-dev-container .taux_rar  p');
var text1Element12 = pElements12[1];

text1Element7.textContent =  value7.toLocaleString('fr-FR') ;
text1Element8.textContent =  value8.toLocaleString('fr-FR') ;
text1Element9.textContent = (value1 === 0) ? '0' :  (value8/value1*100).toFixed(1) + '%'

text1Element10.textContent =  value10.toLocaleString('fr-FR') ;
text1Element11.textContent =  value11.toLocaleString('fr-FR') ;
text1Element12.textContent = ((value10+value11) === 0) ? '0' :  (value11/(value10+value11)*100).toFixed(1) + '%'


// Realisation ODN MOD PA & RAR
var pElements13 = document.querySelectorAll('.pa-mod-container .en_cours p');
var text1Element13 = pElements13[1]; 

var pElements14 = document.querySelectorAll('.pa-mod-container .realiser p');
var text1Element14 = pElements14[1];

var pElements15 = document.querySelectorAll('.pa-mod-container .taux  p');
var text1Element15 = pElements15[1];

var pElements16 = document.querySelectorAll('.rar-mod-container .en_cours_rar p');
var text1Element16 = pElements16[1];

var pElements17 = document.querySelectorAll('.rar-mod-container .realiser_rar p');
var text1Element17 = pElements17[1];

var pElements18 = document.querySelectorAll('.rar-mod-container .taux_rar  p');
var text1Element18 = pElements18[1];

text1Element13.textContent =  value13.toLocaleString('fr-FR') ;
text1Element14.textContent =  value14.toLocaleString('fr-FR') ;
text1Element15.textContent = (value4 === 0) ? '0' :  (value14/value4*100).toFixed(1) + '%'

text1Element16.textContent =  value16.toLocaleString('fr-FR') ;
text1Element17.textContent =  value17.toLocaleString('fr-FR') ;
text1Element18.textContent = ((value16+value17) === 0) ? '0' :  (value17/(value16+value17)*100).toFixed(1) + '%'

// affichage total dev 

var pTotalDevInscrit = document.querySelectorAll('.total_odn_dev .odn_inscrit p');
var textTotalDevInscrit = pTotalDevInscrit[1];
textTotalDevInscrit.textContent = (value1 + value10 + value11).toLocaleString('fr-FR') ;

var pTotalDevEnCours = document.querySelectorAll('.total_odn_dev .odn_en_cours p');
var textTotalDevEnCours = pTotalDevEnCours[1];
textTotalDevEnCours.textContent = (value7 + value10).toLocaleString('fr-FR') ;

var pTotalDevRealise = document.querySelectorAll('.total_odn_dev .odn_realise p');
var textTotalDevRealise = pTotalDevRealise[1];
textTotalDevRealise.innerHTML = ((value1 + value10 + value11) === 0) ? '0' : (value8 + value11).toLocaleString('fr-FR') 
 + '&nbsp;&nbsp<span>'
 + ' ' + ((value8 + value11)/(value1 + value10 + value11)*100).toFixed(0) + '%</span>';


// affichage total  mod 
var pTotalModInscrit = document.querySelectorAll('.total_odn_mod .odn_inscrit p');
var textTotalModInscrit = pTotalModInscrit[1];
textTotalModInscrit.textContent = (value4 + value16 + value17).toLocaleString('fr-FR') ;

var pTotalModEnCours = document.querySelectorAll('.total_odn_mod .odn_en_cours p');
var textTotalModEnCours = pTotalModEnCours[1];
textTotalModEnCours.textContent = (value13 + value16).toLocaleString('fr-FR') ;

var pTotalModRealise = document.querySelectorAll('.total_odn_mod .odn_realise p');
var textTotalModRealise = pTotalModRealise[1];
textTotalModRealise.innerHTML = ((value4 + value16 + value17) === 0) ? '0' : (value14 + value17).toLocaleString('fr-FR') 
 + '&nbsp;&nbsp<span>'
 + ' ' + ((value14 + value17)/(value4 + value16 + value17)*100).toFixed(0) + '%</span>';

// affichage total ODN

var pTotalInscrit = document.querySelectorAll('.total_odn .odn_inscrit p');
var textTotalInscrit = pTotalInscrit[1];
textTotalInscrit.textContent = (value1 + value10 + value11 + value4 + value16 + value17)
.toLocaleString('fr-FR') ;

var pTotalEnCours = document.querySelectorAll('.total_odn .odn_en_cours p');
var textTotalEnCours = pTotalEnCours[1];
textTotalEnCours.textContent = (value7 + value10 + value13 + value16).toLocaleString('fr-FR') ;

var pTotalRealise = document.querySelectorAll('.total_odn .odn_realise p');
var textTotalRealise = pTotalRealise[1];
textTotalRealise.innerHTML = ((value1 + value10 + value11 + value4 + value16 + value17) === 0) ? '0' : (value8 + value11 + value14 + value17).toLocaleString('fr-FR') 
 + '&nbsp;&nbsp<span>'
 + ' ' + ((value8 + value11 + value14 + value17)/(value1 + value10 + value11 + value4 + value16 + value17)*100).toFixed(0) + '%</span>';


function cleanAndParseInt(numberString) {
  let cleanedString;
  if (numberString.includes('%')) {
      cleanedString = numberString.split('%')[0];
   } else {
      cleanedString = numberString.replace(/\D/g, '');
   }

  var floatValue = parseInt(cleanedString);
  return floatValue;
}

function sortTableAsc(column) {
  var table, rows, switching, i, x, y, shouldSwitch;
  table = document.querySelector('.recap_dot');
  switching = true;
  while (switching) {
    switching = false;
    rows = table.rows;
    for (i = 1; i < (rows.length-1); i++) {
      shouldSwitch = false;
      x = rows[i].querySelectorAll("td")[column];
      y = rows[i + 1].querySelectorAll("td")[column];
      
      if (x && y && cleanAndParseInt(x.innerHTML) > cleanAndParseInt(y.innerHTML)) {
        shouldSwitch = true;
        break;
      }
    }
    if (shouldSwitch) {
      rows[i].parentNode.insertBefore(rows[i + 1], rows[i]);
      switching = true;
    }
  }
   // Ajouter des numéros à la colonne index 0
   for (i = 2; i < rows.length; i++) {
    rows[i].querySelectorAll("td")[0].innerHTML = i-1;
  }
  
}

// Fonction de tri par ordre décroissant
function sortTableDesc(column) {
  var table, rows, switching, i, x, y, shouldSwitch;
  table = document.querySelector('.recap_dot');
  switching = true;
  while (switching) {
    switching = false;
    rows = table.rows;
    for (i = 1; i < (rows.length-1); i++) {
      shouldSwitch = false;
      x = rows[i].querySelectorAll("td")[column];
      y = rows[i + 1].querySelectorAll("td")[column];
      if (x && y && cleanAndParseInt(x.innerHTML) < cleanAndParseInt(y.innerHTML)) {
        shouldSwitch = true;
        break;
      }
    }
    if (shouldSwitch) {
      rows[i].parentNode.insertBefore(rows[i + 1], rows[i]);
      switching = true;
    }
  }
   // Ajouter des numéros à la colonne index 0
   for (i = 2; i < rows.length; i++) {
    rows[i].querySelectorAll("td")[0].innerHTML = i-1;
  }
  
}

function toggleSort(column) {
  var columnHeader = document.getElementById("col-" + column);
  var sortDirection = columnHeader.dataset.sortDirection;

  if (sortDirection === "asc") {
    sortTableAsc(column);
    columnHeader.dataset.sortDirection = "desc";
  } else {
    sortTableDesc(column);
    columnHeader.dataset.sortDirection = "asc";
  }
}

document.getElementById("col-3").addEventListener("click", function () {
  toggleSort(3);
});

document.getElementById("col-6").addEventListener("click", function () {
  toggleSort(6);
});
document.getElementById("col-7").addEventListener("click", function () {
  toggleSort(7);
});

document.getElementById("col-8").addEventListener("click", function () {
  toggleSort(8);
});document.getElementById("col-10").addEventListener("click", function () {
  toggleSort(10);
});

document.getElementById("col-13").addEventListener("click", function () {
  toggleSort(13);
});document.getElementById("col-14").addEventListener("click", function () {
  toggleSort(14);
});

document.getElementById("col-15").addEventListener("click", function () {
  toggleSort(15);
});

// fonction affichage barre de progession etude finalisée




document.addEventListener("DOMContentLoaded", function() {
  // Sélectionnez tous les éléments avec la classe "progress-bar"
  var progressBars = document.querySelectorAll(".progress-bar");

  // Parcourez tous les éléments sélectionnés
  progressBars.forEach(function(progressBar) {
    // Récupérez la valeur du taux à partir de l'attribut "data-value"
    var value = parseFloat(progressBar.dataset.value);

    // Mettez à jour la largeur de la barre de progression en fonction de la valeur du taux
    progressBar.style.width = value + "%";

   

    // Sélectionnez l'élément avec la classe "progress-value" et mettez à jour son contenu
    var progressValue = progressBar.querySelector(".progress-value");
    progressValue.textContent = value.toFixed(0) + "%";
  });
});

// partie evalusation sur la derniere colonne 



function updateDot15Column() {
  var evaluationDropdown = document.getElementById('evaluation');
  var selectedValue = evaluationDropdown.value;

  
    const poids_TA = 0.5; // Poids attribué au taux d'avancement
    const poids_R = 0.5; // Poids attribué à % de dot5Value
    var dot0Cells = document.querySelectorAll('.recap_dot #dot_0');
    
    let  eval_cells = document.querySelectorAll('.recap_dot #dot_15');
    let  dot1Cells = document.querySelectorAll('.recap_dot #dot_1');
    let  dot2Cells = document.querySelectorAll('.recap_dot #dot_2');
    let  dot3Cells = document.querySelectorAll('.recap_dot #dot_3');
    let  dot4Cells = document.querySelectorAll('.recap_dot #dot_4');
    let  dot5Cells = document.querySelectorAll('.recap_dot #dot_5');
    let  dot6Cells = document.querySelectorAll('.recap_dot #dot_6');
    let  dot7Cells = document.querySelectorAll('.recap_dot #dot_7');
    let  dot8Cells = document.querySelectorAll('.recap_dot #dot_8');
    let  dot9Cells = document.querySelectorAll('.recap_dot #dot_9');
    let  dot10Cells = document.querySelectorAll('.recap_dot #dot_10');
    let  dot11Cells = document.querySelectorAll('.recap_dot #dot_11');
    let  dot12Cells = document.querySelectorAll('.recap_dot #dot_12');
    let  dot13Cells = document.querySelectorAll('.recap_dot #dot_13');
    let  dot14Cells = document.querySelectorAll('.recap_dot #dot_14');

  if ([2, 4, 6, 8, 10, 12].includes(parseInt(selectedValue))) {
    
    let  dot_dev_pa_max  = 0;
    let  dot_mod_pa_max  = 0;
    let  dot_dev_mod_pa_max  = 0;
    let  dot_dev_total_max  = 0;
    let  dot_mod_total_max  = 0;
    let dot_total_max = 0;

    let  cap_prevue_dev = 0;
    let  cap_prevue_mod = 0;

    let cap_dot_r_dev =0;
    let cap_dot_r_mod =0;

    let cap_dot_r_rar_dev =0;
    let cap_dot_r_rar_mod =0;
    
    for (let i = 0; i < dot5Cells.length; i++) {
       cap_dot_r_dev =  parseInt(dot5Cells[i].textContent.replace(/\s/g, ''), 10);
       cap_dot_r_mod =  parseInt(dot12Cells[i].textContent.replace(/\s/g, ''), 10);
       cap_dot_r_rar_dev = parseInt(dot6Cells[i].textContent.replace(/\s/g, ''), 10);
       cap_dot_r_rar_mod = parseInt(dot13Cells[i].textContent.replace(/\s/g, ''), 10);

      if (cap_dot_r_dev > dot_dev_pa_max) {
          dot_dev_pa_max = cap_dot_r_dev;  }

      if (cap_dot_r_mod > dot_mod_pa_max) {
          dot_mod_pa_max = cap_dot_r_mod;  }
      
      if (cap_dot_r_mod + cap_dot_r_dev > dot_dev_mod_pa_max) {
           dot_dev_mod_pa_max = cap_dot_r_mod + cap_dot_r_dev  ;  }
           
      if ( cap_dot_r_dev + cap_dot_r_rar_dev > dot_dev_total_max) {
           dot_dev_total_max = cap_dot_r_dev + cap_dot_r_rar_dev  ; }

      if ( cap_dot_r_mod + cap_dot_r_rar_mod > dot_mod_total_max) {
          dot_mod_total_max = cap_dot_r_mod + cap_dot_r_rar_mod  ;  }
          
      if ( cap_dot_r_mod + cap_dot_r_rar_mod + cap_dot_r_dev + cap_dot_r_rar_dev > dot_total_max) {
            dot_total_max = cap_dot_r_mod + cap_dot_r_rar_mod + cap_dot_r_dev + cap_dot_r_rar_dev  ;  }
   
 
     }

     for (let i = 0; i < dot0Cells.length; i++) {
      
      cap_prevue_dev = parseInt(dot1Cells[i].textContent.replace(/\s/g, ''), 10);
      cap_dot_r_dev = parseInt(dot5Cells[i].textContent.replace(/\s/g, ''), 10);
      
      cap_prevue_mod = parseInt(dot8Cells[i].textContent.replace(/\s/g, ''), 10);
      cap_dot_r_mod =  parseInt(dot12Cells[i].textContent.replace(/\s/g, ''), 10);

      cap_dot_r_rar_dev = parseInt(dot6Cells[i].textContent.replace(/\s/g, ''), 10);
      cap_dot_r_rar_mod = parseInt(dot13Cells[i].textContent.replace(/\s/g, ''), 10);

      let tauxIndividuel_dev_pa = (cap_dot_r_dev / cap_prevue_dev) * 100;
      let tauxDotValue_dev_pa = (cap_dot_r_dev / dot_dev_pa_max) * 100;

      let tauxIndividuel_mod_pa = (cap_dot_r_mod / cap_prevue_mod) * 100;
      let tauxDotValue_mod_pa = (cap_dot_r_mod / dot_mod_pa_max) * 100;

      let tauxIndividuel_dev_mod_pa = ((cap_dot_r_mod + cap_dot_r_dev)/ (cap_prevue_dev + cap_prevue_mod)) * 100;
      let tauxDotValue_dev_mod_pa = ((cap_dot_r_mod + cap_dot_r_dev) / (dot_dev_mod_pa_max)) * 100;

      
      let tauxIndividuel_dev_total = (( cap_dot_r_dev + cap_dot_r_rar_dev)/ (cap_prevue_dev + cap_dot_r_rar_dev)) * 100;
      let tauxDotValue_dev_total = ((cap_dot_r_dev + cap_dot_r_rar_dev) / (dot_dev_total_max)) * 100;

      let tauxIndividuel_mod_total = (( cap_dot_r_mod + cap_dot_r_rar_mod)/ (cap_prevue_mod + cap_dot_r_rar_mod)) * 100;
      let tauxDotValue_mod_total = ((cap_dot_r_mod + cap_dot_r_rar_mod) / (dot_mod_total_max)) * 100;

      let tauxIndividuel_total = (( cap_dot_r_mod + cap_dot_r_rar_mod + cap_dot_r_dev + cap_dot_r_rar_dev)/ (cap_prevue_mod + cap_dot_r_rar_mod + cap_prevue_dev + cap_dot_r_rar_dev )) * 100;
      let tauxDotValue_total = ((cap_dot_r_mod + cap_dot_r_rar_mod + cap_dot_r_dev + cap_dot_r_rar_dev) / (dot_total_max)) * 100;
  
      let score_dev_pa = (poids_TA * tauxIndividuel_dev_pa) + (poids_R * tauxDotValue_dev_pa);
      let score_mod_pa = (poids_TA * tauxIndividuel_mod_pa) + (poids_R * tauxDotValue_mod_pa);
      let score_dev_mod_pa = (poids_TA * tauxIndividuel_dev_mod_pa) + (poids_R * tauxDotValue_dev_mod_pa);
      let score_dev_total = (poids_TA * tauxIndividuel_dev_total) + (poids_R * tauxDotValue_dev_total);
      let score_mod_total = (poids_TA * tauxIndividuel_mod_total) + (poids_R * tauxDotValue_mod_total);
      let score_total = (poids_TA * tauxIndividuel_total) + (poids_R * tauxDotValue_total);
       
      switch (selectedValue) {

        case '2':
          eval_cells[i].textContent = score_dev_pa.toFixed(2);
        break;
        case '4':
          eval_cells[i].textContent = score_mod_pa.toFixed(2);
        break;
        case '6':
          eval_cells[i].textContent = score_dev_mod_pa.toFixed(2);
        break;
        case '8':
          eval_cells[i].textContent = score_dev_total.toFixed(2);
        break;
        case '10':
          eval_cells[i].textContent = score_mod_total.toFixed(2);
        break;
        case '12':
          eval_cells[i].textContent = score_total.toFixed(2);
        break;

     }
   
   
   
    }

   
  } else {
  for (var i = 0; i < dot0Cells.length; i++) { 

      let dot1Cell = parseInt(dot1Cells[i].textContent.replace(/\s/g, ''), 10);
      let dot2Cell = parseInt(dot2Cells[i].textContent.replace(/\s/g, ''), 10);
      let dot35Cell = parseInt(dot3Cells[i].textContent.replace(/\s/g, ''), 10);
      let dot4Cell = parseInt(dot4Cells[i].textContent.replace(/\s/g, ''), 10);
      let dot5Cell = parseInt(dot5Cells[i].textContent.replace(/\s/g, ''), 10);
      let dot6Cell = parseInt(dot6Cells[i].textContent.replace(/\s/g, ''), 10);
      let dot7Cell = parseInt(dot7Cells[i].textContent.replace(/\s/g, ''), 10);
      let dot8Cell = parseInt(dot8Cells[i].textContent.replace(/\s/g, ''), 10);
      let dot95Cell = parseInt(dot9Cells[i].textContent.replace(/\s/g, ''), 10);
      let dot10Cell = parseInt(dot10Cells[i].textContent.replace(/\s/g, ''), 10);
      let dot11Cell = parseInt(dot11Cells[i].textContent.replace(/\s/g, ''), 10);
      let dot12Cell = parseInt(dot12Cells[i].textContent.replace(/\s/g, ''), 10);
      let dot13Cell = parseInt(dot13Cells[i].textContent.replace(/\s/g, ''), 10);
      let dot14Cell = parseInt(dot14Cells[i].textContent.replace(/\s/g, ''), 10);
      let eval_cell = eval_cells[i];
      
      
      
  switch (selectedValue) {
    
    case '1':
      eval_cell.textContent = dot1Cell !== 0 ? ((dot5Cell / dot1Cell) * 100).toFixed(1) + '%' + ' - ' + dot5Cell : '';
       break;
    case '3':
      eval_cell.textContent = dot8Cell !== 0 ? ((dot12Cell / dot8Cell) * 100).toFixed(1) + '%' + ' - ' + dot12Cell : '';
      break;
    case '5':
      eval_cell.textContent = (dot12Cell + dot5Cell)  !== 0 ? (((dot12Cell + dot5Cell) / (dot8Cell + dot1Cell)) * 100).toFixed(1) + '%' + ' - ' + (dot12Cell + dot5Cell) : '';
      break;
    case '7':
      eval_cell.textContent = (dot1Cell + dot6Cell) !== 0 ? (((dot5Cell + dot6Cell) / (dot1Cell + dot6Cell)) * 100).toFixed(1) + '%' + ' - ' + (dot5Cell + dot6Cell): '';
      break;
    case '9':
      eval_cell.textContent = (dot8Cell + dot13Cell) !== 0 ? (((dot12Cell + dot13Cell) / (dot8Cell + dot13Cell)) * 100).toFixed(1) + '%' + ' - ' + (dot12Cell + dot13Cell) : '';
      break;
    case '11':
      eval_cell.textContent = (dot8Cell + dot13Cell + dot1Cell + dot6Cell) !== 0 ? (((dot12Cell + dot13Cell + dot5Cell + dot6Cell) / (dot8Cell + dot13Cell + dot1Cell + dot6Cell)) * 100).toFixed(1) + '%' + ' - ' + (dot12Cell + dot13Cell + dot5Cell + dot6Cell) : '';
      break;
    default:
      eval_cell.textContent = (dot1Cell + dot6Cell) !== 0 ? (((dot5Cell + dot6Cell) / (dot1Cell + dot6Cell)) * 100).toFixed(1) + '%' + ' - ' + (dot5Cell + dot6Cell): '';
      break;

  }
}
  }
   
}

var evaluationDropdown = document.getElementById('evaluation');
evaluationDropdown.addEventListener('change', function() {
  updateDot15Column();
  setTimeout(function() {

    sortTableDesc(16);
  }, 0);
});


