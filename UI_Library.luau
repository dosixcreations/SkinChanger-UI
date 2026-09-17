--// Services
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

--// Main Library Table
local Library = {
	Colors = {
		DarkBackground = Color3.fromRGB(18, 19, 22),
		Background = Color3.fromRGB(27, 29, 34),
		SideBackground = Color3.fromRGB(41, 44, 51),
		RightSideBackground = Color3.fromRGB(30, 32, 37),
		UIStroke = Color3.fromRGB(50, 54, 65),
		AccentText = Color3.fromRGB(135, 148, 183),
		HoverText = Color3.fromRGB(76, 83, 104)
	},
	
	Fonts = {},
	Flags = {},
    FlagRegistry = {},
	ConfigsList = {},
	
	RarityColors = {
		{ Name = "Stock",     Color = Color3.fromRGB(195, 195, 195) },
		{ Name = "Blue",      Color = Color3.fromRGB(75, 106, 255) },
		{ Name = "Purple",    Color = Color3.fromRGB(136, 71, 255) },
		{ Name = "Pink",      Color = Color3.fromRGB(211, 44, 230) },
		{ Name = "Red",       Color = Color3.fromRGB(235, 75, 75) },
		{ Name = "Special",   Color = Color3.fromRGB(255, 215, 0) },
		{ Name = "Forbidden", Color = Color3.fromRGB(65, 15, 18) }
	},
	
	Images = {
		DropDownIcon = "https://raw.githubusercontent.com/dosixcreations/SkinChanger-UI/main/Polygon%201.png",
		StarIcon = "https://raw.githubusercontent.com/dosixcreations/SkinChanger-UI/main/Star%202.png",
		SkinGlow = "https://raw.githubusercontent.com/dosixcreations/SkinChanger-UI/main/Ellipse%2041.png",
		SkinUnderline = "https://raw.githubusercontent.com/dosixcreations/SkinChanger-UI/main/Rectangle%2086.png",
		ThreeDots = "https://raw.githubusercontent.com/dosixcreations/SkinChanger-UI/main/Group%2035.png",
		BackgroundGlow = "https://raw.githubusercontent.com/dosixcreations/SkinChanger-UI/main/Frame%2024.png",
		ConfigBackgroundGlow = "https://raw.githubusercontent.com/dosixcreations/SkinChanger-UI/main/Frame%2026.png",
		ConfigIcon = "https://raw.githubusercontent.com/dosixcreations/SkinChanger-UI/main/setting%20(2).png",
	},
	
	Folders = {
		"PypsCC_SkinChanger",
		"PypsCC_SkinChanger/Assets",
		"PypsCC_SkinChanger/Fonts",
		"PypsCC_SkinChanger/Configs",
	},
	
	AutoLoadFile = "PypsCC_SkinChanger/autoload.txt",
	Keybind = Enum.KeyCode.RightShift,
}

--// Folders bootstrap
for _, folder in ipairs(Library.Folders) do
    if not isfolder(folder) then makefolder(folder) end
end

--// Assets
for i, v in pairs(Library.Images) do
	if not isfile(Library.Folders[2] .. "/" .. i .. ".png") then
		writefile(Library.Folders[2] .. "/" .. i .. ".png", game:HttpGet(v))
	end
end

--// Functions

--// Fonts
function Library:LoadFont(FontName, Weight, Link)
	print(Library.Folders[3])
	if not isfolder(Library.Folders[3]) then makefolder(Library.Folders[3]) end
	if not isfile(string.format("%s/%d.ttf", Library.Folders[3], Weight)) then writefile(string.format("%s/%d.ttf", Library.Folders[3], Weight), game:HttpGet(Link)) end
	
	if not isfile(string.format("%s/%d.json", Library.Folders[3], Weight)) then
		local fontAssetId = getcustomasset(string.format("%s/%d.ttf", Library.Folders[3], Weight))
		local fontManifest = {
			name = FontName,
			faces = {
				{
					name = "Normal",
					style = "normal",
					weight = Weight,
					assetId = fontAssetId
				}
			}
		}

		writefile(string.format("%s/%d.json", Library.Folders[3], Weight), HttpService:JSONEncode(fontManifest))
	end

	if not Library.Fonts[FontName] then Library.Fonts[FontName] = {} end
	if Library.Fonts[FontName][Weight] then return Library.Fonts[FontName][Weight] end

	local jsonAssetId = getcustomasset(string.format("%s/%d.json", Library.Folders[3], Weight))
	local fontObject = Font.new(jsonAssetId, Enum.FontWeight.Regular, Enum.FontStyle.Normal)

	Library.Fonts[FontName][Weight] = fontObject
	return fontObject
end

--// Flags
function Library:RegisterFlag(flag, setter)
    self.FlagRegistry[flag] = setter
end

function Library:UnregisterFlag(flag)
    self.FlagRegistry[flag] = nil
    self.Flags[flag] = nil
end

--// Config
function Library:SaveConfig(name)
    name = name or "default"
    if not isfolder(Library.Folders[4]) then makefolder(Library.Folders[4]) end
    local ok, encoded = pcall(function()
        return HttpService:JSONEncode(self.Flags)
    end)
    if not ok then return false, encoded end
    writefile(Library.Folders[4] .. "/" .. name .. ".json", encoded)
    return true
end

function Library:LoadConfig(name)
    name = name or "default"
    local path = Library.Folders[4] .. "/" .. name .. ".json"
    if not isfile(path) then return false, "not found" end

    local ok, data = pcall(function()
        return HttpService:JSONDecode(readfile(path))
    end)
    if not ok or type(data) ~= "table" then return false, "corrupt" end

    for flag, setter in pairs(self.FlagRegistry) do
        if data[flag] == nil then
            pcall(setter, false)
        end
    end

    self.Flags = {}
    for flag, value in pairs(data) do
        self.Flags[flag] = value
        local setter = self.FlagRegistry[flag]
        if setter then pcall(setter, value) end
    end
    return true
end

function Library:DeleteConfig(name)
    name = name or "default"
    local path = Library.Folders[4] .. "/" .. name .. ".json"
    if not isfile(path) then return false end
    delfile(path)
    if self:GetAutoLoad() == name then self:DisableAutoLoad() end
    return true
end

--// Auto Load
function Library:GetAutoLoad()
    if isfile(self.AutoLoadFile) then
        local name = readfile(self.AutoLoadFile)
        if name and #name > 0 then return name end
    end
    return nil
end

function Library:ListConfigs()
    local list = {}
    if not isfolder(Library.Folders[4]) then return list end

    local auto = self:GetAutoLoad()

    for _, file in ipairs(listfiles(Library.Folders[4])) do
        local name = file:match("([^/\\]+)%.json$")
        if name then
            table.insert(list, {
                Name       = name,
                IsAutoLoad = (name == auto),
            })
        end
    end

    table.sort(list, function(a, b) return a.Name:lower() < b.Name:lower() end)
    return list
end
Library.ConfigsList = Library:ListConfigs()

function Library:SetAutoLoad(name)
    if name == nil then return self:DisableAutoLoad() end
    if not isfile(Library.Folders[4] .. "/" .. name .. ".json") then
        return false, "config doesn't exist"
    end
    writefile(self.AutoLoadFile, name)
    return true
end

function Library:DisableAutoLoad()
    if isfile(self.AutoLoadFile) then delfile(self.AutoLoadFile) end
    return true
end

function Library:ApplyAutoLoad()
    local name = self:GetAutoLoad()
    if name then return self:LoadConfig(name) end
    return false
end

function Library:IsAutoLoad(name)
    return self:GetAutoLoad() == name
end

--// Font Initialization
local gilroyMedium    = Library:LoadFont("Gilroy", 500, "https://raw.githubusercontent.com/dosixcreations/SkinChanger-UI/main/Gilroy-Medium.ttf")
local gilroySemiBold  = Library:LoadFont("Gilroy", 600, "https://raw.githubusercontent.com/dosixcreations/SkinChanger-UI/main/Gilroy-Semibold.ttf")
local gilroyExtraBold = Library:LoadFont("Gilroy", 800, "https://raw.githubusercontent.com/dosixcreations/SkinChanger-UI/main/Gilroy-Extrabold.ttf")

