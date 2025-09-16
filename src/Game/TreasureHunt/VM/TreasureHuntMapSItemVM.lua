local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local RichTextUtil = require("Utils/RichTextUtil")

local MapCfg = require("TableCfg/MapCfg")
local MapUICfg = require("TableCfg/MapUICfg")

local TreasureHuntMapsItemVM = LuaClass(UIViewModel)

function TreasureHuntMapsItemVM:Ctor()
	self.PanelOwnerNameVisible = false
	self.OwnerName = ""

	self.PanelSelected = false

	self.PanelNotOwnedVisible = false
	self.PanelNotOwnedFocusVisible = false
	self.PanelUninterpretedVisible = false
	self.ImgUninterpretedOrdinaryVisible = false
	self.ImgUninterpretedAdvancedVisible = false
	self.PanelFocusVisible = false

	self.PanelSingleVisible = false
	self.PanelManyVisible = false
	self.SingleSelectVisible = false
	self.ManySelectVisible = false

	self.PanelGPSVisible = false
	self.PanelSensorVisible = false
	self.BtnCloseVisible = false
	self.BtnGOMapVisible = false
	self.PanelContentVisible = false
	self.BtnSelectVisible = false

	self.TextPeople = ""
	self.TextPlace = ""
	self.TextNear = ""
	self.MapPath1 = ""
	self.MapPath2 = ""
	self.MapOrdinaryPath = ""
	self.MapAdvancedPath = ""

	self.PanelNearTips1Visible = false
	self.Anim1Start = false
	self.Anim1Loop = false
	self.Anim2Loop = false
	self.Anim3Loop = false
    self.Anim4Loop = false
	self.TreasureBoxPos = nil
	
	self.MapData = nil
end

function TreasureHuntMapsItemVM:OnReset()
	self.PanelOwnerNameVisible = false
	self.OwnerName = ""

	self.PanelSelected = false

	self.PanelNotOwnedVisible = false
	self.PanelNotOwnedFocusVisible = false
	self.PanelUninterpretedVisible = false
	self.ImgUninterpretedOrdinaryVisible = false
	self.ImgUninterpretedAdvancedVisible = false
	self.PanelFocusVisible = false

	self.PanelSingleVisible = false
	self.PanelManyVisible = false
	self.SingleSelectVisible = false
	self.ManySelectVisible = false

	self.PanelGPSVisible = false
	self.PanelSensorVisible = false
	self.BtnCloseVisible = false
	self.BtnGOMapVisible = false
	self.PanelContentVisible = false
	self.BtnSelectVisible = false

	self.TextPeople = ""
	self.TextPlace = ""
	self.TextNear = ""
	self.MapPath1 = ""
	self.MapPath2 = ""
	self.MapOrdinaryPath = ""
	self.MapAdvancedPath = ""

	self.PanelNearTips1Visible = false
	self.Anim1Start = false
	self.Anim1Loop = false
	self.Anim2Loop = false
	self.Anim3Loop = false
    self.Anim4Loop = false
	self.TreasureBoxPos = nil
end

function TreasureHuntMapsItemVM:UpdateSkillPanel(MapData)
	if MapData == nil then return end
	self.MapData = MapData
	self:OnReset()

	self.PanelNotOwnedVisible = false
	self.PanelGPSVisible = true
	self.BtnCloseVisible = true
	self.BtnGOMapVisible = true
	self.PanelSensorVisible = true
	self.BtnSelectVisible = false
    self.PanelNearTips1Visible = true
	
	self.PanelContentVisible = true
	self.TextPeople = MapData.Number
	self.IsMultiPlayer = MapData.Number > 1

	local DecodeMapCount = _G.TreasureHuntMainVM:GetMapCount(MapData.ID)   			--解读的地图数
	local UnDecodeMapCount = _G.TreasureHuntMainVM:GetMapCount(MapData.UnDecodeMapID) 	--未解读的地图数	
	local MapCount = DecodeMapCount + UnDecodeMapCount
	
	if self.IsMultiPlayer then 
		if TeamMgr:IsInTeam() then
			self.PanelOwnerNameVisible = true
			self.OwnerName = MapData.OwnerName
		else 
			self.PanelOwnerNameVisible = false
		end
		self:ShowMultiMap(MapData)
	else
		self.PanelOwnerNameVisible = false
		self:ShowMap(MapData)
	end

	self.TreasureBoxPos = MapData.Pos  
