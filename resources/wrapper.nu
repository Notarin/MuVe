#!~Nu_bin~

let vencord_installed: bool = '~/.local/share/vvv/Vencord' | path exists
if not $vencord_installed {
    let vencord_dir: string = $"($env.HOME)/.local/share/vvv/Vencord"
    mkdir $vencord_dir
    http get https://github.com/Vendicated/Vencord/releases/download/devbuild/preload.js | save $"($vencord_dir)/preload.js"
    http get https://github.com/Vendicated/Vencord/releases/download/devbuild/patcher.js | save $"($vencord_dir)/patcher.js"
    http get https://github.com/Vendicated/Vencord/releases/download/devbuild/renderer.js | save $"($vencord_dir)/renderer.js"
    http get https://github.com/Vendicated/Vencord/releases/download/devbuild/renderer.css | save $"($vencord_dir)/renderer.css"
    chmod -R 755 $vencord_dir
}
nu -c "~Discord_bin~"