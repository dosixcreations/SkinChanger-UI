local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Library = {}

if not isfolder("PypsCC_SkinChanger") then
    makefolder("PypsCC_SkinChanger")
end

if not isfolder("PypsCC_SkinChanger/Assets") then
    makefolder("PypsCC_SkinChanger/Assets")
end

if not isfile("PypsCC_SkinChanger/Assets/Dropdown_Icon.png") then
    local _success, _errorMessage = pcall(function()
        local imageData = game:HttpGet("https://raw.githubusercontent.com/dosixcreations/SkinChanger-UI/main/Dropdown_Icon.png")
        writefile("PypsCC_SkinChanger/Assets/Dropdown_Icon.png", imageData)
    end)
end

function Library:CreateWindow(args)
	local args = args or {}
	
	local window = {}
	window._tabs = {}
	window._tweens = {}
	window.ActiveSubTab = nil
	
	local screengui = Instance.new("ScreenGui")
	screengui.Name = ""
	screengui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screengui.Parent = gethui()

	window.MainFrame = Instance.new("Frame")
	window.MainFrame.Name = "MainFrame"
	window.MainFrame.AnchorPoint = Vector2.new(0.50, 0.50)
	window.MainFrame.Size = UDim2.new(0.00, 500.00, 0.00, 350.00)
	window.MainFrame.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
	window.MainFrame.Position = UDim2.new(0.50, 0.00, 0.50, 0.00)
	window.MainFrame.BorderSizePixel = 0
	window.MainFrame.BackgroundColor3 = Color3.new(0.08, 0.08, 0.08)
	window.MainFrame.Parent = screengui

	window.UIScale = Instance.new("UIScale")
	window.UIScale.Scale = 0.94
	window.UIScale.Parent = window.MainFrame

	window.UICorner = Instance.new("UICorner")
	window.UICorner.CornerRadius = UDim.new(0.00, 10.00)
	window.UICorner.Parent = window.MainFrame

	window.LeftHolder = Instance.new("Frame")
	window.LeftHolder.Name = "LeftHolder"
	window.LeftHolder.Interactable = true
	window.LeftHolder.Size = UDim2.new(0.30, 0.00, 1.00, 0.00)
	window.LeftHolder.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
	window.LeftHolder.BorderSizePixel = 0
	window.LeftHolder.BackgroundColor3 = Color3.new(0.08, 0.08, 0.08)
	window.LeftHolder.Parent = window.MainFrame
	
	window.TypeHolder = Instance.new("Frame")
	window.TypeHolder.Name = "TypeHolder"
	window.TypeHolder.Size = UDim2.new(1.00, -20.00, 1.00, -70.00)
	window.TypeHolder.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
	window.TypeHolder.Position = UDim2.new(0.00, 10.00, 0.00, 60.00)
	window.TypeHolder.BorderSizePixel = 0
	window.TypeHolder.BackgroundTransparency = 1
	window.TypeHolder.BackgroundColor3 = Color3.new(1.00, 1.00, 1.00)
	window.TypeHolder.Parent = window.LeftHolder

	window.TypeLabel = Instance.new("TextLabel")
	window.TypeLabel.Name = "TypeLabel"
	window.TypeLabel.BorderSizePixel = 0
	window.TypeLabel.TextYAlignment = Enum.TextYAlignment.Top
	window.TypeLabel.BackgroundColor3 = Color3.new(1.00, 1.00, 1.00)
	window.TypeLabel.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	window.TypeLabel.TextXAlignment = Enum.TextXAlignment.Left
	window.TypeLabel.TextSize = 14
	window.TypeLabel.Size = UDim2.new(1.00, 0.00, 1.00, 0.00)
	window.TypeLabel.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
	window.TypeLabel.Text = "Type"
	window.TypeLabel.TextColor3 = Color3.new(0.50, 0.50, 0.50)
	window.TypeLabel.BackgroundTransparency = 1
	window.TypeLabel.Parent = window.TypeHolder

	window.HolderForTypes = Instance.new("Frame")
	window.HolderForTypes.Name = "HolderForTypes"
	window.HolderForTypes.Size = UDim2.new(1.00, 0.00, 1.00, -16.00)
	window.HolderForTypes.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
	window.HolderForTypes.Position = UDim2.new(0.00, 0.00, 0.00, 16.00)
	window.HolderForTypes.BorderSizePixel = 0
	window.HolderForTypes.BackgroundTransparency = 1
	window.HolderForTypes.BackgroundColor3 = Color3.new(1.00, 1.00, 1.00)
	window.HolderForTypes.Parent = window.TypeHolder

	window.ScrollingFrame = Instance.new("ScrollingFrame")
	window.ScrollingFrame.Active = false
	window.ScrollingFrame.ScrollingDirection = Enum.ScrollingDirection.Y
	window.ScrollingFrame.BorderSizePixel = 0
	window.ScrollingFrame.CanvasSize = UDim2.new(0.00, 0.00, 0.00, 0.00)
	window.ScrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	window.ScrollingFrame.BackgroundColor3 = Color3.new(1.00, 1.00, 1.00)
	window.ScrollingFrame.Size = UDim2.new(1.00, 0.00, 1.00, -15.00)
	window.ScrollingFrame.ScrollBarImageColor3 = Color3.new(0.50, 0.50, 0.50)
	window.ScrollingFrame.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
	window.ScrollingFrame.ScrollBarThickness = 2
	window.ScrollingFrame.BackgroundTransparency = 1
	window.ScrollingFrame.Position = UDim2.new(0.00, 0.00, 0.00, 15.00)
	window.ScrollingFrame.Parent = window.TypeHolder
	
	window.UICorner_1 = Instance.new("UICorner")
	window.UICorner_1.CornerRadius = UDim.new(0.00, 10.00)
	window.UICorner_1.Parent = window.LeftHolder

	window.Frame = Instance.new("Frame")
	window.Frame.Size = UDim2.new(0.70, 0.00, 1.00, 0.00)
	window.Frame.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
	window.Frame.Position = UDim2.new(0.30, 0.00, 0.00, 0.00)
	window.Frame.BorderSizePixel = 0
	window.Frame.BackgroundTransparency = 1
	window.Frame.BackgroundColor3 = Color3.new(1.00, 1.00, 1.00)
	window.Frame.Parent = window.MainFrame

	window.SearchBarHolder = Instance.new("Frame")
	window.SearchBarHolder.Name = "window.SearchBarHolder"
	window.SearchBarHolder.Interactable = false
	window.SearchBarHolder.Size = UDim2.new(1.00, -20.00, 0.00, 40.00)
	window.SearchBarHolder.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
	window.SearchBarHolder.Position = UDim2.new(0.00, 10.00, 0.00, 10.00)
	window.SearchBarHolder.BorderSizePixel = 0
	window.SearchBarHolder.BackgroundTransparency = 1
	window.SearchBarHolder.BackgroundColor3 = Color3.new(1.00, 1.00, 1.00)
	window.SearchBarHolder.Parent = window.LeftHolder

	window.SearchBarLabel = Instance.new("TextLabel")
	window.SearchBarLabel.Name = "window.SearchBarLabel"
	window.SearchBarLabel.BorderSizePixel = 0
	window.SearchBarLabel.TextYAlignment = Enum.TextYAlignment.Top
	window.SearchBarLabel.BackgroundColor3 = Color3.new(1.00, 1.00, 1.00)
	window.SearchBarLabel.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	window.SearchBarLabel.TextXAlignment = Enum.TextXAlignment.Left
	window.SearchBarLabel.TextSize = 14
	window.SearchBarLabel.Size = UDim2.new(1.00, 0.00, 1.00, 0.00)
	window.SearchBarLabel.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
	window.SearchBarLabel.Text = "Skin Search"
	window.SearchBarLabel.TextColor3 = Color3.new(0.50, 0.50, 0.50)
	window.SearchBarLabel.BackgroundTransparency = 1
	window.SearchBarLabel.Parent = window.SearchBarHolder

	window.TextBoxHolder = Instance.new("Frame")
	window.TextBoxHolder.Name = "window.TextBoxHolder"
	window.TextBoxHolder.AnchorPoint = Vector2.new(0.00, 1.00)
	window.TextBoxHolder.Size = UDim2.new(1.00, 0.00, 1.00, -16.00)
	window.TextBoxHolder.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
	window.TextBoxHolder.Position = UDim2.new(0.00, 0.00, 1.00, 0.00)
	window.TextBoxHolder.BorderSizePixel = 0
	window.TextBoxHolder.BackgroundColor3 = Color3.new(0.12, 0.12, 0.12)
	window.TextBoxHolder.Parent = window.SearchBarHolder
	
	window.UICorner_1 = Instance.new("UICorner")
	window.UICorner_1.CornerRadius = UDim.new(0.00, 7.00)
	window.UICorner_1.Parent = window.TextBoxHolder
	
	window.UIStroke = Instance.new("UIStroke")
	window.UIStroke.Color = Color3.new(0.62, 0.62, 0.62)
	window.UIStroke.Parent = window.TextBoxHolder

	window.NameTextBox = Instance.new("TextBox")
	window.NameTextBox.Name = "NameTextBox"
	window.NameTextBox.TextTruncate = Enum.TextTruncate.SplitWord
	window.NameTextBox.BorderSizePixel = 0
	window.NameTextBox.BackgroundColor3 = Color3.new(1.00, 1.00, 1.00)
	window.NameTextBox.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	window.NameTextBox.AnchorPoint = Vector2.new(0.50, 0.50)
	window.NameTextBox.TextSize = 14
	window.NameTextBox.Size = UDim2.new(1.00, 0.00, 1.00, 0.00)
	window.NameTextBox.TextColor3 = Color3.new(1.00, 1.00, 1.00)
	window.NameTextBox.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
	window.NameTextBox.Text = ""
	window.NameTextBox.TextEditable = true
	window.NameTextBox.ClearTextOnFocus = false
	window.NameTextBox.TextWrapped = true
	window.NameTextBox.Active = true
	window.NameTextBox.PlaceholderText = "Name"
	window.NameTextBox.TextXAlignment = Enum.TextXAlignment.Left
	window.NameTextBox.BackgroundTransparency = 1
	window.NameTextBox.Position = UDim2.new(0.50, 0.00, 0.50, 0.00)
	window.NameTextBox.Parent = window.TextBoxHolder
	window.NameTextBox.ZIndex = 2

	window.UIPadding = Instance.new("UIPadding")
	window.UIPadding.PaddingLeft = UDim.new(0.00, 5.00)
	window.UIPadding.PaddingRight = UDim.new(0.00, 5.00)
	window.UIPadding.Parent = window.NameTextBox

	window.DragHandle = Instance.new("TextButton")
	window.DragHandle.Name = "DragHandle"
	window.DragHandle.Active = true
	window.DragHandle.AutoButtonColor = false
	window.DragHandle.BackgroundTransparency = 1
	window.DragHandle.BorderSizePixel = 0
	window.DragHandle.Position = UDim2.new(0.30, 0, 0, 0)
	window.DragHandle.Size = UDim2.new(0.70, 0, 0, 50)
	window.DragHandle.Text = ""
	window.DragHandle.ZIndex = 10
	window.DragHandle.Parent = window.MainFrame

	local dragStartPosition
	local dragStartInputPosition
	local dragging = false
	local dragTween
	local dragTweenInfo = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	local function getClampedWindowCenter(center)
		local viewportSize = workspace.CurrentCamera.ViewportSize
		local halfWindowSize = window.MainFrame.AbsoluteSize / 2

		return Vector2.new(
			math.clamp(center.X, halfWindowSize.X, viewportSize.X - halfWindowSize.X),
			math.clamp(center.Y, halfWindowSize.Y, viewportSize.Y - halfWindowSize.Y)
		)
	end

	local function updateWindowPosition(inputPosition)
		local currentInputPosition = Vector2.new(inputPosition.X, inputPosition.Y)
		local offset = currentInputPosition - dragStartInputPosition
		local targetCenter = getClampedWindowCenter(dragStartPosition + offset)

		if dragTween then
			dragTween:Cancel()
		end

		dragTween = TweenService:Create(window.MainFrame, {
			Position = UDim2.fromOffset(targetCenter.X, targetCenter.Y)
		}, dragTweenInfo)
		dragTween:Play()
	end

	window.DragHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStartInputPosition = Vector2.new(input.Position.X, input.Position.Y)
			dragStartPosition = window.MainFrame.AbsolutePosition + (window.MainFrame.AbsoluteSize / 2)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch) then
			updateWindowPosition(input.Position)
		end
	end)

	UserInputService.InputBegan:Connect(function(input)
		if input.KeyCode == Enum.KeyCode.RightShift then
			window.MainFrame.Visible = not window.MainFrame.Visible
		end
	end)
	
	function window:_Tween(object, properties, info)
		info = info or TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

		if self._tweens[object] then
			self._tweens[object]:Cancel()
		end

		local tween = TweenService:Create(object, info, properties)
		self._tweens[object] = tween

		tween.Completed:Connect(function()
			if self._tweens[object] == tween then
				self._tweens[object] = nil
			end
		end)

		tween:Play()
		return tween
	end

	window:_Tween(window.UIScale, {
		Scale = 1
	}, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out))

	function window:_RelayoutTabs(animated)
		local y = 0
		local layoutTweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

		for _, tab in ipairs(self._tabs) do
			local subCount = #tab._subTabOrder
			local subHeight = tab.Open and (subCount * 25) or 0

			local tabPosition = UDim2.new(
				0, 0,
				0, y
			)

			local holderSize = UDim2.new(
				1, 0,
				0, subHeight
			)

			if animated then
				self:_Tween(tab.Tab, {
					Position = tabPosition
				}, layoutTweenInfo)

				self:_Tween(tab.SubTabsHolder, {
					Size = holderSize
				}, layoutTweenInfo)

				self:_Tween(tab.ImageLabel, {
					Rotation = tab.Open and 90 or 0
				}, layoutTweenInfo)
			else
				tab.Tab.Position = tabPosition
				tab.SubTabsHolder.Size = holderSize
				tab.ImageLabel.Rotation = tab.Open and 90 or 0
			end

			for index, subTab in ipairs(tab._subTabOrder) do
				local subY = (index - 1) * 25

				if animated then
					self:_Tween(subTab.SubTab, {
						Position = UDim2.new(0, 0, 0, subY)
					}, layoutTweenInfo)
				else
					subTab.SubTab.Position = UDim2.new(0, 0, 0, subY)
				end
			end

			y += 25 + subHeight
		end

		local canvasSize = UDim2.new(0, 0, 0, y)

		if animated then
			self:_Tween(self.ScrollingFrame, {
				CanvasSize = canvasSize
			}, layoutTweenInfo)
		else
			self.ScrollingFrame.CanvasSize = canvasSize
		end
	end
	
	function window:CreateTab(args)
		args = args or {}
		local name = args.Name or "Tab"
		local subTabs = args.SubTabs or {"1", "2"}
		local oneSkin = args.OneSkin == true
		
		local tab = {}

		tab.Open = false
		tab.OneSkin = oneSkin
		tab.Tabs = {}
		tab._subTabOrder = {}
		tab.SelectedSkin = nil
		tab.SelectedSkinSubTab = nil
		
		tab.Tab = Instance.new("TextButton")
		tab.Tab.Name = "Tab"
		tab.Tab.BorderSizePixel = 0
		tab.Tab.AutoButtonColor = false
		tab.Tab.BackgroundColor3 = Color3.new(0.08, 0.08, 0.08)
		tab.Tab.Size = UDim2.new(1.00, 0.00, 0.00, 25.00)
		tab.Tab.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
		tab.Tab.Text = ""
		tab.Tab.Parent = window.ScrollingFrame

		tab.TabName = Instance.new("TextLabel")
		tab.TabName.Name = "TabName"
		tab.TabName.BorderSizePixel = 0
		tab.TabName.BackgroundColor3 = Color3.new(1.00, 1.00, 1.00)
		tab.TabName.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal)
		tab.TabName.TextXAlignment = Enum.TextXAlignment.Left
		tab.TabName.TextSize = 14
		tab.TabName.Size = UDim2.new(1.00, 0.00, 1.00, 0.00)
		tab.TabName.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
		tab.TabName.Text = name
		tab.TabName.TextColor3 = Color3.new(0.50, 0.50, 0.50)
		tab.TabName.BackgroundTransparency = 1
		tab.TabName.Parent = tab.Tab

		tab.UICorner_1 = Instance.new("UICorner")
		tab.UICorner_1.CornerRadius = UDim.new(0.00, 7.00)
		tab.UICorner_1.Parent = tab.Tab

		tab.UIPadding_1 = Instance.new("UIPadding")
		tab.UIPadding_1.PaddingLeft = UDim.new(0.00, 5.00)
		tab.UIPadding_1.PaddingRight = UDim.new(0.00, 5.00)
		tab.UIPadding_1.Parent = tab.Tab

		tab.ImageLabel = Instance.new("ImageLabel")
		tab.ImageLabel.BorderSizePixel = 0
		tab.ImageLabel.BackgroundColor3 = Color3.new(1.00, 1.00, 1.00)
		tab.ImageLabel.AnchorPoint = Vector2.new(1.00, 0.50)
		tab.ImageLabel.Image = getcustomasset("PypsCC_SkinChanger/Assets/Dropdown_Icon.png")
		tab.ImageLabel.Size = UDim2.new(0.00, 10.00, 0.00, 10.00)
		tab.ImageLabel.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
		tab.ImageLabel.BackgroundTransparency = 1
		tab.ImageLabel.Position = UDim2.new(1.00, 0.00, 0.50, 0.00)
        tab.ImageLabel.Rotation = 90
		tab.ImageLabel.Parent = tab.Tab

		tab.SubTabsHolder = Instance.new("Frame")
		tab.SubTabsHolder.Name = "window.SubTabsHolder"
		tab.SubTabsHolder.Size = UDim2.new(1.00, 0.00, 0, 0.00)
		tab.SubTabsHolder.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
		tab.SubTabsHolder.Position = UDim2.new(0.00, 0.00, 1.00, 0.00)
		tab.SubTabsHolder.BorderSizePixel = 0
		tab.SubTabsHolder.BackgroundTransparency = 1
		tab.SubTabsHolder.BackgroundColor3 = Color3.new(1.00, 1.00, 1.00)
		tab.SubTabsHolder.ClipsDescendants = true
		tab.SubTabsHolder.Parent = tab.Tab
		
		tab.Line = Instance.new("Frame")
		tab.Line.Name = "Line"
		tab.Line.AnchorPoint = Vector2.new(0.00, 0.50)
		tab.Line.Size = UDim2.new(0.00, 1.00, 0.90, 0)
		tab.Line.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
		tab.Line.Position = UDim2.new(0.00, 0.00, 0.50, 0.00)
		tab.Line.BorderSizePixel = 0
		tab.Line.BackgroundColor3 = Color3.new(0.17, 0.17, 0.17)
		tab.Line.Parent = tab.SubTabsHolder
		
		table.insert(window._tabs, tab)
		
		tab.Tab.MouseButton1Click:Connect(function()
			tab.Open = not tab.Open
			if tab.Open then
				tab.ImageLabel.Rotation = 0
				tab.Tab.BackgroundColor3 = Color3.new(0.17, 0.17, 0.17)
			else
				tab.ImageLabel.Rotation = 90
				tab.Tab.BackgroundColor3 = Color3.new(0.08, 0.08, 0.08)
			end
			window:_RelayoutTabs(true)
		end)
		
		tab.Tab.MouseEnter:Connect(function()
			window:_Tween(tab.Tab, {
				BackgroundColor3 = Color3.new(0.13, 0.13, 0.13)
			})
		end)

		tab.Tab.MouseLeave:Connect(function()
			window:_Tween(tab.Tab, {
				BackgroundColor3 = tab.Open
					and Color3.new(0.17, 0.17, 0.17)
					or Color3.new(0.08, 0.08, 0.08)
			})
		end)
		
		function tab:CreateSubTab(args)
			args = args or {}
			local name = args.Name or "SubTab"
			
			local subTab = {}
			subTab.Active = false
			subTab.SelectedSkin = nil
			
			subTab.SubTab = Instance.new("Frame")
			subTab.SubTab.Name = "SubTab"
			subTab.SubTab.Size = UDim2.new(1.00, 0.00, 0.00, 25.00)
			subTab.SubTab.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
			subTab.SubTab.BorderSizePixel = 0
			subTab.SubTab.BackgroundTransparency = 1
			subTab.SubTab.BackgroundColor3 = Color3.new(1.00, 1.00, 1.00)
			subTab.SubTab.Parent = tab.SubTabsHolder

			subTab.TextButton = Instance.new("TextButton")
			subTab.TextButton.BorderSizePixel = 0
			subTab.TextButton.AutoButtonColor = false
			subTab.TextButton.BackgroundColor3 = Color3.new(1.00, 1.00, 1.00)
			subTab.TextButton.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
			subTab.TextButton.TextSize = 14
			subTab.TextButton.Size = UDim2.new(1.00, 0.00, 0.00, 25.00)
			subTab.TextButton.TextColor3 = Color3.new(0.50, 0.50, 0.50)
			subTab.TextButton.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
			subTab.TextButton.Text = name
			subTab.TextButton.BackgroundTransparency = 1
			subTab.TextButton.TextXAlignment = Enum.TextXAlignment.Left
			subTab.TextButton.Parent = subTab.SubTab

			subTab.UIPadding_1 = Instance.new("UIPadding")
			subTab.UIPadding_1.PaddingLeft = UDim.new(0.00, 6.00)
			subTab.UIPadding_1.PaddingRight = UDim.new(0.00, 5.00)
			subTab.UIPadding_1.Parent = subTab.TextButton
			
			subTab.SkinsSelectorHolder = Instance.new("ScrollingFrame")
			subTab.SkinsSelectorHolder.Name = "SkinsSelectorHolder"
			subTab.SkinsSelectorHolder.ScrollingDirection = Enum.ScrollingDirection.Y
			subTab.SkinsSelectorHolder.BorderSizePixel = 0
			subTab.SkinsSelectorHolder.CanvasSize = UDim2.new(0.00, 0.00, 0.00, 0.00)
			subTab.SkinsSelectorHolder.AutomaticCanvasSize = Enum.AutomaticSize.Y
			subTab.SkinsSelectorHolder.BackgroundColor3 = Color3.new(1.00, 1.00, 1.00)
			subTab.SkinsSelectorHolder.Size = UDim2.new(1.00, 0.00, 1.00, -50.00)
			subTab.SkinsSelectorHolder.ScrollBarImageColor3 = Color3.new(0.50, 0.50, 0.50)
			subTab.SkinsSelectorHolder.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
			subTab.SkinsSelectorHolder.ScrollBarThickness = 2
			subTab.SkinsSelectorHolder.BackgroundTransparency = 1
			subTab.SkinsSelectorHolder.Position = UDim2.new(0.00, 0.00, 0.00, 50.00)
			subTab.SkinsSelectorHolder.Parent = window.Frame
			subTab.SkinsSelectorHolder.Visible = false

			subTab.UIPadding_1 = Instance.new("UIPadding")
			subTab.UIPadding_1.PaddingRight = UDim.new(0.00, 4.00)
			subTab.UIPadding_1.Parent = subTab.SkinsSelectorHolder

			subTab.UIGridLayout = Instance.new("UIGridLayout")
			subTab.UIGridLayout.CellPadding = UDim2.new(0.00, 2.00, 0.00, 2.00)
			subTab.UIGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
			subTab.UIGridLayout.CellSize = UDim2.new(0.00, 80.00, 0.00, 80.00)
			subTab.UIGridLayout.Parent = subTab.SkinsSelectorHolder
			
			subTab.TextButton.MouseEnter:Connect(function()
				window:_Tween(subTab.TextButton, {
					TextColor3 = Color3.new(0.75, 0.75, 0.75)
				})
			end)

			subTab.TextButton.MouseLeave:Connect(function()
				window:_Tween(subTab.TextButton, {
					TextColor3 = subTab.Active
						and Color3.new(1, 1, 1)
						or Color3.new(0.50, 0.50, 0.50)
				})
			end)
			
			subTab.TextButton.MouseButton1Click:Connect(function()
				-- close old subtab anywhere in the window
				if window.ActiveSubTab then
					window.ActiveSubTab.Active = false

					if window.ActiveSubTab.SkinsSelectorHolder then
						window.ActiveSubTab.SkinsSelectorHolder.Visible = false
					end

					window:_Tween(window.ActiveSubTab.TextButton, {
						TextColor3 = Color3.new(0.50, 0.50, 0.50)
					})
				end

				-- open this subtab
				window.ActiveSubTab = subTab
				subTab.Active = true

				if subTab.SkinsSelectorHolder then
					subTab.SkinsSelectorHolder.Visible = true
				end

				window:_Tween(subTab.TextButton, {
					TextColor3 = Color3.new(1, 1, 1)
				})
			end)
			
			subTab.Name = name
			table.insert(tab._subTabOrder, subTab)
			tab.Tabs[name] = subTab
			tab[name] = subTab
			subTab.TextButton.Text = name
			window:_RelayoutTabs(false)
			
			function subTab:CreateSkin(args)
				args = args or {}
				local Gun = args.GunName or "GunName"
				local SkinName = args.SkinName or "SkinName"
				local SkinIcon = args.SkinIcon or "rbxassetid://1"
				local Rarity = args.Rarity or "Blue"
				local Callback = args.Callback or function() end
				
				local Skin = {}
				
				Skin.SkinTemplate = Instance.new("TextButton")
				Skin.SkinTemplate.Name = "SkinTemplate"
				Skin.SkinTemplate.BorderSizePixel = 0
				Skin.SkinTemplate.AutoButtonColor = false
				Skin.SkinTemplate.BackgroundColor3 = Color3.new(0.17, 0.17, 0.17)
				Skin.SkinTemplate.Size = UDim2.new(0.00, 100.00, 0.00, 100.00)
				Skin.SkinTemplate.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
				Skin.SkinTemplate.Text = ""
				Skin.SkinTemplate.BackgroundTransparency = 1
				Skin.SkinTemplate.Parent = subTab.SkinsSelectorHolder

				Skin.SkinName = Instance.new("TextLabel")
				Skin.SkinName.Name = "SkinName"
				Skin.SkinName.ZIndex = 2
				Skin.SkinName.BorderSizePixel = 0
				Skin.SkinName.TextYAlignment = Enum.TextYAlignment.Top
				Skin.SkinName.BackgroundColor3 = Color3.new(1.00, 1.00, 1.00)
				Skin.SkinName.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
				Skin.SkinName.TextXAlignment = Enum.TextXAlignment.Left
				Skin.SkinName.TextSize = 12
				Skin.SkinName.Size = UDim2.new(1.00, 0.00, 1.00, 0.00)
				Skin.SkinName.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
				Skin.SkinName.Text = SkinName
				Skin.SkinName.TextColor3 = Color3.new(1.00, 1.00, 1.00)
				Skin.SkinName.BackgroundTransparency = 1
				Skin.SkinName.Parent = Skin.SkinTemplate

				Skin.UIPadding_1 = Instance.new("UIPadding")
				Skin.UIPadding_1.PaddingLeft = UDim.new(0.00, 2.00)
				Skin.UIPadding_1.Parent = Skin.SkinName

				Skin.UIPadding_1 = Instance.new("UIPadding")
				Skin.UIPadding_1.PaddingBottom = UDim.new(0.00, 2.00)
				Skin.UIPadding_1.PaddingTop = UDim.new(0.00, 2.00)
				Skin.UIPadding_1.PaddingLeft = UDim.new(0.00, 2.00)
				Skin.UIPadding_1.PaddingRight = UDim.new(0.00, 2.00)
				Skin.UIPadding_1.Parent = Skin.SkinTemplate

				Skin.SkinIcon = Instance.new("ImageLabel")
				Skin.SkinIcon.Name = "SkinIcon"
				Skin.SkinIcon.BorderSizePixel = 0
				Skin.SkinIcon.BackgroundColor3 = Color3.new(1.00, 1.00, 1.00)
				Skin.SkinIcon.ImageTransparency = 0
				Skin.SkinIcon.AnchorPoint = Vector2.new(0.50, 0.50)
				Skin.SkinIcon.Image = SkinIcon
				Skin.SkinIcon.Size = UDim2.new(0.85, 0.00, 0.85, 0.00)
				Skin.SkinIcon.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
				Skin.SkinIcon.BackgroundTransparency = 1
				Skin.SkinIcon.Position = UDim2.new(0.50, 0.00, 0.50, 0.00)
				Skin.SkinIcon.Parent = Skin.SkinTemplate

				Skin.UICorner_1 = Instance.new("UICorner")
				Skin.UICorner_1.CornerRadius = UDim.new(0.00, 7.00)
				Skin.UICorner_1.Parent = Skin.SkinTemplate
				Skin.Hovered = false
				Skin.Selected = false

				local function getSkinTransparency()
					if Skin.Selected then
						return 0.45
					end

					return Skin.Hovered and 0.78 or 1
				end

				local function animateSkin(transparency, info)
					window:_Tween(Skin.SkinTemplate, {
						BackgroundTransparency = transparency
					}, info)
				end

				Skin.SkinTemplate.MouseEnter:Connect(function()
					Skin.Hovered = true
					animateSkin(getSkinTransparency())
				end)

				Skin.SkinTemplate.MouseLeave:Connect(function()
					Skin.Hovered = false
					animateSkin(getSkinTransparency())
				end)

				Skin.SkinTemplate.MouseButton1Down:Connect(function()
					animateSkin(0.58, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out))
				end)

				Skin.SkinTemplate.MouseButton1Up:Connect(function()
					animateSkin(getSkinTransparency(), TweenInfo.new(0.14, Enum.EasingStyle.Back, Enum.EasingDirection.Out))
				end)
				
				Skin.SkinTemplate.MouseButton1Click:Connect(function()
					local previousSkin = tab.OneSkin and tab.SelectedSkin or subTab.SelectedSkin

					if previousSkin and previousSkin ~= Skin then
						previousSkin.Selected = false
						window:_Tween(previousSkin.SkinTemplate, {
							BackgroundTransparency = previousSkin.Hovered and 0.78 or 1
						})
					end

					if tab.OneSkin then
						if tab.SelectedSkinSubTab and tab.SelectedSkinSubTab ~= subTab then
							tab.SelectedSkinSubTab.SelectedSkin = nil
						end

						tab.SelectedSkin = Skin
						tab.SelectedSkinSubTab = subTab
					else
						subTab.SelectedSkin = Skin
					end

					Skin.Selected = true
					animateSkin(0.45, TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out))

					if Callback then
						Callback(Gun, SkinName)
					end
				end)
				
				return Skin
			end

			return subTab
		end
		
		for _, subTabName in pairs(subTabs or {}) do
			tab:CreateSubTab({Name = subTabName})
		end
		
		return tab
	end
	
	return window
end

return Library
