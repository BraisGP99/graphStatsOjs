<div class="item chart">
    <h2 class="label">Chart</h2>
    <div class="chart-buttons">
    
        <button id="monthButton" value="monthly" aria-label="{translate key="plugins.generic.graphStatsOjs.monthButton"}" class="buttonChart">{translate key="plugins.generic.graphStatsOjs.monthButton"}</button>
       
        <button id="yearButton" value="yearly" aria-label="{translate key="plugins.generic.graphStatsOjs.anualButton"}" class="buttonChart">{translate key="plugins.generic.graphStatsOjs.anualButton"}</button>

        <button id="editorialButton" value="editorial" aria-label="{translate key="plugins.generic.graphStatsOjs.editorialButton"}" class="buttonChart">{translate key="plugins.generic.graphStatsOjs.editorialButton"}</button>

        
        <button id="autoresPais" value="autoresPais" aria-label="{translate key="plugins.generic.graphStatsOjs.autoresPais"}" class="buttonChart">{translate key="plugins.generic.graphStatsOjs.autoresPais"}</button>

    </div>
    <div class="chart">

        <canvas id="myChart" aria-label="canvas for statistics charts" role="img"></canvas>
    </div>
</div>
    {literal}
<script>
window.addEventListener('DOMContentLoaded', function () {
    if (typeof Chart === 'undefined') {
        console.error('Chart.js no está cargado.');
        return;
    }
    {/literal}
    let statsToShow = "monthly";
    const chartButtons = document.querySelectorAll('.chart-buttons>button')

    chartButtons.forEach(el=>el.addEventListener('click',changeChart))

    const stats = {$stats};
    const statsMonth = stats.month;
    const statsYear = stats.year;
    const statsEditorial = stats.editorial;
    const arrayAuthors = stats.authors;

    console.log(arrayAuthors);

    const authorNames = arrayAuthors.map(el => {
        const givenName = el._data.givenName?.es || el._data.givenName?.en || 'Sin nombre';
        const firstSpace = givenName.indexOf(' ');
        return firstSpace !== -1 ? givenName.slice(0, firstSpace) : givenName;
    });

        
    console.log(authorNames);
    const viewsStatsMonthly = Object.values(statsMonth).map(({ abstract, ...rest }) => abstract);
    const downloadStatsMonthly = Object.values(statsMonth).map(({ abstract, month, ...rest }) => rest);
    const totalDownloadStatsMonthly = downloadStatsMonthly.map(el =>
        Object.values(el).reduce((acc, curr) => acc + curr, 0)
    );
    
    const viewsStatsYearly = Object.values(statsYear).map(({ abstract, ...rest }) => abstract);
    const downloadStatsYearly = Object.values(statsYear).map(({ abstract, year, ...rest }) => rest);
    const totalDownloadStatsYearly = downloadStatsYearly.map(el =>
        Object.values(el).reduce((acc, curr) => acc + curr, 0)
    );
    const viewsStatsEditorial = Object.values(statsEditorial).map(item => item.value);


    console.log(stats)
 
const context = document.getElementById('myChart').getContext('2d');
let chartInstance;

function renderChart() {
    if (chartInstance) {
        chartInstance.destroy();
    }
    let viewsData, downloadsData;

switch (statsToShow) {
  case 'monthly':
    viewsData = viewsStatsMonthly;
    downloadsData = totalDownloadStatsMonthly;
    break;
  case 'yearly':
    viewsData = viewsStatsYearly;
    downloadsData = totalDownloadStatsYearly;
    break;
  case 'editorial':
    viewsData = viewsStatsEditorial;
    downloadsData = []; 
    break;
  default:
    viewsData = viewsStatsMonthly;
    downloadsData = totalDownloadStatsMonthly;
}

    const COUNTRIES = [...new Set(arrayAuthors.map(el => el._data.country))];

    const MONTHS = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec'
];
const YEARS = Object.values(statsYear).map(y => y.year);
const EDITORIAL = Object.values(statsEditorial).map(el => el.key); 


let chartType = 'line';
let labels = MONTHS;
let datasets = [
    {
        label: 'Views',
        data: viewsData,
        borderColor: 'rgba(54, 162, 235, 1)',
        backgroundColor: 'rgba(54, 162, 235, 0.2)',
        borderWidth: 2,
        pointStyle: 'rectRounded',
        pointRadius: 5,
        pointHoverRadius: 10
    },
    {
        label: 'Downloads',
        data: downloadsData,
        borderColor: 'rgba(255, 99, 132, 1)',
        backgroundColor: 'rgba(255, 99, 132, 0.2)',
        borderWidth: 2,
        pointStyle: 'rectRounded',
        pointRadius: 5,
        pointHoverRadius: 10
    }
];

let delayed;


switch(statsToShow){
    case 'yearly':
        labels = YEARS;
        break;
    case 'editorial':
        labels = EDITORIAL;
        break;
    case 'autoresPais':
        chartType = 'pie';
        labels = [...new Set(arrayAuthors.map(el => el._data.country || 'Sin país'))];
        viewsData = labels.map(
            country =>
                arrayAuthors.filter(el => el._data.country === country).length
        );
        datasets = [{
            label: 'Autores por país',
            data: viewsData,
            backgroundColor: [
                '#FF6384', '#36A2EB', '#FFCE56', '#33cc33',
                '#9966FF', '#FF9933', '#66CCCC', '#6699FF'
            ],
            borderWidth: 1
        }];
        break;
    default:
        labels = MONTHS;
}


chartInstance = new Chart(context, {
    type: chartType,
    data: {
        labels: labels,
        datasets: datasets
    },
    options: {
        responsive: true,
        animation: {
            onComplete: () => { delayed = true; },
            delay: (context) => {
                let delay = 0;
                if (context.type === 'data' && context.mode === 'default' && !delayed) {
                    delay = context.dataIndex * 150 + context.datasetIndex * 100;
                }
                return delay;
            }
        },
        scales: chartType === 'pie' ? {} : {
            y: {
                beginAtZero: true
            }
        }
    }
});

}
function changeChart(event) {
    statsToShow = event.target.value;
    renderChart();
}

renderChart();
});
</script>
<style>
.chart-buttons{
    display: grid;
    gap: 2px;
}
.buttonChart {
  background-color: #0174ad; 
  color: white;
  border: none;
  padding: 10px 20px;
  font-size: 16px;
  border-radius: 5px;
  cursor: pointer;
}

.buttonChart:hover {
  background-color: #33bbff; 
}

</style>

