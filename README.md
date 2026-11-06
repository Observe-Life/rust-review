# rust-review

Rust 低内存评审容器：把「cargo check + clippy」门禁装进一个用完即走的容器。

## 门禁规则

1. `cargo check --workspace --all-targets` —— 语言层硬校验，任何编译错误阻断
2. `cargo clippy --workspace --all-targets -- -A clippy::all -D clippy::correctness -D clippy::suspicious`
   —— 只启用 correctness（逻辑错误）与 suspicious（高度可疑）两个 lint 组，触发即阻断；style/complexity/perf 不参与

两步全过输出 `[review] PASS`，任一步失败退出码非 0。

## 部署（宿主机）

```bash
mkdir -p /vol1/docker/rust-review/{data/cargo-registry,data/cargo-git,workspace}
# 把仓库里的 compose.yml 复制到 /vol1/docker/rust-review/
cd /vol1/docker/rust-review && docker compose up -d
```

## 使用

```bash
# 待命启动（闲置 IDLE_TIMEOUT 秒后自动停止，默认 600s）
docker compose -f /vol1/docker/rust-review/compose.yml up -d

# 评审 /workspace 下的项目（项目子目录名）
docker exec rust-review review my-project

# 评审直接放在 /workspace 根的项目
docker exec rust-review review
```

## 依赖缓存说明

- 工具链（rustc / clippy / 标准库）：烘焙在镜像里，随镜像版本更新
- crates.io 依赖缓存：持久目录 `data/cargo-registry`、`data/cargo-git`，首次评审联网下载，之后每次启动直接命中
- 项目编译缓存：跟随项目目录（`target/`），放在 `workspace/` 挂载里
- crates.io 走国内源 rsproxy（写在镜像 `/usr/local/cargo/config.toml`）

## 注意

- check/clippy 通过 ≠ 能编译运行：链接错误、feature 互斥、极少数 const 求值错误仍需一次真实构建兜底
- clippy lint 会随工具链版本漂移；本镜像锁定 `rust:1-slim` 大版本，升级需改 Dockerfile 重新构建
- 小内存机器评审大项目时，可在 review 命令后自行加 `-j 2` 限制并行
