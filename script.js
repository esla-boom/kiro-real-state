// Modular Dashboard functionality
document.addEventListener('DOMContentLoaded', function() {
    // Load home page by default
    loadPage('home.html');
    
    // Get all menu items
    const menuItems = document.querySelectorAll('.menu-item');

    // Handle menu item clicks
    menuItems.forEach(item => {
        item.addEventListener('click', function() {
            const targetPage = this.getAttribute('data-page');
            
            // Remove active class from all menu items
            menuItems.forEach(menuItem => {
                menuItem.classList.remove('active');
            });
            
            // Add active class to clicked item
            this.classList.add('active');
            
            // Load the target page
            loadPage(targetPage);
        });
    });

    // Handle property form submission
    document.addEventListener('submit', function(e) {
        if (e.target.classList.contains('property-form')) {
            e.preventDefault();
            
            // Get form data
            const formData = new FormData(e.target);
            const propertyData = {
                title: formData.get('title'),
                price: formData.get('price'),
                area: formData.get('area'),
                dimensions: formData.get('dimensions'),
                bedrooms: formData.get('bedrooms'),
                bathrooms: formData.get('bathrooms'),
                type: formData.get('type'),
                status: formData.get('status'),
                address: formData.get('address'),
                latitude: formData.get('latitude'),
                longitude: formData.get('longitude'),
                description: formData.get('description')
            };
            
            // Here you would typically send the data to your backend
            console.log('New property data:', propertyData);
            alert('Property added successfully!');
            
            // Reset form
            e.target.reset();
        }
    });

    // Handle various button clicks
    document.addEventListener('click', function(e) {
        if (e.target.textContent === 'View Details') {
            alert('View property details functionality would be implemented here');
        } else if (e.target.textContent === 'Edit') {
            alert('Edit functionality would be implemented here');
        } else if (e.target.textContent === 'Add New Property') {
            loadPage('add-property.html');
        } else if (e.target.textContent === 'Add New Client') {
            alert('Add new client form would be implemented here');
        } else if (e.target.textContent === 'Add New User') {
            alert('Add new user form would be implemented here');
        }
    });

    // Handle client and user table actions
    document.addEventListener('click', function(e) {
        if (e.target.classList.contains('btn-small')) {
            const action = e.target.textContent;
            const row = e.target.closest('tr');
            
            if (row) {
                const name = row.cells[0].textContent;
                
                switch(action) {
                    case 'View':
                        alert(`View details for ${name}`);
                        break;
                    case 'Edit':
                        alert(`Edit ${name}`);
                        break;
                    case 'Disable':
                        if (confirm(`Are you sure you want to disable ${name}?`)) {
                            alert(`${name} has been disabled`);
                        }
                        break;
                    case 'Cancel':
                        if (confirm(`Are you sure you want to cancel this appointment?`)) {
                            alert('Appointment cancelled');
                        }
                        break;
                    case 'Download':
                        alert('Download functionality would be implemented here');
                        break;
                    case 'Share':
                        alert('Share functionality would be implemented here');
                        break;
                    case 'Send to Client':
                        alert('Send to client functionality would be implemented here');
                        break;
                    case 'Schedule Viewing':
                        openAppointmentModal();
                        break;
                }
            }
        }
    });
});

// Function to load page content dynamically
async function loadPage(pageName) {
    try {
        const response = await fetch(pageName);
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        const content = await response.text();
        document.getElementById('content-container').innerHTML = content;
        
        // Initialize page-specific functionality
        initializePageFunctionality(pageName);
        
    } catch (error) {
        console.error('Error loading page:', error);
        document.getElementById('content-container').innerHTML = '<p>Error loading page content.</p>';
    }
}

// Initialize functionality specific to each page
function initializePageFunctionality(pageName) {
    switch(pageName) {
        case 'calendar.html':
            setTimeout(generateCalendar, 100);
            break;
        case 'matching.html':
            initializeBudgetSlider();
            break;
        case 'documents.html':
            initializeDocumentFilter();
            break;
        case 'map.html':
            initializeMapFilter();
            setTimeout(generateMapMarkers, 100);
            break;
        case 'add-property.html':
            initializeLocationHelpers();
            break;
    }
}

// Calendar functionality
let currentDate = new Date();

