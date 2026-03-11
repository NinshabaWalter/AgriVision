// Agricultural Intelligence Platform - Advanced Web Interface
class AgriculturalPlatform {
    constructor() {
        this.farmData = {
            totalAcres: 1247,
            overallHealth: 89,
            projectedRevenue: 127000,
            activeSensors: 23,
            crops: [
                { name: 'Corn', health: 92, acres: 450, icon: '🌽' },
                { name: 'Wheat', health: 87, acres: 380, icon: '🌾' },
                { name: 'Carrots', health: 95, acres: 200, icon: '🥕' },
                { name: 'Tomatoes', health: 78, acres: 217, icon: '🍅' }
            ],
            sensors: {
                soilTemperature: 23,
                soilMoisture: 45,
                phLevel: 6.8,
                npk: 320,
                lightIntensity: 850,
                windSpeed: 12
            },
            weather: {
                temperature: 24,
                humidity: 65,
                windSpeed: 12,
                uvIndex: 7,
                rainfall: 0,
                condition: 'sunny'
            }
        };
        
        this.charts = {};
        this.map = null;
        this.aiModel = null;
        
        this.initializePlatform();
    }

    async initializePlatform() {
        this.initializeCharts();
        this.initializeMap();
        this.startRealTimeUpdates();
        await this.loadAIModel();
        this.setupEventListeners();
    }

    initializeCharts() {
        // Yield Chart
        const yieldCtx = document.getElementById('yieldChart');
        if (yieldCtx) {
            this.charts.yield = new Chart(yieldCtx, {
                type: 'line',
                data: {
                    labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
                    datasets: [{
                        label: 'Projected Yield (tons)',
                        data: [45, 52, 48, 61, 55, 67, 73, 69, 78, 82, 75, 71],
                        borderColor: '#90EE90',
                        backgroundColor: 'rgba(144, 238, 144, 0.1)',
                        fill: true,
                        tension: 0.4
                    }, {
                        label: 'Actual Yield (tons)',
                        data: [42, 49, 51, 58, 57, 64, 71, 67, 76, 79, null, null],
                        borderColor: '#4a7c59',
                        backgroundColor: 'rgba(74, 124, 89, 0.1)',
                        fill: true,
                        tension: 0.4
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            labels: { color: 'white' }
                        }
                    },
                    scales: {
                        x: { 
                            ticks: { color: 'white' },
                            grid: { color: 'rgba(255, 255, 255, 0.1)' }
                        },
                        y: { 
                            ticks: { color: 'white' },
                            grid: { color: 'rgba(255, 255, 255, 0.1)' }
                        }
                    }
                }
            });
        }

        // Crop Health Chart
        const cropHealthCtx = document.getElementById('cropHealthChart');
        if (cropHealthCtx) {
            this.charts.cropHealth = new Chart(cropHealthCtx, {
                type: 'radar',
                data: {
                    labels: ['Growth Rate', 'Pest Resistance', 'Nutrient Uptake', 'Water Efficiency', 'Disease Resistance', 'Yield Potential'],
                    datasets: [{
                        label: 'Corn',
                        data: [92, 85, 88, 90, 87, 94],
                        borderColor: '#FFD700',
                        backgroundColor: 'rgba(255, 215, 0, 0.2)',
                        pointBackgroundColor: '#FFD700'
                    }, {
                        label: 'Wheat',
                        data: [87, 90, 85, 88, 92, 89],
                        borderColor: '#DEB887',
                        backgroundColor: 'rgba(222, 184, 135, 0.2)',
                        pointBackgroundColor: '#DEB887'
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            labels: { color: 'white' }
                        }
                    },
                    scales: {
                        r: {
                            ticks: { color: 'white' },
                            grid: { color: 'rgba(255, 255, 255, 0.1)' },
                            pointLabels: { color: 'white' }
                        }
                    }
                }
            });
        }

        // Sensor Chart
        const sensorCtx = document.getElementById('sensorChart');
        if (sensorCtx) {
            this.charts.sensor = new Chart(sensorCtx, {
                type: 'line',
                data: {
                    labels: Array.from({length: 24}, (_, i) => `${i}:00`),
                    datasets: [{
                        label: 'Soil Temperature (°C)',
                        data: this.generateSensorData(24, 20, 26),
                        borderColor: '#FF6B6B',
                        backgroundColor: 'rgba(255, 107, 107, 0.1)',
                        yAxisID: 'y'
                    }, {
                        label: 'Soil Moisture (%)',
                        data: this.generateSensorData(24, 40, 60),
                        borderColor: '#4ECDC4',
                        backgroundColor: 'rgba(78, 205, 196, 0.1)',
                        yAxisID: 'y1'
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            labels: { color: 'white' }
                        }
                    },
                    scales: {
                        x: { 
                            ticks: { color: 'white' },
                            grid: { color: 'rgba(255, 255, 255, 0.1)' }
                        },
                        y: {
                            type: 'linear',
                            display: true,
                            position: 'left',
                            ticks: { color: 'white' },
                            grid: { color: 'rgba(255, 255, 255, 0.1)' }
                        },
                        y1: {
                            type: 'linear',
                            display: true,
                            position: 'right',
                            ticks: { color: 'white' },
                            grid: { drawOnChartArea: false }
                        }
                    }
                }
            });
        }

        // Analytics Chart
        const analyticsCtx = document.getElementById('analyticsChart');
        if (analyticsCtx) {
            this.charts.analytics = new Chart(analyticsCtx, {
                type: 'bar',
                data: {
                    labels: ['Water Usage', 'Fertilizer', 'Pesticides', 'Labor', 'Equipment', 'Seeds'],
                    datasets: [{
                        label: 'Current Season',
                        data: [85, 92, 78, 88, 95, 90],
                        backgroundColor: 'rgba(144, 238, 144, 0.8)',
                        borderColor: '#90EE90',
                        borderWidth: 1
                    }, {
                        label: 'Previous Season',
                        data: [78, 85, 82, 85, 88, 87],
                        backgroundColor: 'rgba(74, 124, 89, 0.8)',
                        borderColor: '#4a7c59',
                        borderWidth: 1
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            labels: { color: 'white' }
                        }
                    },
                    scales: {
                        x: { 
                            ticks: { color: 'white' },
                            grid: { color: 'rgba(255, 255, 255, 0.1)' }
                        },
                        y: { 
                            ticks: { color: 'white' },
                            grid: { color: 'rgba(255, 255, 255, 0.1)' }
                        }
                    }
                }
            });
        }
    }