end

function TreasureHuntMapsItemVM:UpdateMainPanel(MapData)
	if MapData == nil then return end
	self.MapData = MapData
	self:OnReset()
	
	self.PanelOwnerNameVisible = false
	if MapData.Opened == 0 then 
		self.PanelSingleVisible = false
		self.PanelManyVisible = false
		self.PanelGPSVisible = true
		self.PanelSensorVisible = false
		self.BtnCloseVisible = false
		self.BtnSelectVisible = true

		self.PanelContentVisible = false
		self.PanelNotOwnedVisible = true
	else
		self.PanelNotOwnedVisible = false
		self.TextPeople = MapData.Number
		self.PanelGPSVisible = true
		self.PanelSensorVisible = false
		self.BtnCloseVisible = false
		self.BtnSelectVisible = true

		local DecodeMapCount = _G.TreasureHuntMainVM:GetMapCount(MapData.ID)   			--解读的地图数
		local UnDecodeMapCount = _G.TreasureHuntMainVM:GetMapCount(MapData.UnDecodeMapID) 	--未解读的地图数	
		local MapCount = DecodeMapCount + UnDecodeMapCount

		self.IsMultiPlayer = MapData.Number > 1
		if DecodeMapCount > 0 then 
			self.PanelContentVisible = true
			self.BtnGOMapVisible = true

			if self.IsMultiPlayer then 
				self:ShowMultiMap(MapData)
			else
				self:ShowMap(MapData)
			end

			self.TreasureBoxPos = MapData.Pos  
		else
			self.PanelContentVisible = false
			self.BtnGOMapVisible = false
			self.TextPlace = ""

			local Owned = UnDecodeMapCount > 0
			if self.IsMultiPlayer then 
				self:ShowMultiMapUnDecode(Owned) 
			else
				self:ShowUnDecode(Owned) 
			end
		end
	end
end

function TreasureHuntMapsItemVM:ShowUnDecode(Owned)
	self.PanelSingleVisible = false   
	self.PanelManyVisible = false

	self.MapPath1 = ""
	if Owned then 
		self.PanelNotOwnedVisible = false
		self.PanelUninterpretedVisible = true
		self.ImgUninterpretedAdvancedVisible = false
		self.ImgUninterpretedOrdinaryVisible = true
	else
		self.PanelNotOwnedVisible = true
		self.PanelUninterpretedVisible = false
	end
end

function TreasureHuntMapsItemVM:ShowMultiMapUnDecode(Owned)
	self.PanelSingleVisible = false  
	self.PanelManyVisible = false

	self.MapPath2 = ""
	if Owned then 
		self.PanelNotOwnedVisible = false
		self.PanelUninterpretedVisible = true
		self.ImgUninterpretedAdvancedVisible = true
		self.ImgUninterpretedOrdinaryVisible = false
	else
		self.PanelNotOwnedVisible = true
		self.PanelUninterpretedVisible = false
	end
end

function TreasureHuntMapsItemVM:ShowMap(MapData)
	self.PanelSingleVisible = true 
	self.PanelManyVisible = false
	self.PanelNotOwnedVisible = false
	self.PanelUninterpretedVisible = false

	local ImagePath = "Texture2D'/Game/UI/Texture/Map/MiniMap/"
	
	if MapData.MapResID == nil then
		self.TextPlace = ""
		self.MapPath1 = ""
	else
		if MapData.PosID > 0 then
			ImagePath = ImagePath..tostring(MapData.PosID).."."..tostring(MapData.PosID).."'"
			self.MapOrdinaryPath = ImagePath
		end

		local MapCfgInfo = MapCfg:FindCfgByKey(MapData.MapResID)
		if MapCfgInfo ~= nil then 
			self.TextPlace = MapCfgInfo.DisplayName 
			--local MapUICfgInfo =  MapUICfg:FindCfgByKey(MapCfgInfo.UIMapID)
			--if MapUICfgInfo ~= nil then
				--self.MapPath1 = MapUICfgInfo.Path
			--end
		end

	end
