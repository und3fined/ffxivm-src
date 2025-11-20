---
--- Author: zerodeng
--- DateTime: 2025-05-29 10:53
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local GoldSauserMainPanelAwardWinView = require("Game/GoldSauserMainPanel/View/GoldSauserMainPanelAwardWinView")
local WilderExploreAwardTypeCfg = require("TableCfg/WilderExploreAwardTypeCfg")
local WilderExploreAwardShowCfg = require("TableCfg/WilderExploreAwardShowCfg")

---@class WorldExploraAwardWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClose UFButton
---@field BtnGoto CommBtnLView
---@field Comm152Slot CommBackpack152SlotView
---@field CommDropDown CommDropDownListView
---@field CommEmpty CommBackpackEmptyView
---@field CommSingleBox CommSingleBoxView
---@field FCanvasPanel_126 UFCanvasPanel
---@field FDynamicEntryBox_209 UFDynamicEntryBox
---@field IconReceive USizeBox
---@field RichTextBoxItemDescription URichTextBox
---@field RichTextSchedule URichTextBox
---@field ScrollBox_0 UScrollBox
---@field TableViewGatWay UTableView
---@field TableViewTab UTableView
---@field TableViewThing UTableView
---@field TextAchievements UFTextBlock
---@field TextThingName UFTextBlock
---@field TextTitle UFTextBlock
---@field ToggleBtnCollect UToggleButton
---@field AnimIn UWidgetAnimation
---@field AnimLoop UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field AnimTableViewTabSelectionChanged UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WorldExploraAwardWinView = LuaClass(GoldSauserMainPanelAwardWinView, true)

function WorldExploraAwardWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClose = nil
	--self.BtnGoto = nil
	--self.Comm152Slot = nil
	--self.CommDropDown = nil
	--self.CommEmpty = nil
	--self.CommSingleBox = nil
	--self.FCanvasPanel_126 = nil
	--self.FDynamicEntryBox_209 = nil
	--self.IconReceive = nil
	--self.RichTextBoxItemDescription = nil
	--self.RichTextSchedule = nil
	--self.ScrollBox_0 = nil
	--self.TableViewGatWay = nil
	--self.TableViewTab = nil
	--self.TableViewThing = nil
	--self.TextAchievements = nil
	--self.TextThingName = nil
	--self.TextTitle = nil
	--self.ToggleBtnCollect = nil
	--self.AnimIn = nil
	--self.AnimLoop = nil
	--self.AnimOut = nil
	--self.AnimTableViewTabSelectionChanged = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WorldExploraAwardWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnGoto)
	self:AddSubView(self.Comm152Slot)
	self:AddSubView(self.CommDropDown)
	self:AddSubView(self.CommEmpty)
	self:AddSubView(self.CommSingleBox)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WorldExploraAwardWinView:GetMainPanelTitle()
	return _G.LSTR(1610031)
end

function WorldExploraAwardWinView:GetAllAwardTypeCfg()
	return WilderExploreAwardTypeCfg:FindAllCfg("1=1")
end

function WorldExploraAwardWinView:GetAllAwardShowCfgByType(AwardType)
	return WilderExploreAwardShowCfg:FindAllCfg(string.format("AwardType = %d", AwardType))
end

function WorldExploraAwardWinView:GetAwardTypeCfgByType(AwardType)
	return WilderExploreAwardTypeCfg:FindCfgByKey(AwardType)
end

function WorldExploraAwardWinView:GetAwardShowCfgByID(ID)
    local ItemCfg = WilderExploreAwardShowCfg:FindCfgByKey(ID)
    if not ItemCfg then
        _G.FLOG_ERROR("WorldExploraAwardWinView:GetAwardShowCfgByID id:{%d} is not In Config", ID)
        return
    end

	return ItemCfg
end

return WorldExploraAwardWinView