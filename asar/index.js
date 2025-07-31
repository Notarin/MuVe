const fs = require("fs");
const path = require("path");
const {
    execFileSync
} = require("child_process");

// This variable is post-processed by the build script to replace the
// `~curl~` with the absolute path to the curl binary.
const curl = "~curl~";
const vencordDir = path.join(process.env.HOME, ".local", "share", "vvv", "Vencord");
const baseUrl = "https://github.com/Vendicated/Vencord/releases/download/devbuild/";

const files = ["preload.js", "patcher.js", "renderer.js", "renderer.css"];

fs.mkdirSync(vencordDir, {
    recursive: true
});

for (const file of files) {
    const filePath = path.join(vencordDir, file);
    if (!fs.existsSync(filePath)) {
        // We use curl because it"s blocking and ensures each file is fully
        // ready before requiring the patcher.js
        // For whatever reason, normal async solutions just don"t quite block
        // properly, and the patcher.js ends up being required before the
        // files are entirely ready.
        execFileSync(curl, ["-L", "-o", filePath, baseUrl + file]);
    }
}

require(path.join(vencordDir, "patcher.js"));