end

function TreasureHuntMapsItemVM:ShowMultiMap(MapData)
	self.PanelSingleVisible = false  
	self.PanelManyVisible = true
	self.PanelNotOwnedVisible = false
	self.PanelUninterpretedVisible = false

	local ImagePath = "Texture2D'/Game/UI/Texture/Map/MiniMap/"

	if MapData.MapResID == nil then
		self.TextPlace = ""
		self.MapPath2 = ""
	else
		if MapData.PosID > 0 then
			ImagePath = ImagePath..tostring(MapData.PosID).."."..tostring(MapData.PosID).."'"
			self.MapAdvancedPath = ImagePath
		end

		local MapCfgInfo = MapCfg:FindCfgByKey(MapData.MapResID)
		if MapCfgInfo ~= nil then 
			self.TextPlace = MapCfgInfo.DisplayName 
			--local MapUICfgInfo =  MapUICfg:FindCfgByKey(MapCfgInfo.UIMapID)
			--if MapUICfgInfo ~= nil then
				--self.MapPath2 =  MapUICfgInfo.Path
			--end
		end
	end
end

function TreasureHuntMapsItemVM:GetMapData()
	return self.MapData
end

function TreasureHuntMapsItemVM:IsMulti()
	return self.IsMultiPlayer
end

function TreasureHuntMapsItemVM:GetTreasureBoxPos()
	return self.TreasureBoxPos
end

function TreasureHuntMapsItemVM:SetSelected(Value)
	if self.MapData == nil then return end
	local DecodeMapCount = _G.TreasureHuntMainVM:GetMapCount(self.MapData.ID)   			--解读的地图数
	local UnDecodeMapCount = _G.TreasureHuntMainVM:GetMapCount(self.MapData.UnDecodeMapID) 	--未解读的地图数	
	local MapCount = DecodeMapCount + UnDecodeMapCount
	if MapCount > 0 then 
		if self.PanelSingleVisible then
			self.SingleSelectVisible = Value
		end
		if self.PanelManyVisible then 
			self.ManySelectVisible = Value
		end
	else
		self.PanelNotOwnedFocusVisible = Value
	end
	if UnDecodeMapCount > 0 then
		self.PanelFocusVisible = Value
	end
	self.PanelSelected = Value
end

function TreasureHuntMapsItemVM:UpdateDist(sameMap,distance)
	if sameMap then 
		self.PanelNearTips1Visible = true
		if distance <= _G.TreasureHuntMgr:GetTreasureHuntRadius() then
			self.TextNear = ""
			if not self.Anim1Start then
				self.Anim1Start = true 
				self.Anim1Loop = false
				self.Anim2Loop = false
				self.Anim3Loop = false
				self.Anim4Loop = false
			end
		else
			if distance > 200 then 
				self.TextNear = RichTextUtil.GetText(string.format("%d m",math.floor(distance)), "FFFFFFFF")
				if not self.Anim3Loop then
					self.Anim1Start = false
					self.Anim1Loop = false
					self.Anim2Loop = false
					self.Anim3Loop = true
					self.Anim4Loop = false
				end
			else
				self.TextNear = _G.LSTR(640025) --附近
                if distance > 70 then
					if not self.Anim2Loop then
						self.Anim1Start = false
						self.Anim1Loop = false
						self.Anim2Loop = true
						self.Anim3Loop = false
						self.Anim4Loop = false
					end
                else
                    if not self.Anim1Loop then
						self.Anim1Start = false
						self.Anim1Loop = true
						self.Anim2Loop = false
						self.Anim3Loop = false
						self.Anim4Loop = false
					end
                end
			end
		end
	else
		self.PanelNearTips1Visible = true
		self.TextNear = _G.LSTR(640026) --不在附近
		if not self.Anim4Loop then
			self.Anim1Start = false
			self.Anim1Loop = false
			self.Anim2Loop = false
			self.Anim3Loop = false 
			self.Anim4Loop = true
		end
	end
end

return TreasureHuntMapsItemVM