## 1. 启动容器
```bash
docker compose up -d
```

## 2. 进入容器
```bash
docker exec -it <NAMES> bash
```
## 3. 退出容器
```bash
docker stop <NAMES>
```

## 4. 查看当前运行容器
```bash
docker compose ps
```

## 5. 构建镜像
```bash
docker build .
```

## 6. 给镜像打版本号
```bash
docker tag <IMGAE ID> <REPOSITORY>:<TAG>
```

## 7. 删除镜像
```bash
docker rmi -f <IMGAE ID>
```
