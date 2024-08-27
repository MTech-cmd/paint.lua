-- install.lua
local chestMonitorUrl = "https://raw.githubusercontent.com/MTech-cmd/chest-monitor/main/chest_monitor.lua"

print("Downloading paint.lua...")
local response = http.get(chestMonitorUrl)

if response then
    local scriptContent = response.readAll()
    response.close()

    local file = fs.open("paint.lua", "w")
    file.write(scriptContent)
    file.close()

    print("Downloaded and saved as paint.lua.")
    shell.run("paint")
end
