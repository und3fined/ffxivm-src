--[[
Author: v_vvxinchen v_vvxinchen@tencent.com
Date: 2025-01-22 16:07:49
LastEditors: v_vvxinchen v_vvxinchen@tencent.com
LastEditTime: 2025-01-22 16:25:21
FilePath: \Client\Source\Script\Game\FishNotesNew\View\FishIngholeInfoWinView.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
---
--- Author: v_vvxinchen
--- DateTime: 2025-01-06 10:07
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local HelpCfg = require("TableCfg/HelpCfg")
local HelpInfoUtil = require("Utils/HelpInfoUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local CommHelpInfoWinVM =  require("Game/Common/Tips/VM/CommHelpInfoWinVM")
local LSTR = _G.LSTR

---@class FishIngholeInfoWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BG Comm2FrameLView
---@field Menu CommMenuView
---@field PanelContent1 UFCanvasPanel
---@field PanelContent2 UFCanvasPanel
---@field RichTextContent URichTextBox
---@field RichTextContent1 URichTextBox
---@field RichTextContent2 URichTextBox
---@field RichTextContent3 URichTextBox
---@field TableViewContent UTableView
---@field AnimTreeViewMenuSelectionChanged UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FishIngholeInfoWinView = LuaClass(UIView, true)

function FishIngholeInfoWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BG = nil
	--self.Menu = nil
	--self.PanelContent1 = nil
	--self.PanelContent2 = nil
	--self.RichTextContent = nil
	--self.RichTextContent1 = nil
	--self.RichTextContent2 = nil
	--self.RichTextContent3 = nil
	--self.TableViewContent = nil
	--self.AnimTreeViewMenuSelectionChanged = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FishIngholeInfoWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BG)
	self:AddSubView(self.Menu)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FishIngholeInfoWinView:OnInit()
	self.VM = CommHelpInfoWinVM.New()
	self.TableViewContentAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewContent, nil , false)
	self.Binders = {}
end

function FishIngholeInfoWinView:OnDestroy()

end

function FishIngholeInfoWinView:OnShow()
	--'咬钩强度根据玩家头顶感叹号数量分为<span color="#d1ba8e">轻杆，中杆和鱼王杆，</>根据以小钓大的提示，使用不同的提杆技能'
	self.RichTextContent:SetText(LSTR(180094))
	self.RichTextContent1:SetText(LSTR(180091)) --"轻杆"
	self.RichTextContent2:SetText(LSTR(180092))--"中杆"
	self.RichTextContent3:SetText(LSTR(180093))--"鱼王杆"

	local Tabs = {{Key = 1, Name = LSTR(180076)}, {Key = 2, Name = LSTR(180077)}} --"笔记说明" --"以小钓大"
    self.Menu:UpdateItems(Tabs)
    self.Menu:SetSelectedIndex(1)

	local HelpCfgs = HelpCfg:FindAllHelpIDCfg(11111)
	local Cfgs = HelpInfoUtil.ParseContent(HelpCfgs)
	self.VM:InitVM(Cfgs)
end

function FishIngholeInfoWinView:OnHide()

end

function FishIngholeInfoWinView:OnRegisterUIEvent()
	UIUtil.AddOnSelectionChangedEvent(self, self.Menu, self.OnSelectionChangedCommMenu)
end

function FishIngholeInfoWinView:OnRegisterGameEvent()

end

function FishIngholeInfoWinView:OnRegisterBinder()
	local Binders = {
		{"TextTitle", UIBinderSetText.New(self, self.BG.FText_Title)},
		{"TableViewContentList", UIBinderUpdateBindableList.New(self, self.TableViewContentAdapter)},
	}
	self:RegisterBinders(self.VM, Binders)
end

function FishIngholeInfoWinView:OnSelectionChangedCommMenu(Index, ItemData, ItemView)
	local Key = ItemData.Key
    if Key == nil then
        return
    end
    if Key == 1 then
        UIUtil.SetIsVisible(self.PanelContent1, true)
        UIUtil.SetIsVisible(self.PanelContent2, false)
    elseif Key == 2 then
        UIUtil.SetIsVisible(self.PanelContent1, false)
        UIUtil.SetIsVisible(self.PanelContent2, true)
    end
end

return FishIngholeInfoWinView