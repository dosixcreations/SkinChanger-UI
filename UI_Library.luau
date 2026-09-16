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
		BackgroundGlow = "https://raw.githubusercontent.com/dosixcreations/SkinChanger-UI/main/Frame%2024.png"
	},
	
	Folders = {
		"PypsCC_SkinChanger",
		"PypsCC_SkinChanger/Assets",
		"PypsCC_SkinChanger/Fonts"
	},
	
	Keybind = Enum.KeyCode.RightShift,
}

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

	local UIStroke = Instance.new("UIStroke")
	UIStroke.Color = Library.Colors.UIStroke
	UIStroke.Thickness = 2
	UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	UIStroke.BorderStrokePosition = Enum.BorderStrokePosition.Inner
	UIStroke.Parent = _SearchBar
	Window.UIStroke = UIStroke

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
	_TabsHolder.Size = UDim2.new(1.00, 4.00, 1.00, -78.00)
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
	
	local RarityFilter = Instance.new("TextButton")
	RarityFilter.Name = "RarityFilter"
	RarityFilter.Size = UDim2.new(0.00, 210.00, 0.00, 38.00)
	RarityFilter.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
	RarityFilter.BorderSizePixel = 0
	RarityFilter.ZIndex = 3
	RarityFilter.AutoButtonColor = false
	RarityFilter.Text = ""
	RarityFilter.BackgroundColor3 = Library.Colors.RightSideBackground
	RarityFilter.Parent = RIghtSide
	Window.RarityFilter = RarityFilter

	local UICorner_1 = Instance.new("UICorner")
	UICorner_1.CornerRadius = UDim.new(0.00, 5.00)
	UICorner_1.Parent = RarityFilter
	Window.UICorner_1 = UICorner_1

	local UIStroke_1 = Instance.new("UIStroke")
	UIStroke_1.Color = Library.Colors.UIStroke
	UIStroke_1.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	UIStroke_1.BorderStrokePosition = Enum.BorderStrokePosition.Inner
	UIStroke_1.Thickness = 2
	UIStroke_1.Parent = RarityFilter
	Window.UIStroke_1 = UIStroke_1

	local TextLabel_1 = Instance.new("TextLabel")
	TextLabel_1.Active = true
	TextLabel_1.TextTruncate = Enum.TextTruncate.SplitWord
	TextLabel_1.BorderSizePixel = 0
	TextLabel_1.BackgroundColor3 = Color3.new(1.00, 1.00, 1.00)
	TextLabel_1.FontFace = gilroyExtraBold
	TextLabel_1.AnchorPoint = Vector2.new(0.50, 1.00)
	TextLabel_1.TextXAlignment = Enum.TextXAlignment.Left
	TextLabel_1.TextSize = 17
	TextLabel_1.Size = UDim2.new(1.00, -40.00, 1.00, -2.00)
	TextLabel_1.Selectable = true
	TextLabel_1.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
	TextLabel_1.Text = "Rarity Filter"
	TextLabel_1.TextColor3 = Library.Colors.UIStroke
	TextLabel_1.BackgroundTransparency = 1
	TextLabel_1.Position = UDim2.new(0.50, 0.00, 1.00, 0.00)
	TextLabel_1.Parent = RarityFilter
	Window.TextLabel_1 = TextLabel_1

	local UIPadding_1 = Instance.new("UIPadding")
	UIPadding_1.PaddingTop = UDim.new(0.00, 5.00)
	UIPadding_1.Parent = TextLabel_1
	Window.UIPadding_1 = UIPadding_1

	local OpenIcon_1 = Instance.new("ImageLabel")
	OpenIcon_1.Name = "OpenIcon"
	OpenIcon_1.ImageColor3 = Library.Colors.UIStroke
	OpenIcon_1.BorderSizePixel = 0
	OpenIcon_1.ScaleType = Enum.ScaleType.Fit
	OpenIcon_1.BackgroundColor3 = Color3.new(1.00, 1.00, 1.00)
	OpenIcon_1.AnchorPoint = Vector2.new(1.00, 0.50)
	OpenIcon_1.Image = getcustomasset(Library.Folders[2] .. "/" .. "DropDownIcon.png")
	OpenIcon_1.Size = UDim2.new(0.00, 15.00, 0.00, 11.00)
	OpenIcon_1.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
	OpenIcon_1.Rotation = 90
	OpenIcon_1.BackgroundTransparency = 1
	OpenIcon_1.Position = UDim2.new(1.00, -18.00, 0.50, 0.00)
	OpenIcon_1.Parent = RarityFilter
	Window.OpenIcon_1 = OpenIcon_1
	
	--// Open Rarity Tab
	local Frame = Instance.new("Frame")
	Frame.ClipsDescendants = true
	Frame.Visible = true
	Frame.ClipsDescendants = true
	Frame.Size = UDim2.new(0.00, 216.00, 0.00, 0)
	Frame.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
	Frame.Position = UDim2.new(0.00, -2.00, 0.00, 28.00)
	Frame.BorderSizePixel = 0
	Frame.ZIndex = 2
	Frame.BackgroundColor3 = Library.Colors.DarkBackground
	Frame.Parent = RIghtSide
	Window.Frame = Frame

	local UICorner_1 = Instance.new("UICorner")
	UICorner_1.CornerRadius = UDim.new(0.00, 5.00)
	UICorner_1.Parent = Frame
	Window.UICorner_1 = UICorner_1

	local Frame_1 = Instance.new("Frame")
	Frame_1.Size = UDim2.new(0.00, 210.00, 0.00, 100.00)
	Frame_1.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
	Frame_1.Position = UDim2.new(0.00, 2.00, 0.00, 0.00)
	Frame_1.BorderSizePixel = 0
	Frame_1.ZIndex = 2
	Frame_1.BackgroundColor3 = Library.Colors.RightSideBackground
	Frame_1.Parent = Frame
	Window.Frame_1 = Frame_1

	local UICorner_1 = Instance.new("UICorner")
	UICorner_1.CornerRadius = UDim.new(0.00, 5.00)
	UICorner_1.Parent = Frame_1
	Window.UICorner_1 = UICorner_1

	local UIPadding_1 = Instance.new("UIPadding")
	UIPadding_1.PaddingBottom = UDim.new(0.00, 10.00)
	UIPadding_1.PaddingTop = UDim.new(0.00, 12.00)
	UIPadding_1.PaddingLeft = UDim.new(0.00, 20.00)
	UIPadding_1.PaddingRight = UDim.new(0.00, 20.00)
	UIPadding_1.Parent = Frame_1
	Window.UIPadding_1 = UIPadding_1

	local ScrollingFrame = Instance.new("ScrollingFrame")
	ScrollingFrame.Active = true
	ScrollingFrame.ScrollingDirection = Enum.ScrollingDirection.Y
	ScrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	ScrollingFrame.BorderSizePixel = 0
	ScrollingFrame.CanvasSize = UDim2.new(0.00, 2.00, 0.00, 2.00)
	ScrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	ScrollingFrame.BackgroundColor3 = Color3.new(1.00, 1.00, 1.00)
	ScrollingFrame.Size = UDim2.new(1.00, 0.00, 1.00, 0.00)
	ScrollingFrame.ScrollBarImageColor3 = Library.Colors.UIStroke
	ScrollingFrame.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
	ScrollingFrame.ScrollBarThickness = 2
	ScrollingFrame.BackgroundTransparency = 1
	ScrollingFrame.Parent = Frame_1
	Window.ScrollingFrame = ScrollingFrame

	local UIListLayout_1 = Instance.new("UIListLayout")
	UIListLayout_1.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout_1.Parent = ScrollingFrame
	Window.UIListLayout_1 = UIListLayout_1
	
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
		RarityButton.Parent = ScrollingFrame

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
			TweenService:Create(OpenIcon_1, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Rotation = 0}):Play()
			TweenService:Create(Frame, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0.00, 216.00, 0.00, 104.00)}):Play()
		else
			TweenService:Create(OpenIcon_1, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Rotation = 90}):Play()
			TweenService:Create(Frame, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0.00, 216.00, 0.00, 0)}):Play()
		end
	end)

	RarityFilter.MouseEnter:Connect(function()
		TweenService:Create(TextLabel_1, TweenInfo.new(0.2), {TextColor3 = Library.Colors.HoverText}):Play()
		TweenService:Create(OpenIcon_1, TweenInfo.new(0.2), {ImageColor3 = Library.Colors.HoverText}):Play()
	end)

	RarityFilter.MouseLeave:Connect(function()
		TweenService:Create(TextLabel_1, TweenInfo.new(0.2), {TextColor3 = Library.Colors.UIStroke}):Play()
		TweenService:Create(OpenIcon_1, TweenInfo.new(0.2), {ImageColor3 = Library.Colors.UIStroke}):Play()
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

		local UIStroke = Instance.new("UIStroke")
		UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		UIStroke.BorderStrokePosition = Enum.BorderStrokePosition.Inner
		UIStroke.Color = Library.Colors.UIStroke
		UIStroke.Thickness = 2
		UIStroke.Parent = TabContainer
		UIStroke.Transparency = 1
		tabData.TabContainer = TabContainer

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
			SkinHolder.CanvasSize = UDim2.new(0.00, 0.00, 0.00, 0.00)
			SkinHolder.BackgroundColor3 = Color3.new(1.00, 1.00, 1.00)
			SkinHolder.Size = UDim2.new(1.00, 10.00, 1.00, -40.00)
			SkinHolder.ScrollBarImageColor3 = Color3.new(0.20, 0.21, 0.25)
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
				local _GunName = args.GunName or "GunName"
				local _SkinName = args.SkinName or "SkinName"
				local _SkinIcon = args.SkinIcon or "rbxassetid://1"
				local _Rarity = args.Rarity or "Stock"
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
				SkinVariant.BackgroundTransparency = 1
				SkinVariant.Parent = SkinHolder
				Skin.SkinVariant = SkinVariant

				local UICorner_1 = Instance.new("UICorner")
				UICorner_1.CornerRadius = UDim.new(0.00, 5.00)
				UICorner_1.Parent = SkinVariant

				local UIStroke_1 = Instance.new("UIStroke")
				UIStroke_1.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				UIStroke_1.BorderStrokePosition = Enum.BorderStrokePosition.Inner
				UIStroke_1.Color = Color3.fromRGB(175, 188, 224)
				UIStroke_1.Thickness = 2
				UIStroke_1.Transparency = 0.95
				UIStroke_1.Parent = SkinVariant
				Skin.UIStroke_1 = UIStroke_1

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

				SkinVariant.MouseButton1Click:Connect(function()
					local PrevSkin = OneSkin and tabData.SelectedSkin or SubTab.SubTabSelectedSkin
					if PrevSkin and PrevSkin ~= Skin then
						PrevSkin.Selected = false
						TweenService:Create(PrevSkin.UIStroke_1, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Transparency = 0.95, Color = Color3.fromRGB(175, 188, 224) }):Play()
						TweenService:Create(PrevSkin.SkinVariant, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Transparency = 1, BackgroundColor3 = Color3.fromRGB(127, 135, 157) }):Play()
						TweenService:Create(PrevSkin.SkinName, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextColor3 = Color3.fromRGB(135, 148, 183) }):Play()
						TweenService:Create(PrevSkin.GunName, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextColor3 = Color3.fromRGB(135, 148, 183) }):Play()
					end

					if OneSkin then
						if tabData.SelectedSkinSubTab and tabData.SelectedSkinSubTab ~= SubTab then
							tabData.SelectedSkinSubTab.SelectedSkin = nil
						end

						tabData.SelectedSkin = Skin
						tabData.SelectedSkinSubTab = SubTab
					else
						SubTab.SubTabSelectedSkin = Skin
					end

					Skin.Selected = true
					TweenService:Create(UIStroke_1, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Transparency = 0.85, Color = RarityColor }):Play()
					TweenService:Create(SkinVariant, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Transparency = 0.91, BackgroundColor3 = RarityColor }):Play()
					TweenService:Create(SkinName, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextColor3 = RarityColor }):Play()
					TweenService:Create(GunName, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextColor3 = RarityColor }):Play()

					_Callback(_GunName, _SkinName)
				end)

				SkinVariant.MouseEnter:Connect(function()
					if not Skin.Selected then
						TweenService:Create(UIStroke_1, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Transparency = 0.85 }):Play()
						TweenService:Create(SkinVariant, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Transparency = 0.91 }):Play()
					end
				end)

				SkinVariant.MouseLeave:Connect(function()
					if not Skin.Selected then
						TweenService:Create(UIStroke_1, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Transparency = 0.95 }):Play()
						TweenService:Create(SkinVariant, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Transparency = 1 }):Play()
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
				TweenService:Create(UIStroke, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Transparency = 0 }):Play()
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
				TweenService:Create(UIStroke, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Transparency = 1 }):Play()
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
	
	return Window
end

return Library
