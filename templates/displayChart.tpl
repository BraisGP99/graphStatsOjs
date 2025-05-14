<div class="item chart">
    <h2 class="label">Chart</h2>
    <div class="chart-buttons">
    
        <button id="monthButton" value="monthly" aria-label="{translate key="plugins.generic.graphStatsOjs.MonthButton"}" class="buttonChart">{translate key="plugins.generic.graphStatsOjs.MonthButton"}</button>
       
        <button id="yearButton" value="anual" aria-label="{translate key="plugins.generic.graphStatsOjs.AnualButton"}" class="buttonChart">{translate key="plugins.generic.graphStatsOjs.AnualButton"}</button>
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
    const monthButton = document.getElementById('monthButton')
    const yearButton = document.getElementById('yearButton')
    monthButton.addEventListener('click',changeChart)
    yearButton.addEventListener('click',changeChart)

    const stats = {$stats};
    const statsMonth = stats.month;
    const statsYear = stats.year
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
    console.log(stats)
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

const context = document.getElementById('myChart').getContext('2d');
let chartInstance;

function renderChart() {
    if (chartInstance) {
        chartInstance.destroy();
    }

    const labels = statsToShow === 'monthly' ? MONTHS : YEARS;
    const viewsData = statsToShow === 'monthly' ? viewsStatsMonthly : viewsStatsYearly;
    const downloadsData = statsToShow === 'monthly' ? totalDownloadStatsMonthly : totalDownloadStatsYearly;
    let delayed;
    chartInstance = new Chart(context, {
        type: 'line',
        data: {
            labels: labels,
            datasets: [
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
            ]
        },
        options: {
            responsive: true,
            animation: {
                onComplete: () => {
                  delayed = true;
                },
                delay: (context) => {
                  let delay = 0;
                  if (context.type === 'data' && context.mode === 'default' && !delayed) {
                   delay = context.dataIndex * 300 + context.datasetIndex * 100;
                 }
                 return delay;
                 },
              },
            scales: {
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

