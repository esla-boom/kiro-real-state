from flask import Flask, render_template, send_from_directory
import os

app = Flask(__name__)

# Serve the main index.html
@app.route('/')
def index():
    return send_from_directory('.', 'index.html')

# Serve all HTML module files
@app.route('/<path:filename>')
def serve_files(filename):
    return send_from_directory('.', filename)

# API endpoints for future backend integration
@app.route('/api/properties')
def get_properties():
    # Mock data - replace with database queries
    properties = [
        {
            "id": 1,
            "title": "Modern Apartment",
            "price": 450000,
            "area": 120,
            "bedrooms": 3,
            "bathrooms": 2,
            "status": "available"
        },
        {
            "id": 2,
            "title": "Family House",
            "price": 680000,
            "area": 200,
            "bedrooms": 4,
            "bathrooms": 3,
            "status": "available"
        }
    ]
    return {"properties": properties}

@app.route('/api/clients')
def get_clients():
    # Mock data - replace with database queries
    clients = [
        {
            "id": 1,
            "name": "John Smith",
            "email": "john.smith@email.com",
            "phone": "+1 (555) 123-4567",
            "budget": 500000,
            "status": "active"
        },
        {
            "id": 2,
            "name": "Sarah Johnson",
            "email": "sarah.j@email.com",
            "phone": "+1 (555) 987-6543",
            "budget": 750000,
            "status": "pending"
        }
    ]
    return {"clients": clients}

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)