function generateCalendar() {
    const calendarGrid = document.getElementById('calendarGrid');
    const currentMonthElement = document.getElementById('currentMonth');
    
    if (!calendarGrid || !currentMonthElement) return;
    
    const year = currentDate.getFullYear();
    const month = currentDate.getMonth();
    
    currentMonthElement.textContent = new Intl.DateTimeFormat('en-US', {
        month: 'long',
        year: 'numeric'
    }).format(currentDate);
    
    const firstDay = new Date(year, month, 1);
    const lastDay = new Date(year, month + 1, 0);
    const startDate = new Date(firstDay);
    startDate.setDate(startDate.getDate() - firstDay.getDay());
    
    calendarGrid.innerHTML = '';
    
    // Add day headers
    const dayHeaders = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    dayHeaders.forEach(day => {
        const dayHeader = document.createElement('div');
        dayHeader.className = 'calendar-day-header';
        dayHeader.textContent = day;
        dayHeader.style.cssText = 'background: #34495e; color: white; padding: 8px; text-align: center; font-weight: 600;';
        calendarGrid.appendChild(dayHeader);
    });
    
    // Generate calendar days
    for (let i = 0; i < 42; i++) {
        const date = new Date(startDate);
        date.setDate(startDate.getDate() + i);
        
        const dayElement = document.createElement('div');
        dayElement.className = 'calendar-day';
        dayElement.textContent = date.getDate();
        
        if (date.getMonth() !== month) {
            dayElement.classList.add('other-month');
        }
        
        if (date.toDateString() === new Date().toDateString()) {
            dayElement.classList.add('today');
        }
        
        // Add appointment indicator (mock data)
        if (Math.random() > 0.8) {
            dayElement.classList.add('has-appointment');
            const dot = document.createElement('div');
            dot.className = 'appointment-dot';
            dayElement.appendChild(dot);
        }
        
        calendarGrid.appendChild(dayElement);
    }
}

function previousMonth() {
    currentDate.setMonth(currentDate.getMonth() - 1);
    generateCalendar();
}

function nextMonth() {
    currentDate.setMonth(currentDate.getMonth() + 1);
    generateCalendar();
}

// Modal functions
function openAppointmentModal() {
    document.getElementById('appointmentModal').style.display = 'block';
}

function closeAppointmentModal() {
    document.getElementById('appointmentModal').style.display = 'none';
}

function openUploadModal() {
    alert('Document upload functionality would be implemented here');
}

// Property matching functions
function findMatches() {
    const clientSelect = document.getElementById('clientSelect');
    const budgetRange = document.getElementById('budgetRange');
    
    if (clientSelect && budgetRange) {
        const client = clientSelect.options[clientSelect.selectedIndex].text;
        const budget = formatCurrency(budgetRange.value);
        alert(`Finding matches for ${client} with budget up to ${budget}`);
    }
}

// Initialize budget slider
function initializeBudgetSlider() {
    const budgetRange = document.getElementById('budgetRange');
    const budgetValue = document.getElementById('budgetValue');
    
    if (budgetRange && budgetValue) {
        budgetRange.addEventListener('input', function() {
            budgetValue.textContent = formatCurrency(this.value);
        });
    }
}

// Report generation
function generateReport() {
    const reportType = document.getElementById('reportType');
    const startDate = document.getElementById('startDate');
    const endDate = document.getElementById('endDate');
    
    if (reportType && startDate && endDate) {
        const type = reportType.options[reportType.selectedIndex].text;
        alert(`Generating ${type} from ${startDate.value} to ${endDate.value}`);
    }
}

// Document filtering
function initializeDocumentFilter() {
    const documentFilter = document.getElementById('documentFilter');
    if (documentFilter) {
        documentFilter.addEventListener('change', function() {
            const filterValue = this.value;
            console.log(`Filtering documents by: ${filterValue}`);
            // Filter logic would be implemented here
        });
    }
}

// Map functionality
function initializeMapFilter() {
    const mapFilter = document.getElementById('mapFilter');
    if (mapFilter) {
        mapFilter.addEventListener('change', function() {
            const filterValue = this.value;
            console.log(`Filtering map properties by: ${filterValue}`);
            generateMapMarkers(filterValue);
        });
    }
}

