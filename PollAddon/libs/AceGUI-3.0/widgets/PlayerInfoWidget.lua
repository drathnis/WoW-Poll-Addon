--[[-----------------------------------------------------------------------------
Frame Container
-------------------------------------------------------------------------------]]
local Type, Version = "PlayerInfo", 30
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

-- Lua APIs
local pairs, assert, type = pairs, assert, type
local wipe = table.wipe

-- WoW APIs
local PlaySound = PlaySound
local CreateFrame, UIParent = CreateFrame, UIParent

-- Global vars/functions that we don't upvalue since they might get hooked, or upgraded
-- List them here for Mikk's FindGlobals script
-- GLOBALS: CLOSE

--[[-----------------------------------------------------------------------------
Scripts
-------------------------------------------------------------------------------]]
local function Button_OnClick(frame)
	PlaySound(799) -- SOUNDKIT.GS_TITLE_OPTION_EXIT
	frame.obj:Hide()
end

local function Frame_OnShow(frame)
	frame.obj:Fire("OnShow")
end

local function Frame_OnClose(frame)
	frame.obj:Fire("OnClose")
end


local function Frame_OnMouseDown(frame)
	print("MOUSE DOWN")
	AceGUI:ClearFocus()
end

local function SizerE_OnMouseDown(frame)
	frame:GetParent():StartSizing("RIGHT")
	AceGUI:ClearFocus()
end

local function StatusBar_OnEnter(frame)
	frame.obj:Fire("OnEnterStatusBar")
end

local function StatusBar_OnLeave(frame)
	frame.obj:Fire("OnLeaveStatusBar")
end

local function checkButtonTest(frame)
	print("Toggle")
end


--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
local methods = {

	["SetText"] = function(self, name)
		self.nameTextFrame.text:SetText(name)
		--self.titlebg:SetWidth((self.textFrame:GetWidth() or 0) + 10)
	end,

	["SetColor"] = function(self, RGB)
		self.nameTextFrame.text:SetTextColor(RGB[1],RGB[2],RGB[3],1)
	end,

	["SetVoted"] = function(self, hasVoted)
		--if  hasVoted then
			self.checkButton:SetChecked(hasVoted)
		-- else
		-- 	self.checkButton:
		-- end

	end,
	
	["SetAddonState"] = function(self, hasAddon)
		if  hasAddon then
			self.nameTextFrame.text:SetTextColor(0,1,.5,1)
		else
			self.nameTextFrame.text:SetTextColor(1,.5,0,1)
		end

	end,

	["OnAcquire"] = function(self)
		self.frame:SetParent(UIParent)
		self.frame:SetFrameStrata("FULLSCREEN_DIALOG")
		self.frame:SetFrameLevel(100) -- Lots of room to draw under it
		self:ApplyStatus()
		self:Show()
	end,

	["OnRelease"] = function(self)
		self.status = nil
		wipe(self.localstatus)
	end,

	["OnWidthSet"] = function(self, width)
		local content = self.content
		local contentwidth = width - 34
		if contentwidth < 0 then
			contentwidth = 0
		end
		content:SetWidth(contentwidth)
		content.width = contentwidth
	end,

	["OnHeightSet"] = function(self, height)
		local content = self.content
		local contentheight = height - 57
		if contentheight < 0 then
			contentheight = 0
		end
		content:SetHeight(contentheight)
		content.height = contentheight
	end,

	["Hide"] = function(self)
		self.frame:Hide()
	end,

	["Show"] = function(self)
		self.frame:Show()
	end,

	-- called to set an external table to store status in
	["SetStatusTable"] = function(self, status)
		assert(type(status) == "table")
		self.status = status
		self:ApplyStatus()
	end,

	["ApplyStatus"] = function(self)
		local status = self.status or self.localstatus
		local frame = self.frame
		self:SetWidth(100)
		self:SetHeight(40)
		frame:ClearAllPoints()
		if status.top and status.left then
			frame:SetPoint("TOP", UIParent, "BOTTOM", 0, status.top)
			frame:SetPoint("LEFT", UIParent, "LEFT", status.left, 0)
		else
			frame:SetPoint("CENTER")
		end
	end
}

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]

