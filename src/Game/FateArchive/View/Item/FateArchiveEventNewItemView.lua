---
--- Author: michaelyang_lgihtpaw
--- DateTime: 2024-08-28 14:29
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local FateMainCfgTable = require("TableCfg/FateMainCfg")
local FateIconCfgTable = require("TableCfg/FateIconCfg")
local UIViewID = require("Define/UIViewID")
local FateModelParamCfg = require("TableCfg/FateModelParamCfg")
local FateArchiveMainVM = require("Game/FateArchive/VM/FateArchiveMainVM")
local UnknownTypeIcon =
    "PaperSprite'/Game/UI/Atlas/FateArchive/Frames/UI_FateArchive_Icon_Unknown_png.UI_FateArchive_Icon_Unknown_png'"
local FinishTypeIcon =
    "PaperSprite'/Game/UI/Atlas/FateArchive/Frames/UI_FateArchive_Image_Done_png.UI_FateArchive_Image_Done_png'"
local ProtoCS = require("Protocol/ProtoCS")

---@class FateArchiveEventNewItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn UFButton
---@field ImgMonster UFImage
---@field ImgMountBG UFImage
---@field ImgNormalTag UFImage
---@field ImgStateIcon UFImage
---@field RichTextContent URichTextBox
---@field TextDefeatRate UFTextBlock
---@field TextLevel UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FateArchiveEventNewItemView = LuaClass(UIView, true)

function FateArchiveEventNewItemView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    --self.Btn = nil
    --self.ImgMonster = nil
    --self.ImgMountBG = nil
    --self.ImgNormalTag = nil
    --self.ImgStateIcon = nil
    --self.RichTextContent = nil
    --self.TextDefeatRate = nil
    --self.TextLevel = nil
    --AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FateArchiveEventNewItemView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    --AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FateArchiveEventNewItemView:OnInit()
end

function FateArchiveEventNewItemView:OnDestroy()
end

function FateArchiveEventNewItemView:OnShow()
    self.CurEventData, self.CurEventType = _G.FateMgr:GetCurWorldEventData()
    local Params = self.Params
    if nil == Params then
        return
    end
    local FateInfo = Params.Data
    self.Index = FateInfo.Index

    if FateInfo.Percent >= 10 then
        self.TextDefeatRate:SetText(string.format("%.0f%%", FateInfo.Percent))
    else
        self.TextDefeatRate:SetText(string.format("%.1f%%", FateInfo.Percent))
    end

    local bIsDefeat = (FateInfo and FateInfo.AvatarDone) or FateArchiveMainVM.bForceShowAll

    local ModelData = FateModelParamCfg:FindCfgByKey(FateInfo.FateID)
    local BGPath = _G.FateMgr.DefaultMonsterTabBGIcon
    local MonsterIcon = nil
    if (ModelData ~= nil) then
        BGPath = ModelData.MonsterTabBGIcon or _G.FateMgr.DefaultMonsterTabBGIcon
        MonsterIcon = ModelData.MonsterSmallIcon
        if (MonsterIcon == nil or MonsterIcon == "") then
            MonsterIcon = _G.FateMgr:GetUnknownIcon()
        end
    else
        MonsterIcon = _G.FateMgr:GetUnknownIcon()
    end

    UIUtil.ImageSetBrushFromAssetPath(self.ImgMountBG, BGPath)
    UIUtil.ImageSetBrushFromAssetPath(self.ImgMonster, MonsterIcon)

    -- 这里考虑未发现和已完成的Fate，使用不同的图标
    if not bIsDefeat then
        UIUtil.SetIsVisible(self.TextLevel, false)
        self.RichTextContent:SetText(LSTR(190115))

        -- Fate图标设置
        UIUtil.ImageSetBrushFromAssetPath(self.ImgStateIcon, UnknownTypeIcon)

        -- 还没有打的
        UIUtil.ImageSetColorAndOpacityHex(self.ImgMonster, _G.FateMgr:GetUnknownMonsterIconColor())
    else
        UIUtil.SetIsVisible(self.TextLevel, true)

        local FateMainCfg = FateMainCfgTable:FindCfgByKey(FateInfo.FateID)
        if (FateMainCfg ~= nil) then
            self.TextLevel:SetText(string.format(LSTR(10031), FateMainCfg.Level))
            self.RichTextContent:SetText(FateMainCfg.Name)

            if FateMgr:IsFateAchievementFinish(FateInfo.FateID) then
                UIUtil.ImageSetBrushFromAssetPath(self.ImgStateIcon, FinishTypeIcon)
            else
                local IconCfg = FateIconCfgTable:FindCfg(string.format("Type = %d", FateMainCfg.Type))
                UIUtil.ImageSetBrushFromAssetPath(self.ImgStateIcon, IconCfg.IconPath)
            end
        else
            _G.FLOG_ERROR("错误，无法获取 Fate 数据，ID：" .. FateInfo.FateID)
        end

        -- 已经打了
        UIUtil.ImageSetColorAndOpacityHex(self.ImgMonster, "ffffffff")
    end

    -- 判断是否正在进行中
    local bIsInFateArea = (FateMgr.CurrentFate ~= nil and FateMgr.CurrentFate.ID == FateInfo.FateID)
end

function FateArchiveEventNewItemView:OnHide()
end

function FateArchiveEventNewItemView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.Btn, self.OnBtnClicked)
end

function FateArchiveEventNewItemView:OnRegisterGameEvent()
end

function FateArchiveEventNewItemView:OnRegisterBinder()
end

function FateArchiveEventNewItemView:OnBtnClicked()
    UIViewMgr:ShowView(UIViewID.FateEventStatsDetialPanel, {Index = self.Index})
end

return FateArchiveEventNewItemView