--// Window
function Library:CreateWindow(args)
	args = args or {}
	
	local Window = {
		SelectedRarityFilter = nil,
		ActiveSubTab = nil
	}

	local Tabs = {}
	local CurrentTab = nil
	
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.IgnoreGuiInset = true
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	ScreenGui.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets
	ScreenGui.Parent = gethui()
	Window.ScreenGui = ScreenGui

	local MainUI = Instance.new("Frame")
	MainUI.Name = "MainUI"
	MainUI.ClipsDescendants = true
	MainUI.AnchorPoint = Vector2.new(0.50, 0.50)
	MainUI.Size = UDim2.new(0.00, 735.00, 0.00, 500.00)
	MainUI.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
	MainUI.Position = UDim2.new(0.50, 0.00, 0.50, 0.00)
	MainUI.BorderSizePixel = 0
	MainUI.BackgroundColor3 = Library.Colors.DarkBackground
	MainUI.Parent = ScreenGui
	Window.MainUI = MainUI

	local ImageLabel = Instance.new("ImageLabel")
	ImageLabel.Interactable = false
	ImageLabel.BorderSizePixel = 0
	ImageLabel.BackgroundColor3 = Color3.new(1.00, 1.00, 1.00)
	ImageLabel.AnchorPoint = Vector2.new(0.50, 0.50)
	ImageLabel.Image = getcustomasset(Library.Folders[2] .. "/" .. "BackgroundGlow.png")
	ImageLabel.Size = UDim2.new(1.00, 0.00, 1.00, 0.00)
	ImageLabel.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
	ImageLabel.BackgroundTransparency = 1
	ImageLabel.Position = UDim2.new(0.50, 0.00, 0.50, 0.00)
	ImageLabel.ZIndex = 2
	ImageLabel.Parent = MainUI

	local UICorner = Instance.new("UICorner")
	UICorner.CornerRadius = UDim.new(0.00, 10.00)
	UICorner.Parent = MainUI
	Window.UICorner = UICorner
	
	--// Left Bar
	local LeftBar = Instance.new("Frame")
	LeftBar.Name = "LeftBar"
	LeftBar.Size = UDim2.new(0.00, 250.00, 1.00, 0.00)
	LeftBar.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
	LeftBar.BorderSizePixel = 0
	LeftBar.BackgroundColor3 = Library.Colors.Background
	LeftBar.Parent = MainUI
	Window.LeftBar = LeftBar
	
	local UICorner_1 = Instance.new("UICorner")
	UICorner_1.CornerRadius = UDim.new(0.00, 10.00)
	UICorner_1.Parent = LeftBar
	Window.UICorner_1 = UICorner_1
	
	local _SearchBar = Instance.new("Frame")
	_SearchBar.Name = "1SearchBar"
	_SearchBar.Size = UDim2.new(1.00, 0.00, 0.00, 38.00)
	_SearchBar.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
	_SearchBar.BorderSizePixel = 0
	_SearchBar.BackgroundTransparency = 0.5
	_SearchBar.BackgroundColor3 = Library.Colors.SideBackground
	_SearchBar.Parent = LeftBar
	Window._SearchBar = _SearchBar

	local UICorner_1 = Instance.new("UICorner")
	UICorner_1.CornerRadius = UDim.new(0.00, 5.00)
	UICorner_1.Parent = _SearchBar
	Window.UICorner_1 = UICorner_1

	--[[local UIStroke = Instance.new("UIStroke")
	UIStroke.Color = Library.Colors.UIStroke
	UIStroke.Thickness = 2
	UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	UIStroke.BorderStrokePosition = Enum.BorderStrokePosition.Inner
	UIStroke.Parent = _SearchBar
	Window.UIStroke = UIStroke]]

	local TextBox = Instance.new("TextBox")
	TextBox.TextTruncate = Enum.TextTruncate.SplitWord
	TextBox.BorderSizePixel = 0
	TextBox.BackgroundColor3 = Color3.new(1.00, 1.00, 1.00)
	TextBox.FontFace = gilroyMedium
	TextBox.AnchorPoint = Vector2.new(0.50, 1.00)
	TextBox.TextSize = 17
	TextBox.Size = UDim2.new(1.00, -40.00, 1.00, -2.00)
	TextBox.TextColor3 = Library.Colors.AccentText
	TextBox.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
	TextBox.Text = ""
	TextBox.PlaceholderText = "Search..."
	TextBox.PlaceholderColor3 = Library.Colors.UIStroke
	TextBox.ClearTextOnFocus = false
	TextBox.TextXAlignment = Enum.TextXAlignment.Left
	TextBox.BackgroundTransparency = 1
	TextBox.Position = UDim2.new(0.50, 0.00, 1.00, 0.00)
	TextBox.Parent = _SearchBar
	Window.TextBox = TextBox

	local UIPadding = Instance.new("UIPadding")
	UIPadding.PaddingTop = UDim.new(0.00, 5.00)
	UIPadding.Parent = TextBox
	Window.UIPadding = UIPadding
	
	local UIPadding = Instance.new("UIPadding")
	UIPadding.PaddingBottom = UDim.new(0.00, 20.00)
	UIPadding.PaddingTop = UDim.new(0.00, 20.00)
	UIPadding.PaddingLeft = UDim.new(0.00, 20.00)
	UIPadding.PaddingRight = UDim.new(0.00, 18.00)
	UIPadding.Parent = LeftBar
	Window.UIPadding = UIPadding
	
	local _TypeLabel = Instance.new("TextLabel")
	_TypeLabel.Name = "2TypeLabel"
	_TypeLabel.TextWrapped = true
	_TypeLabel.BorderSizePixel = 0
	_TypeLabel.TextYAlignment = Enum.TextYAlignment.Bottom
	_TypeLabel.BackgroundColor3 = Color3.new(1.00, 1.00, 1.00)
	_TypeLabel.FontFace = gilroyMedium
	_TypeLabel.TextXAlignment = Enum.TextXAlignment.Left
	_TypeLabel.TextSize = 17
	_TypeLabel.Size = UDim2.new(1.00, 0.00, 0.00, 38.00)
	_TypeLabel.Selectable = true
	_TypeLabel.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
	_TypeLabel.Text = "Type"
	_TypeLabel.TextColor3 = Library.Colors.UIStroke
	_TypeLabel.BackgroundTransparency = 1
	_TypeLabel.Parent = LeftBar
	Window._TypeLabel = _TypeLabel

	local UIPadding_1 = Instance.new("UIPadding")
	UIPadding_1.PaddingTop = UDim.new(0.00, 5.00)
	UIPadding_1.Parent = _TypeLabel
	Window.UIPadding_1 = UIPadding_1
	
	local UIPadding_1 = Instance.new("UIPadding")
	UIPadding_1.PaddingBottom = UDim.new(0.00, 4.00)
	UIPadding_1.Parent = _TypeLabel
	Window.UIPadding_1 = UIPadding_1

	local UIListLayout = Instance.new("UIListLayout")
	UIListLayout.Padding = UDim.new(0.00, 2.00)
	UIListLayout.Parent = LeftBar
	Window.UIListLayout = UIListLayout
	
	local _TabsHolder = Instance.new("ScrollingFrame")
	_TabsHolder.Name = "3TabsHolder"
	_TabsHolder.ScrollingDirection = Enum.ScrollingDirection.Y
	_TabsHolder.BorderSizePixel = 0
	_TabsHolder.CanvasSize = UDim2.new(0.00, 0.00, 0.00, 0.00)
	_TabsHolder.BackgroundColor3 = Color3.new(1.00, 1.00, 1.00)
	_TabsHolder.Size = UDim2.new(1.00, 4.00, 1.00, -138.00)
	_TabsHolder.ScrollBarImageColor3 = Library.Colors.UIStroke
	_TabsHolder.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
	_TabsHolder.ScrollBarThickness = 2
	_TabsHolder.BackgroundTransparency = 1
	_TabsHolder.AutomaticCanvasSize = Enum.AutomaticSize.Y
	_TabsHolder.Parent = LeftBar
	Window._TabsHolder = _TabsHolder

	local UIPadding_1 = Instance.new("UIPadding")
	UIPadding_1.PaddingRight = UDim.new(0.00, 4.00)
	UIPadding_1.Parent = _TabsHolder

	local _Icon = Instance.new("Frame")
	_Icon.Name = "4Icon"
	_Icon.Size = UDim2.new(1.00, 0.00, 0.00, 76.00)
	_Icon.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
	_Icon.BorderSizePixel = 0
	_Icon.BackgroundTransparency = 1
	_Icon.BackgroundColor3 = Color3.new(1.00, 1.00, 1.00)
	_Icon.Parent = LeftBar

	local UIPadding = Instance.new("UIPadding")
	UIPadding.PaddingBottom = UDim.new(0.00, 20.00)
	UIPadding.PaddingTop = UDim.new(0.00, 18.00)
	UIPadding.Parent = _Icon

	local Frame = Instance.new("Frame")
	Frame.Size = UDim2.new(0.00, 38.00, 0.00, 38.00)
	Frame.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
	Frame.BorderSizePixel = 0
	Frame.BackgroundTransparency = 0.5
	Frame.BackgroundColor3 = Library.Colors.AccentText
	Frame.Parent = _Icon

	local UICorner = Instance.new("UICorner")
	UICorner.CornerRadius = UDim.new(1.00, 0.00)
	UICorner.Parent = Frame

	local UIStroke = Instance.new("UIStroke")
	UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	UIStroke.BorderStrokePosition = Enum.BorderStrokePosition.Inner
	UIStroke.Color = Library.Colors.AccentText
	UIStroke.Thickness = 2
	UIStroke.Parent = Frame

	local ImageLabel1 = Instance.new("ImageLabel")
	ImageLabel1.BorderSizePixel = 0
	ImageLabel1.BackgroundColor3 = Color3.new(1.00, 1.00, 1.00)
	ImageLabel1.AnchorPoint = Vector2.new(0.50, 0.50)
	ImageLabel1.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. game:GetService("Players").LocalPlayer.UserId .. "&width=420&height=420&format=png"
	ImageLabel1.Size = UDim2.new(1.00, -4.00, 1.00, -4.00)
	ImageLabel1.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
	ImageLabel1.BackgroundTransparency = 1
	ImageLabel1.Position = UDim2.new(0.50, 0.00, 0.50, 0.00)
	ImageLabel1.Parent = Frame

	local UICorner_1 = Instance.new("UICorner")
	UICorner_1.CornerRadius = UDim.new(1.00, 0.00)
	UICorner_1.Parent = ImageLabel1

	local TextLabel = Instance.new("TextLabel")
	TextLabel.BorderSizePixel = 0
	TextLabel.BackgroundColor3 = Color3.new(1.00, 1.00, 1.00)
	TextLabel.FontFace = gilroyExtraBold
	TextLabel.TextXAlignment = Enum.TextXAlignment.Left
	TextLabel.TextSize = 15
	TextLabel.Size = UDim2.new(1.00, -42.00, 0.00, 19.00)
	TextLabel.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
	TextLabel.Text = game:GetService("Players").LocalPlayer.Name
	TextLabel.TextColor3 = Library.Colors.AccentText
	TextLabel.BackgroundTransparency = 1
	TextLabel.Position = UDim2.new(0.00, 42.00, 0.00, 0.00)
	TextLabel.Parent = _Icon

	local UIPadding_1 = Instance.new("UIPadding")
	UIPadding_1.PaddingTop = UDim.new(0.00, 10.00)
	UIPadding_1.Parent = TextLabel

	local TextLabel_1 = Instance.new("TextLabel")
	TextLabel_1.BorderSizePixel = 0
	TextLabel_1.TextYAlignment = Enum.TextYAlignment.Top
	TextLabel_1.BackgroundColor3 = Color3.new(1.00, 1.00, 1.00)
	TextLabel_1.FontFace = gilroySemiBold
	TextLabel_1.TextXAlignment = Enum.TextXAlignment.Left
	TextLabel_1.TextSize = 10
	TextLabel_1.Size = UDim2.new(1.00, -42.00, 0.00, 19.00)
	TextLabel_1.BorderColor3 = Color3.new(0.00, 0.00, 0.00)

	local dateComponents = os.date("!*t")
	local months = {"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"}
	
	TextLabel_1.Text = dateComponents.day .. " " .. months[dateComponents.month] .. " " .. dateComponents.year
	TextLabel_1.TextColor3 = Library.Colors.UIStroke
	TextLabel_1.BackgroundTransparency = 1
	TextLabel_1.Position = UDim2.new(0.00, 42.00, 0.00, 19.00)
	TextLabel_1.Parent = _Icon

	local UIPadding_1 = Instance.new("UIPadding")
	UIPadding_1.PaddingTop = UDim.new(0.00, 2)
	UIPadding_1.Parent = TextLabel_1

	--// Main Window
	local SeparatingLine = Instance.new("Frame")
	SeparatingLine.Name = "SeparatingLine"
	SeparatingLine.Size = UDim2.new(0.00, 1.00, 1.00, 0.00)
	SeparatingLine.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
	SeparatingLine.Position = UDim2.new(0.00, 250.00, 0.00, 0.00)
	SeparatingLine.BorderSizePixel = 0
	SeparatingLine.BackgroundColor3 = Library.Colors.UIStroke
	SeparatingLine.Parent = MainUI
	Window.SeparatingLine = SeparatingLine
	
	local FixingCorners = Instance.new("Frame")
	FixingCorners.Name = "FixingCorners"
	FixingCorners.Size = UDim2.new(0.00, 10.00, 1.00, 0.00)
	FixingCorners.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
	FixingCorners.Position = UDim2.new(0.00, 240.00, 0.00, 0.00)
	FixingCorners.BorderSizePixel = 0
	FixingCorners.BackgroundColor3 = Library.Colors.Background
	FixingCorners.Parent = MainUI
	Window.FixingCorners = FixingCorners
	
	--// Right Side
	local RIghtSide = Instance.new("Frame")
	RIghtSide.Name = "RIghtSide"
	RIghtSide.Size = UDim2.new(1.00, -251.00, 1.00, 0.00)
	RIghtSide.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
	RIghtSide.Position = UDim2.new(0.00, 251.00, 0.00, 0.00)
	RIghtSide.BorderSizePixel = 0
	RIghtSide.BackgroundTransparency = 1
	RIghtSide.BackgroundColor3 = Color3.new(1.00, 1.00, 1.00)
	RIghtSide.Parent = MainUI
	RIghtSide.ZIndex = 3
	Window.RIghtSide = RIghtSide
	
	local UIPadding_1 = Instance.new("UIPadding")
	UIPadding_1.PaddingBottom = UDim.new(0.00, 20.00)
	UIPadding_1.PaddingTop = UDim.new(0.00, 20.00)
	UIPadding_1.PaddingLeft = UDim.new(0.00, 18.00)
	UIPadding_1.PaddingRight = UDim.new(0.00, 18.00)
	UIPadding_1.Parent = RIghtSide
	Window.UIPadding_1 = UIPadding_1

	--[[local UIStroke_1 = Instance.new("UIStroke")
	UIStroke_1.Color = Library.Colors.UIStroke
	UIStroke_1.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	UIStroke_1.BorderStrokePosition = Enum.BorderStrokePosition.Inner
	UIStroke_1.Thickness = 2
	UIStroke_1.Parent = RarityFilter
	Window.UIStroke_1 = UIStroke_1]]

	local RarityText = Instance.new("TextLabel")
	RarityText.Name = "RarityText"
	RarityText.Active = true
	RarityText.TextTruncate = Enum.TextTruncate.SplitWord
	RarityText.ZIndex = 3
	RarityText.BorderSizePixel = 0
	RarityText.BackgroundColor3 = Color3.new(1.00, 1.00, 1.00)
	RarityText.FontFace = gilroySemiBold
	RarityText.TextXAlignment = Enum.TextXAlignment.Left
	RarityText.TextSize = 17
	RarityText.Size = UDim2.new(0.00, 170.00, 0.00, 36.00)
	RarityText.Selectable = true
	RarityText.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
	RarityText.Text = "Rarity Filter"
	RarityText.TextColor3 = Library.Colors.UIStroke
	RarityText.BackgroundTransparency = 1
	RarityText.Position = UDim2.new(0.00, 20.00, 0.00, 2.00)
	RarityText.Parent = RIghtSide

	local UIPadding = Instance.new("UIPadding")
	UIPadding.PaddingTop = UDim.new(0.00, 5.00)
	UIPadding.Parent = RarityText

	local InvisRarityHolder = Instance.new("Frame")
	InvisRarityHolder.Name = "InvisRarityHolder"
	InvisRarityHolder.ClipsDescendants = true
	InvisRarityHolder.Size = UDim2.new(0.00, 214.00, 0.00, 0)
	InvisRarityHolder.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
	InvisRarityHolder.Position = UDim2.new(0.00, -2.00, 0.00, 0.00)
	InvisRarityHolder.BorderSizePixel = 0
	InvisRarityHolder.ZIndex = 3
	InvisRarityHolder.BackgroundTransparency = 1
	InvisRarityHolder.BackgroundColor3 = Library.Colors.DarkBackground
	InvisRarityHolder.Parent = RIghtSide

	local InvisRarityFrame = Instance.new("Frame")
	InvisRarityFrame.Name = "InvisRarityFrame"
	InvisRarityFrame.AnchorPoint = Vector2.new(0.00, 0.50)
	InvisRarityFrame.Size = UDim2.new(0.00, 210.00, 1.00, -4.00)
	InvisRarityFrame.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
	InvisRarityFrame.Position = UDim2.new(0.00, 2.00, 0.50, 0.00)
	InvisRarityFrame.BorderSizePixel = 0
	InvisRarityFrame.ZIndex = 2
	InvisRarityFrame.BackgroundTransparency = 1
	InvisRarityFrame.BackgroundColor3 = Color3.fromRGB(127, 135, 157)
	InvisRarityFrame.Parent = InvisRarityHolder

	local UIPadding_1 = Instance.new("UIPadding")
	UIPadding_1.PaddingBottom = UDim.new(0.00, 5.00)
	UIPadding_1.PaddingTop = UDim.new(0.00, 41.00)
	UIPadding_1.PaddingLeft = UDim.new(0.00, 20.00)
	UIPadding_1.PaddingRight = UDim.new(0.00, 20.00)
	UIPadding_1.Parent = InvisRarityFrame

	local InvisRarityContainer = Instance.new("ScrollingFrame")
	InvisRarityContainer.Name = "InvisRarityContainer"
	InvisRarityContainer.Active = true
	InvisRarityContainer.ScrollingDirection = Enum.ScrollingDirection.Y
	InvisRarityContainer.BorderSizePixel = 0
	InvisRarityContainer.CanvasSize = UDim2.new(0.00, 2.00, 0.00, 2.00)
	InvisRarityContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
	InvisRarityContainer.BackgroundColor3 = Color3.new(1.00, 1.00, 1.00)
	InvisRarityContainer.Size = UDim2.new(1.00, 0.00, 1.00, 0.00)
	InvisRarityContainer.ScrollBarImageColor3 = Library.Colors.UIStroke
	InvisRarityContainer.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
	InvisRarityContainer.ScrollBarThickness = 2
	InvisRarityContainer.BackgroundTransparency = 1
	InvisRarityContainer.Parent = InvisRarityFrame

	local UIListLayout = Instance.new("UIListLayout")
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout.Parent = InvisRarityContainer

	local BlackBackground = Instance.new("Frame")
	BlackBackground.Name = "BlackBackground"
	BlackBackground.ClipsDescendants = true
	BlackBackground.Size = UDim2.new(0.00, 214.00, 0.00, 42)
	BlackBackground.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
	BlackBackground.Position = UDim2.new(0.00, -2.00, 0.00, -2.00)
	BlackBackground.BorderSizePixel = 0
	BlackBackground.ZIndex = 2
	BlackBackground.BackgroundColor3 = Library.Colors.DarkBackground
	BlackBackground.Parent = RIghtSide

	local UICorner2 = Instance.new("UICorner")
	UICorner2.CornerRadius = UDim.new(0.00, 5.00)
	UICorner2.Parent = BlackBackground

	local OpenIcon = Instance.new("ImageLabel")
	OpenIcon.Name = "OpenIcon"
	OpenIcon.ImageColor3 = Library.Colors.UIStroke
	OpenIcon.ZIndex = 4
	OpenIcon.BorderSizePixel = 0
	OpenIcon.ScaleType = Enum.ScaleType.Fit
	OpenIcon.BackgroundColor3 = Color3.new(1.00, 1.00, 1.00)
	OpenIcon.Image = getcustomasset(Library.Folders[2] .. "/" .. "DropDownIcon.png")
	OpenIcon.Size = UDim2.new(0.00, 15.00, 0.00, 11.00)
	OpenIcon.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
	OpenIcon.Rotation = 90
	OpenIcon.BackgroundTransparency = 1
	OpenIcon.Position = UDim2.new(0.00, 177.00, 0.00, 13.00)
	OpenIcon.Parent = RIghtSide

	local InvisRarityFrame_1 = Instance.new("CanvasGroup")
	InvisRarityFrame_1.Name = "InvisRarityFrame"
	InvisRarityFrame_1.GroupTransparency = 0.97 -- 0.97
	InvisRarityFrame_1.ZIndex = 3
	InvisRarityFrame_1.BorderSizePixel = 0
	InvisRarityFrame_1.BackgroundColor3 = Color3.fromRGB(127, 135, 157)
	InvisRarityFrame_1.Size = UDim2.new(0.00, 210.00, 0.00, 130)
	InvisRarityFrame_1.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
	InvisRarityFrame_1.BackgroundTransparency = 1
	InvisRarityFrame_1.Parent = RIghtSide

	local RarityFilter = Instance.new("TextButton")
	RarityFilter.Name = "RarityFilter"
	RarityFilter.Size = UDim2.new(0.00, 210.00, 0.00, 38.00)
	RarityFilter.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
	RarityFilter.AutoButtonColor = false
	RarityFilter.Text = ""
	RarityFilter.BorderSizePixel = 0
	RarityFilter.ZIndex = 4
	RarityFilter.BackgroundColor3 = Color3.fromRGB(127, 135, 157)
	RarityFilter.Parent = InvisRarityFrame_1

	local UICorner = Instance.new("UICorner")
	UICorner.CornerRadius = UDim.new(0.00, 5.00)
	UICorner.Parent = RarityFilter

	local InvisRarityFrame2 = Instance.new("Frame")
	InvisRarityFrame2.Name = "InvisRarityFrame"
	InvisRarityFrame2.Size = UDim2.new(0.00, 210.00, 0.00, 38)
	InvisRarityFrame2.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
	InvisRarityFrame2.BorderSizePixel = 0
	InvisRarityFrame2.ZIndex = 3
	InvisRarityFrame2.BackgroundColor3 = Color3.fromRGB(127, 135, 157)
	InvisRarityFrame2.Parent = InvisRarityFrame_1

	local UICorner = Instance.new("UICorner")
	UICorner.CornerRadius = UDim.new(0.00, 5.00)
	UICorner.Parent = InvisRarityFrame2

	--//Config!
		local ConfigToggle = Instance.new("TextButton")
	ConfigToggle.Name = "ConfigToggle"
	ConfigToggle.BorderSizePixel = 0
	ConfigToggle.AutoButtonColor = false
	ConfigToggle.BackgroundColor3 = Color3.fromRGB(127, 135, 157)
	ConfigToggle.AnchorPoint = Vector2.new(1.00, 0.00)
	ConfigToggle.Size = UDim2.new(0.00, 38.00, 0.00, 38.00)
	ConfigToggle.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
	ConfigToggle.Text = ""
	ConfigToggle.BackgroundTransparency = 0.97
	ConfigToggle.Position = UDim2.new(1.00, 0.00, 0.00, 0.00)
	ConfigToggle.Parent = RIghtSide

	local UICorner = Instance.new("UICorner")
	UICorner.Parent = ConfigToggle

	local ImageLabel = Instance.new("ImageLabel")
	ImageLabel.ImageColor3 = Library.Colors.UIStroke
	ImageLabel.BorderSizePixel = 0
	ImageLabel.BackgroundColor3 = Color3.new(1.00, 1.00, 1.00)
	ImageLabel.AnchorPoint = Vector2.new(0.50, 0.50)
	ImageLabel.Image = getcustomasset(Library.Folders[2] .. "/" .. "ConfigIcon.png")
	ImageLabel.Size = UDim2.new(0.00, 25.00, 0.00, 25.00)
	ImageLabel.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
	ImageLabel.BackgroundTransparency = 1
	ImageLabel.Position = UDim2.new(0.50, 0.00, 0.50, 0.00)
	ImageLabel.Parent = ConfigToggle

	for i = 1, #Library.RarityColors do 
		local RarityButton = Instance.new("TextButton") 
		local data = Library.RarityColors[i]

		RarityButton.Name = data.Name
		RarityButton.BorderSizePixel = 0
		RarityButton.BackgroundColor3 = Color3.new(1.00, 1.00, 1.00)
		RarityButton.FontFace = gilroySemiBold
		RarityButton.TextSize = 17
		RarityButton.Size = UDim2.new(1.00, 0.00, 0.00, 26.00)
		RarityButton.TextColor3 = Library.Colors.UIStroke
		RarityButton.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
		RarityButton.Text = data.Name
		RarityButton.BackgroundTransparency = 1
		RarityButton.TextXAlignment = Enum.TextXAlignment.Left
		RarityButton.Parent = InvisRarityContainer

		local UIPadding_1 = Instance.new("UIPadding")
		UIPadding_1.PaddingTop = UDim.new(0.00, 5.00)
		UIPadding_1.Parent = RarityButton
		Window.UIPadding_1 = UIPadding_1
		
		Window[data.Name .. "_" .. tostring(i)] = RarityButton 
	
		local function DeselectRarity(Button)
			TweenService:Create(Button, TweenInfo.new(0.15), {TextColor3 = Library.Colors.UIStroke}):Play()
			Window.SelectedRarityFilter = nil
		end

		local function SelectRarity(Button)
			if Window.SelectedRarityFilter then 
				DeselectRarity(Window.SelectedRarityFilter) 
			end
			TweenService:Create(Button, TweenInfo.new(0.15), {TextColor3 = Library.Colors.AccentText}):Play()
			Window.SelectedRarityFilter = Button
		end

		RarityButton.MouseButton1Click:Connect(function()
			if Window.SelectedRarityFilter == RarityButton then
				DeselectRarity(RarityButton)
			else
				SelectRarity(RarityButton)
			end
		end)

		local function SetHoverColor(TargetColor)
			return function()
				if Window.SelectedRarityFilter ~= RarityButton then
					TweenService:Create(RarityButton, TweenInfo.new(0.15), {TextColor3 = TargetColor}):Play()
				end
			end
		end

		RarityButton.MouseEnter:Connect(SetHoverColor(Library.Colors.HoverText))
		RarityButton.MouseLeave:Connect(SetHoverColor(Library.Colors.UIStroke))
	end
	
	local Toggled = false
	RarityFilter.MouseButton1Click:Connect(function()
		Toggled = not Toggled
		if Toggled then
			TweenService:Create(OpenIcon, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Rotation = 0}):Play()
			TweenService:Create(BlackBackground, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0.00, 214.00, 0.00, 134.00)}):Play()
			TweenService:Create(InvisRarityHolder, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0.00, 214.00, 0.00, 132.00)}):Play()
			TweenService:Create(InvisRarityFrame2, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0.00, 210.00, 0.00, 130.00)}):Play()

		else
			TweenService:Create(OpenIcon, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Rotation = 90}):Play()
			TweenService:Create(BlackBackground, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0.00, 214.00, 0.00, 42.00)}):Play()
			TweenService:Create(InvisRarityHolder, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0.00, 214.00, 0.00, 0)}):Play()
			TweenService:Create(InvisRarityFrame2, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0.00, 210.00, 0.00, 38.00)}):Play()
		end
	end)

	RarityFilter.MouseEnter:Connect(function()
		TweenService:Create(RarityText, TweenInfo.new(0.2), {TextColor3 = Library.Colors.HoverText}):Play()
		TweenService:Create(OpenIcon, TweenInfo.new(0.2), {ImageColor3 = Library.Colors.HoverText}):Play()
	end)

	RarityFilter.MouseLeave:Connect(function()
		TweenService:Create(RarityText, TweenInfo.new(0.2), {TextColor3 = Library.Colors.UIStroke}):Play()
		TweenService:Create(OpenIcon, TweenInfo.new(0.2), {ImageColor3 = Library.Colors.UIStroke}):Play()
	end)
	
	function Window:Open()
		if not Window.MainUI.Visible then
			Window.MainUI.Visible = true
		end
	end
	
	function Window:Close()
		if Window.MainUI.Visible then
			Window.MainUI.Visible = false
		end
	end
	
	UserInputService.InputBegan:Connect(function(Input)
		if Input.KeyCode == Library.Keybind then
			Window.MainUI.Visible = not Window.MainUI.Visible
		end
	end)
	
	local TAB_HEIGHT = 38
	local SUBTAB_HEIGHT = 26
	local TAB_PADDING = 2
	local TOP_BOTTOM_PADDING = 20

	local SizeTweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	local FadeInInfo    = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local FadeOutInfo   = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	
	local function RecalculateTabPositions()
		local currentY = 0

		for _, tabData in ipairs(Tabs) do
			local subCount = #tabData.SubTabButtons
			local targetHeight = TAB_HEIGHT

			if tabData.IsOpen and subCount > 0 then
				targetHeight = TAB_HEIGHT + (subCount * SUBTAB_HEIGHT) + TOP_BOTTOM_PADDING
			end

			TweenService:Create(tabData.ActiveTab, SizeTweenInfo, {
				Position = UDim2.new(0, 0, 0, currentY),
				Size = UDim2.new(1, -4, 0, targetHeight)
			}):Play()

			currentY = currentY + targetHeight + TAB_PADDING
		end
	end

	function Window:CreateTab(args)
		args = args or {}
		local Name = args.Name or "Knives"
		local SubTabsList = args.SubTabs or {"M9 Bayonet", "Karambit"}
		local OneSkin = args.OneSkin or false
		local Stars = args.Stars or false

		local tabData = {
			IsOpen = false,
			SubTabButtons = {},
			SelectedSkin = nil,
			SelectedSkinSubTab = nil,
		}

		table.insert(Tabs, tabData)

		local ActiveTab = Instance.new("CanvasGroup")
		ActiveTab.Name = "ActiveTab"
		ActiveTab.BorderSizePixel = 0
		ActiveTab.BackgroundColor3 = Library.Colors.SideBackground
		ActiveTab.Size = UDim2.new(1.00, 0.00, 0.00, TAB_HEIGHT)
		ActiveTab.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
		ActiveTab.BackgroundTransparency = 1
		ActiveTab.Parent = _TabsHolder
		tabData.ActiveTab = ActiveTab

		local TabContainer = Instance.new("TextButton")
		TabContainer.Name = "TabContainer"
		TabContainer.BorderSizePixel = 0
		TabContainer.AutoButtonColor = false
		TabContainer.BackgroundColor3 = Library.Colors.SideBackground
		TabContainer.Size = UDim2.new(1.00, 0.00, 0.00, TAB_HEIGHT)
		TabContainer.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
		TabContainer.Text = ""
		TabContainer.BackgroundTransparency = 1
		TabContainer.Parent = ActiveTab
		tabData.TabContainer = TabContainer

		local UICorner = Instance.new("UICorner")
		UICorner.CornerRadius = UDim.new(0.00, 5.00)
		UICorner.Parent = TabContainer
		tabData.TabContainer = TabContainer

		--[[local UIStroke = Instance.new("UIStroke")
		UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		UIStroke.BorderStrokePosition = Enum.BorderStrokePosition.Inner
		UIStroke.Color = Library.Colors.UIStroke
		UIStroke.Thickness = 2
		UIStroke.Parent = TabContainer
		UIStroke.Transparency = 1
		tabData.TabContainer = TabContainer]]

		local TabName = Instance.new("TextLabel")
		TabName.Name = "TabName"
		TabName.Active = true
		TabName.TextTruncate = Enum.TextTruncate.SplitWord
		TabName.BorderSizePixel = 0
		TabName.BackgroundColor3 = Color3.new(1.00, 1.00, 1.00)
		TabName.FontFace = gilroyExtraBold
		TabName.AnchorPoint = Vector2.new(0.50, 1.00)
		TabName.TextXAlignment = Enum.TextXAlignment.Left
		TabName.TextSize = 17
		TabName.Size = UDim2.new(1.00, 0, 1.00, -2.00)
		TabName.Selectable = true
		TabName.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
		TabName.Text = Name
		TabName.TextColor3 = Library.Colors.UIStroke
		TabName.BackgroundTransparency = 1
		TabName.Position = UDim2.new(0.50, 0.00, 1.00, 0.00)
		TabName.Parent = TabContainer
		tabData.TabName = TabName

		local UIPadding = Instance.new("UIPadding")
		UIPadding.PaddingTop = UDim.new(0.00, 5.00)
		UIPadding.Parent = TabName
		tabData.TabContainer = TabContainer

		local OpenIcon = Instance.new("ImageLabel")
		OpenIcon.Name = "OpenIcon"
		OpenIcon.ImageColor3 = Library.Colors.AccentText
		OpenIcon.BorderSizePixel = 0
		OpenIcon.ScaleType = Enum.ScaleType.Fit
		OpenIcon.BackgroundColor3 = Color3.new(1.00, 1.00, 1.00)
		OpenIcon.AnchorPoint = Vector2.new(1.00, 0.50)
		OpenIcon.Image = getcustomasset(Library.Folders[2] .. "/" .. "DropDownIcon.png")
		OpenIcon.ImageColor3 = Library.Colors.UIStroke
		OpenIcon.Size = UDim2.new(0.00, 15.00, 0.00, 11.00)
		OpenIcon.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
		OpenIcon.BackgroundTransparency = 1
		OpenIcon.Rotation = 90
		OpenIcon.Position = UDim2.new(1.00, 0, 0.50, 0.00)
		OpenIcon.Parent = TabContainer
		tabData.ActiveTab = ActiveTab

		local SubTabContainer = Instance.new("Frame")
		SubTabContainer.Name = "SubTabContainer"
		SubTabContainer.ClipsDescendants = true
		SubTabContainer.Size = UDim2.new(1, 0, 1, -TAB_HEIGHT)
		SubTabContainer.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
		SubTabContainer.Position = UDim2.new(0, 0, 0, TAB_HEIGHT)
		SubTabContainer.BorderSizePixel = 0
		SubTabContainer.ZIndex = 2
		SubTabContainer.BackgroundTransparency = 1
		SubTabContainer.BackgroundColor3 = Color3.new(1.00, 1.00, 1.00)
		SubTabContainer.Parent = ActiveTab
		tabData.ActiveTab = ActiveTab

		local UIPadding_1 = Instance.new("UIPadding")
		UIPadding_1.PaddingBottom = UDim.new(0.00, 12.00)
		UIPadding_1.PaddingTop = UDim.new(0.00, 12.00)
		UIPadding_1.PaddingLeft = UDim.new(0.00, 5.00)
		UIPadding_1.Parent = SubTabContainer
		tabData.ActiveTab = ActiveTab

		local Line = Instance.new("Frame")
		Line.Name = "Line"
		Line.AnchorPoint = Vector2.new(0.00, 0.50)
		Line.Size = UDim2.new(0.00, 2.00, 1.00, 0.00)
		Line.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
		Line.Position = UDim2.new(0.00, 0.00, 0.50, 0.00)
		Line.BorderSizePixel = 0
		Line.BackgroundColor3 = Library.Colors.UIStroke
		Line.Parent = SubTabContainer
		tabData.ActiveTab = ActiveTab

		local UICorner_1 = Instance.new("UICorner")
		UICorner_1.CornerRadius = UDim.new(0.00, 999.00)
		UICorner_1.Parent = Line
		tabData.ActiveTab = ActiveTab

		local SubTabsHolder = Instance.new("Frame")
		SubTabsHolder.Name = "SubTabsHolder"
		SubTabsHolder.ClipsDescendants = true
		SubTabsHolder.AnchorPoint = Vector2.new(1.00, 0.50)
		SubTabsHolder.Size = UDim2.new(1.00, -16.00, 1.00, 0.00)
		SubTabsHolder.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
		SubTabsHolder.Position = UDim2.new(1.00, 0.00, 0.50, 0.00)
		SubTabsHolder.BorderSizePixel = 0
		SubTabsHolder.ZIndex = 2
		SubTabsHolder.BackgroundTransparency = 1
		SubTabsHolder.BackgroundColor3 = Color3.new(1.00, 1.00, 1.00)
		SubTabsHolder.Parent = SubTabContainer
		tabData.ActiveTab = ActiveTab

		local UIListLayout = Instance.new("UIListLayout")
		UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		UIListLayout.Parent = SubTabsHolder
		tabData.ActiveTab = ActiveTab

		function tabData:CreateSubTab(args)
			args = args or {}
			local Name = args.Name or "SubTab"

			local SubTab = {
				SubTabSelectedSkin = nil,
				Active = false
			}

			local SubTabButton = Instance.new("CanvasGroup")
			SubTabButton.Name = "SubTabButton"
			SubTabButton.Active = true
			SubTabButton.BorderSizePixel = 0
			SubTabButton.BackgroundColor3 = Color3.new(1.00, 1.00, 1.00)
			SubTabButton.Selectable = true
			SubTabButton.Size = UDim2.new(1.00, 0.00, 0.00, 26.00)
			SubTabButton.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
			SubTabButton.BackgroundTransparency = 1
			SubTabButton.Parent = SubTabsHolder
			SubTab.SubTabButton = SubTabButton
			
			local SubTabButton_1 = Instance.new("TextButton")
			SubTabButton_1.Name = "SubTabButton"
			SubTabButton_1.BorderSizePixel = 0
			SubTabButton_1.BackgroundColor3 = Color3.new(1.00, 1.00, 1.00)
			SubTabButton_1.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
			SubTabButton_1.TextSize = 17
			SubTabButton_1.Size = UDim2.new(1.00, 0.00, 1.00, 0.00)
			SubTabButton_1.TextColor3 = Library.Colors.UIStroke
			SubTabButton_1.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
			SubTabButton_1.Text = ""
			SubTabButton_1.BackgroundTransparency = 1
			SubTabButton_1.TextXAlignment = Enum.TextXAlignment.Left
			SubTabButton_1.Parent = SubTabButton
			SubTab.SubTabButton_1 = SubTabButton_1

			local ImageLabel = Instance.new("ImageLabel")
			ImageLabel.ImageColor3 = Library.Colors.UIStroke
			ImageLabel.BorderSizePixel = 0
			ImageLabel.BackgroundColor3 = Color3.new(1.00, 1.00, 1.00)
			ImageLabel.AnchorPoint = Vector2.new(0.00, 0.50)
			ImageLabel.Image = getcustomasset(Library.Folders[2] .. "/" .. "StarIcon.png")
			ImageLabel.Size = UDim2.new(0.00, 12.00, 0.00, 11.00)
			ImageLabel.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
			ImageLabel.BackgroundTransparency = 1
			ImageLabel.Position = UDim2.new(0.00, 0.00, 0.50, 0.00)
			ImageLabel.Parent = SubTabButton_1
			ImageLabel.Visible = Stars
			SubTab.ImageLabel = ImageLabel

			local TextLabel = Instance.new("TextLabel")
			TextLabel.BorderSizePixel = 0
			TextLabel.BackgroundColor3 = Color3.new(1.00, 1.00, 1.00)
			TextLabel.FontFace = gilroySemiBold
			TextLabel.AnchorPoint = Vector2.new(0.50, 0.50)
			TextLabel.TextXAlignment = Enum.TextXAlignment.Left
			TextLabel.TextSize = 17
			TextLabel.Size = UDim2.new(1.00, 0.00, 1.00, 0.00)
			TextLabel.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
			TextLabel.Text = Name
			TextLabel.TextColor3 = Library.Colors.UIStroke
			TextLabel.BackgroundTransparency = 1
			TextLabel.Position = UDim2.new(0.50, 0.00, 0.50, 0.00)
			TextLabel.Parent = SubTabButton_1
			SubTab.TextLabel = TextLabel

			local UIPadding_1 = Instance.new("UIPadding")
			UIPadding_1.PaddingTop = UDim.new(0.00, 7.00)
			UIPadding_1.PaddingLeft = UDim.new(0.00, Stars and 19 or 0)
			UIPadding_1.Parent = TextLabel
			SubTab.UIPadding_1 = UIPadding_1

			local SkinHolder = Instance.new("ScrollingFrame")
			SkinHolder.Name = "SkinHolder"
			SkinHolder.Visible = false
			SkinHolder.BorderSizePixel = 0
			SkinHolder.ScrollingDirection = Enum.ScrollingDirection.Y
			SkinHolder.AutomaticCanvasSize = Enum.AutomaticSize.Y
			SkinHolder.CanvasSize = UDim2.new(0.00, 0.00, 0.00, 0.00)
			SkinHolder.BackgroundColor3 = Color3.new(1.00, 1.00, 1.00)
			SkinHolder.Size = UDim2.new(1.00, 10.00, 1.00, -40.00)
			SkinHolder.ScrollBarImageColor3 = Library.Colors.UIStroke
			SkinHolder.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
			SkinHolder.ScrollBarThickness = 2
			SkinHolder.BackgroundTransparency = 1
			SkinHolder.Position = UDim2.new(0.00, 0.00, 0.00, 40.00)
			SkinHolder.Parent = RIghtSide
			SubTab.SkinHolder = SkinHolder

			local UIPadding_1 = Instance.new("UIPadding")
			UIPadding_1.PaddingRight = UDim.new(0.00, 10.00)
			UIPadding_1.Parent = SkinHolder
			SubTab.UIPadding_1 = UIPadding_1

			local UIGridLayout = Instance.new("UIGridLayout")
			UIGridLayout.CellPadding = UDim2.new(0.00, 2.00, 0.00, 2.00)
			UIGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
			UIGridLayout.CellSize = UDim2.new(0.00, 148.00, 0.00, 165.00)
			UIGridLayout.Parent = SkinHolder
			SubTab.UIGridLayout = UIGridLayout

			SubTabButton_1.MouseButton1Click:Connect(function()
				if Window.ActiveSubTab then	
					Window.ActiveSubTab.Active = false
					Window.ActiveSubTab.SkinHolder.Visible = false
					TweenService:Create(Window.ActiveSubTab.TextLabel, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextColor3 = Library.Colors.UIStroke }):Play()
					TweenService:Create(Window.ActiveSubTab.ImageLabel, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ImageColor3 = Library.Colors.UIStroke }):Play()
				end

				Window.ActiveSubTab = SubTab
				SubTab.Active = true
				SkinHolder.Visible = true
				TweenService:Create(TextLabel, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextColor3 = Library.Colors.AccentText }):Play()
				TweenService:Create(ImageLabel, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ImageColor3 = Library.Colors.AccentText }):Play()
			end)

			SubTabButton_1.MouseEnter:Connect(function()
				if not SubTab.Active then
					TweenService:Create(TextLabel, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextColor3 = Library.Colors.HoverText }):Play()
					TweenService:Create(ImageLabel, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ImageColor3 = Library.Colors.HoverText }):Play()
				end
			end)

			SubTabButton_1.MouseLeave:Connect(function()
				if not SubTab.Active then
					TweenService:Create(TextLabel, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextColor3 = Library.Colors.UIStroke }):Play()
					TweenService:Create(ImageLabel, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ImageColor3 = Library.Colors.UIStroke }):Play()
				end
			end)

			table.insert(tabData.SubTabButtons, SubTabButton)
			tabData[Name] = SubTab

			function SubTab:CreateSkin(args)
				args = args or {}
				local _GunName  = args.GunName or "GunName"
				local _SkinName = args.SkinName or "SkinName"
				local _SkinIcon = args.SkinIcon or "rbxassetid://1"
				local _Rarity 	= args.Rarity or "Stock"
				local _Flag     = args.Flag or (_GunName .. "_" .. _SkinName)
				local _Callback = args.Callback or function() end

				local RarityColor = Color3.fromRGB(195, 195, 195)
				for _, v in ipairs(Library.RarityColors) do
					if v.Name == _Rarity then
						RarityColor = v.Color
						break
					end
				end

				local Skin = {
					Selected = false
				}

				local SkinVariant = Instance.new("TextButton")
				SkinVariant.Name = "SkinVariant"
				SkinVariant.BorderSizePixel = 0
				SkinVariant.AutoButtonColor = false
				SkinVariant.BackgroundColor3 = Color3.fromRGB(127, 135, 157)
				SkinVariant.Size = UDim2.new(0.00, 100.00, 0.00, 100.00)
				SkinVariant.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
				SkinVariant.Text = ""
				SkinVariant.BackgroundTransparency = 0.97
				SkinVariant.Parent = SkinHolder
				Skin.SkinVariant = SkinVariant

				local UICorner_1 = Instance.new("UICorner")
				UICorner_1.CornerRadius = UDim.new(0.00, 5.00)
				UICorner_1.Parent = SkinVariant

				--[[local UIStroke_1 = Instance.new("UIStroke")
				UIStroke_1.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				UIStroke_1.BorderStrokePosition = Enum.BorderStrokePosition.Inner
				UIStroke_1.Color = Color3.fromRGB(175, 188, 224)
				UIStroke_1.Thickness = 2
				UIStroke_1.Transparency = 0.95
				UIStroke_1.Parent = SkinVariant
				Skin.UIStroke_1 = UIStroke_1]]

				local SkinIcon = Instance.new("ImageLabel")
				SkinIcon.Name = "SkinIcon"
				SkinIcon.ZIndex = 2
				SkinIcon.BorderSizePixel = 0
				SkinIcon.BackgroundColor3 = Color3.new(1.00, 1.00, 1.00)
				SkinIcon.AnchorPoint = Vector2.new(0.50, 0.00)
				SkinIcon.Image = _SkinIcon
				SkinIcon.Size = UDim2.new(0.00, 98.00, 0.00, 98.00)
				SkinIcon.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
				SkinIcon.BackgroundTransparency = 1
				SkinIcon.Position = UDim2.new(0.50, 0.00, 0.00, 10.00)
				SkinIcon.Parent = SkinVariant

				local Glow = Instance.new("ImageLabel")
				Glow.Name = "Glow"
				Glow.ImageColor3 = RarityColor
				Glow.BorderSizePixel = 0
				Glow.BackgroundColor3 = Color3.new(1.00, 1.00, 1.00)
				Glow.AnchorPoint = Vector2.new(0.50, 0.00)
				Glow.Image = getcustomasset(Library.Folders[2] .. "/" .. "SkinGlow.png")
				Glow.Size = UDim2.new(0.00, 120.00, 0.00, 120.00)
				Glow.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
				Glow.BackgroundTransparency = 1
				Glow.Position = UDim2.new(0.50, 0.00, 0.00, 5.00)
				Glow.Parent = SkinVariant

				local GunName = Instance.new("TextLabel")
				GunName.Name = "GunName"
				GunName.BorderSizePixel = 0
				GunName.BackgroundColor3 = Color3.new(1.00, 1.00, 1.00)
				GunName.FontFace = gilroyMedium
				GunName.TextTransparency = 0.800000011920929
				GunName.AnchorPoint = Vector2.new(0.50, 1.00)
				GunName.TextXAlignment = Enum.TextXAlignment.Left
				GunName.TextSize = 12
				GunName.Size = UDim2.new(0.00, 118.00, 0.00, 14.00)
				GunName.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
				GunName.Text = _GunName
				GunName.TextColor3 = Color3.fromRGB(135, 148, 183)
				GunName.BackgroundTransparency = 1
				GunName.Position = UDim2.new(0.50, 0.00, 1.00, -33.00)
				GunName.Parent = SkinVariant
				Skin.GunName = GunName

				local UIPadding_1 = Instance.new("UIPadding")
				UIPadding_1.PaddingTop = UDim.new(0.00, 5.00)
				UIPadding_1.Parent = GunName

				local SkinName = Instance.new("TextLabel")
				SkinName.Name = "SkinName"
				SkinName.BorderSizePixel = 0
				SkinName.BackgroundColor3 = Color3.new(1.00, 1.00, 1.00)
				SkinName.FontFace = gilroySemiBold
				SkinName.AnchorPoint = Vector2.new(0.50, 1.00)
				SkinName.TextXAlignment = Enum.TextXAlignment.Left
				SkinName.TextSize = 17
				SkinName.Size = UDim2.new(0.00, 118.00, 0.00, 36.00)
				SkinName.BorderColor3 = Color3.fromRGB(0, 0, 0)
				SkinName.Text = _SkinName
				SkinName.TextColor3 = Color3.fromRGB(135, 148, 183)
				SkinName.BackgroundTransparency = 1
				SkinName.Position = UDim2.new(0.50, 0.00, 1.00, -6.00)
				SkinName.Parent = SkinVariant
				Skin.SkinName = SkinName

				local UIPadding_1 = Instance.new("UIPadding")
				UIPadding_1.PaddingTop = UDim.new(0.00, 5.00)
				UIPadding_1.Parent = SkinName

				local BottomLine = Instance.new("ImageLabel")
				BottomLine.Name = "BottomLine"
				BottomLine.ImageColor3 = RarityColor
				BottomLine.BorderSizePixel = 0
				BottomLine.BackgroundColor3 = Color3.new(1.00, 1.00, 1.00)
				BottomLine.AnchorPoint = Vector2.new(0.50, 1.00)
				BottomLine.Image = getcustomasset(Library.Folders[2] .. "/" .. "SkinUnderline.png")
				BottomLine.Size = UDim2.new(0.00, 118.00, 0.00, 3.00)
				BottomLine.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
				BottomLine.BackgroundTransparency = 1
				BottomLine.Position = UDim2.new(0.50, 0.00, 1.00, 0.00)
				BottomLine.Parent = SkinVariant

				local _Dots = Instance.new("ImageButton")
				_Dots.Name = "3Dots"
				_Dots.BorderSizePixel = 0
				_Dots.BackgroundColor3 = Color3.new(1.00, 1.00, 1.00)
				_Dots.Visible = false
				_Dots.Image = getcustomasset(Library.Folders[2] .. "/" .. "ThreeDots.png")
				_Dots.Size = UDim2.new(0.00, 5.00, 0.00, 19.00)
				_Dots.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
				_Dots.BackgroundTransparency = 1
				_Dots.Position = UDim2.new(0.00, 15.00, 0.00, 16.00)
				_Dots.Parent = SkinVariant

				Skin.Flag = _Flag

				local function ApplyDeselect(s)
					s.Selected = false
					TweenService:Create(s.SkinVariant, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Transparency = 0.97, BackgroundColor3 = Color3.fromRGB(127, 135, 157) }):Play()
					TweenService:Create(s.SkinName, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextColor3 = Color3.fromRGB(135, 148, 183) }):Play()
					TweenService:Create(s.GunName, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextColor3 = Color3.fromRGB(135, 148, 183) }):Play()
				end

				local function ApplySelect(s, color)
					s.Selected = true
					TweenService:Create(s.SkinVariant, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Transparency = 0.91, BackgroundColor3 = color }):Play()
					TweenService:Create(s.SkinName, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextColor3 = color }):Play()
					TweenService:Create(s.GunName, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextColor3 = color }):Play()
				end

				function Skin:Deselect()
					if not Skin.Selected then return end
					ApplyDeselect(Skin)
					Library.Flags[_Flag] = nil
					if OneSkin and tabData.SelectedSkin == Skin then
						tabData.SelectedSkin = nil
						tabData.SelectedSkinSubTab = nil
					elseif not OneSkin and SubTab.SubTabSelectedSkin == Skin then
						SubTab.SubTabSelectedSkin = nil
					end
				end

				function Skin:SetSkin(skipSave)
					local PrevSkin = OneSkin and tabData.SelectedSkin or SubTab.SubTabSelectedSkin
					if PrevSkin and PrevSkin ~= Skin then PrevSkin:Deselect() end

					if OneSkin then
						if tabData.SelectedSkinSubTab and tabData.SelectedSkinSubTab ~= SubTab
						and tabData.SelectedSkinSubTab.SubTabSelectedSkin then
							tabData.SelectedSkinSubTab.SubTabSelectedSkin:Deselect()
						end
						tabData.SelectedSkin = Skin
						tabData.SelectedSkinSubTab = SubTab
					else
						SubTab.SubTabSelectedSkin = Skin
					end

					ApplySelect(Skin, RarityColor)

					if not skipSave then
						Library.Flags[_Flag] = true
					end
					_Callback(_GunName, _SkinName)
				end

				SkinVariant.MouseButton1Click:Connect(function()
					Skin:SetSkin(false)
				end)

				SkinVariant.MouseEnter:Connect(function()
					if not Skin.Selected then
						TweenService:Create(SkinVariant, TweenInfo.new(0.15), { Transparency = 0.95 }):Play()
					end
				end)

				SkinVariant.MouseLeave:Connect(function()
					if not Skin.Selected then
						TweenService:Create(SkinVariant, TweenInfo.new(0.15), { Transparency = 0.97 }):Play()
					end
				end)

				--// Register flag with the config system
				Library:RegisterFlag(_Flag, function(value)
					if value then
						Skin:SetSkin(true)   -- skipSave = true (we're the ones applying the value)
					else
						Skin:Deselect()
					end
				end)

				return Skin
			end

			return SubTab
		end

		for _, subName in ipairs(SubTabsList) do
			tabData:CreateSubTab({Name = subName})
		end

		TabContainer.MouseButton1Click:Connect(function()
			tabData.IsOpen = not tabData.IsOpen

			if tabData.IsOpen then
				SubTabContainer.Visible = true

				TweenService:Create(TabName, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.new(1, -40, 1, -2), TextColor3 = Library.Colors.AccentText }):Play()
				--TweenService:Create(UIStroke, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Transparency = 0 }):Play()
				TweenService:Create(OpenIcon, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Rotation = 0, Position = UDim2.new(1.00, -18.00, 0.50, 0.00), ImageColor3 = Library.Colors.AccentText }):Play()
				TweenService:Create(TabContainer, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 0.5 }):Play()

				-- Stagger sub-tab fade in
				for j, subBtn in ipairs(tabData.SubTabButtons) do
					task.delay((j - 1) * 0.04, function()
						if tabData.IsOpen then
							TweenService:Create(subBtn, FadeInInfo, { GroupTransparency = 0 }):Play()
						end
					end)
				end
			else
				TweenService:Create(TabName, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.new(1, 0, 1, -2), TextColor3 = Library.Colors.UIStroke }):Play()
				--TweenService:Create(UIStroke, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Transparency = 1 }):Play()
				TweenService:Create(OpenIcon, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Rotation = 90, Position = UDim2.new(1.00, 0, 0.50, 0.00), ImageColor3 = Library.Colors.UIStroke }):Play()
				TweenService:Create(TabContainer, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 1 }):Play()

				-- Stagger sub-tab fade out (reverse order)
				local count = #tabData.SubTabButtons
				for j, subBtn in ipairs(tabData.SubTabButtons) do
					task.delay((count - j) * 0.04, function()
						if not tabData.IsOpen then
							TweenService:Create(subBtn, FadeOutInfo, { GroupTransparency = 1 }):Play()
						end
					end)
				end

				-- Hide frame after shrink completes
				task.delay(0.35, function()
					if not tabData.IsOpen then
						SubTabContainer.Visible = false
					end
				end)
			end

			RecalculateTabPositions()
		end)

		TabContainer.MouseEnter:Connect(function()
			if not tabData.IsOpen then
				TweenService:Create(TabName, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextColor3 = Library.Colors.HoverText }):Play()
				TweenService:Create(OpenIcon, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ImageColor3 = Library.Colors.HoverText }):Play()
			end
		end)

		TabContainer.MouseLeave:Connect(function()
			if not tabData.IsOpen then
				TweenService:Create(TabName, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextColor3 = Library.Colors.UIStroke }):Play()
				TweenService:Create(OpenIcon, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ImageColor3 = Library.Colors.UIStroke }):Play()
			end
		end)

		RecalculateTabPositions()

		return tabData
	end
	
	function Window:CreateConfigWindow()
		local ConfigWindow = {}

		local ConfigTabContainer = Instance.new("Frame")
		ConfigTabContainer.Name = "ConfigTabContainer"
		ConfigTabContainer.Size = UDim2.new(0.00, 226.00, 0.00, 357.00)
		ConfigTabContainer.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
		ConfigTabContainer.Position = UDim2.new(0.50, (Window.MainUI.Position.X.Offset + Window.MainUI.Size.X.Offset / 2) + 4, 0.50, -250.00)
		ConfigTabContainer.BorderSizePixel = 0
		ConfigTabContainer.BackgroundColor3 = Library.Colors.DarkBackground
		ConfigTabContainer.Parent = ScreenGui

		local UICorner = Instance.new("UICorner")
		UICorner.CornerRadius = UDim.new(0.00, 10.00)
		UICorner.Parent = ConfigTabContainer

		local UIGlow = Instance.new("ImageLabel")
		UIGlow.Name = "UIGlow"
		UIGlow.BorderSizePixel = 0
		UIGlow.BackgroundColor3 = Color3.new(1.00, 1.00, 1.00)
		UIGlow.AnchorPoint = Vector2.new(0.50, 0.50)
		UIGlow.Image = getcustomasset(Library.Folders[2] .. "/" .. "ConfigBackgroundGlow.png")
		UIGlow.Size = UDim2.new(1.00, 0.00, 1.00, 0.00)
		UIGlow.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
		UIGlow.BackgroundTransparency = 1
		UIGlow.Position = UDim2.new(0.50, 0.00, 0.50, 0.00)
		UIGlow.Parent = ConfigTabContainer

		local MainHolder = Instance.new("Frame")
		MainHolder.Name = "MainHolder"
		MainHolder.AnchorPoint = Vector2.new(0.50, 0.50)
		MainHolder.Size = UDim2.new(1.00, 0.00, 1.00, 0.00)
		MainHolder.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
		MainHolder.Position = UDim2.new(0.50, 0.00, 0.50, 0.00)
		MainHolder.BorderSizePixel = 0
		MainHolder.BackgroundTransparency = 1
		MainHolder.BackgroundColor3 = Color3.new(1.00, 1.00, 1.00)
		MainHolder.Parent = ConfigTabContainer

		local UIPadding = Instance.new("UIPadding")
		UIPadding.PaddingBottom = UDim.new(0.00, 20.00)
		UIPadding.PaddingTop = UDim.new(0.00, 20.00)
		UIPadding.PaddingLeft = UDim.new(0.00, 20.00)
		UIPadding.PaddingRight = UDim.new(0.00, 20.00)
		UIPadding.Parent = MainHolder

		local ConfigContainerHolder = Instance.new("Frame")
		ConfigContainerHolder.Name = "ConfigContainerHolder"
		ConfigContainerHolder.Size = UDim2.new(0.00, 186.00, 0.00, 159.00)
		ConfigContainerHolder.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
		ConfigContainerHolder.BorderSizePixel = 0
		ConfigContainerHolder.BackgroundTransparency = 0.1
		ConfigContainerHolder.BackgroundColor3 = Color3.new(0.07, 0.07, 0.09)
		ConfigContainerHolder.Parent = MainHolder

		local UICorner_1 = Instance.new("UICorner")
		UICorner_1.CornerRadius = UDim.new(0.00, 5.00)
		UICorner_1.Parent = ConfigContainerHolder

		local UIStroke = Instance.new("UIStroke")
		UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		UIStroke.Color = Color3.new(0.04, 0.05, 0.05)
		UIStroke.Thickness = 2
		UIStroke.Transparency = 0.69
		UIStroke.Parent = ConfigContainerHolder

		local UIPadding_1 = Instance.new("UIPadding")
		UIPadding_1.PaddingBottom = UDim.new(0.00, 6.00)
		UIPadding_1.PaddingTop = UDim.new(0.00, 6.00)
		UIPadding_1.PaddingLeft = UDim.new(0.00, 6.00)
		UIPadding_1.PaddingRight = UDim.new(0.00, 6.00)
		UIPadding_1.Parent = ConfigContainerHolder

		local ConfigContainer = Instance.new("ScrollingFrame")
		ConfigContainer.Name = "ConfigContainer"
		ConfigContainer.Active = true
		ConfigContainer.ScrollingDirection = Enum.ScrollingDirection.Y
		ConfigContainer.BorderSizePixel = 0
		ConfigContainer.CanvasSize = UDim2.new(0.00, 0.00, 0.00, 0.00)
		ConfigContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
		ConfigContainer.BackgroundColor3 = Color3.new(1.00, 1.00, 1.00)
		ConfigContainer.Size = UDim2.new(1.00, 0.00, 1.00, 0.00)
		ConfigContainer.ScrollBarImageColor3 = Library.Colors.UIStroke
		ConfigContainer.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
		ConfigContainer.ScrollBarThickness = 2
		ConfigContainer.BackgroundTransparency = 1
		ConfigContainer.Parent = ConfigContainerHolder

		local UIPadding_1 = Instance.new("UIPadding")
		UIPadding_1.PaddingRight = UDim.new(0.00, 6.00)
		UIPadding_1.Parent = ConfigContainer

		local UIListLayout = Instance.new("UIListLayout")
		UIListLayout.Padding = UDim.new(0.00, 4.00)
		UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		UIListLayout.Parent = ConfigContainer

		local Config = Instance.new("TextButton")
		Config.Name = "Config"
		Config.BorderSizePixel = 0
		Config.BackgroundColor3 = Color3.fromRGB(127, 135, 157)
		Config.Size = UDim2.new(1.00, -6.00, 0.00, 26.00)
		Config.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
		Config.Text = ""
		Config.BackgroundTransparency = 0.97
		Config.Parent = ConfigContainer

		local ConfigName = Instance.new("TextLabel")
		ConfigName.Name = "ConfigName"
		ConfigName.Active = true
		ConfigName.TextTruncate = Enum.TextTruncate.SplitWord
		ConfigName.BorderSizePixel = 0
		ConfigName.BackgroundColor3 = Color3.new(1.00, 1.00, 1.00)
		ConfigName.FontFace = gilroySemiBold
		ConfigName.AnchorPoint = Vector2.new(0.50, 1.00)
		ConfigName.TextXAlignment = Enum.TextXAlignment.Left
		ConfigName.TextSize = 13
		ConfigName.Size = UDim2.new(1.00, -12.00, 1.00, -2.00)
		ConfigName.Selectable = true
		ConfigName.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
		ConfigName.Text = "Config Name"
		ConfigName.TextColor3 = Library.Colors.UIStroke
		ConfigName.BackgroundTransparency = 1
		ConfigName.Position = UDim2.new(0.50, 0.00, 1.00, 0.00)
		ConfigName.Parent = Config

		local ConfigNamePadding = Instance.new("UIPadding")
		ConfigNamePadding.Name = "ConfigNamePadding"
		ConfigNamePadding.PaddingTop = UDim.new(0.00, 5.00)
		ConfigNamePadding.Parent = ConfigName

		local UICorner_1 = Instance.new("UICorner")
		UICorner_1.CornerRadius = UDim.new(0.00, 2.00)
		UICorner_1.Parent = Config

		local ButtonsHolder = Instance.new("Frame")
		ButtonsHolder.Name = "ButtonsHolder"
		ButtonsHolder.Size = UDim2.new(0.00, 186.00, 0.00, 138.00)
		ButtonsHolder.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
		ButtonsHolder.Position = UDim2.new(0.00, 0.00, 0.00, 179.00)
		ButtonsHolder.BorderSizePixel = 0
		ButtonsHolder.BackgroundTransparency = 1
		ButtonsHolder.BackgroundColor3 = Color3.new(1.00, 1.00, 1.00)
		ButtonsHolder.Parent = MainHolder

		local UIListLayout_1 = Instance.new("UIListLayout")
		UIListLayout_1.Padding = UDim.new(0.00, 2.00)
		UIListLayout_1.Parent = ButtonsHolder

		local _ConfigNameHolder = Instance.new("Frame")
		_ConfigNameHolder.Name = "1ConfigNameHolder"
		_ConfigNameHolder.Size = UDim2.new(0.00, 186.00, 0.00, 26.00)
		_ConfigNameHolder.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
		_ConfigNameHolder.BorderSizePixel = 0
		_ConfigNameHolder.BackgroundTransparency = 0.10000000149011612
		_ConfigNameHolder.BackgroundColor3 = Color3.new(0.07, 0.07, 0.09)
		_ConfigNameHolder.Parent = ButtonsHolder

		local UICorner_1 = Instance.new("UICorner")
		UICorner_1.CornerRadius = UDim.new(0.00, 5.00)
		UICorner_1.Parent = _ConfigNameHolder

		local UIStroke_1 = Instance.new("UIStroke")
		UIStroke_1.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		UIStroke_1.Color = Color3.new(0.04, 0.05, 0.05)
		UIStroke_1.Thickness = 2
		UIStroke_1.Transparency = 0.69
		UIStroke_1.Parent = _ConfigNameHolder

		local ConfigName_1 = Instance.new("TextBox")
		ConfigName_1.Name = "ConfigName"
		ConfigName_1.TextTruncate = Enum.TextTruncate.SplitWord
		ConfigName_1.BorderSizePixel = 0
		ConfigName_1.BackgroundColor3 = Color3.new(1.00, 1.00, 1.00)
		ConfigName_1.FontFace = gilroySemiBold
		ConfigName_1.AnchorPoint = Vector2.new(0.50, 1.00)
		ConfigName_1.TextSize = 13
		ConfigName_1.Size = UDim2.new(1.00, -24.00, 1.00, -2.00)
		ConfigName_1.TextColor3 = Library.Colors.AccentText
		ConfigName_1.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
		ConfigName_1.Text = ""
		ConfigName_1.TextXAlignment = Enum.TextXAlignment.Left
		ConfigName_1.BackgroundTransparency = 1
		ConfigName_1.Position = UDim2.new(0.50, 0.00, 1.00, 0.00)
		ConfigName_1.Parent = _ConfigNameHolder

		local UIPadding_1 = Instance.new("UIPadding")
		UIPadding_1.PaddingTop = UDim.new(0.00, 5.00)
		UIPadding_1.Parent = ConfigName_1

		local _AddConfigButton = Instance.new("TextButton")
		_AddConfigButton.Name = "2AddConfigButton"
		_AddConfigButton.BorderSizePixel = 0
		_AddConfigButton.BackgroundColor3 = Color3.fromRGB(127, 135, 157)
		_AddConfigButton.Size = UDim2.new(0.00, 186.00, 0.00, 26.00)
		_AddConfigButton.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
		_AddConfigButton.Text = ""
		_AddConfigButton.BackgroundTransparency = 0.97
		_AddConfigButton.Parent = ButtonsHolder

		local Name = Instance.new("TextLabel")
		Name.Name = "Name"
		Name.Active = true
		Name.TextTruncate = Enum.TextTruncate.SplitWord
		Name.BorderSizePixel = 0
		Name.BackgroundColor3 = Color3.new(1.00, 1.00, 1.00)
		Name.FontFace = gilroySemiBold
		Name.AnchorPoint = Vector2.new(0.50, 1.00)
		Name.TextXAlignment = Enum.TextXAlignment.Left
		Name.TextSize = 13
		Name.Size = UDim2.new(1.00, -24.00, 1.00, -2.00)
		Name.Selectable = true
		Name.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
		Name.Text = "Add Config"
		Name.TextColor3 = Library.Colors.UIStroke
		Name.BackgroundTransparency = 1
		Name.Position = UDim2.new(0.50, 0.00, 1.00, 0.00)
		Name.Parent = _AddConfigButton

		local UIPadding_1 = Instance.new("UIPadding")
		UIPadding_1.PaddingTop = UDim.new(0.00, 5.00)
		UIPadding_1.Parent = Name

		local UICorner_1 = Instance.new("UICorner")
		UICorner_1.CornerRadius = UDim.new(0.00, 5.00)
		UICorner_1.Parent = _AddConfigButton

		local _LoadConfigButton = Instance.new("TextButton")
		_LoadConfigButton.Name = "3LoadConfigButton"
		_LoadConfigButton.BorderSizePixel = 0
		_LoadConfigButton.BackgroundColor3 = Color3.fromRGB(127, 135, 157)
		_LoadConfigButton.Size = UDim2.new(0.00, 186.00, 0.00, 26.00)
		_LoadConfigButton.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
		_LoadConfigButton.Text = ""
		_LoadConfigButton.BackgroundTransparency = 0.97
		_LoadConfigButton.Parent = ButtonsHolder

		local Name_1 = Instance.new("TextLabel")
		Name_1.Name = "Name"
		Name_1.Active = true
		Name_1.TextTruncate = Enum.TextTruncate.SplitWord
		Name_1.BorderSizePixel = 0
		Name_1.BackgroundColor3 = Color3.new(1.00, 1.00, 1.00)
		Name_1.FontFace = gilroySemiBold
		Name_1.AnchorPoint = Vector2.new(0.50, 1.00)
		Name_1.TextXAlignment = Enum.TextXAlignment.Left
		Name_1.TextSize = 13
		Name_1.Size = UDim2.new(1.00, -24.00, 1.00, -2.00)
		Name_1.Selectable = true
		Name_1.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
		Name_1.Text = "Load Config"
		Name_1.TextColor3 = Library.Colors.UIStroke
		Name_1.BackgroundTransparency = 1
		Name_1.Position = UDim2.new(0.50, 0.00, 1.00, 0.00)
		Name_1.Parent = _LoadConfigButton

		local UIPadding_1 = Instance.new("UIPadding")
		UIPadding_1.PaddingTop = UDim.new(0.00, 5.00)
		UIPadding_1.Parent = Name_1

		local UICorner_1 = Instance.new("UICorner")
		UICorner_1.CornerRadius = UDim.new(0.00, 5.00)
		UICorner_1.Parent = _LoadConfigButton

		local _DeleteConfigButton = Instance.new("TextButton")
		_DeleteConfigButton.Name = "4DeleteConfigButton"
		_DeleteConfigButton.BorderSizePixel = 0
		_DeleteConfigButton.BackgroundColor3 = Color3.fromRGB(127, 135, 157)
		_DeleteConfigButton.Size = UDim2.new(0.00, 186.00, 0.00, 26.00)
		_DeleteConfigButton.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
		_DeleteConfigButton.Text = ""
		_DeleteConfigButton.BackgroundTransparency = 0.97
		_DeleteConfigButton.Parent = ButtonsHolder

		local Name_1 = Instance.new("TextLabel")
		Name_1.Name = "Name"
		Name_1.Active = true
		Name_1.TextTruncate = Enum.TextTruncate.SplitWord
		Name_1.BorderSizePixel = 0
		Name_1.BackgroundColor3 = Color3.new(1.00, 1.00, 1.00)
		Name_1.FontFace = gilroySemiBold
		Name_1.AnchorPoint = Vector2.new(0.50, 1.00)
		Name_1.TextXAlignment = Enum.TextXAlignment.Left
		Name_1.TextSize = 13
		Name_1.Size = UDim2.new(1.00, -24.00, 1.00, -2.00)
		Name_1.Selectable = true
		Name_1.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
		Name_1.Text = "Delete Config"
		Name_1.TextColor3 = Library.Colors.UIStroke
		Name_1.BackgroundTransparency = 1
		Name_1.Position = UDim2.new(0.50, 0.00, 1.00, 0.00)
		Name_1.Parent = _DeleteConfigButton

		local UIPadding_1 = Instance.new("UIPadding")
		UIPadding_1.PaddingTop = UDim.new(0.00, 5.00)
		UIPadding_1.Parent = Name_1

		local UICorner_1 = Instance.new("UICorner")
		UICorner_1.CornerRadius = UDim.new(0.00, 5.00)
		UICorner_1.Parent = _DeleteConfigButton

		local _AutoLoadToggle = Instance.new("TextButton")
		_AutoLoadToggle.Name = "5AutoLoadToggle"
		_AutoLoadToggle.BorderSizePixel = 0
		_AutoLoadToggle.BackgroundColor3 = Color3.fromRGB(127, 135, 157)
		_AutoLoadToggle.Size = UDim2.new(0.00, 26.00, 0.00, 26.00)
		_AutoLoadToggle.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
		_AutoLoadToggle.Text = ""
		_AutoLoadToggle.BackgroundTransparency = 0.97
		_AutoLoadToggle.Parent = ButtonsHolder

		local Text = Instance.new("TextLabel")
		Text.Name = "Text"
		Text.Active = true
		Text.TextTruncate = Enum.TextTruncate.SplitWord
		Text.BorderSizePixel = 0
		Text.BackgroundColor3 = Color3.new(1.00, 1.00, 1.00)
		Text.FontFace = gilroySemiBold
		Text.AnchorPoint = Vector2.new(0.00, 0.50)
		Text.TextXAlignment = Enum.TextXAlignment.Left
		Text.TextSize = 13
		Text.Size = UDim2.new(0.00, 148.00, 1.00, 0.00)
		Text.Selectable = true
		Text.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
		Text.Text = "Auto Load"
		Text.TextColor3 = Library.Colors.UIStroke
		Text.BackgroundTransparency = 1
		Text.Position = UDim2.new(0.00, 38.00, 0.50, 0.00)
		Text.Parent = _AutoLoadToggle

		local UIPadding_1 = Instance.new("UIPadding")
		UIPadding_1.PaddingTop = UDim.new(0.00, 5.00)
		UIPadding_1.Parent = Text

		local ToggleFill = Instance.new("Frame")
		ToggleFill.Name = "ToggleFill"
		ToggleFill.AnchorPoint = Vector2.new(0.50, 0.50)
		ToggleFill.Size = UDim2.new(1.00, -4.00, 1.00, -4.00)
		ToggleFill.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
		ToggleFill.Position = UDim2.new(0.50, 0.00, 0.50, 0.00)
		ToggleFill.BorderSizePixel = 0
		ToggleFill.BackgroundColor3 = Library.Colors.AccentText
		ToggleFill.Parent = _AutoLoadToggle

		local UICorner_1 = Instance.new("UICorner")
		UICorner_1.CornerRadius = UDim.new(0.00, 5.00)
		UICorner_1.Parent = ToggleFill

		local UICorner_1 = Instance.new("UICorner")
		UICorner_1.CornerRadius = UDim.new(0.00, 5.00)
		UICorner_1.Parent = _AutoLoadToggle

		function ConfigWindow:Open()
			ConfigTabContainer.Visible = true
		end

		function ConfigWindow:Close()
			ConfigTabContainer.Visible = false
		end

		local TWEEN_INFO   = TweenInfo.new(0.15)

		local function Tween(obj, props)
			TweenService:Create(obj, TWEEN_INFO, props):Play()
		end

		-- References to the buttons + their text labels
		local AddBtn        = _AddConfigButton
		local AddBtnText    = AddBtn:FindFirstChild("Name")
		local LoadBtn       = _LoadConfigButton
		local LoadBtnText   = LoadBtn:FindFirstChild("Name")
		local DeleteBtn     = _DeleteConfigButton
		local DeleteBtnText = DeleteBtn:FindFirstChild("Name")
		local ToggleBtn     = _AutoLoadToggle
		local ToggleText    = ToggleBtn:FindFirstChild("Text")

		-- State
		local SelectedConfig = nil
		local AddEnabled     = true
		local ToggleState    = false
		local ConfigButtons  = {}

		-- Steal the template that lives inside ConfigContainer, then remove it
		local configTemplate = Config:Clone()
		Config:Destroy()

		--==================================================================
		--  TOGGLE
		--==================================================================
		local function SetToggleValue(value)
			ToggleState = value
			Tween(ToggleFill, { BackgroundTransparency = value and 0 or 1 })
		end

		--==================================================================
		--  SELECT / DESELECT
		--==================================================================
		local function DeselectConfig()
			if SelectedConfig then
				local btn = ConfigButtons[SelectedConfig]
				if btn and btn.Parent then
					local label = btn:FindFirstChild("ConfigName")
					Tween(btn,   { BackgroundTransparency = 0.97 })
					Tween(label, { TextColor3 = Library.Colors.UIStroke })
				end
			end

			SelectedConfig = nil
			ConfigName_1.Text         = ""
			ConfigName_1.TextEditable = true
			AddEnabled = true
			SetToggleValue(false)
		end

		local function SelectConfig(name)
			if SelectedConfig == name then return end

			-- Deselect the previous one
			if SelectedConfig then
				local prevBtn = ConfigButtons[SelectedConfig]
				if prevBtn and prevBtn.Parent then
					local prevLabel = prevBtn:FindFirstChild("ConfigName")
					Tween(prevBtn,   { BackgroundTransparency = 0.97 })
					Tween(prevLabel, { TextColor3 = Library.Colors.UIStroke })
				end
			end

			SelectedConfig = name
			local btn = ConfigButtons[name]
			if not btn then return end

			local label = btn:FindFirstChild("ConfigName")
			Tween(btn,   { BackgroundTransparency = 0.91 })
			Tween(label, { TextColor3 = Library.Colors.AccentText })

			-- Lock the textbox + disable add
			ConfigName_1.Text         = name
			ConfigName_1.TextEditable = false

			AddEnabled = false
			Tween(AddBtn,     { BackgroundTransparency = 0.97 })
			Tween(AddBtnText, { TextColor3 = Library.Colors.UIStroke })

			-- Sync toggle to this config's auto-load state
			SetToggleValue(Library:IsAutoLoad(name))
		end

		--==================================================================
		--  CONFIG LIST BUTTONS
		--==================================================================
		local function CreateConfigButton(configName, order)
			local btn = configTemplate:Clone()
			btn.Name                   = configName
			btn.LayoutOrder            = order
			btn.BackgroundTransparency = 0.97
			btn.Parent                 = ConfigContainer

			local label = btn:FindFirstChild("ConfigName")
			label.Text       = configName
			label.TextColor3 = Library.Colors.UIStroke

			ConfigButtons[configName] = btn

			-- Hover only fires when this button isn't the currently selected one
			btn.MouseEnter:Connect(function()
				if SelectedConfig == configName then return end
				Tween(btn,   { BackgroundTransparency = 0.95 })
				Tween(label, { TextColor3 = Library.Colors.HoverText })
			end)
			btn.MouseLeave:Connect(function()
				if SelectedConfig == configName then return end
				Tween(btn,   { BackgroundTransparency = 0.97 })
				Tween(label, { TextColor3 = Library.Colors.UIStroke })
			end)

			btn.MouseButton1Click:Connect(function()
				if SelectedConfig == configName then
					DeselectConfig()            -- clicking the active one deselects
				else
					SelectConfig(configName)
				end
			end)
		end

		local function RefreshConfigList()
			for _, btn in pairs(ConfigButtons) do
				btn:Destroy()
			end
			ConfigButtons = {}

			local list = Library:ListConfigs()
			for i, cfg in ipairs(list) do
				CreateConfigButton(cfg.Name, i)
			end
		end

		--==================================================================
		--  BASIC BUTTON ANIMATIONS (Add / Load / Delete)
		--==================================================================
		local function SetupBasicButton(button, textLabel, isEnabledFn)
			button.MouseEnter:Connect(function()
				if isEnabledFn and not isEnabledFn() then return end
				Tween(button,    { BackgroundTransparency = 0.95 })
				Tween(textLabel, { TextColor3 = Library.Colors.HoverText })
			end)
			button.MouseLeave:Connect(function()
				Tween(button,    { BackgroundTransparency = 0.97 })
				Tween(textLabel, { TextColor3 = Library.Colors.UIStroke })
			end)
			button.MouseButton1Down:Connect(function()
				if isEnabledFn and not isEnabledFn() then return end
				Tween(button, { BackgroundTransparency = 0.91 })
			end)
			button.MouseButton1Up:Connect(function()
				if isEnabledFn and not isEnabledFn() then return end
				Tween(button, { BackgroundTransparency = 0.95 })
			end)
		end

		SetupBasicButton(AddBtn,    AddBtnText,    function() return AddEnabled end)
		SetupBasicButton(LoadBtn,   LoadBtnText)
		SetupBasicButton(DeleteBtn, DeleteBtnText)

		--==================================================================
		--  TOGGLE HOVER ANIMATIONS
		--==================================================================
		ToggleBtn.MouseEnter:Connect(function()
			if ToggleState then return end
			Tween(ToggleBtn,  { BackgroundTransparency = 0.95 })
			Tween(ToggleText, { TextColor3 = Library.Colors.HoverText })
		end)
		ToggleBtn.MouseLeave:Connect(function()
			if ToggleState then return end
			Tween(ToggleBtn,  { BackgroundTransparency = 0.97 })
			Tween(ToggleText, { TextColor3 = Library.Colors.UIStroke })
		end)
		ToggleBtn.MouseButton1Down:Connect(function()
			if ToggleState then return end
			Tween(ToggleBtn, { BackgroundTransparency = 0.91 })
		end)
		ToggleBtn.MouseButton1Up:Connect(function()
			if ToggleState then return end
			Tween(ToggleBtn, { BackgroundTransparency = 0.95 })
		end)

		--==================================================================
		--  ACTION HANDLERS
		--==================================================================

		-- Add Config
		AddBtn.MouseButton1Click:Connect(function()
			if not AddEnabled then return end
			local name = ConfigName_1.Text
			if name == "" then return end

			local ok = Library:SaveConfig(name)
			if ok then
				RefreshConfigList()
			end
		end)

		-- Load Config
		LoadBtn.MouseButton1Click:Connect(function()
			if not SelectedConfig then return end
			Library:LoadConfig(SelectedConfig)
		end)

		-- Delete Config
		DeleteBtn.MouseButton1Click:Connect(function()
			if not SelectedConfig then return end
			Library:DeleteConfig(SelectedConfig)
			RefreshConfigList()   -- rebuild (old button destroyed)
			DeselectConfig()      -- safe, no-op if button gone
		end)

		-- Toggle Auto Load
		ToggleBtn.MouseButton1Click:Connect(function()
			if not SelectedConfig then return end

			local newValue = not ToggleState
			SetToggleValue(newValue)

			if newValue then
				Library:SetAutoLoad(SelectedConfig)
			else
				if Library:IsAutoLoad(SelectedConfig) then
					Library:DisableAutoLoad()
				end
			end
		end)

		--==================================================================
		--  OPEN / CLOSE (fixed — original never flipped `state`)
		--==================================================================
		RefreshConfigList()
		SetToggleValue(false)
		ConfigWindow:Close()

		local state = false
		ConfigToggle.MouseButton1Click:Connect(function()
			state = not state
			if state then
				RefreshConfigList()   -- keep list fresh on open
				ConfigWindow:Open()
			else
				ConfigWindow:Close()
			end
		end)

		return ConfigWindow
	end

	local ConfigWindow = Window:CreateConfigWindow()

	return Window
end

return Library
