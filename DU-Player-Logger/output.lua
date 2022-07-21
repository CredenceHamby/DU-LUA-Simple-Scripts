----------
-- INIT --
----------
local rx, ry = getResolution() 
local layer = createLayer()
local front = createLayer()
local font = loadFont('FiraMono', 20)
local fontAH, fontDH = getFontMetrics(font)

-- https://github.com/EricHamby/DU-LUA-Scripts
-- DU-Player-Logger
-- v1.0

-- Set default text color to white
setDefaultFillColor(layer, Shape_Text, 1, 1, 1, 1)
-- Set background color
setBackgroundColor( 15/255,24/255,29/255)

if not init then
    init = true
    data = {}
    buffer = ""
    comState = ""
end
-------------------
-- PB <-> Screen --
-- Communication --
-------------------
local input = getInput()
if input ~= "" then
    local instruction = {}
    local pos = string.find(input, " ")
    if pos == nil then pos=-1 end
    for word in string.gmatch(string.sub(input, 1, pos), "%w+") do
        table.insert(instruction, word)
    end
    local inputData = string.sub(input, pos+1)
    if instruction[1] == "load" then
        if inputData == "[]" then
            data = {}
        else
            local i = tonumber(instruction[2])
            local max = tonumber(instruction[3])

            buffer = buffer..inputData

            if i < max then
                setOutput(string.format("load,%s,%s ", math.floor(i+1), max))
            else
                -- Use pattern matching to return 'str' JSON data as a log table
                local tempData = {}
                local stringtoboolean = { ["true"]=true, ["false"]=false }
                for name, id, time, known in string.gmatch(buffer, '%[(%b""),(%d+),"([%d/ :]+)",(%a+)%]') do
                    table.insert(tempData, #tempData+1, {string.sub(name, 2, -2), tonumber(id), time, stringtoboolean[known]})
                end
                if tempData ~= nil then
                    data = tempData
                end
                buffer = ""
                comState = nil
                setOutput("end")
            end
        end
    end
end
----------------
-- Player Log --
----------------
for k, v in ipairs(data) do
    -- How many fit vertically
    local fit = math.floor(ry/fontAH)
    if k > fit*2 then break end
    
    local text = string.format('%s %s %s', v[3], v[1], v[2])
    local textX = 5+math.floor((k-1)/fit)*rx/2
    local textY = fontAH*(((k-1)%fit)+1)
    
    if v[4] then setNextFillColor(layer, 0, 1, 0, 1) end
    addText(layer, font, text, textX, textY)
end

----------------
-- Info Panel --
----------------
local spacing, border = 12, 5
local fontSmall = loadFont('FiraMono', spacing)
local text = {
    'Location: "Retail Store"',
    "Locura Mining Co v3.8"
}
-- find the string with the most width
local width, height = 0, #text*spacing
for k,v in pairs(text) do
    local curWidth, height = getTextBounds(fontSmall, v)
    if curWidth > width then width = curWidth end
end
local x, y = rx-width-border*2, ry-height-border*2
-- Draw text / box
for k,v in pairs(text) do
    setNextFillColor(front, 1, 0, 0, 1)
    setNextTextAlign(front, AlignH_Center, AlignV_Middle)
    setNextFillColor(front, 1, 1, 1, 1)
    addText(front, fontSmall, v, x+width/2, y + (k-1)*spacing + spacing/2)
end
setNextStrokeColor(front, 1, 1, 1, 1)
setNextStrokeWidth(front, 1)
setNextFillColor(front, 0, 0, 0, 1)
addBoxRounded(front, x-border, y-border, width+border*2, height+border*2, 1)