    generateSensorData(points, min, max) {
        return Array.from({length: points}, () => 
            Math.floor(Math.random() * (max - min + 1)) + min
        );
    }

    initializeMap() {
        const mapElement = document.getElementById('farmMap');
        if (mapElement) {
            // Initialize Leaflet map
            this.map = L.map('farmMap').setView([40.7128, -74.0060], 13);
            
            L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                attribution: '© OpenStreetMap contributors'
            }).addTo(this.map);

            // Add farm field markers
            const fields = [
                { name: 'Field A - Corn', lat: 40.7128, lng: -74.0060, health: 92, crop: '🌽' },
                { name: 'Field B - Wheat', lat: 40.7148, lng: -74.0080, health: 87, crop: '🌾' },
                { name: 'Field C - Carrots', lat: 40.7108, lng: -74.0040, health: 95, crop: '🥕' },
                { name: 'Field D - Tomatoes', lat: 40.7088, lng: -74.0100, health: 78, crop: '🍅' }
            ];

            fields.forEach(field => {
                const color = field.health > 90 ? 'green' : field.health > 80 ? 'orange' : 'red';
                
                L.circleMarker([field.lat, field.lng], {
                    radius: 15,
                    fillColor: color,
                    color: 'white',
                    weight: 2,
                    opacity: 1,
                    fillOpacity: 0.7
                }).addTo(this.map)
                .bindPopup(`
                    <div style="text-align: center;">
                        <div style="font-size: 2rem;">${field.crop}</div>
                        <strong>${field.name}</strong><br>
                        Health: ${field.health}%<br>
                        <button onclick="viewFieldDetails('${field.name}')" style="margin-top: 10px; padding: 5px 10px; background: #4a7c59; color: white; border: none; border-radius: 5px; cursor: pointer;">
                            View Details
                        </button>
                    </div>
                `);
            });