local FrameBackdrop = {
	bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
	edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
	tile = true, tileSize = 32, edgeSize = 32,
	insets = { left = 8, right = 8, top = 8, bottom = 8 }
}

local PaneBackdrop  = {
	bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	tile = true, tileSize = 16, edgeSize = 16,
	insets = { left = 3, right = 3, top = 5, bottom = 3 }
}

local function Constructor()
	
	local frame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
	frame:Hide()


	frame:EnableMouse(true)
	frame:SetMovable(true)
	frame:SetResizable(true)
	frame:SetFrameStrata("FULLSCREEN_DIALOG")
	frame:SetFrameLevel(100) -- Lots of room to draw under it
	frame:SetBackdrop(FrameBackdrop)
	frame:SetBackdropColor(.1, .9, .5, 1)

	frame.texture = frame:CreateTexture()
	frame.texture:SetAllPoints(frame)
	frame.texture:SetColorTexture(0,0,.3,.3)

	frame:SetHeight(10)
	frame:SetWidth(10)


	frame:SetToplevel(true)
	frame:SetScript("OnShow", Frame_OnShow)
	frame:SetScript("OnHide", Frame_OnClose)
	--frame:SetScript("OnMouseDown", Frame_OnMouseDown)

	--

	local nameTextFrame = CreateFrame("Frame",nil,frame)
	nameTextFrame:SetWidth(10) 
	nameTextFrame:SetHeight(10) 
	nameTextFrame:SetAlpha(.90);
	nameTextFrame:SetPoint("LEFT")
	nameTextFrame.text = nameTextFrame:CreateFontString(nil,"ARTWORK","GameFontNormal") 
	nameTextFrame.text:SetFont("Fonts\\ARIALN.ttf", 13, "OUTLINE")
	nameTextFrame.text:SetPoint("LEFT", 10, 0)
	nameTextFrame.text:SetText("FTW")
	nameTextFrame:Show()


	local checkButton = CreateFrame("CheckButton", nil, frame, "ChatConfigCheckButtonTemplate")
	checkButton:SetPoint("RIGHT", -10, 0)
	checkButton:SetHeight(20)
	checkButton:SetWidth(20)
	--checkButton:SetScript("OnClick", checkButtonTest)
	checkButton:Disable()
	checkButton:Disable()


	--[[   
		


	-- local statusbg = CreateFrame("Button", nil, frame, "BackdropTemplate")
	-- statusbg:SetPoint("BOTTOMLEFT", 15, 15)
	-- statusbg:SetPoint("BOTTOMRIGHT", -132, 15)
	-- statusbg:SetHeight(24)
	-- statusbg:SetBackdrop(PaneBackdrop)
	-- statusbg:SetBackdropColor(0.1,0.1,0.1)
	-- statusbg:SetBackdropBorderColor(0.4,0.4,0.4)
	-- statusbg:SetScript("OnEnter", StatusBar_OnEnter)
	-- statusbg:SetScript("OnLeave", StatusBar_OnLeave)

	-- local statustext = statusbg:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	-- statustext:SetPoint("TOPLEFT", 7, -2)
	-- statustext:SetPoint("BOTTOMRIGHT", -7, 2)
	-- statustext:SetHeight(20)
	-- statustext:SetJustifyH("LEFT")
	-- statustext:SetText("")

	-- local titlebg = frame:CreateTexture(nil, "OVERLAY")
	-- titlebg:SetTexture(131080) -- Interface\\DialogFrame\\UI-DialogBox-Header
	-- titlebg:SetTexCoord(0.31, 0.67, 0, 0.63)
	-- titlebg:SetPoint("TOP", 0, 12)
	-- titlebg:SetWidth(100)
	-- titlebg:SetHeight(40)

	-- local title = CreateFrame("Frame", nil, frame)
	-- title:EnableMouse(true)
	-- title:SetScript("OnMouseDown", Title_OnMouseDown)
	-- title:SetScript("OnMouseUp", MoverSizer_OnMouseUp)
	-- title:SetAllPoints(titlebg)

	-- local titletext = title:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	-- titletext:SetPoint("TOP", titlebg, "TOP", 0, -14)

	-- local titlebg_l = frame:CreateTexture(nil, "OVERLAY")
	-- titlebg_l:SetTexture(131080) -- Interface\\DialogFrame\\UI-DialogBox-Header
	-- titlebg_l:SetTexCoord(0.21, 0.31, 0, 0.63)
	-- titlebg_l:SetPoint("RIGHT", titlebg, "LEFT")
	-- titlebg_l:SetWidth(30)
	-- titlebg_l:SetHeight(40)

	-- local titlebg_r = frame:CreateTexture(nil, "OVERLAY")
	-- titlebg_r:SetTexture(131080) -- Interface\\DialogFrame\\UI-DialogBox-Header
	-- titlebg_r:SetTexCoord(0.67, 0.77, 0, 0.63)
	-- titlebg_r:SetPoint("LEFT", titlebg, "RIGHT")
	-- titlebg_r:SetWidth(30)
	-- titlebg_r:SetHeight(40)

	-- local sizer_se = CreateFrame("Frame", nil, frame)
	-- sizer_se:SetPoint("BOTTOMRIGHT")
	-- sizer_se:SetWidth(25)
	-- sizer_se:SetHeight(25)
	-- sizer_se:EnableMouse()
	-- sizer_se:SetScript("OnMouseDown",SizerSE_OnMouseDown)
	-- sizer_se:SetScript("OnMouseUp", MoverSizer_OnMouseUp)

	-- local line1 = sizer_se:CreateTexture(nil, "BACKGROUND")
	-- line1:SetWidth(14)
	-- line1:SetHeight(14)
	-- line1:SetPoint("BOTTOMRIGHT", -8, 8)
	-- line1:SetTexture(137057) -- Interface\\Tooltips\\UI-Tooltip-Border
	-- local x = 0.1 * 14/17
	-- line1:SetTexCoord(0.05 - x, 0.5, 0.05, 0.5 + x, 0.05, 0.5 - x, 0.5 + x, 0.5)

	-- local line2 = sizer_se:CreateTexture(nil, "BACKGROUND")
	-- line2:SetWidth(8)
	-- line2:SetHeight(8)
	-- line2:SetPoint("BOTTOMRIGHT", -8, 8)
	-- line2:SetTexture(137057) -- Interface\\Tooltips\\UI-Tooltip-Border
	-- local x = 0.1 * 8/17
	-- line2:SetTexCoord(0.05 - x, 0.5, 0.05, 0.5 + x, 0.05, 0.5 - x, 0.5 + x, 0.5)

	-- local sizer_s = CreateFrame("Frame", nil, frame)
	-- sizer_s:SetPoint("BOTTOMRIGHT", -25, 0)
	-- sizer_s:SetPoint("BOTTOMLEFT")
	-- sizer_s:SetHeight(25)
	-- sizer_s:EnableMouse(true)
	-- sizer_s:SetScript("OnMouseDown", SizerS_OnMouseDown)
	-- sizer_s:SetScript("OnMouseUp", MoverSizer_OnMouseUp)

	-- local sizer_e = CreateFrame("Frame", nil, frame)
	-- sizer_e:SetPoint("BOTTOMRIGHT", 0, 25)
	-- sizer_e:SetPoint("TOPRIGHT")
	-- sizer_e:SetWidth(25)
	-- sizer_e:EnableMouse(true)
	-- sizer_e:SetScript("OnMouseDown", SizerE_OnMouseDown)
	-- sizer_e:SetScript("OnMouseUp", MoverSizer_OnMouseUp)



	--]]


	--Container Support
	local content = CreateFrame("Frame", nil, frame)
	content:SetPoint("TOPLEFT", 17, -27)
	content:SetPoint("BOTTOMRIGHT", -17, 40)

	local widget = {
		localstatus = {},
		checkButton = checkButton,
		nameTextFrame = nameTextFrame,
		content     = content,
		frame       = frame,
		type        = Type
	}
	
	for method, func in pairs(methods) do
		widget[method] = func
	end
	checkButton.obj, nameTextFrame.obj = widget , widget--closebutton.obj, statusbg.obj = widget, widget

	return AceGUI:RegisterAsContainer(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
