---
--- Author: michaelyang_lightpaw
--- DateTime: 2024-08-28 14:28
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MonsterCfg = require("TableCfg/MonsterCfg")
local UIViewID = require("Define/UIViewID")
-- local UnknownMonsterIcon = "Texture2D'/Game/UI/Texture/FateArchive/UI_FateArchive_Img_Unknown.UI_FateArchive_Img_Unknown'"
local FateArchiveMainVM = require("Game/FateArchive/VM/FateArchiveMainVM")
local FateModelParamCfg = require("TableCfg/FateModelParamCfg")

local FateMgr = _G.FateMgr

---@class FateArchiveMonsterCardNewItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn UFButton
---@field ImgDefeatBg UFImage
---@field ImgMonster UFImage
---@field ImgMountBG UFImage
---@field TextDefeatRate UFTextBlock
---@field TextName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FateArchiveMonsterCardNewItemView = LuaClass(UIView, true)

function FateArchiveMonsterCardNewItemView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    --self.Btn = nil
    --self.ImgDefeatBg = nil
    --self.ImgMonster = nil
    --self.ImgMountBG = nil
    --self.TextDefeatRate = nil
    --self.TextName = nil
    --AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FateArchiveMonsterCardNewItemView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    --AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FateArchiveMonsterCardNewItemView:OnInit()
end

function FateArchiveMonsterCardNewItemView:OnDestroy()
end

function FateArchiveMonsterCardNewItemView:OnShow()
    local Params = self.Params
    if nil == Params then
        return
    end
    local MonsterInfo = Params.Data
    self.Index = MonsterInfo.Index
    self.MonsterID = MonsterInfo.ResID
    self.FateID = MonsterInfo.FateID
    if MonsterInfo.Percent >= 10 then
        self.TextDefeatRate:SetText(string.format("%.0f%%", MonsterInfo.Percent))
    else
        self.TextDefeatRate:SetText(string.format("%.1f%%", MonsterInfo.Percent))
    end

    local bIsDefeat = (MonsterInfo and MonsterInfo.AvatarDone) or FateArchiveMainVM.bForceShowAll

    local ModelData = FateModelParamCfg:FindCfgByKey(self.FateID)
    if (ModelData ~= nil) then
        local BGPath = ModelData.MonsterCardBGIcon
        if (BGPath == nil or BGPath == "") then
            BGPath = FateMgr.DefaultMonsterCardBGIcon
        end

        UIUtil.ImageSetBrushFromAssetPath(self.ImgMountBG, BGPath)
    else
        UIUtil.ImageSetBrushFromAssetPath(self.ImgMountBG, FateMgr.DefaultMonsterCardBGIcon)
        self.ImgMonster:SetRenderScale(_G.UE.FVector2D(1, 1))
        _G.FLOG_ERROR("无法获取 FateModelParamCfg 数据, ID是 : %s", self.FateID)
    end

    -- 读取怪物图标
    if (ModelData ~= nil) then
        local Scale = ModelData.SecondPanelPicScale
        local Scale2D = _G.UE.FVector2D(Scale, Scale)
        self.ImgMonster:SetRenderScale(Scale2D)

        local MonsterIcon = ModelData.MonsterSmallIcon
        if (MonsterIcon == nil or MonsterIcon == "") then
            MonsterIcon = _G.FateMgr:GetUnknownIcon()
        end
        UIUtil.ImageSetBrushFromAssetPath(self.ImgMonster, MonsterIcon)
    else
        UIUtil.ImageSetBrushFromAssetPath(self.ImgMonster, _G.FateMgr:GetUnknownIcon())
        self.ImgMonster:SetRenderScale(_G.UE.FVector2D(1, 1))
        _G.FLOG_ERROR("无法获取 FateModelParamCfg 数据, ID是 : %s", self.FateID)
    end

    -- 这里考虑未发现和已完成的Fate，使用不同的图标
    if bIsDefeat then
        local Cfg = MonsterCfg:FindCfgByKey(self.MonsterID)
        self.TextName:SetText(Cfg.Name)
        -- 已经打了
        UIUtil.ImageSetColorAndOpacityHex(self.ImgMonster, "ffffffff")
    else
        self.TextName:SetText(LSTR(190115))
        -- 还没有打的
        UIUtil.ImageSetColorAndOpacityHex(self.ImgMonster, _G.FateMgr:GetUnknownMonsterIconColor())
    end
end

function FateArchiveMonsterCardNewItemView:OnHide()
end

function FateArchiveMonsterCardNewItemView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.Btn, self.OnBtnClicked)
end

function FateArchiveMonsterCardNewItemView:OnRegisterGameEvent()
end

function FateArchiveMonsterCardNewItemView:OnRegisterBinder()
end

function FateArchiveMonsterCardNewItemView:OnBtnClicked()
    UIViewMgr:ShowView(UIViewID.FateEventStatsDetialPanel, {Index = self.Index})
end

return FateArchiveMonsterCardNewItemView