            // Add sensor locations
            const sensors = [
                { name: 'Weather Station', lat: 40.7118, lng: -74.0050, type: '🌡️' },
                { name: 'Soil Sensor 1', lat: 40.7138, lng: -74.0070, type: '🌱' },
                { name: 'Irrigation Control', lat: 40.7098, lng: -74.0090, type: '💧' }
            ];

            sensors.forEach(sensor => {
                L.marker([sensor.lat, sensor.lng])
                .addTo(this.map)
                .bindPopup(`
                    <div style="text-align: center;">
                        <div style="font-size: 2rem;">${sensor.type}</div>
                        <strong>${sensor.name}</strong><br>
                        Status: Online<br>
                        Last Update: 2 min ago
                    </div>
                `);
            });
        }
    }

    async loadAIModel() {
        try {
            // Simulate loading a TensorFlow.js model for crop prediction
            console.log('Loading AI model for crop analysis...');
            
            // In a real implementation, you would load a pre-trained model
            // this.aiModel = await tf.loadLayersModel('/models/crop-prediction-model.json');
            
            // For demo purposes, we'll simulate the model
            this.aiModel = {
                predict: (inputData) => {
                    // Simulate AI prediction
                    return {
                        cropHealth: Math.random() * 100,
                        yieldPrediction: Math.random() * 1000,
                        recommendations: [
                            'Increase nitrogen fertilizer by 10%',
                            'Monitor for pest activity',
                            'Adjust irrigation schedule'
                        ]
                    };
                }
            };
            
            console.log('AI model loaded successfully');
        } catch (error) {
            console.error('Failed to load AI model:', error);
        }
    }

    startRealTimeUpdates() {
        // Simulate real-time sensor data updates
        setInterval(() => {
            this.updateSensorData();
            this.updateWeatherData();
            this.updateCharts();
        }, 30000); // Update every 30 seconds

        // Update time-sensitive displays
        setInterval(() => {
            this.updateTimestamps();
        }, 60000); // Update every minute
    }

    updateSensorData() {
        // Simulate sensor data fluctuations
        this.farmData.sensors.soilTemperature += (Math.random() - 0.5) * 2;
        this.farmData.sensors.soilMoisture += (Math.random() - 0.5) * 5;
        this.farmData.sensors.phLevel += (Math.random() - 0.5) * 0.2;
        
        // Update sensor display
        this.updateSensorDisplay();
    }

    updateSensorDisplay() {
        const sensorCards = document.querySelectorAll('.sensor-card .sensor-value');
        if (sensorCards.length >= 6) {
            sensorCards[0].textContent = `${this.farmData.sensors.soilTemperature.toFixed(1)}°C`;
            sensorCards[1].textContent = `${this.farmData.sensors.soilMoisture.toFixed(0)}%`;
            sensorCards[2].textContent = this.farmData.sensors.phLevel.toFixed(1);
            sensorCards[3].textContent = `${this.farmData.sensors.npk}`;
            sensorCards[4].textContent = `${this.farmData.sensors.lightIntensity}`;
            sensorCards[5].textContent = `${this.farmData.sensors.windSpeed}`;
        }
    }

    updateWeatherData() {
        // Simulate weather changes
        this.farmData.weather.temperature += (Math.random() - 0.5) * 3;
        this.farmData.weather.humidity += (Math.random() - 0.5) * 10;
        
        // Update weather display
        const tempElement = document.querySelector('.temperature');
        if (tempElement) {
            tempElement.textContent = `${Math.round(this.farmData.weather.temperature)}°C`;
        }
    }

    updateCharts() {
        // Update sensor chart with new data
        if (this.charts.sensor) {
            const newTempData = this.generateSensorData(24, 20, 26);
            const newMoistureData = this.generateSensorData(24, 40, 60);
            
            this.charts.sensor.data.datasets[0].data = newTempData;
            this.charts.sensor.data.datasets[1].data = newMoistureData;
            this.charts.sensor.update('none');
        }
    }

    updateTimestamps() {
        const now = new Date();
        const timeString = now.toLocaleTimeString();
        
        // Update any timestamp displays
        document.querySelectorAll('.last-update').forEach(element => {
            element.textContent = `Last updated: ${timeString}`;
        });
    }

    setupEventListeners() {
        // Add event listeners for interactive elements
        document.addEventListener('click', (e) => {
            if (e.target.classList.contains('crop-card')) {
                this.showCropDetails(e.target);
            }
        });

        // Add touch gestures for mobile
        this.setupTouchGestures();
    }

    setupTouchGestures() {
        let touchStartX = 0;
        let touchStartY = 0;

        document.addEventListener('touchstart', e => {
            touchStartX = e.changedTouches[0].screenX;
            touchStartY = e.changedTouches[0].screenY;
        }, false);

        document.addEventListener('touchend', e => {
            const touchEndX = e.changedTouches[0].screenX;
            const touchEndY = e.changedTouches[0].screenY;
            
            const deltaX = touchEndX - touchStartX;
            const deltaY = touchEndY - touchStartY;
            
            // Swipe gestures for tab navigation
            if (Math.abs(deltaX) > Math.abs(deltaY) && Math.abs(deltaX) > 50) {
                if (deltaX > 0) {
                    this.navigateTab('prev');
                } else {
                    this.navigateTab('next');
                }
            }
        }, false);
    }

    navigateTab(direction) {
        const tabs = document.querySelectorAll('.tab');
        const activeTab = document.querySelector('.tab.active');
        const currentIndex = Array.from(tabs).indexOf(activeTab);
        
        let newIndex;
        if (direction === 'next') {
            newIndex = (currentIndex + 1) % tabs.length;
        } else {
            newIndex = (currentIndex - 1 + tabs.length) % tabs.length;
        }
        
        tabs[newIndex].click();
    }

    async runAICropAnalysis(cropType, analysisType) {
        if (!this.aiModel) {
            console.error('AI model not loaded');
            return;
        }

        // Show loading indicator
        this.showLoadingIndicator('Running AI analysis...');

        try {
            // Simulate AI processing time
            await new Promise(resolve => setTimeout(resolve, 2000));

            // Get AI prediction
            const prediction = this.aiModel.predict({
                cropType: cropType,
                analysisType: analysisType,
                sensorData: this.farmData.sensors,
                weatherData: this.farmData.weather
            });

            // Show results
            this.showAIAnalysisResults(prediction);

        } catch (error) {
            console.error('AI analysis failed:', error);
            this.showError('AI analysis failed. Please try again.');
        } finally {
            this.hideLoadingIndicator();
        }
    }

    showAIAnalysisResults(results) {
        const modal = document.createElement('div');
        modal.className = 'modal';
        modal.style.display = 'flex';
        modal.innerHTML = `
            <div class="modal-content">
                <h2>🤖 AI Analysis Results</h2>
                <div style="margin: 20px 0;">
                    <div style="margin-bottom: 15px;">
                        <strong>Crop Health Score:</strong> ${results.cropHealth.toFixed(1)}%
                    </div>
                    <div style="margin-bottom: 15px;">
                        <strong>Predicted Yield:</strong> ${results.yieldPrediction.toFixed(0)} kg/hectare
                    </div>
                    <div style="margin-bottom: 15px;">
                        <strong>AI Recommendations:</strong>
                        <ul style="margin-left: 20px; margin-top: 10px;">
                            ${results.recommendations.map(rec => `<li>${rec}</li>`).join('')}
                        </ul>
                    </div>
                </div>
                <button class="btn" onclick="this.closest('.modal').remove()">Close</button>
            </div>
        `;
        document.body.appendChild(modal);
    }

    showLoadingIndicator(message) {
        const indicator = document.createElement('div');
        indicator.id = 'loadingIndicator';
        indicator.style.cssText = `
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.8);
            display: flex;
            align-items: center;
            justify-content: center;
            z-index: 2000;
        `;
        indicator.innerHTML = `
            <div style="text-align: center; color: white;">
                <div class="loading-spinner"></div>
                <p style="margin-top: 20px; font-size: 1.1rem;">${message}</p>
            </div>
        `;
        document.body.appendChild(indicator);
    }

    hideLoadingIndicator() {
        const indicator = document.getElementById('loadingIndicator');
        if (indicator) {
            indicator.remove();
        }
    }

    showError(message) {
        const alert = document.createElement('div');
        alert.style.cssText = `
            position: fixed;
            top: 20px;
            right: 20px;
            background: #f44336;
            color: white;
            padding: 15px 20px;
            border-radius: 10px;
            z-index: 1500;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.3);
        `;
        alert.textContent = message;
        document.body.appendChild(alert);
        
        setTimeout(() => alert.remove(), 5000);
    }

    // Irrigation control system
    async controlIrrigation(zone, action) {
        this.showLoadingIndicator('Updating irrigation system...');
        
        try {
            // Simulate API call to irrigation system
            await new Promise(resolve => setTimeout(resolve, 1500));
            
            const message = action === 'start' ? 
                `Irrigation started in ${zone}` : 
                `Irrigation stopped in ${zone}`;
                
            this.showSuccess(message);
            
        } catch (error) {
            this.showError('Failed to control irrigation system');
        } finally {
            this.hideLoadingIndicator();
        }
    }

    showSuccess(message) {
        const alert = document.createElement('div');
        alert.style.cssText = `
            position: fixed;
            top: 20px;
            right: 20px;
            background: #4caf50;
            color: white;
            padding: 15px 20px;
            border-radius: 10px;
            z-index: 1500;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.3);
        `;
        alert.textContent = message;
        document.body.appendChild(alert);
        
        setTimeout(() => alert.remove(), 3000);
    }

    // Export farm data
    exportFarmData(format = 'json') {
        const data = {
            timestamp: new Date().toISOString(),
            farmData: this.farmData,
            sensorReadings: this.farmData.sensors,
            weatherData: this.farmData.weather
        };

        let content, filename, mimeType;

        switch (format) {
            case 'csv':
                content = this.convertToCSV(data);
                filename = 'farm-data.csv';
                mimeType = 'text/csv';
                break;
            case 'json':
            default:
                content = JSON.stringify(data, null, 2);
                filename = 'farm-data.json';
                mimeType = 'application/json';
                break;
        }

        const blob = new Blob([content], { type: mimeType });
        const url = URL.createObjectURL(blob);
        const link = document.createElement('a');
        link.href = url;
        link.download = filename;
        link.click();
        URL.revokeObjectURL(url);
    }

    convertToCSV(data) {
        const headers = ['Timestamp', 'Metric', 'Value', 'Unit'];
        const rows = [headers.join(',')];

        // Add sensor data
        Object.entries(data.sensorReadings).forEach(([key, value]) => {
            rows.push([data.timestamp, key, value, this.getSensorUnit(key)].join(','));
        });

        // Add weather data
        Object.entries(data.weatherData).forEach(([key, value]) => {
            rows.push([data.timestamp, `weather_${key}`, value, this.getWeatherUnit(key)].join(','));
        });

        return rows.join('\n');
    }

    getSensorUnit(sensor) {
        const units = {
            soilTemperature: '°C',
            soilMoisture: '%',
            phLevel: 'pH',
            npk: 'ppm',
            lightIntensity: 'lux',
            windSpeed: 'km/h'
        };
        return units[sensor] || '';
    }

    getWeatherUnit(metric) {
        const units = {
            temperature: '°C',
            humidity: '%',
            windSpeed: 'km/h',
            uvIndex: 'index',
            rainfall: 'mm'
        };
        return units[metric] || '';
    }
}

