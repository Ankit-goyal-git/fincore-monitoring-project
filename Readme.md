# FinCore Monitoring & Observability Project

![Docker](https://img.shields.io/badge/Docker-Enabled-blue?logo=docker)
![Grafana](https://img.shields.io/badge/Grafana-Dashboards-orange?logo=grafana)
![Prometheus](https://img.shields.io/badge/Prometheus-Metrics-orange?logo=prometheus)

This project demonstrates an end-to-end **Monitoring & Observability system** for a Dockerized Flask-based application using **Prometheus + Grafana**, hosted on **AWS EC2**. It captures both custom application metrics and system metrics with Node Exporter.
## 📚 Table of Contents

- [Tech Stack](#tech-stack)
- [Folder Structure](#folder-structure)
- [How to Clone and Run This Project](#how-to-clone-and-run-this-project)
- [Alerting](#alerting)
- [Simulate Alerts](#simulate-alerts)
- [Screenshots](#screenshots-uploaded-via-scp)



## Tech Stack

- 🐍 Flask (Python microservice with Prometheus metrics)
- 📈 Prometheus (metrics collection)
- 📊 Grafana (visual dashboards)
- 📦 Docker (containerization)
- ☁️ AWS EC2 (infrastructure)


## Folder Structure

```bash
fincore-monitoring/                                          
  ├── app.py # Flask application exposing /metrics                      
  ├── Dockerfile # Docker image for Flask app                 
  ├── prometheus.yml # Prometheus scrape config   
  ├── README.md  # Project documentation                
  ├── Grafana/  
  │   ├── fincore-alerts.json # Custom alert panel                 
  │   └── node-exporter-dashboard.json # Grafana dashboard export  
  ├── screenshots/     
  │     ├── grafana.png # Screenshot of Grafana 
  |     ├── Grafana2.png # Another dashboard viewdashboard        
  │     └── Prometheus-targets.png # Screenshot of Prometheus targets

```
## How to Clone and Run This Project
### 🔹 1. Clone the Repository

```bash
git clone https://github.com/darpan-cloud/fincore-monitoring.git
cd fincore-monitoring
```

### 🔹 2.  Launch EC2 Instance (Amazon Linux 2)
- Open ports in **Security Group**: `5000`, `9090`, `3000`, `9100`
- Download your `.pem` file for SSH access

### 🔹 3. SSH into EC2

```bash
ssh -i "path/to/your-key.pem" ec2-user@<EC2_PUBLIC_IP>
```


### 🔹 4. Install Docker (Amazon Linux 2)

```bash
sudo yum update -y
sudo amazon-linux-extras enable docker
sudo yum install docker -y
sudo service docker start
sudo usermod -aG docker ec2-user
exit
```

Then reconnect via SSH:

```bash
ssh -i "your-key.pem" ec2-user@<EC2_PUBLIC_IP>
```

### 🔹 5. Upload Project from Your Local PC

```bash
scp -i "path/to/your-key.pem" -r fincore-monitoring/ ec2-user@<EC2_PUBLIC_IP>:/home/ec2-user/
```


### 🔹 6. Build and Run Flask App

```bash
cd fincore-monitoring
docker build -t ecommerce-app .
docker run -d -p 5000:5000 ecommerce-app
```

Open in browser:
`http://<EC2_PUBLIC_IP>:5000/products`

### 🔹 7. Start Prometheus

```bash
docker run -d -p 9090:9090 \
  -v $PWD/prometheus.yml:/etc/prometheus/prometheus.yml \
  prom/prometheus
```

- Check Prometheus Targets:
`http://<EC2_PUBLIC_IP>:9090/targets`

- Verify both Node-exporter and E-commerce app should be UP

### 🔹 8. Start Node Exporter

```bash
docker run -d -p 9100:9100 prom/node-exporter
```

### 🔹 9. Start Grafana

```bash
docker run -d -p 3000:3000 grafana/grafana
```

- Access Grafana:
`http://<EC2_PUBLIC_IP>:3000`

- Login:

  - Username: admin

  - Password: admin


### 🔹 10. Import Grafana Dashboard
- Open Grafana in browser

- Go to Dashboards → Import

- Upload: Grafana/node-exporter-dashboard.json

- Select Prometheus as data source

- View live metrics


#### 🧪 How to Generate Metrics
Open the following repeatedly to simulate API load:

`http://<EC2_PUBLIC_IP>:5000/products`


This updates metrics like:

- http_requests_total

- http_request_duration_seconds

- http_request_errors_total


#### 📈 Metrics Tracked
- Application Metrics

- Total HTTP requests

- Request durations

- Error count

- System Metrics (via Node Exporter)

- CPU usage

- Memory usage

- Disk and filesystem stats

### 🔹 11. Import Alerts

- Open Grafana at `http://<EC2-IP>:3000` and log in.

- Go to **Alerting → Alert rules → Import** 

-  Upload `Grafana/fincore-alerts.json`.

- Select the appropriate Prometheus data source.

- Save/import to recreate all four alert rules.

## Alerting

This project includes four active Grafana-managed alert rules. They are exported and stored in `Grafana/fincore-alerts.json`. Anyone cloning the repo can import them into Grafana to reproduce the same alerting behavior.

### Alert Rules Included

1. **High Memory Usage** (`fincore-alert-memory`)
   - **Purpose:** Detect when memory usage exceeds 80%.
   - **Query:** `100 * (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes))`
   - **Condition:** Average above 80% for 2 minutes.
   - **Labels:** `severity: warning`
   - **Summary:** High memory usage detected on instance.
   - **Description:** Memory usage is above threshold, consider investigating memory pressure.

2. **High Disk I/O Wait** (`fincore-alert-disk I/O`)
   - **Purpose:** Detect excessive CPU time waiting on disk I/O.
   - **Query:** `rate(node_cpu_seconds_total{mode="iowait"}[1m]) * 100`
   - **Condition:** Above 20% for 2 minutes.
   - **Labels:** `severity: warning`
   - **Summary:** High I/O wait detected.
   - **Description:** CPU is spending too much time waiting on disk operations.

3. **Low Disk Space** (`fincore-alert-lowdisk`)
   - **Purpose:** Alert when disk usage is high (>80%).
   - **Query:** `(node_filesystem_size_bytes{fstype!~"tmpfs|overlay"} - node_filesystem_free_bytes{fstype!~"tmpfs|overlay"}) / node_filesystem_size_bytes{fstype!~"tmpfs|overlay"} * 100`
   - **Condition:** Above 80% usage for 2 minutes.
   - **Labels:** `severity: warning`
   - **Summary:** Disk space running low.
   - **Description:** Available disk space below acceptable threshold.

4. **General Monitoring Health** (`fincore-alert`)
   - **Purpose:** Ensure that all key monitoring targets (application, system metrics) are up and being scraped correctly.
   - **Query/Condition:** Checks for missing or down Prometheus targets.
   - **Labels:** `severity: normal`
   - **Summary:** One or more monitoring targets are unavailable.
   - **Description:** This alert fires if any expected service (e.g., Node Exporter or Flask app) is down or not exposing metrics. It serves as a catch-all for missing metrics and general system monitoring health.


### How to Simulate and Revert Alerts
You can manually trigger and then revert the alert conditions to test your Grafana alert rules.

#### 🔺 1. High Memory Usage (fincore-alert-memory)

**Simulate:**

```bash
sudo yum install -y stress
stress --vm 1 --vm-bytes 512M --timeout 30s
```

This allocates 512MB of memory for 30 seconds.

**Revert:**
No action needed — memory is released automatically after 30 seconds.

#### 🔺 2. High Disk I/O Wait (fincore-alert-disk I/O)

**Simulate:**

```bash
dd if=/dev/zero of=testfile bs=10M count=500
```
This writes 5GB to disk, causing disk I/O pressure.

**Revert:**

```bash
rm testfile
```
Deletes the file and stops disk activity.

#### 🔺 3. Low Disk Space (fincore-alert-lowdisk)

**Simulate:**

```bash
dd if=/dev/zero of=bigfile bs=100M count=100
```
Creates a 10GB dummy file to reduce available disk space.

**Revert:**

```bash
rm bigfile
```
Removes the file to free up space and reset the alert.

#### 🔺 4. General Monitoring Health (fincore-alert)

**Simulate (stop Node Exporter):**

```bash
docker stop $(docker ps -q --filter ancestor=prom/node-exporter)
```
Stops Node Exporter, simulating a failed or unreachable monitoring service.

**Revert (restart Node Exporter):**

```bash
docker run -d -p 9100:9100 prom/node-exporter
```
Restarts Node Exporter to restore monitoring.

## Screenshots (Uploaded via SCP)

### Grafana dashboard (Grafana.png)

![alt text](screenshots/grafana.png)
![alt text](screenshots/Grafana2.png)

---


### Prometheus targets page (Prometheus-targets.png)

![alt text](screenshots/Prometheus-targets.png)



### 📌 Future Enhancements


- Provision infrastructure with Terraform

- Use Docker Compose for easier deployment

- Add API testing load scripts


---


✅ Project Status : Fully working

✅ Runs in Docker

✅ Monitors Flask app and system

✅ Screenshots included

✅ Easy to replicate by cloning repo





