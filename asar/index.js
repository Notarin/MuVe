const fs = require("fs");
const path = require("path");
const { execFileSync } = require("child_process");

const vencordDir = path.join(process.env.HOME, ".local", "share", "vvv", "Vencord");
const baseUrl = "https://github.com/Vendicated/Vencord/releases/download/devbuild/";

const files = ["preload.js", "patcher.js", "renderer.js", "renderer.css"];

fs.mkdirSync(vencordDir, { recursive: true });

for (const file of files) {
    const filePath = path.join(vencordDir, file);
    if (!fs.existsSync(filePath)) {
        execFileSync("curl", ["-L", "-o", filePath, baseUrl + file]);
    }
}

require(path.join(vencordDir, "patcher.js"));