// Generate map markers based on property coordinates
function generateMapMarkers(filter = 'all') {
    const markersContainer = document.getElementById('mapMarkers');
    if (!markersContainer) return;
    
    markersContainer.innerHTML = '';
    
    // Get properties from mock data
    const properties = window.mockData.properties.filter(property => {
        if (filter === 'all') return true;
        return property.status === filter;
    });
    
    properties.forEach(property => {
        if (property.latitude && property.longitude) {
            // Convert lat/lng to map position (simplified conversion)
            // In a real app, you'd use a proper mapping library like Leaflet or Google Maps
            const x = ((property.longitude + 180) / 360) * 100; // Convert lng to percentage
            const y = ((90 - property.latitude) / 180) * 100;   // Convert lat to percentage
            
            const marker = document.createElement('div');
            marker.className = 'map-marker';
            marker.style.cssText = `top: ${y}%; left: ${x}%;`;
            
            marker.innerHTML = `
                <span class="marker-pin">📍</span>
                <div class="marker-popup">
                    <strong>${property.title}</strong><br>
                    $${property.price.toLocaleString()} • ${property.status || 'Available'}<br>
                    <small>Lat: ${property.latitude.toFixed(4)}, Lng: ${property.longitude.toFixed(4)}</small>
                </div>
            `;
            
            markersContainer.appendChild(marker);
        }
    });
}

// Initialize location helpers for add property page
function initializeLocationHelpers() {
    // Add coordinate validation on input
    const latInput = document.getElementById('property-latitude');
    const lngInput = document.getElementById('property-longitude');
    
    if (latInput && lngInput) {
        [latInput, lngInput].forEach(input => {
            input.addEventListener('blur', function() {
                const lat = latInput.value;
                const lng = lngInput.value;
                
                if (lat && lng) {
                    const validation = validateCoordinates(lat, lng);
                    if (!validation.valid) {
                        showLocationStatus(validation.message, 'error');
                        this.focus();
                    } else {
                        showLocationStatus(`Valid coordinates: ${parseFloat(lat).toFixed(4)}, ${parseFloat(lng).toFixed(4)}`, 'success');
                    }
                }
            });
        });
    }
}

// Appointment form handling
document.addEventListener('DOMContentLoaded', function() {
    const appointmentForm = document.getElementById('appointmentForm');
    if (appointmentForm) {
        appointmentForm.addEventListener('submit', function(e) {
            e.preventDefault();
            
            const formData = new FormData(this);
            const appointmentData = {
                type: formData.get('type'),
                date: formData.get('date'),
                time: formData.get('time'),
                client: formData.get('client'),
                property: formData.get('property')
            };
            
            console.log('New appointment:', appointmentData);
            alert('Appointment scheduled successfully!');
            closeAppointmentModal();
            this.reset();
        });
    }
});

// Utility functions
function formatCurrency(amount) {
    return new Intl.NumberFormat('en-US', {
        style: 'currency',
        currency: 'USD'
    }).format(amount);
}

function formatDate(date) {
    return new Intl.DateTimeFormat('en-US', {
        year: 'numeric',
        month: 'short',
        day: 'numeric'
    }).format(new Date(date));
}

// Mock data for demonstration
//const mockProperties = [
//    {
//        id: 1,
//        title: "Modern Apartment",
//        price: 450000,
//        area: 120,
//        dimensions: "12m x 10m",
//        bedrooms: 3,
//        bathrooms: 2,
//        description: "Beautiful modern apartment in the city center"
//    },
//    {
//        id: 2,
//        title: "Family House",
//        price: 680000,
//        area: 200,
//        dimensions: "15m x 13m",
//        bedrooms: 4,
//        bathrooms: 3,
//        description: "Spacious family house with garden"
//    }
//];

const mockClients = [
    {
        id: 1,
        name: "John Smith",
        email: "john.smith@email.com",
        phone: "+1 (555) 123-4567",
        budget: 500000,
        status: "active"
    },
    {
        id: 2,
        name: "Sarah Johnson",
        email: "sarah.j@email.com",
        phone: "+1 (555) 987-6543",
        budget: 750000,
        status: "pending"
    }
];

// Location functionality
let selectedLocation = { lat: null, lng: null };

// Get current location using browser geolocation
function getCurrentLocation() {
    const statusElement = document.getElementById('location-status');
    
    if (!navigator.geolocation) {
        showLocationStatus('Geolocation is not supported by this browser.', 'error');
        return;
    }
    
    showLocationStatus('Getting your location...', 'loading');
    
    navigator.geolocation.getCurrentPosition(
        function(position) {
            const lat = position.coords.latitude;
            const lng = position.coords.longitude;
            
            // Update the form fields
            document.getElementById('property-latitude').value = lat.toFixed(6);
            document.getElementById('property-longitude').value = lng.toFixed(6);
            
            showLocationStatus(`Location found: ${lat.toFixed(4)}, ${lng.toFixed(4)}`, 'success');
        },
        function(error) {
            let errorMessage = 'Unable to get location: ';
            switch(error.code) {
                case error.PERMISSION_DENIED:
                    errorMessage += 'Location access denied by user.';
                    break;
                case error.POSITION_UNAVAILABLE:
                    errorMessage += 'Location information unavailable.';
                    break;
                case error.TIMEOUT:
                    errorMessage += 'Location request timed out.';
                    break;
                default:
                    errorMessage += 'Unknown error occurred.';
                    break;
            }
            showLocationStatus(errorMessage, 'error');
        },
        {
            enableHighAccuracy: true,
            timeout: 10000,
            maximumAge: 60000
        }
    );
}

