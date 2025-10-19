// Firebase Configuration
const FIREBASE_URL = "https://sensor-staion-default-rtdb.firebaseio.com";
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
    },
    "Quận 3": {
        temperature: 0,
        humidity: 0,
        windSpeed: 0,
        rainLevel: 0,
        switchStatus: false
    },
    "Quận 4": {
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
    initializeFirebaseData();
    loadCurrentData();
});

// Initialize Firebase data structure and start sending data
async function initializeFirebaseData() {
    try {
        status.textContent = 'Đang khởi tạo...';
        
        // Tạo cấu trúc JSON ban đầu cho tất cả quận
        const initialData = {
            "Quận 1": {
                temperature: 25.5,
                humidity: 60.0,
                windSpeed: 5.2,
                rainLevel: 0.0,
                switchStatus: false,
                timestamp: new Date().toISOString()
            },
            "Quận 2": {
                temperature: 26.1,
                humidity: 65.0,
                windSpeed: 4.8,
                rainLevel: 0.0,
                switchStatus: true,
                timestamp: new Date().toISOString()
            },
            "Quận 3": {
                temperature: 26.5,
                humidity: 65.0,
                windSpeed: 6.0,
                rainLevel: 1.5,
                switchStatus: false,
                timestamp: new Date().toISOString()
            },
            "Quận 4": {
                temperature: 29.0,
                humidity: 50.0,
                windSpeed: 8.0,
                rainLevel: 0.5,
                switchStatus: false,
                timestamp: new Date().toISOString()
            }
        };

        // Gửi dữ liệu khởi tạo lên Firebase
        const success = await sendToFirebase(initialData);
        if (success) {
            
            // Tự động bắt đầu gửi dữ liệu
            await startDataTransmission();
        } else {
            status.textContent = 'Lỗi khởi tạo dữ liệu';
        }
    } catch (error) {
        status.textContent = 'Lỗi khởi tạo dữ liệu';
    }
}

// Start automatic data transmission
async function startDataTransmission() {
    if (isRunning) return;
    
    isRunning = true;
    startBtn.disabled = true;
    stopBtn.disabled = false;
    status.textContent = 'Đang gửi dữ liệu...';
    status.classList.add('running');
    
    
    // Set interval to send data every 7 seconds
    intervalId = setInterval(async () => {
        const sensorData = await generateSensorData();
        sendToFirebase(sensorData);
    }, 7000);
}

// Generate random sensor data
async function generateSensorData() {
    const data = {};
    
    for (let i = 1; i <= 4; i++) {
        const districtName = `Quận ${i}`;
        
        // Base values khác nhau cho mỗi quận
        const baseTemp = i === 1 ? 25.0 : i === 2 ? 28.0 : i === 3 ? 26.5 : 29.0;
        const baseHumidity = i === 1 ? 60.0 : i === 2 ? 55.0 : i === 3 ? 65.0 : 50.0;
        const baseWind = i === 1 ? 5.0 : i === 2 ? 7.0 : i === 3 ? 6.0 : 8.0;
        const baseRain = i === 1 ? 2.0 : i === 2 ? 1.0 : i === 3 ? 1.5 : 0.5;
        
        // Tạo dữ liệu random
        const temperature = Math.round((baseTemp + Math.random() * 10 - 5) * 10) / 10;
        const humidity = Math.round((baseHumidity + Math.random() * 25 - 20) * 10) / 10;
        const windSpeed = Math.round((baseWind + Math.random() * 10 - 2) * 10) / 10;
        const rainLevel = Math.round((baseRain + Math.random() * 5 - 1) * 10) / 10;
        
        // Đọc switchStatus hiện tại từ Firebase
        const currentSwitch = await getCurrentSwitchStatus(districtName);
        
        data[districtName] = {
            temperature: temperature,
            humidity: humidity,
            windSpeed: windSpeed,
            rainLevel: rainLevel,
            switchStatus: currentSwitch,
            timestamp: new Date().toISOString()
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
            return false;
        }
    } catch (error) {
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
    }
}

// Update display with current data
function updateDisplay() {
    // Update Quận 1
    if (currentData['Quận 1']) {
        document.getElementById('temp1').textContent = `${currentData['Quận 1'].temperature}°C`;
        document.getElementById('humidity1').textContent = `${currentData['Quận 1'].humidity}%`;
        document.getElementById('wind1').textContent = `${currentData['Quận 1'].windSpeed}m/s`;
        document.getElementById('rain1').textContent = `${currentData['Quận 1'].rainLevel}mm`;
        updateLightStatus('light1', currentData['Quận 1'].switchStatus, currentData['Quận 1'].temperature);
    }
    
    // Update Quận 2
    if (currentData['Quận 2']) {
        document.getElementById('temp2').textContent = `${currentData['Quận 2'].temperature}°C`;
        document.getElementById('humidity2').textContent = `${currentData['Quận 2'].humidity}%`;
        document.getElementById('wind2').textContent = `${currentData['Quận 2'].windSpeed}m/s`;
        document.getElementById('rain2').textContent = `${currentData['Quận 2'].rainLevel}mm`;
        updateLightStatus('light2', currentData['Quận 2'].switchStatus, currentData['Quận 2'].temperature);
    }
    
    // Update Quận 3 (nếu có trong HTML)
    if (currentData['Quận 3'] && document.getElementById('temp3')) {
        document.getElementById('temp3').textContent = `${currentData['Quận 3'].temperature}°C`;
        document.getElementById('humidity3').textContent = `${currentData['Quận 3'].humidity}%`;
        document.getElementById('wind3').textContent = `${currentData['Quận 3'].windSpeed}m/s`;
        document.getElementById('rain3').textContent = `${currentData['Quận 3'].rainLevel}mm`;
        updateLightStatus('light3', currentData['Quận 3'].switchStatus, currentData['Quận 3'].temperature);
    }
    
    // Update Quận 4 (nếu có trong HTML)
    if (currentData['Quận 4'] && document.getElementById('temp4')) {
        document.getElementById('temp4').textContent = `${currentData['Quận 4'].temperature}°C`;
        document.getElementById('humidity4').textContent = `${currentData['Quận 4'].humidity}%`;
        document.getElementById('wind4').textContent = `${currentData['Quận 4'].windSpeed}m/s`;
        document.getElementById('rain4').textContent = `${currentData['Quận 4'].rainLevel}mm`;
        updateLightStatus('light4', currentData['Quận 4'].switchStatus, currentData['Quận 4'].temperature);
    }
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
        icon.src = 'img/light_on.png';
        icon.alt = 'Switch ON';
    }
}


// Start simulator (restart data transmission)
async function startSimulator() {
    if (isRunning) return;
    
    await startDataTransmission();
}

// Stop simulator
function stopSimulator() {
    if (!isRunning) return;
    
    isRunning = false;
    startBtn.disabled = false;
    stopBtn.disabled = true;
    status.textContent = 'Đã dừng - Click "Bắt đầu" để tiếp tục';
    status.classList.remove('running');
    
    if (intervalId) {
        clearInterval(intervalId);
        intervalId = null;
    }
    
}

// Handle page unload
window.addEventListener('beforeunload', function() {
    if (isRunning) {
        stopSimulator();
    }
});
