# 第一阶段：使用带有 Maven 和 Java 21 的环境进行编译打包
FROM maven:3.9.6-eclipse-temurin-21 AS builder
WORKDIR /app
# 先拷贝 pom.xml 以利用 Docker 缓存加速依赖下载
COPY pom.xml .
RUN mvn dependency:go-offline -B
# 拷贝源代码并进行打包
COPY src ./src
RUN mvn clean package -DskipTests

# 第二阶段：使用纯净的 Java 21 运行环境启动后端服务（大大减小最终体积）
FROM eclipse-temurin:21-jre
WORKDIR /app
# 将第一阶段打包好的 jar 包拿过来
COPY --from=builder /app/target/*.jar app.jar
# 暴露后端的 8080 端口
EXPOSE 8080
# 启动 Spring Boot 应用
ENTRYPOINT ["java", "-jar", "app.jar"]
