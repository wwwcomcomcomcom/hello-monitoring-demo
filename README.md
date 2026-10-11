# Prometheus + Grafana with templated prometheus.yml

이 프로젝트는 `prometheus.yml.tmpl` 템플릿에 환경변수 또는 인자를 주입해 `prometheus.yml`을 생성한 뒤, Docker Compose로 Prometheus와 Grafana를 실행합니다.

## 주입 변수 목록

- SCRAPE_TARGET (기본: host.docker.internal:8080)

## Windows (PowerShell)에서 실행

환경변수로 주입하거나 인자로 전달할 수 있습니다.

환경변수 예시:

```powershell
$env:SCRAPE_TARGET = "host.docker.internal:8081"
./render-and-up.bat
```

인자 전달 예시: (target)

```powershell
./render-and-up.bat host.docker.internal:8081
```

## Linux / macOS (sh)

환경변수 예시:

```sh
SCRAPE_TARGET=host.docker.internal:8081 \
./render-and-up.sh
```

인자 전달 예시:

```sh
./render-and-up.sh host.docker.internal:8081
```

## 동작 방식

1. 스크립트가 `prometheus.yml.tmpl`을 읽어 토큰(${...})을 실제 값으로 치환해 `prometheus.yml`을 생성합니다.
2. `docker compose up --build -d`로 이미지를 빌드하고 컨테이너를 실행합니다.
3. `Dockerfile.prometheus`는 워크스페이스의 `prometheus.yml`을 이미지의 `/etc/prometheus/prometheus.yml`로 복사합니다.

## 참고

- 기존의 정적 `prometheus.yml`은 템플릿 렌더링으로 덮어씁니다. Git으로 관리 시 템플릿만 관리하도록 권장합니다.
- 더 복잡한 템플릿이 필요하면 `envsubst`(GNU gettext) 또는 `gomplate`, `yq` 같은 도구로 교체 가능합니다.
