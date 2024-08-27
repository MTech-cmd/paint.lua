---@diagnostic disable: undefined-field
-- Enhanced Paint Program with Buttons for Print and Exit

-- Initialize Variables
local width, height = term.getSize()
local grid = {}
local cursorX, cursorY = 1, 3 -- Start below the title bar and buttons
local colorsList = {colors.white, colors.red, colors.orange, colors.yellow, colors.green, colors.blue, colors.purple, colors.black}
local currentColor = colors.white
local titleBarHeight = 3
local colorPaletteY = height - 1
local buttonTextColor = colors.white
local buttonBackgroundColor = colors.gray

-- Initialize Grid
for y = titleBarHeight + 1, height - 2 do
    grid[y] = {}
    for x = 1, width do
        grid[y][x] = colors.black
    end
end

-- Draw the Title Bar
local function drawTitleBar()
    term.setBackgroundColor(colors.gray)
    term.clear()
    term.setCursorPos(1, 1)
    term.setTextColor(colors.white)
    term.write(" Paint Program ")

    -- Draw Buttons
    term.setCursorPos(width - 16, 1)
    term.setBackgroundColor(buttonBackgroundColor)
    term.setTextColor(buttonTextColor)
    term.write("[ Print ]")

    term.setCursorPos(width - 7, 1)
    term.setBackgroundColor(buttonBackgroundColor)
    term.setTextColor(buttonTextColor)
    term.write("[ Exit ]")
end

-- Draw the Color Palette
local function drawColorPalette()
    term.setCursorPos(1, colorPaletteY)
    for i, col in ipairs(colorsList) do
        term.setBackgroundColor(col)
        term.setTextColor(col == currentColor and colors.white or col)
        term.write("   ")
    end
    term.setBackgroundColor(colors.black)
end

-- Draw the Grid
local function drawGrid()
    for y = titleBarHeight + 1, height - 2 do
        for x = 1, width do
            term.setCursorPos(x, y)
            term.setBackgroundColor(grid[y][x])
            term.write(" ")
        end
    end
end

-- Draw the Cursor
local function drawCursor()
    term.setCursorPos(cursorX, cursorY)
    term.setBackgroundColor(currentColor)
    term.setTextColor(colors.black)
    term.write("+")
    term.setCursorPos(cursorX, cursorY)
end

-- Handle Keyboard Input
local function handleKeyboardInput(key)
    if key == keys.left and cursorX > 1 then
        cursorX = cursorX - 1
    elseif key == keys.right and cursorX < width then
        cursorX = cursorX + 1
    elseif key == keys.up and cursorY > titleBarHeight + 1 then
        cursorY = cursorY - 1
    elseif key == keys.down and cursorY < height - 2 then
        cursorY = cursorY + 1
    elseif key == keys.space then
        grid[cursorY][cursorX] = currentColor
    elseif key == keys.c then
        currentColor = colorsList[((table.indexOf(colorsList, currentColor) or 1) % #colorsList) + 1]
        drawColorPalette()
    elseif key == keys.p then
        printDrawing()
    elseif key == keys.q then
        os.shutdown()
    end
end

-- Handle Mouse Input
local function handleMouseInput(event, button, x, y)
    -- Check if clicking on the grid
    if y > titleBarHeight and y < height - 1 then
        cursorX, cursorY = x, y
        grid[cursorY][cursorX] = currentColor
    -- Check if clicking on the color palette
    elseif y == colorPaletteY then
        local colorIndex = math.ceil(x / 3)
        if colorsList[colorIndex] then
            currentColor = colorsList[colorIndex]
            drawColorPalette()
        end
    -- Check if clicking on the Print or Exit button
    elseif y == 1 then
        if x >= width - 16 and x <= width - 7 then
            printDrawing()
        elseif x >= width - 7 and x <= width then
            os.shutdown()
        end
    end
end

-- Print the Drawing
-- Print the Drawing
local function printDrawing()
    local printer = peripheral.find("printer")
    if not printer then
        print("No printer connected!")
        return
    end

    -- Retrieve printer page dimensions
    local pageWidth, pageHeight = printer.getPageSize()

    -- Start a new page
    printer.newPage()
    printer.setPageTitle("Paint Drawing")

    -- Determine the number of pages required
    local drawingHeight = height - 2 - titleBarHeight
    local pagesRequired = math.ceil(drawingHeight / pageHeight)

    for page = 1, pagesRequired do
        -- Calculate the starting and ending row for this page
        local startY = titleBarHeight + 1 + (page - 1) * pageHeight
        local endY = math.min(startY + pageHeight - 1, height - 2)

        -- Write the content for this page
        for y = startY, endY do
            local line = ""
            for x = 1, width do
                -- Generate a line of text representing the current row
                line = line .. (grid[y][x] == currentColor and " " or "#")
            end
            -- Write the line to the printer
            printer.write(line)
            -- Move to the next line on the printer
            printer.setCursorPos(1, y - startY + 1)
        end

        -- End the page and start a new one if more pages are needed
        if page < pagesRequired then
            printer.endPage()
            printer.newPage()
            printer.setPageTitle("Paint Drawing - Page " .. page + 1)
        end
    end

    -- End the final page
    printer.endPage()
    print("Drawing printed!")
end


-- Main Program Loop
term.clear()
drawTitleBar()
drawColorPalette()
while true do
    drawGrid()
    drawCursor()

    local event, p1, p2, p3 = os.pullEvent()

    if event == "key" then
        handleKeyboardInput(p1)
    elseif event == "mouse_click" or event == "mouse_drag" then
        handleMouseInput(event, p1, p2, p3)
    end
end
