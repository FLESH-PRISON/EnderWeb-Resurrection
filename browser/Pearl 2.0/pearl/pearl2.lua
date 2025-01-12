 --Pearl EnderWeb Browser by TurtleScripts
--Written by da404lewzer
--This is delivered to you without warranty under the Creative Commons Attribution-ShareAlike 3.0 Unported License (http://creativecommons.org/licenses/by-sa/3.0/).

--Usage: After launching you load pages by typing in their six-digit number.

--[[LOCAL VARS]]

local versionStr="2.0a"
local userAgent="EnderWeb/1.0 (Minecraft; ComputerCraft; Forge) Pearl/" .. versionStr

local running = true
local w,h = term.getSize()

--[[LOCAL DEPENDENCIES]]

local logger = require("logger")
local inputHandler = require("input")
local settings = require("settings")

local function setColors(monitor, bg, fg, bg2, fg2)
   if monitor then
    if monitor.isColor() then
      monitor.setBackgroundColor(bg)
      monitor.setTextColor(fg)
    else
      monitor.setBackgroundColor(bg2)
      monitor.setTextColor(fg2)
    end
  end
end
local function lpad(str, len, char)
    if char == nil then char = ' ' end
    local i = len - #str
    if i >= 0 then
      return string.rep(char, i) .. str
    else
      return str
    end
end
local function rpad(str, len, char)
    if char == nil then char = ' ' end
    local i = len - #str
    if i >= 0 then
      return str .. string.rep(char, i)
    else
      return str
    end
end
local function drawScreen(monitor)
--TODO
end

--[[Stolen Shamelessly from nPaintPro - http://pastebin.com/4QmTuJGU]]
local function getColourOf(hex)
  local value = tonumber(hex, 16)
  if not value then return nil end
  value = math.pow(2,value)
  return value
end
local function drawPictureTable(mon, xinit, yinit, width, image, align)
  
  
  local imageWidth = 0
  for y=1,#image do
    for x=1,#image[y] do
      if x > imageWidth then imageWidth = x end
    end
  end
  
  local height = #image
  
  local alignOffset = 0
  if align == "center" then
    alignOffset = width /2 - imageWidth /2
  elseif align == "right" then
    alignOffset = width - imageWidth
  end
  
  for y=1,#image do
    for x=1,#image[y] do
      mon.setCursorPos(xinit + x-1 + alignOffset, yinit + y-1)
      local col = getColourOf(string.sub(image[y], x, x))
      if col then
        if term.isColor() then
          mon.setBackgroundColour(col)
        else
          local pixel = string.sub(image[y], x, x)
          if pixel == "c" or pixel == "5" or pixel == " " then
            mon.setBackgroundColour(colors.white)
          else
            mon.setBackgroundColour(colors.black)
          end
        end
        mon.write(" ")
      end
    	end
	end
  
  return height
  
end
--[[End Theft]]

--[[START PROGRAM]]

local currentPageID
local currentPage
local startPageId, startPageName = settings.getStartPage()
currentPageID = startPageId
currentPage = startPageName
local args = {...}
local localPageDOM = {}
local pageScroll = 0
local totalLines = 0
local currentLocation = shell.resolve("logs")

logger.setup("Pearl" , currentLocation)
settings.setup(shell.resolve("usersettings"))

local function writeTextRAW(monitor, x, y, text)
  monitor.setCursorPos(x, y)
  monitor.write(text)
end

local function writeTextBlock(monitor, x, y, width, text, align, fill)
  
  local words = {}
  
  if text ~= nil then
    for word in string.gmatch(text, "%S+")   do table.insert(words, word) end
  else
    table.insert(words, " ")
  end
  
  local lines = {}
  
  local curLine = 1
  local strLen = 0
  
  for i=1, #words do
  
    local word = words[i]
    
    if word ~= nil then
      
      strLen = strLen + #word
      
      if lines[curLine] == nil then
        lines[curLine] = {}
      end

      local wordSpaceLen = #lines[curLine]-1   
      
      if strLen + wordSpaceLen >= width then
        curLine = curLine + 1
        lines[curLine] = {}
        strLen = #word --this needs to be carried over so we don't accidentally let words hang off the screen
      end
      
      table.insert(lines[curLine], word)
    
    end
    
  end
  
  
  for i=1, #lines do
    
    local line = lines[i]
    local text = table.concat(line, " ")
    
    local offX = 0
    if align == "left" then
      offX = 0
    elseif align == "center" then
      offX = width/2 - (string.len(text)-1)/2
    elseif align == "right" then
      offX = width - string.len(text)
    end
    if fill == true then
      writeTextRAW(monitor, x, y + i-1, string.rep(" ", width))
    end
    writeTextRAW(monitor, x + offX, y + i-1, text)
  end
  
  return curLine
  
end

function newNode(name)
  local node = {}
  node.___value = nil
  node.___name = name
  node.___children = {}
  node.___props = {}

  function node:value() return self.___value end
  function node:setValue(val) self.___value = val end
  function node:name() return self.___name end
  function node:setName(name) self.___name = name end
  function node:children() return self.___children end
  function node:numChildren() return #self.___children end
  function node:addChild(child)
    if self[child:name()] ~= nil then
      if type(self[child:name()].name) == "function" then
        local tempTable = {}
        table.insert(tempTable, self[child:name()])
        self[child:name()] = tempTable
      end
      table.insert(self[child:name()], child)
    else
      self[child:name()] = child
    end
    table.insert(self.___children, child)
  end

  function node:properties() return self.___props end
  function node:numProperties() return #self.___props end
  function node:addProperty(name, value)
    local lName = "@" .. name
    if self[lName] ~= nil then
      if type(self[lName]) == "string" then
        local tempTable = {}
        table.insert(tempTable, self[lName])
        self[lName] = tempTable
      end
      table.insert(self[lName], value)
    else
      self[lName] = value
    end
    table.insert(self.___props, { name = name, value = self[name] })
  end

  return node
end

local function FromXmlString(value)
  value = string.gsub(value, "&#x([%x]+)%;",
    function(h)
      return string.char(tonumber(h, 16))
    end);
  value = string.gsub(value, "&#([0-9]+)%;",
    function(h)
      return string.char(tonumber(h, 10))
    end);
  value = string.gsub(value, "&quot;", "\"");
  value = string.gsub(value, "&apos;", "'");
  value = string.gsub(value, "&gt;", ">");
  value = string.gsub(value, "&lt;", "<");
  value = string.gsub(value, "&amp;", "&");
  return value;
end

local function ParseArgs(node, s)
  string.gsub(s, "(%w+)=([\"'])(.-)%2", function(w, _, a)
    node:addProperty(w, FromXmlString(a))
  end)
end

local function parseTree(xmlText)
  logger.startLog("parseTree", currentPage, currentPageID)
  local stack = {}
  local top = newNode()   
  table.insert(stack, top)
  local ni, c, label, xarg, empty
  local i, j = 1, 1
  while true do
    ni, j, c, label, xarg, empty = string.find(xmlText, "<(%/?)([%w_:]+)(.-)(%/?)>", i)
    if not ni then break end
    local text = string.sub(xmlText, i, ni - 1);
    if not string.find(text, "^%s*$") then
      local lVal = (top:value() or "") .. FromXmlString(text)
      stack[#stack]:setValue(lVal)
    end
    if empty == "/" then -- empty element tag
      local lNode = newNode(label)
      ParseArgs(lNode, xarg)
      top:addChild(lNode)
    elseif c == "" then -- start tag
      local lNode = newNode(label)
      ParseArgs(lNode, xarg)
      table.insert(stack, lNode)
      top = lNode
    else -- end tag
      local toclose = table.remove(stack) -- remove top

      top = stack[#stack]
      if #stack < 1 then
        error("XmlParser: nothing to close with " .. label)
      end
      if toclose:name() ~= label then
        error("XmlParser: trying to close " .. toclose.name .. " with " .. label)
      end
      top:addChild(toclose)
    end
    i = j + 1
  end
  local text = string.sub(xmlText, i);
  if #stack > 1 then
    error("XmlParser: unclosed " .. stack[#stack]:name())
  end
  logger.endLog()
  return top
end

local function updateTitle()
  setColors(term, colors.lightGray, colors.gray, colors.white, colors.black)
  --writeTextRAW(term, 1, 1, string.rep(" ", w), "left")
  writeTextBlock(term, 1, 1, w, "@ " .. currentPageID, "left", true)
  --writeRightText(term, 1, 1, "0 bytes")
end

local function updateTitleKeying(keyCode)
  setColors(term, colors.lightGray, colors.gray, colors.white, colors.black)
  writeTextBlock(term, 1, 1, w, "@ " .. string.rep("-", 6), "left", false)
  setColors(term, colors.lightGray, colors.black, colors.white, colors.black)
  writeTextBlock(term, 1, 1, w, "@", "left", false)
  writeTextBlock(term, 9 - #keyCode, 1, w, keyCode, "left", false)
end

local function updatePage()
  updateTitle()
  setColors(term, colors.white, colors.black, colors.white, colors.black)
end

local function getColor(color, default)
  if color == "white" then
    return colors.white
  elseif color == "orange" then
    return colors.orange
  elseif color == "magenta" then
    return colors.magenta
  elseif color == "lightblue" then
    return colors.lightBlue
  elseif color == "yellow" then
    return colors.yellow
  elseif color == "lime" then
    return colors.lime
  elseif color == "pink" then
    return colors.pink
  elseif color == "gray" or color == "grey" then
    return colors.gray
  elseif color == "lightgray" or color == "lightgrey" then
    return colors.lightGray
  elseif color == "cyan" then
    return colors.cyan
  elseif color == "purple" then
    return colors.purple
  elseif color == "blue" then
    return colors.blue
  elseif color == "brown" then
    return colors.brown
  elseif color == "green" then
    return colors.green
  elseif color == "red" then
    return colors.red
  elseif color == "black" then
    return colors.black
  end
  return default
end

local function renderDOM()
  logger.startLog("renderDOM", currentPage, currentPageID)
  local body = localPageDOM.page.body
  local children = body:children();
  
    
  local defaultColor = colors.gray
  local defaultBGColor = colors.white
    
  if body["@color"] ~= nil then
    defaultColor = getColor(body["@color"], "black")
  end
  if body["@bgcolor"] ~= nil then
    defaultBGColor = getColor(body["@bgcolor"], "white")
  end
      
  term.setTextColor(defaultColor)
  term.setBackgroundColor(defaultBGColor)
  term.clear()
  
  updatePage()
  
  totalLines = 0 --global
  
  local pageOffset = 1 + pageScroll + 1
  local extraOffset = 0 
  
  --totalLines = #children --fix
  for i=1, #children do
    local child = children[i]
    
    
    local setColor = defaultColor
    local setBGColor = defaultBGColor
    if child["@color"] ~= nil then
      setColor = getColor(child["@color"], "gray")
    end
    if child["@bgcolor"] ~= nil then
      setBGColor = getColor(child["@bgcolor"], "white")
    end
    
    term.setTextColor(setColor)
    term.setBackgroundColor(setBGColor)
    
    if child:name() == "div" then
      local fill = child["@fill"] ~= nil and child["@fill"] == "true"
      local align = "left"
      if child["@align"] ~= nil then
        align = child["@align"]
      end
      totalLines = totalLines + writeTextBlock(term, 1, pageOffset+totalLines, w, child:value(), align, fill)
    
    elseif child:name() == "drawing" then  
      local scanLines = {}
      local image = string.gsub(child.image:value(), "[\r\n]?", "")
      if image ~= nil then
        for scanLine in string.gmatch(image, "[^+]+")   do table.insert(scanLines, scanLine) end
      end
      
      local align = "left"
      if child["@align"] ~= nil then
        align = child["@align"]
      end
      
      totalLines = totalLines + drawPictureTable(term, 1, pageOffset+totalLines, w, scanLines, align);
    
    elseif child:name() == "listing" then
      term.setTextColor(colors.lightGray)
      writeTextBlock(term, 1, pageOffset+totalLines, w, string.rep(".", w), "left", true)
      term.setTextColor(setColor)
      writeTextBlock(term, 1, pageOffset+totalLines, w, child:value(), "left", false)
      term.setTextColor(colors.blue)
      writeTextBlock(term, 1, pageOffset+totalLines, w, child["@id"], "right", false)
      totalLines = totalLines + 1
    
    else
      totalLines = totalLines + 1
    end
    
  end

  logger.endLog()
  updatePage()

end

local function setPageScroll(scroll)
  local pageScrollBefore = pageScroll
  pageScroll = scroll
  
  if pageScrollBefore ~= pageScroll then
    renderDOM()
  end
end

local function getPageScroll(tmpScroll)
  local scrollDiff = -(totalLines - h + 1)
  if tmpScroll > 0 then tmpScroll = 0 end
  if math.abs(totalLines) > h-1 then
    if tmpScroll < scrollDiff then tmpScroll = scrollDiff end
  else
    tmpScroll = 0
  end
  return tmpScroll
end

local function scrollPage(amt)
  setPageScroll(getPageScroll(pageScroll + amt))
end

local function loadPage(id)
  logger.startLog("loadPage", currentPage, currentPageID)
  if currentPage == "internet" then
      -- Internet logic
      local headers = { ["User-Agent"] = userAgent }
      local pageResult = http.get("https://chorus.enderweb.net/getPage/" .. id, headers)
      
      if pageResult then
          local responseCode = pageResult.getResponseCode()
          local pageData = pageResult.readAll()
          pageResult.close()
          if responseCode == 200 then
              -- Successfully fetched the page
              logger.endLog("Page Served Correctly")
              localPageDOM = parseTree(pageData)
          else
              logger.endLog(responseCode)
              currentPage = (tostring(responseCode))
              loadPage()
          end
      else
        logger.endLog("Dreaded NoWifi Page")
          currentPage = "NoWifi"
          loadPage()
      end
  else
      -- Offline logic
      updateTitleKeying(currentPageID)
      local filePath = shell.resolve("pages/" .. currentPage .. ".xml")
      if fs.exists(filePath) then
          local file = fs.open(filePath, "r")
          local pageData = file.readAll()
          file.close()
          localPageDOM = parseTree(pageData)
      else
          localPageDOM = parseTree([[<?xml version="1.0"?><page><body><br></br><div align="center" color="red">Error Loading Page</div><br></br><div align="center" color="black">Couldnt load  the page "]] .. currentPage .. [["</div><div align="center" color="black">Please make issue or pull request on Github.</div><br></br><div align="center" color="black">Link: v.gd/i7Hs8e</div></body></page>]])
      end
      logger.endLog("Offline Site Loaded")
  end
  pageScroll = 0
  renderDOM()
end

--saveSettings()

function updateAllTheThings()
    term.setTextColor(colors.green)
    term.setBackgroundColor(colors.black)
    term.clear()
    term.setCursorPos(1,1)
    shell.run("market get gjdi84 pearl y")
    currentPageID = '001300'
    loadPage('001300')
end

loadPage()

if args[1] == "update" then
  updateAllTheThings()
--elseif args[1] then
--  currentPageID = args[1]
end

loadPage(currentPageID)

-- Replace the existing main loop with this simplified version
local isKeyingCode = false
local keyCode = ""

while running do
    local event, param1 = os.pullEvent()
    
    if event == "key" then
        local action = inputHandler.handleKeyPress(param1)
        
        -- Handle number input and page navigation
        if action.type == "input" then
            keyCode = keyCode .. action.keyPressed
            isKeyingCode = true
            updateTitleKeying(keyCode)
            
            -- Auto-submit when we have 6 digits
            if #keyCode == 6 then
                currentPageID = keyCode
                keyCode = ""
                isKeyingCode = false
                currentPage = "internet"
                loadPage(currentPageID)
            end
            
        -- Handle backspace during input
        elseif action.type == "backspace" and isKeyingCode then
            keyCode = string.sub(keyCode, 1, #keyCode-1)
            updateTitleKeying(keyCode)
            
        -- Handle enter/submit
        elseif action.type == "submit" and isKeyingCode then
            currentPageID = lpad(keyCode, 6, "0")
            keyCode = ""
            isKeyingCode = false
            currentPage = "internet"
            loadPage(currentPageID)
            
        -- Handle scrolling
        elseif action.type == "scroll" then
            scrollPage(action.scroll)
            
        -- Handle jump to position
        elseif action.type == "jump" then
            if action.jumpTo == -1 then
                setPageScroll(getPageScroll(-totalLines))
            else
                setPageScroll(getPageScroll(action.jumpTo))
            end
            
        -- Handle refresh
        elseif action.type == "refresh" then
            loadPage(currentPageID)
            
        -- Handle bookmark
        elseif action.type == "bookmark" then
            settings.addBookmark(currentPageID, currentPage)
            
        -- Handle quit
        elseif action.type == "quit" then
            running = false
            break
        end
    end
end


--saveSettings()
setColors(term, colors.black, colors.white, colors.black, colors.white)
term.clear()
term.setCursorPos(1,1)