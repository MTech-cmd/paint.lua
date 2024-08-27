-- install.lua
local url = "https://raw.githubusercontent.com/MTech-cmd/paint.lua/main/paint.lua"

print("Downloading paint.lua...")
local response = http.get(url)

if response then
    local scriptContent = response.readAll()
    response.close()

    local file = fs.open("paint.lua", "w")
    file.write(scriptContent)
    file.close()

    print("Downloaded and saved as paint.lua.")
    shell.run("paint")
end
