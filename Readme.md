# 📊 FinCore Monitoring & Observability Project

This project demonstrates an end-to-end **Monitoring & Observability system** for a Dockerized Flask-based application using **Prometheus + Grafana**, hosted on **AWS EC2**. It captures both custom application metrics and system metrics with Node Exporter.

---

## 🧱 Tech Stack

- 🐍 Flask (Python microservice with Prometheus metrics)
- 📈 Prometheus (metrics collection)
- 📊 Grafana (visual dashboards)
- 📦 Docker (containerization)
- ☁️ AWS EC2 (infrastructure)

---

## 📁 Folder Structure

fincore-monitoring/                                          
├── app.py # Flask application exposing /metrics                      
├── Dockerfile # Docker image for Flask app                 
├── prometheus.yml # Prometheus scrape config                   
├── Grafana/                   
│     └── node-exporter-dashboard.json # Grafana dashboard export  
├── screenshots/     
│     ├── grafana.png # Screenshot of Grafana dashboard        
│     └── Prometheus-targets.png # Screenshot of Prometheus targets


---

## 🚀 Step-by-Step Deployment (With Commands)

### 🔹 Step 1: Launch EC2 Instance (Amazon Linux 2)
- Open ports in **Security Group**: `5000`, `9090`, `3000`, `9100`
- Download your `.pem` file for SSH access

### 🔹 Step 2: SSH into EC2

```bash
ssh -i "path/to/your-key.pem" ec2-user@<EC2_PUBLIC_IP>
```

### 🔹 Step 3:Install Docker

```bash
sudo yum update -y
sudo amazon-linux-extras enable docker
sudo yum install docker -y
sudo service docker start
sudo usermod -aG docker ec2-user
exit
```

#### Reconnect to apply Docker permissions

```bash
ssh -i "path/to/your-key.pem" ec2-user@<EC2_PUBLIC_IP>
```

### 🔹 Step 4: Upload Project from Your Local PC

```bash
scp -i "path/to/your-key.pem" -r fincore-monitoring/ ec2-user@<EC2_PUBLIC_IP>:/home/ec2-user/
```

### 🔹 Step 5: Build and Run Flask App

```bash
cd fincore-monitoring
docker build -t ecommerce-app .
docker run -d -p 5000:5000 ecommerce-app
```

#### Test in browser
```
http://<EC2_PUBLIC_IP>:5000/products 
```

### 🔹 Step 6: Start Prometheus

```bash
docker run -d -p 9090:9090 \
  -v $PWD/prometheus.yml:/etc/prometheus/prometheus.yml \
  prom/prometheus
```

#### Check Prometheus Targets:
```
http://<EC2_PUBLIC_IP>:9090/targets
(refer saved screenshot at /screenshots/Prometheus-targets.png for preview)
```


### 🔹 Step 7: Start Node Exporter

```bash
docker run -d -p 9100:9100 prom/node-exporter
```

###🔹 Step 8: Start Grafana

```bash
docker run -d -p 3000:3000 grafana/grafana
```

Open Grafana:
```
http://<EC2_PUBLIC_IP>:3000
```

Login:

- Username: admin

- Password: admin

### 🔹 Step 9: Import Dashboard in Grafana
- Go to Dashboards → Import

- Upload: Grafana/node-exporter-dashboard.json

- Set data source: Prometheus


#### 🧪 How to Generate Metrics
Use this URL to simulate load:

```arduino
http://<EC2_PUBLIC_IP>:5000/products
```

Each request will increment Prometheus counters like:

- http_requests_total

- http_request_duration_seconds

- http_request_errors_total


## 📷 Screenshots (Uploaded via SCP)

### Grafana dashboard (Grafana.png)

![alt text](screenshots/grafana.png)

### Prometheus targets page (Prometheus-targets.png)

![alt text](screenshots/Prometheus-targets.png)


## 📡 Prometheus Targets

### 📈 Metrics Tracked

- Custom App Metrics:

- http_requests_total

- http_request_duration_seconds

- http_request_errors_total

- System Metrics (via Node Exporter):

- CPU, RAM, Disk, Filesystem usage


### 📌 Future Enhancements
- Add Alertmanager for Slack/Email alerts

- Provision infrastructure with Terraform

- Use Docker Compose for easier deployment

- Add API testing load scripts


---









👨‍💻 Author & Project Info
Internship: FinCore – Monitoring & Observability
Name: Your Name Here
Email: your.email@example.com
Skills Learned: Docker, EC2, Prometheus, Grafana




---

### 📦 What to Do Next

- ✔️ Replace `_Your Name Here_` and email
- 📁 Save this file as `README.md` in your `fincore-monitoring/` folder
- 🔼 Push to GitHub, or
- 📤 Zip and submit it as your final project

Let me know if you want help with pushing to GitHub or creating a `.pptx` from this. 
