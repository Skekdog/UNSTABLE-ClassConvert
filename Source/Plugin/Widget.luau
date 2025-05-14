local Selection = game:GetService("Selection")
local GetPlugin = require("../Lib/GetPlugin")
local Reflection = require("../Lib/Reflection")
local Convert = require("./Convert")

local plugin = GetPlugin

local module = {}

local colourSyncTargets: {GuiObject} = {}

local widget = plugin:CreateDockWidgetPluginGui("ClassConvert", DockWidgetPluginGuiInfo.new(
	Enum.InitialDockState.Float,
	false,
	true,
	600,
	400,
	600,
	400
	)
)

widget.Name = "Class Convert"
widget.Title = "Class Convert"
widget.ResetOnSpawn = false
widget.Enabled = false

local frame = Instance.new("Frame")
frame.Transparency = 1
frame.Size = UDim2.fromScale(1, 1)

do
	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0.025, 0)
	padding.PaddingRight = UDim.new(0.025, 0)
	padding.PaddingTop = UDim.new(0.025, 0)
	padding.Parent = frame
	
	local list = Instance.new("UIListLayout")
	list.Padding = UDim.new(0, 10)
	list.FillDirection = Enum.FillDirection.Vertical
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Parent = frame
	
	local separator = Instance.new("Frame")
	separator.BackgroundColor3 = Color3.new(0, 0, 0)
	separator.Size = UDim2.fromScale(1, 0.01)
	separator.Name = "Separator"
	separator.LayoutOrder = 3
	separator.Parent = frame
	table.insert(colourSyncTargets, separator)
end

local showDeprecatedFrame = Instance.new("Frame")
showDeprecatedFrame.BackgroundTransparency = 1
showDeprecatedFrame.Size = UDim2.fromScale(1, 0.075)
showDeprecatedFrame.LayoutOrder = 1
showDeprecatedFrame.Name = "ShowDeprecated"
showDeprecatedFrame.Parent = frame

local showDeprecatedButton = Instance.new("ImageButton")
showDeprecatedButton.BackgroundTransparency = 1
showDeprecatedButton.Image = if plugin:GetSetting("ShowDeprecated") then "rbxasset://studio_svg_textures/Shared/Utility/Light/Standard/CheckboxOn@3x.png" else "rbxasset://studio_svg_textures/Shared/Utility/Light/Standard/CheckboxOff@3x.png"
showDeprecatedButton.Name = "Checkbox"
showDeprecatedButton.Size = UDim2.fromScale(1, 1)
showDeprecatedButton.Parent = showDeprecatedFrame

do
	local label = Instance.new("TextLabel")
	label.Text = "Show Deprecated"
	label.TextScaled = true
	label.Font = Enum.Font.SourceSans
	label.BackgroundTransparency = 1
	label.Size = UDim2.fromScale(1, 1)
	label.Name = "Label"
	label.Parent = showDeprecatedFrame
	label.TextXAlignment = Enum.TextXAlignment.Left
	table.insert(colourSyncTargets, label)
	
	local list = Instance.new("UIListLayout")
	list.FillDirection = Enum.FillDirection.Horizontal
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Padding = UDim.new(0, 10)
	list.Parent = showDeprecatedFrame
	
	local aspectRatio = Instance.new("UIAspectRatioConstraint")
	aspectRatio.DominantAxis = Enum.DominantAxis.Height
	aspectRatio.Parent = showDeprecatedButton
end

local showNonBrowsableFrame = Instance.new("Frame")
showNonBrowsableFrame.BackgroundTransparency = 1
showNonBrowsableFrame.Size = UDim2.fromScale(1, 0.075)
showNonBrowsableFrame.LayoutOrder = 2
showNonBrowsableFrame.Name = "ShowNonBrowsable"
showNonBrowsableFrame.Parent = frame

local showNonBrowsableButton = Instance.new("ImageButton")
showNonBrowsableButton.BackgroundTransparency = 1
showNonBrowsableButton.Image = if showNonBrowsable then "rbxasset://studio_svg_textures/Shared/Utility/Light/Standard/CheckboxOn@3x.png" else "rbxasset://studio_svg_textures/Shared/Utility/Light/Standard/CheckboxOff@3x.png"
showNonBrowsableButton.Name = "Checkbox"
showNonBrowsableButton.Size = UDim2.fromScale(1, 1)
showNonBrowsableButton.Parent = showNonBrowsableFrame

