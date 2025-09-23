const express = require("express");
const Docker = require("dockerode");

const app = express();
const port = 8080;

// 컨테이너 내에서 호스트의 Docker 소켓을 통해 Docker 데몬에 연결합니다.
const docker = new Docker({ socketPath: "/var/run/docker.sock" });

// docker-compose.yml에 정의된 container_name 목록
const servicesToCheck = ["prometheus", "grafana"];

app.get("/health", async (req, res) => {
  try {
    const healthChecks = servicesToCheck.map((serviceName) => {
      return new Promise(async (resolve, reject) => {
        try {
          const container = docker.getContainer(serviceName);
          const data = await container.inspect();

          // 컨테이너의 Health Check 상태를 확인합니다.
          if (data.State.Health && data.State.Health.Status === "healthy") {
            resolve({ service: serviceName, status: "healthy" });
          } else {
            const status = data.State.Health
              ? data.State.Health.Status
              : "not healthy or no healthcheck";
            reject({ service: serviceName, status: status });
          }
        } catch (error) {
          // 컨테이너를 찾지 못하거나 inspect에 실패한 경우
          console.error(
            `Error inspecting container ${serviceName}:`,
            error.message
          );
          reject({ service: serviceName, status: "error" });
        }
      });
    });

    // 모든 서비스의 health check가 통과했는지 기다립니다.
    await Promise.all(healthChecks);

    // 모두 'healthy' 상태이면 HTTP 200 OK를 응답합니다.
    res.status(200).json({
      status: "ok",
      services: servicesToCheck.map((s) => ({ name: s, status: "healthy" })),
    });
  } catch (failedService) {
    // 하나라도 'healthy'가 아니면 HTTP 503 Service Unavailable을 응답합니다.
    console.error("Health check failed:", failedService);
    res
      .status(503)
      .json({ status: "unhealthy", failed_service: failedService });
  }
});

app.listen(port, () => {
  console.log(`Health check server listening on port ${port}`);
});
