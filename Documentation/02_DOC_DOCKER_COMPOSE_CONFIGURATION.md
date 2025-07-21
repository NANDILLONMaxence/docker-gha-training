---

# Running the Flask App with Docker Compose

This guide explains how to run the Flask application and a PostgreSQL database using Docker Compose.

---

## Project Structure (simplified)

```
myapp/
├── app/
│   └── main.py
├── Dockerfile
├── pyproject.toml
├── poetry.lock
└── docker-compose.yml
```

---

## Requirements

- [Docker & Docker Compose installed](https://docs.docker.com/get-docker/)
    
- Internet connection (for pulling images)
    
- The Flask app must listen on `0.0.0.0:5000` (already configured)
    

---

## `docker-compose.yml` Overview

This configuration defines two services:

- `myapp`: your Python Flask application
    
- `postgres`: a PostgreSQL 16.3 database with persistent data and health checks
    

**Highlights**:

- Ports are mapped from `5000` (container) → `8080` (host)
    
- Database uses `postgres:16.3` (not `latest` to avoid breaking upgrades)
    
- Persistent volume ensures data is not lost
    
- Flask app waits for the database to be ready before starting
    

---

## PostgreSQL Configuration

The database service is pre-configured with the following credentials:

|Setting|Value|
|---|---|
|Database name|`mydatabase`|
|Username|`myuser`|
|Password|`mypassword`|
|Port|`5432` (default PostgreSQL port)|

The Flask app will be able to connect using the following connection string:

```
postgresql://myuser:mypassword@postgres:5432/mydatabase
```

---

## Starting the Docker Compose Stack

1. Create Directory myapp/
 ```bash
	mkdir myapp
```
2. Create docker-compose.yml file
     ```bash
	nano docker-compose.ym
```
3. Paste the configuration:
```Docker-compose.yml
    version: '3.9'

services:
  myapp:
    image: myapp:1
    container_name: myapp_container
    ports:
      - "8080:5000"
    restart: always
    depends_on:
      postgres:
        condition: service_healthy
    environment:
      - DATABASE_URL=postgresql://myuser:mypassword@postgres:5432/mydatabase
    networks:
      - mynetwork

  postgres:
    image: postgres:16.3
    container_name: postgres_container
    restart: always
    environment:
      POSTGRES_USER: myuser
      POSTGRES_PASSWORD: mypassword
      POSTGRES_DB: mydatabase
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U myuser -d mydatabase"]
      interval: 5s
      timeout: 5s
      retries: 10
    networks:
      - mynetwork

volumes:
  postgres_data:

networks:
  mynetwork:
```
3. Run the following command:
    
```bash
docker compose up -d
```

> If you're using Docker Compose v1:
> 
> ```bash
> docker-compose up -d
> ```
![05_Build.png](Pieces_jointes/05_Build.png)
This will:

- Build (if needed) and run the `myapp` container
    
- Pull and start a healthy `postgres` service
    
- Expose the app at `http://localhost:8080`
    

---

## Verifying the Setup

### Check service status:

```bash
docker compose ps
```

Expected output:

```
NAME                COMMAND                  STATE          PORTS
myapp_container     "python app/main.py"     Up (healthy)   0.0.0.0:8080->5000/tcp
postgres_container  "docker-entrypoint..."   Up (healthy)   5432/tcp
```

![06_RUN.png](Pieces_jointes/06_RUN.png)
### Test the Flask API:

```bash
curl http://localhost:8080/books
```

Expected response:

```json
{
  "1": {"title": "1984", "author": "George Orwell", "year": 1949},
  "2": {"title": "To Kill a Mockingbird", "author": "Harper Lee", "year": 1960}
}
```

---

## 🛑 Stopping the Services

To stop the running containers:

```bash
docker compose down
```

This will stop all containers, but **preserve the database data**.

---

## 📌 Summary of Useful Commands

|Command|Description|
|---|---|
|`docker compose up -d`|Start all services in the background|
|`docker compose ps`|List running services|
|`docker compose down`|Stop and remove containers|
|`curl http://localhost:8080/books`|Test the Flask API endpoint|

---
