const path = require("path");

const homeDir = process.env.HOME;
const patcherPath = path.join(homeDir, ".local", "share", "vvv", "Vencord", "patcher.js");

require(patcherPath);