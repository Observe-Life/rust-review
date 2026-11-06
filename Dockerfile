FROM rust:1-slim

# check/clippy 不做最终链接，但 build.rs 会被编译执行，需要 cc；git 用于拉取 git 依赖
RUN apt-get update \
 && apt-get install -y --no-install-recommends gcc git ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# 官方 rust 镜像不含 clippy 组件，需单独装
RUN rustup component add clippy

# crates.io 国内源（rsproxy），写入镜像；依赖缓存在运行时挂载到 registry/git 子目录
COPY cargo-config.toml /usr/local/cargo/config.toml
COPY review /usr/local/bin/review
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/review /usr/local/bin/entrypoint.sh

# 待命看门狗：闲置超时自动退出，容器随之停止
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