// Show location status message
function showLocationStatus(message, type = 'success') {
    const statusElement = document.getElementById('location-status');
    if (statusElement) {
        statusElement.textContent = message;
        statusElement.className = `location-status ${type}`;
        
        // Clear status after 5 seconds for success messages
        if (type === 'success') {
            setTimeout(() => {
                statusElement.textContent = '';
                statusElement.className = 'location-status';
            }, 5000);
        }
    }
}

// Open location picker modal
function openLocationPicker() {
    document.getElementById('locationPickerModal').style.display = 'block';
    
    // Reset selected coordinates display
    document.getElementById('selectedCoordinates').style.display = 'none';
    selectedLocation = { lat: null, lng: null };
}

// Close location picker modal
function closeLocationPicker() {
    document.getElementById('locationPickerModal').style.display = 'none';
}

// Select location on map click
function selectLocationOnMap(event) {
    const mapElement = document.getElementById('locationPickerMap');
    const rect = mapElement.getBoundingClientRect();
    
    // Calculate relative position (0-1)
    const x = (event.clientX - rect.left) / rect.width;
    const y = (event.clientY - rect.top) / rect.height;
    
    // Convert to approximate lat/lng (this is a simplified conversion)
    // In a real implementation, you'd use a proper mapping library
    const lat = 90 - (y * 180); // Latitude: 90 to -90
    const lng = (x * 360) - 180; // Longitude: -180 to 180
    
    selectedLocation.lat = lat;
    selectedLocation.lng = lng;
    
    // Update display
    document.getElementById('selectedLat').textContent = lat.toFixed(6);
    document.getElementById('selectedLng').textContent = lng.toFixed(6);
    document.getElementById('selectedCoordinates').style.display = 'block';
}

// Confirm location selection
function confirmLocationSelection() {
    if (selectedLocation.lat !== null && selectedLocation.lng !== null) {
        // Update form fields
        document.getElementById('property-latitude').value = selectedLocation.lat.toFixed(6);
        document.getElementById('property-longitude').value = selectedLocation.lng.toFixed(6);
        
        showLocationStatus(`Location selected: ${selectedLocation.lat.toFixed(4)}, ${selectedLocation.lng.toFixed(4)}`, 'success');
        closeLocationPicker();
    } else {
        alert('Please click on the map to select a location first.');
    }
}

// Validate coordinates
function validateCoordinates(lat, lng) {
    const latitude = parseFloat(lat);
    const longitude = parseFloat(lng);
    
    if (isNaN(latitude) || isNaN(longitude)) {
        return { valid: false, message: 'Coordinates must be valid numbers' };
    }
    
    if (latitude < -90 || latitude > 90) {
        return { valid: false, message: 'Latitude must be between -90 and 90' };
    }
    
    if (longitude < -180 || longitude > 180) {
        return { valid: false, message: 'Longitude must be between -180 and 180' };
    }
    
    return { valid: true };
}

// Update mock properties to include coordinates
const mockProperties = [
    {
        id: 1,
        title: "Modern Apartment",
        price: 450000,
        area: 120,
        dimensions: "12m x 10m",
        bedrooms: 3,
        bathrooms: 2,
        latitude: 40.712776,
        longitude: -74.005974,
        address: "123 Main St, New York, NY",
        description: "Beautiful modern apartment in the city center"
    },
    {
        id: 2,
        title: "Family House",
        price: 680000,
        area: 200,
        dimensions: "15m x 13m",
        bedrooms: 4,
        bathrooms: 3,
        latitude: 40.758896,
        longitude: -73.985130,
        address: "456 Oak Ave, New York, NY",
        description: "Spacious family house with garden"
    }
];

// Export mock data for potential use in other modules
window.mockData = {
    properties: mockProperties,
    clients: mockClients
};