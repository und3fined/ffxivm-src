---
--- Author: michaelyang_lightpaw
--- DateTime: 2024-09-27 10:20
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local SidebarDefine = require("Game/Sidebar/SidebarDefine")
local CardCfg = require("TableCfg/FantasyCardCfg")

---@class SidebarLeftWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClick UFButton
---@field ImgAetherCurrents UFImage
---@field ImgDiscoverNote UFImage
---@field ImgFate UFImage
---@field ImgLevel_1 UFImage
---@field PanelAchievement UFCanvasPanel
---@field RichTextContent URichTextBox
---@field RichTextTitle URichTextBox
---@field SidebarMagicCard SidebarCardItemView
---@field TextLevel UFTextBlock
---@field AnimHide UWidgetAnimation
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SidebarLeftWinView = LuaClass(UIView, true)

function SidebarLeftWinView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClick = nil
	--self.ImgAetherCurrents = nil
	--self.ImgDiscoverNote = nil
	--self.ImgFate = nil
	--self.ImgLevel_1 = nil
	--self.PanelAchievement = nil
	--self.RichTextContent = nil
	--self.RichTextTitle = nil
	--self.SidebarMagicCard = nil
	--self.TextLevel = nil
	--self.AnimHide = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SidebarLeftWinView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.SidebarMagicCard)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SidebarLeftWinView:OnInit()
    self.SymbolTable = {}
    self.SymbolTable[SidebarDefine.LeftSidebarType.Achievement] = self.PanelAchievement
    self.SymbolTable[SidebarDefine.LeftSidebarType.AetherCurrents] = self.ImgAetherCurrents
    self.SymbolTable[SidebarDefine.LeftSidebarType.Fate] = self.ImgFate
    self.SymbolTable[SidebarDefine.LeftSidebarType.FantacyCard] = self.SidebarMagicCard
    self.SymbolTable[SidebarDefine.LeftSidebarType.DiscoverNote] = self.ImgDiscoverNote
end

function SidebarLeftWinView:OnDestroy()
end

---@param InData            	table 		传入数据
---@param InData.Content        string      内容
---@param InData.ClickCallback  function    点击回调
---@param InData.xx  			any    	 	自定义数据
function SidebarLeftWinView:OnShow()
    self:StopAnimation(self.AnimHide)
    local InData = self.Params
    if (InData.Type == SidebarDefine.LeftSidebarType.None) then
        _G.FLOG_ERROR("传入的 Param.Type 无效，请检查")
        self:Hide()
        return
    end

    local InDataTable = InData.DataTable

    self.ClickCallback = InDataTable.ClickCallback

    if (InDataTable.Content ~= nil) then
        self.RichTextContent:SetText(InDataTable.Content)
    else
        self.RichTextContent:SetText("")
    end

    if (InDataTable.Title ~= nil) then
        self.RichTextTitle:SetText(InDataTable.Title)
    end

    for Index = 1, #self.SymbolTable do
        UIUtil.SetIsVisible(self.SymbolTable[Index], InData.Type == Index)
    end

    if (InData.Type == SidebarDefine.LeftSidebarType.Achievement) then
        self:InternalShowAchievement(InDataTable)
    elseif (InData.Type == SidebarDefine.LeftSidebarType.AetherCurrents) then
        self:InternalShowAetherCurrents(InDataTable)
    elseif (InData.Type == SidebarDefine.LeftSidebarType.Fate) then
        self:InternalShowFate(InDataTable)
    elseif (InData.Type == SidebarDefine.LeftSidebarType.FantacyCard) then
        -- 显示幻卡相关
        self:InternalShowFantacyCard(InDataTable)
    elseif (InData.Type == SidebarDefine.LeftSidebarType.DiscoverNote) then
        self:InternalShowDiscoverNote(InDataTable)
    else
        _G.FLOG_ERROR("SidebarLeftWinView 未处理的类型：" .. tostring(InData.Type))
    end
end

function SidebarLeftWinView:InternalShowDiscoverNote(InDataTable)
    self.RichTextTitle:SetText(LSTR(330015))
end

function SidebarLeftWinView:InternalShowFantacyCard(InDataTable)
    self.RichTextTitle:SetText(LSTR(1130092))

    local CardID = InDataTable.CardID
    self.SidebarMagicCard:RefreshCardInfo(CardID)

    local ItemCfg = CardCfg:FindCfgByKey(CardID)
    if (ItemCfg ~= nil) then
        self.RichTextContent:SetText(ItemCfg.Name)
    else
        _G.FLOG_ERROR("无法找到 CardCfg 数据，传入的ID是：" .. tostring(CardID))
    end

    local function ClickCallbackToShowCard()
        _G.MagicCardCollectionMgr:ShowMagicCardCollectionMainPanel(CardID)
        self:Hide()
    end
    self.ClickCallback = ClickCallbackToShowCard
end

function SidebarLeftWinView:InternalShowAetherCurrents(InDataTable)
    self.RichTextTitle:SetText(LSTR(310028))
end

function SidebarLeftWinView:InternalShowAchievement(InDataTable)
    self.RichTextTitle:SetText(LSTR(720024))
	local AchievePoint = 0
	local ImgLevelPath = ""
    local TextName = ""
    local Info = _G.AchievementMgr:GetAchievementInfo(InDataTable.AchievementID)
    if Info ~= nil then
        AchievePoint = Info.AchievePoint
        ImgLevelPath = Info.AchievePointIcon
        TextName = Info.TextName
    end
    self.RichTextContent:SetText(TextName)
    self.TextLevel:SetText(tostring(AchievePoint))
    UIUtil.ImageSetBrushFromAssetPath(self.ImgLevel_1, ImgLevelPath)    
end

function SidebarLeftWinView:InternalShowFate(InDataTable)
    local Title = string.format('%s<span color="#bd8213">%s</>', LSTR(190120), LSTR(190121))
    self.RichTextTitle:SetText(Title)
end

function SidebarLeftWinView:OnHide()
end

function SidebarLeftWinView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.BtnClick, self.OnBtnClick)
end
function SidebarLeftWinView:OnBtnClick()
    -- 正在播放剧情，点击无效
    if (_G.StoryMgr:SequenceIsPlaying()) then
        return
    end
    if (self.ClickCallback ~= nil) then
        self.ClickCallback()
    end
end

function SidebarLeftWinView:OnRegisterGameEvent()
end

function SidebarLeftWinView:OnRegisterBinder()
end

return SidebarLeftWinView
