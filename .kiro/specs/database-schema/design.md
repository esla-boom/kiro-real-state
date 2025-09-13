# Database Schema Design Document

## Overview

This document presents the relational database schema design for the Real Estate Dashboard application. The schema supports comprehensive property management, client relationships, user management, appointments, documents, financial tracking, and reporting capabilities.

## Architecture

The database follows a normalized relational design with the following key principles:
- **Third Normal Form (3NF)** compliance to minimize redundancy
- **Referential integrity** through foreign key constraints
- **Scalable design** supporting future enhancements
- **Performance optimization** through appropriate indexing
- **Data security** through role-based access patterns

## Core Entities and Relationships

### Entity Relationship Overview

```
Users (1) -----> (M) Properties
Users (1) -----> (M) Clients  
Users (1) -----> (M) Appointments
Users (1) -----> (M) Documents
Users (1) -----> (M) Transactions
Users (1) -----> (M) ActivityLogs

Properties (1) -----> (M) Appointments
Properties (1) -----> (M) Documents
Properties (1) -----> (M) Transactions
Properties (1) -----> (M) PropertyMatches

Clients (1) -----> (M) Appointments
Clients (1) -----> (M) ClientPreferences
Clients (1) -----> (M) PropertyMatches
Clients (1) -----> (M) Documents

Appointments (1) -----> (M) ActivityLogs
Properties (M) <-----> (M) Clients (through PropertyMatches)
```

## Data Models

### 1. Users Table
Stores system users with role-based access control.

**Columns:**
- `user_id` (Primary Key): Unique identifier
- `username`: Login username
- `email`: User email address
- `password_hash`: Encrypted password
- `first_name`: User's first name
- `last_name`: User's last name
- `role`: User role (admin, agent, manager)
- `status`: Account status (active, inactive, suspended)
- `phone`: Contact phone number
- `created_at`: Account creation timestamp
- `updated_at`: Last update timestamp
- `last_login_at`: Last login timestamp

### 2. Properties Table
Central property information storage.

**Columns:**
- `property_id` (Primary Key): Unique identifier
- `title`: Property title/name
- `description`: Detailed description
- `address`: Full address
- `latitude`: Geographic latitude
- `longitude`: Geographic longitude
- `price`: Listed price
- `area_sqm`: Area in square meters
- `dimensions`: Property dimensions
- `bedrooms`: Number of bedrooms
- `bathrooms`: Number of bathrooms
- `property_type`: Type (apartment, house, condo, villa)
- `status`: Availability status (available, pending, sold, rented)
- `agent_id` (Foreign Key): Assigned agent
- `created_at`: Listing creation timestamp
- `updated_at`: Last update timestamp

### 3. Clients Table
Client information and contact details.

**Columns:**
- `client_id` (Primary Key): Unique identifier
- `first_name`: Client's first name
- `last_name`: Client's last name
- `email`: Contact email
- `phone`: Contact phone number
- `budget_min`: Minimum budget
- `budget_max`: Maximum budget
- `status`: Client status (active, pending, inactive)
- `agent_id` (Foreign Key): Assigned agent
- `created_at`: Registration timestamp
- `updated_at`: Last update timestamp

### 4. Appointments Table
Scheduling and appointment management.

**Columns:**
- `appointment_id` (Primary Key): Unique identifier
- `appointment_type`: Type (viewing, meeting, inspection)
- `appointment_date`: Scheduled date
- `appointment_time`: Scheduled time
- `duration_minutes`: Expected duration
- `status`: Status (scheduled, completed, cancelled)
- `client_id` (Foreign Key): Associated client
- `property_id` (Foreign Key): Associated property (optional)
- `agent_id` (Foreign Key): Assigned agent
- `notes`: Additional notes
- `created_at`: Creation timestamp
- `updated_at`: Last update timestamp

### 5. Documents Table
Document storage and management.

**Columns:**
- `document_id` (Primary Key): Unique identifier
- `filename`: Original filename
- `file_path`: Storage path
- `file_size`: File size in bytes
- `mime_type`: File MIME type
- `document_type`: Category (contract, photo, certificate, client_doc)
- `title`: Document title
- `description`: Document description
- `property_id` (Foreign Key): Associated property (optional)
- `client_id` (Foreign Key): Associated client (optional)
- `uploaded_by` (Foreign Key): User who uploaded
- `created_at`: Upload timestamp
- `updated_at`: Last update timestamp

### 6. Transactions Table
Financial transaction tracking.