// Global functions for HTML onclick handlers
function switchTab(tabName) {
    // Hide all tab contents
    document.querySelectorAll('.tab-content').forEach(content => {
        content.classList.remove('active');
    });
    
    // Remove active class from all tabs
    document.querySelectorAll('.tab').forEach(tab => {
        tab.classList.remove('active');
    });
    
    // Show selected tab content
    document.getElementById(tabName).classList.add('active');
    
    // Add active class to clicked tab
    event.target.classList.add('active');
}

function showCropAnalysis() {
    document.getElementById('cropAnalysisModal').style.display = 'flex';
}

function showWeatherForecast() {
    platform.showLoadingIndicator('Loading weather forecast...');
    setTimeout(() => {
        platform.hideLoadingIndicator();
        platform.showSuccess('Weather forecast updated');
    }, 1500);
}

function showIrrigationControl() {
    const modal = document.createElement('div');
    modal.className = 'modal';
    modal.style.display = 'flex';
    modal.innerHTML = `
        <div class="modal-content">
            <h2>💧 Irrigation Control</h2>
            <div class="form-group">
                <label>Select Zone:</label>
                <select id="irrigationZone">
                    <option>Zone 1 - Field A</option>
                    <option>Zone 2 - Field B</option>
                    <option>Zone 3 - Field C</option>
                    <option>Zone 4 - Field D</option>
                </select>
            </div>
            <div style="display: flex; gap: 10px;">
                <button class="btn" onclick="controlIrrigation('start')">Start Irrigation</button>
                <button class="btn btn-secondary" onclick="controlIrrigation('stop')">Stop Irrigation</button>
            </div>
            <button class="btn btn-secondary" onclick="this.closest('.modal').remove()" style="margin-top: 10px;">Close</button>
        </div>
    `;
    document.body.appendChild(modal);
}

