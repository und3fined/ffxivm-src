--
-- Author: Alex
-- Date: 2024-06-13 15:30
-- Description:功能模块使用MapContent绑定用VM（如：风脉）
--


local LuaClass = require("Core/LuaClass")
--local TimeUtil = require("Utils/TimeUtil")
local MapMgr = require("Game/Map/MapMgr")
local MapVM = require("Game/Map/VM/MapVM")
local MapUICfg = require("TableCfg/MapUICfg")
local MapUtil = require("Game/Map/MapUtil")
local MapDefine =  require("Game/Map/MapDefine")
--local MapContentType = MapDefine.MapContentType
local FLOG_INFO = _G.FLOG_INFO

---@class ModuleMapContentVM : MapVM
---@field MapContentType MapContentType@地图内容类型
---@field UIMapID number
---@field MapScale number@地图缩放比，默认等比缩放
local ModuleMapContentVM = LuaClass(MapVM)

---Ctor
function ModuleMapContentVM:Ctor()
	self.MapContentType = nil
    self.UIMapID = nil
    self.MapScale = 1
    self.MapOffset = _G.UE.FVector2D(0, 0)
    self.BackgroundPath = nil

    self.bOnTouchValid = true -- CommGesture_UIBP的触摸操作是否生效
end

function ModuleMapContentVM:OnInit()

end

function ModuleMapContentVM:OnBegin()

end

function ModuleMapContentVM:OnEnd()
    self.MapOffset = nil
    self.UIMapID = nil -- 清除地图数据
end

function ModuleMapContentVM:OnShutdown()

end


---@param MapContentType MapContentType@地图内容类型
function ModuleMapContentVM:SetMapContentType(MapContentType)
	self.MapContentType = MapContentType
end


---@param MapContentType MapContentType@地图内容类型
function ModuleMapContentVM:SetTouchAllowed(bAllowed)
	self.bOnTouchValid = bAllowed
end

---@param MapContentType MapContentType@地图内容类型
function ModuleMapContentVM:GetTouchAllowed()
	return self.bOnTouchValid
end

function ModuleMapContentVM:ChangeUIMap(UIMapID)
	if not UIMapID or type(UIMapID) ~= "number" then
        return
    end

	self.UIMapID = UIMapID

	local Cfg = MapUICfg:FindCfgByKey(UIMapID)
   
	if nil == Cfg then
		self:SetMapPath(nil)
		self:SetMapMaskPath(nil)
		self:SetIsAllActivate(true)
		self.MapScale = 1
	else
        self:SetMapPath(Cfg.Path)
        local MapID = MapUtil.GetMapID(UIMapID)
        if MapID > 0 then
            self:SetMapMaskPath(Cfg.MaskPath)
            self:SetDiscoveryFlag(_G.FogMgr:GetFlogFlag(MapID))
            self:SetIsAllActivate(_G.FogMgr:IsAllActivate(MapID))
        else
            self:SetMapMaskPath("")
            self:SetIsAllActivate(true)
        end
        FLOG_INFO("ModuleMapContentVM:ChangeUIMap: Update FogInfo. MapID:%s", tostring(MapID))
        self.BackgroundPath = Cfg.Background
		self.MapScale = Cfg.Scale
        self:SetMapOffset(Cfg.UIMapOffsetX, Cfg.UIMapOffsetY)
	end

	local MapName = MapUtil.GetMapName(UIMapID)
	self:SetMapName(MapName)
end

function ModuleMapContentVM:SetMapOffset(X, Y)
    local MapOffset = self.MapOffset

    if not MapOffset then
        self.MapOffset = _G.UE.FVector2D(X, Y)
        return
    end

    local OldX = MapOffset.X
    local OldY = MapOffset.Y
    if OldX and OldX == X and OldY and OldY == Y then
        return
    end
    MapOffset.X = X
    MapOffset.Y = Y

    local OffsetBindProp = self:FindBindableProperty("MapOffset")
    if OffsetBindProp then
        OffsetBindProp:ValueChanged()
    end
end


function ModuleMapContentVM:SetMapScale(Scale)
	self.MapScale = Scale
end

return ModuleMapContentVM