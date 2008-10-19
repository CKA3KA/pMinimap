pMinimap = CreateFrame('Frame', 'pMinimap', UIParent)
pMinimap:SetScript('OnEvent', function(self, event, ...) self[event](self, event, ...) end)
pMinimap:RegisterEvent('ADDON_LOADED')

function pMinimap.ADDON_LOADED(self)
	if(not IsAddOnLoaded('Blizzard_TimeManager')) then
		LoadAddOn('Blizzard_TimeManager')
	end

	local db = pMinimapDB or {point = {'TOPRIGHT', UIParent, 'TOPRIGHT', -15, -15}, scale = 0.9, offset = 1, colors = {0, 0, 0}, durability = true}

	MinimapBorder:SetTexture()
	MinimapBorderTop:Hide()
	MinimapToggleButton:Hide()

	MinimapZoomIn:Hide()
	MinimapZoomOut:Hide()
	Minimap:EnableMouseWheel()
	Minimap:SetScript('OnMouseWheel', function(self, dir)
		if(dir > 0) then
			Minimap_ZoomIn()
		else
			Minimap_ZoomOut()
		end
	end)

	MinimapZoneText:Hide()
	MinimapZoneTextButton:Hide()

	MiniMapTrackingButtonBorder:SetTexture()
	MiniMapTrackingBackground:Hide()
	MiniMapTrackingIconOverlay:SetAlpha(0)
	MiniMapTrackingIcon:SetTexCoord(0.065, 0.935, 0.065, 0.935)
	MiniMapTracking:SetParent(Minimap)
	MiniMapTracking:ClearAllPoints()
	MiniMapTracking:SetPoint('TOPLEFT', -2, 2)

	BattlegroundShine:Hide()
	MiniMapBattlefieldBorder:SetTexture()
	MiniMapBattlefieldFrame:SetParent(Minimap)
	MiniMapBattlefieldFrame:ClearAllPoints()
	MiniMapBattlefieldFrame:SetPoint('TOPRIGHT', -2, -2)

	MiniMapMailBorder:SetTexture()
	MiniMapMailIcon:Hide()
	MiniMapMailFrame:SetParent(Minimap)
	MiniMapMailFrame:ClearAllPoints()
	MiniMapMailFrame:SetPoint('TOP')
	MiniMapMailFrame:SetHeight(8)

	MiniMapMailText = MiniMapMailFrame:CreateFontString(nil, 'OVERLAY')
	MiniMapMailText:SetFont([=[Interface\AddOns\pMinimap\font.ttf]=], 13, 'OUTLINE')
	MiniMapMailText:SetPoint('BOTTOM', 0, 2)
	MiniMapMailText:SetText('New Mail!')
	MiniMapMailText:SetTextColor(1, 1, 1)

	TimeManagerClockButton:ClearAllPoints()
	TimeManagerClockButton:SetPoint('BOTTOM', Minimap)
	TimeManagerClockButton:SetWidth(40)
	TimeManagerClockButton:SetHeight(14)
	TimeManagerClockButton:GetRegions():Hide()
	TimeManagerClockTicker:SetPoint('CENTER', TimeManagerClockButton)
	TimeManagerClockTicker:SetFont([=[Interface\AddOns\pMinimap\font.ttf]=], 13, 'OUTLINE')
	TimeManagerAlarmFiredTexture.Show = function() TimeManagerClockTicker:SetTextColor(1, 0, 0) end
	TimeManagerAlarmFiredTexture.Hide = function() TimeManagerClockTicker:SetTextColor(1, 1, 1) end
	TimeManagerClockButton:SetScript('OnClick', function(self, button)
		if(self.alarmFiring) then
			PlaySound('igMainMenuQuit')
			TimeManager_TurnOffAlarm()
		else
			if(button == 'RightButton') then
				if(not IsAddOnLoaded('Blizzard_Calendar')) then
					LoadAddOn('Blizzard_Calendar')
				end
				ToggleCalendar()
			else
				ToggleTimeManager()
			end
		end
	end)

	GameTimeFrame:Hide()
	MiniMapWorldMapButton:Hide()
	MiniMapVoiceChatFrame:Hide()
	MiniMapMeetingStoneFrame:Hide()
	MiniMapMeetingStoneFrame:SetAlpha(0)
	MinimapNorthTag:SetAlpha(0)

	self:SetPoint(unpack(db.point))
	self:SetWidth(Minimap:GetWidth() * db.scale)
	self:SetHeight(Minimap:GetHeight() * db.scale)
	self:SetBackdrop({bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=]})
	self:SetBackdropColor(0, 1, 0, 0.5)
	self:SetAlpha(0)
	self:SetMovable(true)
	self:EnableMouse(false)
	self:SetScript('OnMouseDown', function() self:StartMoving() end)
	self:SetScript('OnMouseUp', function() self:StopMovingOrSizing() end)

	Minimap:ClearAllPoints()
	Minimap:SetPoint('CENTER', self)
	Minimap:SetScale(db.scale)
	Minimap:SetMaskTexture([=[Interface\ChatFrame\ChatFrameBackground]=])
	Minimap:SetBackdrop({bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=], insets = {top = - db.offset, left = - db.offset, bottom = - db.offset, right = - db.offset}})
	Minimap:SetBackdropColor(unpack(db.colors))

	if(db.durability) then
		self:RegisterEvent('UPDATE_INVENTORY_ALERTS')
		DurabilityFrame:SetAlpha(0)
	end

	self:RegisterEvent('PLAYER_ENTERING_WORLD')
	self:UnregisterEvent('ADDON_LOADED')
end

function pMinimap.UPDATE_INVENTORY_ALERTS()
	local db = pMinimapDB or {colors = {0, 0, 0, 1}}
	local maxStatus = 0
	for id in pairs(INVENTORY_ALERT_STATUS_SLOTS) do
		local status = GetInventoryAlertStatus(id)
		if(status > maxStatus) then
			maxStatus = status
		end
	end

	local color = INVENTORY_ALERT_COLORS[maxStatus]
	if(color) then
		Minimap:SetBackdropColor(color.r, color.g, color.b)
	else
		Minimap:SetBackdropColor(unpack(db.colors))
	end
end

-- http://www.wowwiki.com/GetMinimapShape
function GetMinimapShape() return 'SQUARE' end