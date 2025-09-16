---
--- Author: Alex
--- DateTime: 2024-03-08 11:36:30
--- Description: 探索笔记IconItemVM
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
--local ProtoRes = require("Protocol/ProtoRes")
local DiscoverNoteCfg = require("TableCfg/DiscoverNoteCfg")
local DiscoverNoteAreaCfg = require("TableCfg/DiscoverNoteAreaCfg")
local DiscoverNoteDefine = require("Game/SightSeeingLog/DiscoverNoteDefine")
local TextureColoredColorParam = DiscoverNoteDefine.TextureColoredColorParam
local TextureGreyColorParam = DiscoverNoteDefine.TextureGreyColorParam
local TextureColoredOpacityParam = DiscoverNoteDefine.TextureColoredOpacityParam
local TextureGreyOpacityParam = DiscoverNoteDefine.TextureGreyOpacityParam
local MapUtil = require("Game/Map/MapUtil")

local FLinearColor = _G.UE.FLinearColor

---@class DiscoverNoteIconItemVM : UIViewModel
local DiscoverNoteIconItemVM = LuaClass(UIViewModel)

---Ctor
function DiscoverNoteIconItemVM:Ctor()
    -- Main Part
    self.ItemID = 0
    self.IconPath = ""
    self.IndexText = ""
    self.bSelected = false
    self.bCompleted = false -- 普通探索
    self.AnimInSwitch = false
    self.AnimClickSwitch = false
    self.RedDotName = ""
    self.TextNumberColor = ""
    self.OffsetAngle = 0

    -- 二期内容
    self.bPerfectComplete = false -- 完美探索
    -- Texture参数
    self.Color = nil
    self.Opacity = nil
    self.Int = nil
    self.Tint = nil

    -- 三期内容
    self.bUnderPerfectCond = nil -- 是否满足完美点条件
    self.bShowPerfectCondEffect = nil -- 是否显示完美条件提示特效
end

function DiscoverNoteIconItemVM:IsEqualVM(Value)
    return false
end

function DiscoverNoteIconItemVM:UpdateVM(Value)
    local NoteItemID = Value.ItemID
    if not NoteItemID then
        return
    end
    self.ItemID = NoteItemID

    local ItemIndex = Value.Index or 1
    if math.floor(ItemIndex / 10) == 0 then
        self.IndexText = string.format("0%s", tostring(ItemIndex))
    else
        self.IndexText = tostring(ItemIndex)
    end

    local NoteCfg = DiscoverNoteCfg:FindCfgByKey(NoteItemID)
    if not NoteCfg then
        return
    end

    local MapID = NoteCfg.MapID or 0
    local RegionID = MapUtil.GetMapRegionID(MapID) or 0
    local bCompleted = Value.bCompleted
    local bPerfectComplete = Value.bPerfectComplete
    self.bCompleted = bCompleted
    self.bPerfectComplete = bPerfectComplete
    self:SetLeftPhotoTextureParams(bPerfectComplete)
    if bCompleted then
        self.IconPath = NoteCfg.CompIcon
    else
        local NoteRegionCfg = DiscoverNoteAreaCfg:FindCfgByKey(RegionID)
        if NoteRegionCfg then
            local IncompIcon = NoteRegionCfg.IncompIcon
            if IncompIcon then
                self.IconPath = IncompIcon
            end
        end
    end

    self.RedDotName = string.format("%s/%s/%s", DiscoverNoteDefine.RedDotBaseName, tostring(RegionID), tostring(NoteItemID))
    self.OffsetAngle = Value.OffsetAngle

    -- 三期内容
    local bShowPerfectCondEffect = Value.bShowPerfectCondEffect
    self.bShowPerfectCondEffect = bShowPerfectCondEffect
    self.bUnderPerfectCond = bShowPerfectCondEffect
end

function DiscoverNoteIconItemVM:SetLeftPhotoTextureParams(bPerfectComplete)
    if bPerfectComplete then
        self.Color = TextureColoredColorParam.Color
        self.Opacity = TextureColoredOpacityParam.Opacity
        self.Int = TextureColoredColorParam.Int
        self.Tint = TextureColoredColorParam.Tint
    else
        self.Color = TextureGreyColorParam.Color
        self.Opacity = TextureGreyOpacityParam.Opacity
        self.Int = TextureGreyColorParam.Int
        self.Tint = TextureGreyColorParam.Tint
    end
end

return DiscoverNoteIconItemVM