function controlIrrigation(action) {
    const zone = document.getElementById('irrigationZone').value;
    platform.controlIrrigation(zone, action);
    document.querySelector('.modal').remove();
}

function showPestDetection() {
    platform.showLoadingIndicator('Analyzing images for pest detection...');
    setTimeout(() => {
        platform.hideLoadingIndicator();
        const modal = document.createElement('div');
        modal.className = 'modal';
        modal.style.display = 'flex';
        modal.innerHTML = `
            <div class="modal-content">
                <h2>🐛 Pest Detection Results</h2>
                <div style="margin: 20px 0;">
                    <div style="margin-bottom: 15px;">
                        <strong>Detected Pests:</strong>
                        <ul style="margin-left: 20px; margin-top: 10px;">
                            <li>Aphids - Low severity (Field A)</li>
                            <li>Corn Borer - Medium severity (Field B)</li>
                        </ul>
                    </div>
                    <div style="margin-bottom: 15px;">
                        <strong>Recommended Actions:</strong>
                        <ul style="margin-left: 20px; margin-top: 10px;">
                            <li>Apply neem oil spray to Field A</li>
                            <li>Consider biological control for Field B</li>
                            <li>Increase monitoring frequency</li>
                        </ul>
                    </div>
                </div>
                <button class="btn" onclick="this.closest('.modal').remove()">Close</button>
            </div>
        `;
        document.body.appendChild(modal);
    }, 2000);
}

