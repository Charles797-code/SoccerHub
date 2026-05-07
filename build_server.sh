#!/bin/bash
# Simplified Dockerfiles using pre-built artifacts

cat > /root/SoccerHub/backend/Dockerfile.prebuilt << 'DEOF'
FROM eclipse-temurin:21-jre
WORKDIR /app
COPY target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
DEOF

cat > /root/SoccerHub/frontend/Dockerfile.prebuilt << 'DEOF'
FROM nginx:alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
DEOF

cd /root/SoccerHub
docker build -f backend/Dockerfile.prebuilt -t soccerhub-backend:latest backend/
docker build -f frontend/Dockerfile.prebuilt -t soccerhub-frontend:latest frontend/
echo "IMAGES_READY"

# Start all containers
docker compose up -d
echo "ALL_CONTAINERS_STARTED"
