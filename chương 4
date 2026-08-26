
4.3. Entity-Relationship Diagram (ERD)
The Entity-Relationship Diagram (ERD) of the AR-IMMS system models all 15 core entities to store and manage data center infrastructure, real-time monitoring data, incident maintenance resolution workflows, and system security management.
4.3.1. Overall ERD (Mermaid Diagram)
https://drive.google.com/file/d/1LxIRqTlG0yXtiNSSErilx3PWOR7b5z7U/view?usp=sharing
4.3.2. Entity Relationship Matrix
The table below summarizes relationships, cardinality, Primary Keys (PK), Foreign Keys (FK), and business logic for each pair:
### 4.3.2. Entity Relationship Matrix

| Parent Entity | Cardinality | Child Entity | Foreign Key (FK) | Business Meaning |
| :--- | :---: | :--- | :--- | :--- |
| **`ROLE`** | 1:N | **`USER`** | `user.role_id` | Each role (Admin, Operator, Technician) is assigned to multiple users. |
| **`SITE`** | 1:N | **`ROOM`** | `room.site_id` | A data center site contains multiple server rooms. |
| **`ROOM`** | 1:N | **`RACK`** | `rack.room_id` | A server room houses multiple equipment racks. |
| **`RACK`** | 1:N | **`SERVER`** | `server.rack_id` | An equipment rack mounts multiple physical/virtual servers. |
| **`SERVER`** | 1:N | **`CONTAINER`** | `container.server_id` | A server runs multiple Docker containers/workloads. |
| **`SERVER`** | 1:1 | **`MARKER`** | `marker.server_id` | Each server is directly assigned one QR/ArUco marker for AR scanning. |
| **`SERVER`** | 1:1 | **`WARRANTY`** | `warranty.server_id` | Each server has hardware warranty information attached. |
| **`SERVER`** | 1:N | **`TELEMETRY`** | `telemetry.server_id` | A server generates resource metric logs every 5 seconds. |
| **`SERVER`** | 1:N | **`ALERT`** | `alert.server_id` | Metrics exceeding thresholds trigger alerts for the server. |
| **`ALERT`** | 1:1 | **`INCIDENT`** | `incident.alert_id` | Critical alerts escalate into system incidents. |
| **`INCIDENT`** | 1:1 | **`TICKET`** | `ticket.incident_id` | Each incident triggers the creation of a maintenance work ticket. |
| **`USER`** | 1:N | **`TICKET`** | `ticket.assigned_to` | Operators assign tickets to Technicians for resolution. |
| **`TICKET`** | 1:N | **`MAINTENANCE`** | `maintenance.ticket_id` | Logs field maintenance action records for the ticket. |
| **`USER`** | 1:N | **`AUDIT_LOG`** | `audit_log.user_id` | Tracks and records all system actions performed by users. |