function showYieldPrediction() {
    platform.showLoadingIndicator('Calculating yield predictions...');
    setTimeout(() => {
        platform.hideLoadingIndicator();
        const modal = document.createElement('div');
        modal.className = 'modal';
        modal.style.display = 'flex';
        modal.innerHTML = `
            <div class="modal-content">
                <h2>📊 Yield Prediction</h2>
                <div style="margin: 20px 0;">
                    <div style="margin-bottom: 15px;">
                        <strong>Predicted Yields (per hectare):</strong>
                        <ul style="margin-left: 20px; margin-top: 10px;">
                            <li>Corn: 8,500 kg (+12% vs last year)</li>
                            <li>Wheat: 4,200 kg (+8% vs last year)</li>
                            <li>Carrots: 35,000 kg (+15% vs last year)</li>
                            <li>Tomatoes: 42,000 kg (+5% vs last year)</li>
                        </ul>
                    </div>
                    <div style="margin-bottom: 15px;">
                        <strong>Confidence Level:</strong> 87%
                    </div>
                    <div style="margin-bottom: 15px;">
                        <strong>Factors Considered:</strong>
                        <ul style="margin-left: 20px; margin-top: 10px;">
                            <li>Historical yield data</li>
                            <li>Current weather patterns</li>
                            <li>Soil conditions</li>
                            <li>Crop health status</li>
                        </ul>
                    </div>
                </div>
                <button class="btn" onclick="this.closest('.modal').remove()">Close</button>
            </div>
        `;
        document.body.appendChild(modal);
    }, 2000);
}

