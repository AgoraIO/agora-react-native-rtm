const version = require("./package.json").version
const fs = require("fs")
!fs.existsSync('latest') && fs.mkdirSync("latest")
fs.writeFileSync('latest/index.html', `<html><head><title>agora react native rtm docs</title></head><body><script>window.location.href="https://agoraio.github.io/RN-SDK-RTM/${version}"</script></body></html>`);
module.exports =
{
    "mode": "file",
    "out": [version]
}
