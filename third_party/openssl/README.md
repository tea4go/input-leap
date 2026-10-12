# OpenSSL (vendored)

供 Windows 构建使用的 OpenSSL 1.1.1w 预编译开发文件（MSVC 静态库）。

- 版本：OpenSSL 1.1.1w (11 Sep 2023)
- 来源：slproweb 的 `Win64OpenSSL-1_1_1w.exe`，用 innoextract 解包后提取：
  - `include/openssl/` —— 全部头文件
  - `lib/VC/static/libcrypto64MD.lib`、`libssl64MD.lib` —— /MD 静态库（Release）
- 许可：见 `LICENSE.txt`（OpenSSL License + SSLeay License）

`CMakeLists.txt` 在 Windows 下会默认把 `OPENSSL_ROOT_DIR` 指向本目录，
因此全新 clone 无需外部 SDK 即可配置构建。要换用别的 OpenSSL，传
`-DOPENSSL_ROOT_DIR=<路径>` 覆盖。

注意：这里只放了 Release (/MD) 静态库，构建 Debug 配置需另行补 `*MDd.lib`。
