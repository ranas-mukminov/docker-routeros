# Mikrotik RouterOS в Docker

Этот проект предоставляет Docker-образ, который запускает виртуальную машину MikroTik RouterOS внутри QEMU.

Он предназначен для разработки и тестирования, в том числе:
- отладки приложений, использующих RouterOS API;
- тестирования библиотек (например, [routeros-api-php](https://github.com/EvilFreelancer/routeros-api-php));
- быстрого подъёма лабораторной среды без отдельного гипервизора или «живого» роутера.

Репозиторий является форком [EvilFreelancer/docker-routeros](https://github.com/EvilFreelancer/docker-routeros),
поддерживается [Ranas Mukminov](https://github.com/ranas-mukminov).

[Русский] | [English](README.md)

## Сценарии использования

- Локальная лаборатория для разработки под RouterOS API.
- Автотесты и CI, которым нужен «живой» RouterOS.
- Быстрый тест конфигураций RouterOS в изолированном окружении.

> Для более сложных продакшн-подобных стендов с несколькими устройствами
> лучше использовать проекты уровня [VR Network Lab](https://github.com/vrnetlab/vrnetlab).

## Быстрый старт

### Образ с Docker Hub

```bash
docker pull evilfreelancer/docker-routeros
docker run -d \
  -p 2222:22 \
  -p 8728:8728 \
  -p 8729:8729 \
  -p 5900:5900 \
  -ti evilfreelancer/docker-routeros
```

Так вы поднимете RouterOS с доступом по SSH, API, API-SSL и VNC.

### Пример docker-compose

См. [docker-compose.dist.yml](docker-compose.dist.yml) для полного примера:

```yml
version: "3.9"

services:
  routeros:
    image: evilfreelancer/docker-routeros:latest
    restart: unless-stopped
    cap_add:
      - NET_ADMIN
    devices:
      - /dev/net/tun
      - /dev/kvm
    ports:
      - "2222:22"
      - "23:23"
      - "80:80"
      - "5900:5900"
      - "8728:8728"
      - "8729:8729"
```

### Сборка из исходников

```bash
git clone https://github.com/ranas-mukminov/docker-routeros.git
cd docker-routeros
docker build . --tag ros
docker run -d \
  -p 2222:22 \
  -p 8728:8728 \
  -p 8729:8729 \
  -p 5900:5900 \
  -ti ros
```

После запуска контейнера:
- VNC подключение к порту 5900 даёт консоль RouterOS.
- SSH на порт 2222 подключает к RouterOS по SSH.

### Создание собственного Dockerfile

Вы можете легко создать свой Dockerfile для включения пользовательских скриптов
или конфигураций. Docker-образ поддерживает различные теги, которые перечислены
[здесь](https://hub.docker.com/r/evilfreelancer/docker-routeros/tags/).
По умолчанию используется тег `latest`, если тег не указан.

```dockerfile
FROM evilfreelancer/docker-routeros
ADD ["your-scripts.sh", "/"]
RUN /your-scripts.sh
```

## Открытые порты

По умолчанию VM RouterOS использует и может пробрасываться наружу набор портов:
- **Базовые сервисы**: 21, 22, 23, 80, 443, 8291, 8728, 8729
- **IPSec**: 50, 51, 500/udp, 4500/udp
- **OpenVPN**: 1194/tcp, 1194/udp
- **L2TP**: 1701
- **PPTP**: 1723

Вы можете изменить проброс портов в командах `docker run` или в `docker-compose`.

## Замечания по безопасности

- Образ предназначен в первую очередь для **разработки и лабораторного использования**.
- **Не публикуйте порты RouterOS в открытый Интернет** без файрвола и чётких правил доступа.
- При использовании `/dev/kvm` убедитесь, что доступ к хосту имеют только доверенные пользователи.

## Диагностика

### QEMU не запускается

- Проверьте наличие `/dev/kvm` и права доступа.
- Убедитесь, что контейнер имеет `NET_ADMIN` и доступ к `/dev/net/tun`.

### VNC не подключается

- Проверьте проброс порта 5900.
- Убедитесь, что на хосте этот порт не занят другим сервисом.

### Контейнер постоянно перезапускается

- Проверьте логи командой `docker logs <container_id>`.
- Убедитесь, что образ RouterOS успешно загрузился во время сборки.

## Ссылки

Дополнительные материалы по Docker и технологиям виртуализации,
связанным с RouterOS и сетевым оборудованием:

* [Mikrotik RouterOS в Docker с использованием Qemu](https://habr.com/ru/articles/498012/) - Статья на Habr с руководством по настройке Mikrotik RouterOS в Docker.
* [RouterOS API Client](https://github.com/EvilFreelancer/routeros-api-php) - Библиотека PHP для работы с RouterOS API.
* [VR Network Lab](https://github.com/vrnetlab/vrnetlab) - Проект для запуска сетевого оборудования в Docker-контейнерах, рекомендуется для продакшн-подобных симуляций RouterOS.
* [qemu-docker](https://github.com/joshkunz/qemu-docker) - Ресурс для интеграции QEMU с Docker.
* [QEMU/KVM on Docker](https://github.com/ennweb/docker-kvm) - Демонстрация использования виртуализации QEMU/KVM внутри Docker-контейнеров.

## Лицензия

Проект распространяется по лицензии MIT. Подробности см. в файле [LICENSE](LICENSE).
