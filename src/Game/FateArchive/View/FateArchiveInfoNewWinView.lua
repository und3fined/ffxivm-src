---
--- Author: Administrator
--- DateTime: 2024-08-29 11:41
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIViewID = require("Define/UIViewID")
local ProtoCS = require("Protocol/ProtoCS")
local MonsterCfgTable = require("TableCfg/MonsterCfg")
local FateMainCfgTable = require("TableCfg/FateMainCfg")
local FateGeneratorCfgTable = require("TableCfg/FateGeneratorCfg")
local MapMap2areaCfgTable = require("TableCfg/MapMap2areaCfg")
local FateTextCfgTable = require("TableCfg/FateTextCfg")
local FateArchiveMainVM = require("Game/FateArchive/VM/FateArchiveMainVM")
local ItemCfg = require("TableCfg/ItemCfg")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local FateModelParamCfg = require("TableCfg/FateModelParamCfg")

local LSTR = _G.LSTR
local FateMgr = _G.FateMgr
local UIViewMgr = nil
local EventMgr = nil
local EventID = nil

local MsgTipsUtil = nil
local FateNotDiscoverMsgID = 307100 -- 跳转的时候发现FATE没揭示的提示

---@class FateArchiveInfoNewWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BorderNotJoin UBorder
---@field BorderUnknown UBorder
---@field BtnClose UFButton
---@field BtnDetail UFButton
---@field BtnInfor CommInforBtnView
---@field BtnLeft UFButton
---@field BtnRight UFButton
---@field BtnToGet UFButton
---@field BtnToGet1 UFButton
---@field Common_ModelToImage_UIBP CommonModelToImageView
---@field ImgDoing UFImage
---@field ImgEventIcon UFImage
---@field ImgEventIcon1 UFImage
---@field ImgMountBG UFImage
---@field ImgPic UFImage
---@field ImgToGet UFImage
---@field ImgToGet1 UFImage
---@field MonsterRender2D_UIBP MonsterRender2DView
---@field PanelInfo UFCanvasPanel
---@field PanelInfoTextOnly UFCanvasPanel
---@field PopUpBG CommonPopUpBGView
---@field TextDefeatRate UFTextBlock
---@field TextDefeatRate1 UFTextBlock
---@field TextDescription UFTextBlock
---@field TextDescription1 UFTextBlock
---@field TextEventName UFTextBlock
---@field TextEventName1 UFTextBlock
---@field TextLocationName UFTextBlock
---@field TextLocationName1 UFTextBlock
---@field TextName UFTextBlock
---@field TextNotJoin UFTextBlock
---@field TextUnknown UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field AnimUpdateInfo UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FateArchiveInfoNewWinView = LuaClass(UIView, true)

