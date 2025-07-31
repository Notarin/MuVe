const fs = require("fs");
const path = require("path");
const { execFileSync } = require("child_process");

const vencordDir = path.join(process.env.HOME, ".local", "share", "vvv", "Vencord");
const baseUrl = "https://github.com/Vendicated/Vencord/releases/download/devbuild/";

if (!fs.existsSync(vencordDir)) {
    fs.mkdirSync(vencordDir, { recursive: true });

    execFileSync("curl", ["-L", "-o", path.join(vencordDir, "preload.js"), baseUrl + "preload.js"]);
    execFileSync("curl", ["-L", "-o", path.join(vencordDir, "patcher.js"), baseUrl + "patcher.js"]);
    execFileSync("curl", ["-L", "-o", path.join(vencordDir, "renderer.js"), baseUrl + "renderer.js"]);
    execFileSync("curl", ["-L", "-o", path.join(vencordDir, "renderer.css"), baseUrl + "renderer.css"]);
}

require(path.join(vencordDir, "patcher.js"));
