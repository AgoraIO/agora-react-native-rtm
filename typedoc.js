const version = require("./package.json").version
const fs = require("fs")
fs.existsSync('latest') && fs.unlinkSync('latest')
module.exports =
{
    "mode": "file",
    "out": [version]
}
