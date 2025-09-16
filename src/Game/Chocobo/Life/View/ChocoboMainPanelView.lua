---
--- Author: Administrator
--- DateTime: 2023-12-14 10:54
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ProtoRes = require("Protocol/ProtoRes")
local EventID = require("Define/EventID")
local ChocoboUiIconCfg = require("TableCfg/ChocoboUiIconCfg")
local ChocoboDefine = require("Game/Chocobo/ChocoboDefine")
local UIViewID = require("Define/UIViewID")
local ProtoCommon = require("Protocol/ProtoCommon")

local LSTR = nil
local ChocoboMainVM = nil
local ChocoboMgr = nil

---@class ChocoboMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClose CommonCloseBtnView
---@field CommonTitle CommonTitleView
---@field ImageRole UFImage
---@field VerIconTabs CommVerIconTabsView
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChocoboMainPanelView = LuaClass(UIView, true)

function ChocoboMainPanelView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClose = nil
	--self.CommonTitle = nil
	--self.ImageRole = nil
	--self.VerIconTabs = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChocoboMainPanelView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnClose)
	self:AddSubView(self.CommonTitle)
	self:AddSubView(self.VerIconTabs)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChocoboMainPanelView:OnInit()
    LSTR = _G.LSTR
    ChocoboMgr = _G.ChocoboMgr
    ChocoboMainVM = _G.ChocoboMainVM
    self.ChocoboMainTabIconPath = {
        { IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Contest_Default_Normal.UI_Icon_Tab_Contest_Default_Normal'",
          SelectIcon = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Contest_Default_Select.UI_Icon_Tab_Contest_Default_Select'",},
        { IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Contest_Chocobos_Normal.UI_Icon_Tab_Contest_Chocobos_Normal'",
          SelectIcon = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Contest_Chocobos_Select.UI_Icon_Tab_Contest_Chocobos_Select'",},
        --{ IconPath = "PaperSprite'/Game/UI/Atlas/Chocobo/Frames/UI_Chocobo_Icon_Tab03_png.UI_Chocobo_Icon_Tab03_png'",
        --          SelectIcon = "PaperSprite'/Game/UI/Atlas/Chocobo/Frames/UI_Chocobo_Icon_Tab03_Select_png.UI_Chocobo_Icon_Tab03_Select_png'",},
        { IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Contest_Skill_Normal.UI_Icon_Tab_Contest_Skill_Normal'",
          SelectIcon = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Contest_Skill_Select.UI_Icon_Tab_Contest_Skill_Select'",},
    }
    self.CurrentIndex = ChocoboDefine.PAGE_INDEX.INFO_PAGE
end

function ChocoboMainPanelView:OnDestroy()

end

function ChocoboMainPanelView:OnShow()
    _G.ChocoboShowModelMgr:SetImageRole(self.ImageRole)
    self:InitConstInfo()
    ChocoboMgr:ReqQuery()
    ChocoboMgr:ReqQuerySkillList()
    ChocoboMgr:ReqQueryTitle()

    local _IsModuelOpen = _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDBuddy)
    if _IsModuelOpen then
        _G.BuddyMgr:ReqUsedColor()
        _G.BuddyMgr:ReqUsedArmor()
    end
    
    local PageIndex = 1
    if self.Params ~= nil and self.Params.PageIndex ~= nil then
        PageIndex = self.Params.PageIndex
    end
    self.VerIconTabs:UpdateItems(self.ChocoboMainTabIconPath, PageIndex, 0)
    _G.LightMgr:EnableUIWeather(ChocoboDefine.ChocoboMainLightID)
end

function ChocoboMainPanelView:ChangePage(PageIndex)
    self.VerIconTabs:SetSelectedIndex(PageIndex)
end

function ChocoboMainPanelView:InitConstInfo()
    if self.IsInitConstInfo then
        return
    end

    self.IsInitConstInfo = true

    -- LSTR string: 竞赛陆行鸟
    self.CommonTitle:SetTextTitleName(LSTR(420001))
    self.CommonTitle.CommInforBtn:SetHelpInfoID(11030)
end

function ChocoboMainPanelView:OnHide()
    _G.LightMgr:DisableUIWeather()
    self:HideCurrentView()
    _G.ChocoboShowModelMgr:OnHide()
end

function ChocoboMainPanelView:OnRegisterUIEvent()
    UIUtil.AddOnSelectionChangedEvent(self, self.VerIconTabs, self.OnSelectionChangedCommVerIconTabs)
end

function ChocoboMainPanelView:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.ChocoboMainTabSelect, self.OnGameEventChocoboMainTabSelect)
    --本地传送
    self:RegisterGameEvent(EventID.PWorldTransBegin, self.OnGameEventNeedHide)
    --切地图
    self:RegisterGameEvent(EventID.WorldPostLoad, self.OnGameEventNeedHide)
end

function ChocoboMainPanelView:OnRegisterBinder()
end

function ChocoboMainPanelView:OnGameEventChocoboMainTabSelect(Params)
    self.VerIconTabs:SetSelectedIndex(Params.Index)
end

function ChocoboMainPanelView:OnGameEventNeedHide()
    self:Hide()
end

function ChocoboMainPanelView:HideCurrentView()
    if _G.UIViewMgr:IsViewVisible(UIViewID.ChocoboSkillSideWinView) then
        _G.UIViewMgr:HideView(UIViewID.ChocoboSkillSideWinView)
    end
    
    if self.CurrentIndex == ChocoboDefine.PAGE_INDEX.INFO_PAGE then
        _G.UIViewMgr:HideView(UIViewID.ChocoboInfoPanelView)
    elseif self.CurrentIndex == ChocoboDefine.PAGE_INDEX.LIST_PAGE then
        _G.UIViewMgr:HideView(UIViewID.ChocoboOverviewPanelView)
        if _G.UIViewMgr:IsViewVisible(UIViewID.ChocoboRelationPageView) then
            _G.UIViewMgr:HideView(UIViewID.ChocoboRelationPageView, true)
        end
    elseif self.CurrentIndex == ChocoboDefine.PAGE_INDEX.SKILL_PAGE then
        _G.UIViewMgr:HideView(UIViewID.ChocoboSkillPanelView)
    end
end

function ChocoboMainPanelView:OnSelectionChangedCommVerIconTabs(Index, ItemData, ItemView, bClick)
    self:HideCurrentView()
    -- Show new view.
    if Index == ChocoboDefine.PAGE_INDEX.INFO_PAGE then
        -- LSTR string: 竞赛陆行鸟
        -- LSTR string: 默认陆行鸟
        self.CommonTitle:SetTextTitleName(LSTR(420001))
        self.CommonTitle:SetTextSubtitle(LSTR(420058))
        self.CommonTitle:SetCommInforBtnIsVisible(false)
        _G.UIViewMgr:ShowView(UIViewID.ChocoboInfoPanelView)
    elseif Index == ChocoboDefine.PAGE_INDEX.LIST_PAGE then
        -- LSTR string: 竞赛陆行鸟
        -- LSTR string: 陆行鸟一览
        self.CommonTitle:SetTextTitleName(LSTR(420001))
        self.CommonTitle:SetTextSubtitle(LSTR(420059))
        self.CommonTitle:SetCommInforBtnIsVisible(false)
        _G.UIViewMgr:ShowView(UIViewID.ChocoboOverviewPanelView)
    elseif Index == ChocoboDefine.PAGE_INDEX.SKILL_PAGE then
        -- LSTR string: 竞赛陆行鸟
        -- LSTR string: 技能%d/%d
        local num, max = ChocoboMgr:GetHasSkillNum()
        self.CommonTitle:SetTextTitleName(LSTR(420001))
        self.CommonTitle:SetTextSubtitle(string.format(LSTR(420060), num, max))
        self.CommonTitle:SetCommInforBtnIsVisible(true)
        _G.UIViewMgr:ShowView(UIViewID.ChocoboSkillPanelView)
    end
    self.CurrentIndex = Index
    _G.ObjectMgr:CollectGarbage(false)
end

return ChocoboMainPanelView