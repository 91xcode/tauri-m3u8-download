// M3U8 Downloader - Tauri Wrapper
// 100% 保留原有架构，零改动前端代码

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    // 🔥 使用固定端口启动本地服务器，让 Service Worker 和 StreamSaver 可用
    let port: u16 = 1430;

    tauri::Builder::default()
        .plugin(tauri_plugin_opener::init())
        // 初始化 localhost 插件，在端口 1430 提供静态文件服务
        .plugin(tauri_plugin_localhost::Builder::new(port).build())
        .plugin(tauri_plugin_http::init())
        .plugin(tauri_plugin_dialog::init())
        .plugin(tauri_plugin_fs::init())
        .setup(move |app| {
            // 构建 localhost URL
            let url = format!("http://localhost:{}", port);

            // 创建主窗口，加载 localhost 服务器的内容
            #[cfg(debug_assertions)]
            {
                use tauri::Manager;
                let window = tauri::WebviewWindowBuilder::new(
                    app,
                    "main",
                    tauri::WebviewUrl::External(url.parse().unwrap())
                )
                .title("M3U8 视频下载器")
                .inner_size(1200.0, 900.0)
                .center()
                .resizable(true)
                .build()?;

                // 开发模式下自动打开 DevTools
                window.open_devtools();
            }

            #[cfg(not(debug_assertions))]
            {
                tauri::WebviewWindowBuilder::new(
                    app,
                    "main",
                    tauri::WebviewUrl::External(url.parse().unwrap())
                )
                .title("M3U8 视频下载器")
                .inner_size(1200.0, 900.0)
                .center()
                .resizable(true)
                .build()?;
            }

            Ok(())
        })
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