**Columns:**
- `transaction_id` (Primary Key): Unique identifier
- `transaction_type`: Type (commission, expense, rental_fee)
- `amount`: Transaction amount
- `currency`: Currency code (USD, EUR, etc.)
- `transaction_date`: Transaction date
- `status`: Payment status (pending, paid, cancelled)
- `description`: Transaction description
- `property_id` (Foreign Key): Associated property (optional)
- `client_id` (Foreign Key): Associated client (optional)
- `agent_id` (Foreign Key): Associated agent
- `created_at`: Creation timestamp
- `updated_at`: Last update timestamp

### 7. Client Preferences Table
Client property preferences for matching.

**Columns:**
- `preference_id` (Primary Key): Unique identifier
- `client_id` (Foreign Key): Associated client
- `property_type`: Preferred property type
- `min_bedrooms`: Minimum bedrooms
- `max_bedrooms`: Maximum bedrooms
- `min_bathrooms`: Minimum bathrooms
- `preferred_areas`: Preferred locations (JSON)
- `max_distance_km`: Maximum distance from preferred areas
- `amenities`: Desired amenities (JSON)
- `created_at`: Creation timestamp
- `updated_at`: Last update timestamp

### 8. Property Matches Table
Property-client matching results.

**Columns:**
- `match_id` (Primary Key): Unique identifier
- `property_id` (Foreign Key): Matched property
- `client_id` (Foreign Key): Matched client
- `match_score`: Calculated match percentage
- `match_criteria`: Matching criteria met (JSON)
- `status`: Match status (new, sent, viewed, interested, rejected)
- `created_at`: Match creation timestamp
- `updated_at`: Last update timestamp

### 9. Activity Logs Table
System activity and audit trail.

**Columns:**
- `log_id` (Primary Key): Unique identifier
- `user_id` (Foreign Key): User who performed action
- `action_type`: Type of action performed
- `entity_type`: Type of entity affected
- `entity_id`: ID of affected entity
- `old_values`: Previous values (JSON)
- `new_values`: New values (JSON)
- `ip_address`: User's IP address
- `user_agent`: User's browser/client info
- `created_at`: Action timestamp

### 10. Reports Table
Saved report configurations.

**Columns:**
- `report_id` (Primary Key): Unique identifier
- `report_name`: Report name
- `report_type`: Type (sales, properties, clients, financial)
- `parameters`: Report parameters (JSON)
- `created_by` (Foreign Key): User who created report
- `is_scheduled`: Whether report runs automatically
- `schedule_frequency`: Frequency if scheduled
- `created_at`: Creation timestamp
- `updated_at`: Last update timestamp

## Indexing Strategy

### Primary Indexes
- All primary keys automatically indexed
- Foreign key columns indexed for join performance

### Secondary Indexes
- `properties.status` - For filtering available properties
- `properties.price` - For price range queries
- `properties.latitude, longitude` - For geographic queries
- `clients.budget_min, budget_max` - For budget matching
- `appointments.appointment_date` - For calendar queries
- `transactions.transaction_date` - For financial reporting
- `activity_logs.created_at` - For audit queries

### Composite Indexes
- `properties(agent_id, status)` - Agent's active listings
- `appointments(agent_id, appointment_date)` - Agent's schedule
- `transactions(agent_id, transaction_date)` - Agent's financial history

## Data Integrity Constraints

### Referential Integrity
- All foreign keys enforce referential integrity
- Cascade deletes where appropriate (logs, preferences)
- Restrict deletes for critical relationships (users, properties)

### Check Constraints
- Price values must be positive
- Latitude between -90 and 90
- Longitude between -180 and 180
- Budget min <= budget max
- Valid email format validation
- Valid phone number format

### Unique Constraints
- User email addresses
- Property addresses (within same agent)
- Client email addresses (within same agent)

## Security Considerations

### Data Protection
- Password hashing using bcrypt or similar
- Sensitive data encryption at rest
- Row-level security for multi-tenant scenarios

### Access Control
- Role-based permissions at application level
- Database user accounts with minimal privileges
- Audit logging for all data modifications

## Performance Optimization

### Query Optimization
- Appropriate indexing for common query patterns
- Partitioning for large tables (logs, transactions)
- Query result caching for reports

### Storage Optimization
- Appropriate data types to minimize storage
- Archive old data to separate tables
- Compress large text fields where possible

## Scalability Considerations

### Horizontal Scaling
- Design supports read replicas
- Partition-friendly primary keys
- Stateless application design

### Vertical Scaling
- Efficient indexing reduces memory requirements
- Normalized design minimizes redundancy
- Archive strategy for historical data