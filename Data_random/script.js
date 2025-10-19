// Firebase Configuration
const FIREBASE_URL = "https://sensor-station-e536d-default-rtdb.firebaseio.com/";
const DATABASE_PATH = "/sensor_data";

// Global variables
let isRunning = false;
let intervalId = null;
let currentData = {
    "Quận 1": {
        temperature: 0,
        humidity: 0,
        windSpeed: 0,
        rainLevel: 0,
        switchStatus: false
    },
    "Quận 2": {
        temperature: 0,
        humidity: 0,
        windSpeed: 0,
        rainLevel: 0,
        switchStatus: false
    }
};

// DOM elements
const startBtn = document.getElementById('startBtn');
const stopBtn = document.getElementById('stopBtn');
const status = document.getElementById('status');

// Initialize
document.addEventListener('DOMContentLoaded', function() {
    startBtn.addEventListener('click', startSimulator);
    stopBtn.addEventListener('click', stopSimulator);
    loadCurrentData();
});

// Generate random sensor data
async function generateSensorData() {
    const data = {};
    
    for (let i = 1; i <= 2; i++) {
        const districtName = `Quận ${i}`;
        
        // Base values khác nhau cho mỗi quận
        const baseTemp = i === 1 ? 28.0 : 30.0;
        const baseHumidity = i === 1 ? 60.0 : 55.0;
        const baseWind = i === 1 ? 5.0 : 7.0;
        const baseRain = i === 1 ? 2.0 : 1.0;
        
        // Tạo dữ liệu random
        const temperature = Math.round((25 + Math.random() * 15) * 10) / 10;      // 25-40°C
        const humidity = Math.round((40 + Math.random() * 50) * 10) / 10;         // 40-90%
        const windSpeed = Math.round((Math.random() * 60) * 10) / 10;             // 0-60 m/s
        const rainLevel = Math.round((Math.random() * 100) * 10) / 10;   
        
        // Đọc switchStatus hiện tại từ Firebase
        const currentSwitch = await getCurrentSwitchStatus(districtName);
        
        data[districtName] = {
            temperature: temperature,
            humidity: humidity,
            windSpeed: windSpeed,
            rainLevel: rainLevel,
            switchStatus: currentSwitch,
        };
    }
    
    return data;
}

// Get current switch status from Firebase
async function getCurrentSwitchStatus(districtName) {
    try {
        const url = `${FIREBASE_URL}${DATABASE_PATH}/${districtName}/switchStatus.json`;
        const response = await fetch(url);
        
        if (response.ok) {
            const data = await response.json();
            return data === true || data === false ? data : false;
        }
        return false;
    } catch (error) {
        console.log(`Error reading switch status for ${districtName}:`, error);
        return false;
    }
}

// Send data to Firebase
async function sendToFirebase(data) {
    try {
        const url = `${FIREBASE_URL}${DATABASE_PATH}.json`;
        
        const response = await fetch(url, {
            method: 'PUT',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(data)
        });
        
        if (response.ok) {
            // Update current data
            currentData = data;
            updateDisplay();
            
            return true;
        } else {
            console.log(`Failed to send data: HTTP ${response.status}`);
            return false;
        }
    } catch (error) {
        console.log(`Network error: ${error.message}`);
        return false;
    }
}

// Load current data from Firebase
async function loadCurrentData() {
    try {
        const url = `${FIREBASE_URL}${DATABASE_PATH}.json`;
        const response = await fetch(url);
        
        if (response.ok) {
            const data = await response.json();
            if (data) {
                currentData = data;
                updateDisplay();
            }
        }
    } catch (error) {
        console.log(`Error loading data: ${error.message}`);
    }
}

// Update display with current data
function updateDisplay() {
    // Update Quận 1
    document.getElementById('temp1').textContent = `${currentData['Quận 1'].temperature}°C`;
    document.getElementById('humidity1').textContent = `${currentData['Quận 1'].humidity}%`;
    document.getElementById('wind1').textContent = `${currentData['Quận 1'].windSpeed}m/s`;
    document.getElementById('rain1').textContent = `${currentData['Quận 1'].rainLevel}mm`;
    updateLightStatus('light1', currentData['Quận 1'].switchStatus, currentData['Quận 1'].temperature);
    
    // Update Quận 2
    document.getElementById('temp2').textContent = `${currentData['Quận 2'].temperature}°C`;
    document.getElementById('humidity2').textContent = `${currentData['Quận 2'].humidity}%`;
    document.getElementById('wind2').textContent = `${currentData['Quận 2'].windSpeed}m/s`;
    document.getElementById('rain2').textContent = `${currentData['Quận 2'].rainLevel}mm`;
    updateLightStatus('light2', currentData['Quận 2'].switchStatus, currentData['Quận 2'].temperature);
}

// Update light status
function updateLightStatus(lightId, switchStatus, temperature) {
    const light = document.getElementById(lightId);
    const icon = light.querySelector('.lightbulb-icon');
    light.className = 'light';
    
    if (!switchStatus) {
        light.classList.add('off');
        icon.src = 'img/light_off.png';
        icon.alt = 'Switch OFF';
    } else if (temperature > 30) {
        light.classList.add('warning');
        icon.src = 'img/light_on.png';
        icon.alt = 'Switch ON (Warning)';
    } else {
        light.classList.add('on');
        icon.src = 'img/green.png';
        icon.alt = 'Switch ON';
    }
}


// Start simulator
async function startSimulator() {
    if (isRunning) return;
    
    isRunning = true;
    startBtn.disabled = true;
    stopBtn.disabled = false;
    status.textContent = 'Đang chạy';
    status.classList.add('running');
    
    console.log('Starting sensor data simulator...');
    
    // Send data immediately
    const sensorData = await generateSensorData();
    sendToFirebase(sensorData);
    
    // Set interval to send data every 3 seconds
    intervalId = setInterval(async () => {
        const sensorData = await generateSensorData();
        sendToFirebase(sensorData);
    }, 7000);
}

// Stop simulator
function stopSimulator() {
    if (!isRunning) return;
    
    isRunning = false;
    startBtn.disabled = false;
    stopBtn.disabled = true;
    status.textContent = 'Đã dừng';
    status.classList.remove('running');
    
    if (intervalId) {
        clearInterval(intervalId);
        intervalId = null;
    }
    
    console.log('Sensor data simulator stopped');
}

// Handle page unload
window.addEventListener('beforeunload', function() {
    if (isRunning) {
        stopSimulator();
    }
});