function FateArchiveInfoNewWinView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BorderNotJoin = nil
	--self.BorderUnknown = nil
	--self.BtnClose = nil
	--self.BtnDetail = nil
	--self.BtnInfor = nil
	--self.BtnLeft = nil
	--self.BtnRight = nil
	--self.BtnToGet = nil
	--self.BtnToGet1 = nil
	--self.Common_ModelToImage_UIBP = nil
	--self.ImgDoing = nil
	--self.ImgEventIcon = nil
	--self.ImgEventIcon1 = nil
	--self.ImgMountBG = nil
	--self.ImgPic = nil
	--self.ImgToGet = nil
	--self.ImgToGet1 = nil
	--self.MonsterRender2D_UIBP = nil
	--self.PanelInfo = nil
	--self.PanelInfoTextOnly = nil
	--self.PopUpBG = nil
	--self.TextDefeatRate = nil
	--self.TextDefeatRate1 = nil
	--self.TextDescription = nil
	--self.TextDescription1 = nil
	--self.TextEventName = nil
	--self.TextEventName1 = nil
	--self.TextLocationName = nil
	--self.TextLocationName1 = nil
	--self.TextName = nil
	--self.TextNotJoin = nil
	--self.TextUnknown = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--self.AnimUpdateInfo = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FateArchiveInfoNewWinView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnInfor)
	self:AddSubView(self.Common_ModelToImage_UIBP)
	self:AddSubView(self.MonsterRender2D_UIBP)
	self:AddSubView(self.PopUpBG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FateArchiveInfoNewWinView:OnInit()
    MsgTipsUtil = require("Utils/MsgTipsUtil")
    UIViewMgr = _G.UIViewMgr
    EventMgr = _G.EventMgr
    EventID = _G.EventID
    self.BtnInfor:SetCallback(self, self.OnBtnInforClicked)
    self.PopUpBG:SetHideOnClick(false)
end

function FateArchiveInfoNewWinView:OnDestroy()
end

function FateArchiveInfoNewWinView:OnShow()
    self.CurEventData, self.CurEventType = FateMgr:GetCurWorldEventData()
    self.SelectedIndex = 1
    if self.Params ~= nil then
        print("FateArchiveInfoNewWinView:OnShow Select Index:", self.Params.Index)
        self.SelectedIndex = self.Params.Index
    end

    self:RefreshContent()
end

function FateArchiveInfoNewWinView:RefreshContent()
    self.MonsterInfo = nil
    self.FateInfo = nil
    -- 根据不同的类型执行不同的加载逻辑
    if self.CurEventType == ProtoCS.CS_FATE_STATS.CS_FATE_STATS_POWERFUL_MONSTER then
        self:RefreshMonsterPanel()
    elseif self.CurEventType == ProtoCS.CS_FATE_STATS.CS_FATE_STATS_DIFFICULT_FATE then
        self:RefreshFateEventPanel()
    end
    self:RefreshLRButton()
    self:PlayAnimation(self.AnimUpdateInfo)
end

function FateArchiveInfoNewWinView:RefreshMonsterPanel()
    UIUtil.SetIsVisible(self.BtnInfor, false)
    UIUtil.SetIsVisible(self.PanelInfo, true)
    UIUtil.SetIsVisible(self.PanelInfoTextOnly, false)
    local MonsterInfo = self.CurEventData[self.SelectedIndex]
    self.MonsterInfo = MonsterInfo
    self.TextNotJoin:SetText(LSTR(190017))
    self.TextUnknown:SetText(LSTR(190017))
    local FateID = self.MonsterInfo.FateID
    local ModelData = FateModelParamCfg:FindCfgByKey(FateID)
    if (ModelData ~= nil) then
        local BGPath = ModelData.MonsterBGIcon
        if (BGPath == nil or BGPath == "") then
            BGPath = FateMgr.DefaultMonsterBGIcon
        end

        UIUtil.ImageSetBrushFromAssetPath(self.ImgMountBG, BGPath)
    else
        UIUtil.ImageSetBrushFromAssetPath(self.ImgMountBG, FateMgr.DefaultMonsterBGIcon)

        _G.FLOG_ERROR("无法获取 FateModelParamCfg 数据, ID是 : %s", FateID)
    end

    --TODO:右边怪物图标设置
    local MonsterIcon = FateMgr:GetMonsterIcon(FateID)
    if (MonsterIcon == nil or MonsterIcon == "") then
        MonsterIcon = _G.FateMgr:GetUnknownIcon()
    end
    UIUtil.ImageSetBrushFromAssetPath(self.ImgPic, MonsterIcon)

    local bIsDefeat = MonsterInfo.AvatarDone
    if bIsDefeat then
        local MonsterCfg = MonsterCfgTable:FindCfgByKey(MonsterInfo.ResID)
        self.TextName:SetText(MonsterCfg.Name)
        UIUtil.SetIsVisible(self.BorderUnknown, false)

        if (ModelData ~= nil) then
            local Scale = ModelData.ThirdPanelPicScale
            local Scale2D = _G.UE.FVector2D(Scale, Scale)
            self.ImgPic:SetRenderScale(Scale2D)
        else
            _G.FLOG_ERROR("无法获取 FateModelParamCfg 数据, ID是 : %s", FateID)
            self.ImgPic:SetRenderScale(_G.UE.FVector2D(1, 1))
        end

        -- 打了
        UIUtil.ImageSetColorAndOpacityHex(self.ImgPic, "ffffffff")

        local FateMainCfg = FateMainCfgTable:FindCfgByKey(FateID)
        if (FateMainCfg ~= nil) then
            self.TextEventName:SetText(FateMainCfg.Name)
        else
            _G.FLOG_ERROR("无法获取FATE主数据，ID是 : "..tostring(FateID))
        end
        local FateTextCfg = FateTextCfgTable:FindCfgByKey(FateID)
        if (FateTextCfg ~= nil) then
            self.TextDescription:SetText(FateTextCfg.StoryCh)
        else
            _G.FLOG_ERROR("无法获取 FateTextCfgTable 数据，ID是: "..tostring(FateID))
        end
    else
        self.TextEventName:SetText(LSTR(190115))
        self.TextDescription:SetText(LSTR(190087))

        self.TextName:SetText(LSTR(190115))
        UIUtil.SetIsVisible(self.BorderUnknown, true)

        -- 还没有打的
        UIUtil.ImageSetColorAndOpacityHex(self.ImgPic, _G.FateMgr:GetUnknownMonsterIconColor())
    end

    self:SetLocationAndRate(MonsterInfo, LSTR(190084))
end

function FateArchiveInfoNewWinView:RefreshFateEventPanel()
    UIUtil.SetIsVisible(self.PanelInfo, false)
    UIUtil.SetIsVisible(self.PanelInfoTextOnly, true)
    local FateInfo = self.CurEventData[self.SelectedIndex]
    self.FateInfo = FateInfo
    self.TextNotJoin:SetText(LSTR(190016))
    local bIsDefeat = FateInfo.AvatarDone or FateArchiveMainVM.bForceShowAll
    if bIsDefeat then
        local FateMainCfg = FateMainCfgTable:FindCfgByKey(FateInfo.FateID)
        self.TextEventName1:SetText(FateMainCfg.Name)
        UIUtil.SetIsVisible(self.BorderNotJoin, false)

        local FateTextCfg = FateTextCfgTable:FindCfgByKey(FateInfo.FateID)
        self.TextDescription1:SetText(FateTextCfg.StoryCh)
    else
        self.TextDescription1:SetText(LSTR(190087))
        self.TextEventName1:SetText(LSTR(190115))
        UIUtil.SetIsVisible(self.BorderNotJoin, true)
    end

    local FateGeneratorCfg = FateGeneratorCfgTable:FindCfgByKey(FateInfo.FateID)
    local MapMap2areaCfg = MapMap2areaCfgTable:FindCfgByKey(FateGeneratorCfg.MapID)
    self.TextLocationName1:SetText(MapMap2areaCfg.MapName)

    if FateInfo.Percent >= 10 then
        self.TextDefeatRate1:SetText(string.format("%.0f%%", FateInfo.Percent))
    else
        self.TextDefeatRate1:SetText(string.format("%.1f%%", FateInfo.Percent))
    end

    -- 判断是否正在进行中
    local bIsInFateArea = (FateMgr.CurrentFate ~= nil and FateMgr.CurrentFate.ID == FateInfo.FateID)
    UIUtil.SetIsVisible(self.ImgDoing, bIsInFateArea)
end

-- 设置Fate事件相关信息
function FateArchiveInfoNewWinView:SetFateEventInfo(FateID)

end

function FateArchiveInfoNewWinView:SetLocationAndRate(ItemInfo, Describe)
    local FateGeneratorCfg = FateGeneratorCfgTable:FindCfgByKey(ItemInfo.FateID)
    local MapMap2areaCfg = MapMap2areaCfgTable:FindCfgByKey(FateGeneratorCfg.MapID)
    self.TextLocationName:SetText(MapMap2areaCfg.MapName)
    if ItemInfo.Percent >= 10 then
        self.TextDefeatRate:SetText(string.format("%.0f%%", ItemInfo.Percent))
    else
        self.TextDefeatRate:SetText(string.format("%.1f%%", ItemInfo.Percent))
    end
end

function FateArchiveInfoNewWinView:RefreshLRButton()
    UIUtil.SetIsVisible(self.BtnLeft, self.SelectedIndex ~= 1, true)
    UIUtil.SetIsVisible(self.BtnRight, self.SelectedIndex ~= #self.CurEventData, true)
end

function FateArchiveInfoNewWinView:OnHide()
end

function FateArchiveInfoNewWinView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.BtnLeft, self.OnBtnLeftClicked)
    UIUtil.AddOnClickedEvent(self, self.BtnRight, self.OnBtnRightClicked)
    UIUtil.AddOnClickedEvent(self, self.BtnToGet, self.OnBtnToGetClicked)
    UIUtil.AddOnClickedEvent(self, self.BtnToGet1, self.OnBtnToGetClicked)
    UIUtil.AddOnClickedEvent(self, self.BtnClose, self.OnClickBtnClose)
end

function FateArchiveInfoNewWinView:OnClickBtnClose()
    _G.UIViewMgr:HideView(self.ViewID)
end

function FateArchiveInfoNewWinView:OnRegisterGameEvent()
end

function FateArchiveInfoNewWinView:OnRegisterBinder()
end

function FateArchiveInfoNewWinView:OnBtnLeftClicked()
    if self.SelectedIndex > 1 then
        self:PlayAnimation(self.AnimArrowLeftIn)
        self.SelectedIndex = self.SelectedIndex - 1
        self:RefreshContent()
    end
end

function FateArchiveInfoNewWinView:OnBtnRightClicked()
    if self.SelectedIndex < #self.CurEventData then
        self:PlayAnimation(self.AnimArrowRightIn)
        self.SelectedIndex = self.SelectedIndex + 1
        self:RefreshContent()
    end
end

function FateArchiveInfoNewWinView:OnBtnToGetClicked()
    if (self.MonsterInfo ~= nil) then
        -- 这里先判断一下，如果FATE没有发现，那么不跳转，弹出提示框"暂未发现该危命任务"
        local bFateDiscover = _G.FateMgr:GetFateInfo(self.MonsterInfo.FateID) ~= nil
        if (not bFateDiscover) then
            MsgTipsUtil.ShowTipsByID(FateNotDiscoverMsgID)
        else
            self:Hide()
            EventMgr:SendEvent(EventID.FateCloseStatisticsPanel)
            EventMgr:SendEvent(EventID.FateOnFateSelected, self.MonsterInfo.FateID)
        end
    elseif (self.FateInfo ~= nil) then
        -- 这里先判断一下，如果FATE没有发现，那么不跳转，弹出提示框"暂未发现该危命任务"
        local bFateDiscover = _G.FateMgr:GetFateInfo(self.FateInfo.FateID) ~= nil
        if (not bFateDiscover) then
            MsgTipsUtil.ShowTipsByID(FateNotDiscoverMsgID)
        else
            self:Hide()
            EventMgr:SendEvent(EventID.FateCloseStatisticsPanel)
            EventMgr:SendEvent(EventID.FateOnFateSelected, self.FateInfo.FateID)
        end
    else
        _G.FLOG_ERROR("FateArchiveInfoNewWinView:OnBtnToGetClicked() 数据错误，请检查")
    end
end

function FateArchiveInfoNewWinView:OnBtnInforClicked()
    ItemTipsUtil.ShowTipsByResID(self.SpoilInfo.ResID, self.BtnInfor)
end

return FateArchiveInfoNewWinView