do
	local label = Instance.new("TextLabel")
	label.Text = "Show Non-Browsable"
	label.TextScaled = true
	label.Font = Enum.Font.SourceSans
	label.BackgroundTransparency = 1
	label.Size = UDim2.fromScale(1, 1)
	label.Name = "Label"
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = showNonBrowsableFrame
	table.insert(colourSyncTargets, label)

	local list = Instance.new("UIListLayout")
	list.FillDirection = Enum.FillDirection.Horizontal
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Padding = UDim.new(0, 10)
	list.Parent = showNonBrowsableFrame

	local aspectRatio = Instance.new("UIAspectRatioConstraint")
	aspectRatio.DominantAxis = Enum.DominantAxis.Height
	aspectRatio.Parent = showNonBrowsableButton
end


local searchBar = Instance.new("TextBox")
searchBar.Font = Enum.Font.SourceSans
searchBar.AnchorPoint = Vector2.new(0.5, 0)
searchBar.Position = UDim2.fromScale(0.5, 0)
searchBar.Size = UDim2.fromScale(1, 0.1)
searchBar.Text = ""
searchBar.PlaceholderText = "Search..."
searchBar.TextScaled = true
searchBar.TextXAlignment = Enum.TextXAlignment.Left
searchBar.Name = "SearchBar"
searchBar.ClearTextOnFocus = false
searchBar.Parent = frame
table.insert(colourSyncTargets, searchBar)

do
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0.4, 0)
	corner.Parent = searchBar
	
	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 10)
	padding.Parent = searchBar
end

local resultsGrid = Instance.new("ScrollingFrame")
resultsGrid.BackgroundTransparency = 1
resultsGrid.Position = UDim2.new(0, 0, 0.11, 10)
resultsGrid.Size = UDim2.fromScale(1, 0.74)
resultsGrid.CanvasSize = UDim2.fromScale(0, 0)
resultsGrid.ScrollBarThickness = 6
resultsGrid.AutomaticCanvasSize = Enum.AutomaticSize.Y
resultsGrid.ScrollingDirection = Enum.ScrollingDirection.Y
resultsGrid.ScrollBarImageColor3 = Color3.new(0, 0, 0)
resultsGrid.BorderSizePixel = 4
resultsGrid.LayoutOrder = 4
resultsGrid.Name = "Results"
resultsGrid.Parent = frame
table.insert(colourSyncTargets, resultsGrid)

do
	local grid = Instance.new("UIGridLayout")
	grid.CellSize = UDim2.fromScale(1, 0.1)
	grid.SortOrder = Enum.SortOrder.LayoutOrder
	grid.Parent = resultsGrid
end

local resultBase = Instance.new("TextButton")
resultBase.Text = ""
resultBase.Name = "Result"

do
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0.25)
	corner.Parent = resultBase
	
	local list = Instance.new("UIListLayout")
	list.FillDirection = Enum.FillDirection.Horizontal
	list.Padding = UDim.new(0, 5)
	list.VerticalAlignment = Enum.VerticalAlignment.Center
	list.Parent = resultBase
	
	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 10)
	padding.Parent = resultBase
	
	local label = Instance.new("TextLabel")
	label.Font = Enum.Font.SourceSans
	label.TextScaled = true
	label.Size = UDim2.fromScale(1, 1)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.BackgroundTransparency = 1
	label.Name = "Label"
	label.Parent = resultBase
	
	local icon = Instance.new("ImageLabel")
	icon.Name = "Icon"
	icon.BackgroundTransparency = 1
	icon.Size = UDim2.fromScale(1, 0.9)
	icon.Image = ""
	icon.Parent = resultBase
	
	do
		local aspectRatio = Instance.new("UIAspectRatioConstraint")
		aspectRatio.DominantAxis = Enum.DominantAxis.Height
		aspectRatio.Parent = icon
	end
end

frame.Parent = widget

local function convert(to: string): ()
	local result = Convert.ConvertMany(Selection:Get(), to)
	if result then
		Selection:Set(result)
	end
end

local function addClass(class: Reflection.Class): ()
	local result = resultBase:Clone();
	(result:FindFirstChild("Label") :: TextLabel).Text = class.Name
	result:SetAttribute("Deprecated", false)
	result:SetAttribute("NonBrowsable", false)
	result.Name = class.Name
	result.Parent = resultsGrid
	table.insert(colourSyncTargets, result)
	table.insert(colourSyncTargets, result:FindFirstChild("Label") :: TextLabel)
	table.insert(colourSyncTargets, result:FindFirstChild("Icon") :: ImageLabel)
	result.MouseButton1Click:Connect(function()
		convert(class.Name)
	end)
end

function module.PopulateClasses(classes: {Reflection.Class}): ()
	for _, class in classes do
		addClass(class)
	end
end

function module.ToggleWidget(enabled: boolean?): ()
	widget.Enabled = if typeof(enabled) == "boolean" then enabled else not widget.Enabled

	if widget.Enabled then
		searchBar:CaptureFocus()
	end
end

module.Widget = widget

return module