function runCropAnalysis() {
    const cropType = document.querySelector('#cropAnalysisModal select').value;
    const analysisType = document.querySelectorAll('#cropAnalysisModal select')[1].value;
    
    closeModal('cropAnalysisModal');
    platform.runAICropAnalysis(cropType, analysisType);
}

function closeModal(modalId) {
    document.getElementById(modalId).style.display = 'none';
}

function showAllAlerts() {
    const modal = document.createElement('div');
    modal.className = 'modal';
    modal.style.display = 'flex';
    modal.innerHTML = `
        <div class="modal-content">
            <h2>🚨 All Farm Alerts</h2>
            <div style="margin: 20px 0; max-height: 400px; overflow-y: auto;">
                <div class="alert-card critical">
                    <div class="alert-title">🐛 Critical: Pest Infestation</div>
                    <div class="alert-description">Severe aphid infestation detected in Zone 7. Immediate treatment required.</div>
                </div>
                <div class="alert-card">
                    <div class="alert-title">💧 Warning: Low Soil Moisture</div>
                    <div class="alert-description">Soil moisture in Field C below optimal levels. Consider irrigation adjustment.</div>
                </div>
                <div class="alert-card success">
                    <div class="alert-title">✅ Info: Harvest Ready</div>
                    <div class="alert-description">Carrots in Field B have reached optimal harvest size.</div>
                </div>
                <div class="alert-card">
                    <div class="alert-title">🌡️ Warning: Temperature Alert</div>
                    <div class="alert-description">Soil temperature in greenhouse exceeding optimal range.</div>
                </div>
                <div class="alert-card">
                    <div class="alert-title">📊 Info: Sensor Maintenance</div>
                    <div class="alert-description">Sensor #15 requires calibration. Schedule maintenance.</div>
                </div>
            </div>
            <button class="btn" onclick="this.closest('.modal').remove()">Close</button>
        </div>
    `;
    document.body.appendChild(modal);
}

function viewFieldDetails(fieldName) {
    const modal = document.createElement('div');
    modal.className = 'modal';
    modal.style.display = 'flex';
    modal.innerHTML = `
        <div class="modal-content">
            <h2>🌾 ${fieldName} Details</h2>
            <div style="margin: 20px 0;">
                <div style="margin-bottom: 15px;">
                    <strong>Area:</strong> 125 hectares
                </div>
                <div style="margin-bottom: 15px;">
                    <strong>Crop Health:</strong> 92%
                </div>
                <div style="margin-bottom: 15px;">
                    <strong>Growth Stage:</strong> Reproductive
                </div>
                <div style="margin-bottom: 15px;">
                    <strong>Expected Harvest:</strong> 3 weeks
                </div>
                <div style="margin-bottom: 15px;">
                    <strong>Last Irrigation:</strong> 2 days ago
                </div>
                <div style="margin-bottom: 15px;">
                    <strong>Soil Conditions:</strong>
                    <ul style="margin-left: 20px; margin-top: 5px;">
                        <li>pH: 6.8 (Optimal)</li>
                        <li>Moisture: 45% (Good)</li>
                        <li>Temperature: 23°C (Optimal)</li>
                    </ul>
                </div>
            </div>
            <div style="display: flex; gap: 10px;">
                <button class="btn" onclick="platform.controlIrrigation('${fieldName}', 'start')">Start Irrigation</button>
                <button class="btn btn-secondary" onclick="this.closest('.modal').remove()">Close</button>
            </div>
        </div>
    `;
    document.body.appendChild(modal);
}

// Initialize the platform
const platform = new AgriculturalPlatform();

// Service Worker registration for PWA functionality
if ('serviceWorker' in navigator) {
    window.addEventListener('load', () => {
        navigator.serviceWorker.register('sw.js')
            .then(registration => {
                console.log('SW registered: ', registration);
            })
            .catch(registrationError => {
                console.log('SW registration failed: ', registrationError);
            });
    });
}