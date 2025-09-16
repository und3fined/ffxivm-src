--[[
Author: jususchen jususchen@tencent.com
Date: 2024-05-21 10:13:25
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2024-05-29 16:45:40
FilePath: \Script\Game\PWorld\Entrance\View\PWorldMatchSelectionPanelView.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView =  require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

local PWorldEntVM = nil

---@class PWorldMatchSelectionPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnSelect01 UFButton
---@field BtnSelect02 UFButton
---@field BtnSelect03 UFButton
---@field PanelBottom UFCanvasPanel
---@field PanelBottomEnglish UFCanvasPanel
---@field PanelTab01 UFCanvasPanel
---@field PanelTab02 UFCanvasPanel
---@field PanelTab03 UFCanvasPanel
---@field SelectFrame01 PWorldTabSelectFrameItemView
---@field SelectFrame02 PWorldTabSelectFrameItemView
---@field SelectFrame03 PWorldTabSelectFrameItemView
---@field TableViewTab UTableView
---@field TextSelect01 UFTextBlock
---@field TextSelect02 UFTextBlock
---@field TextSelect03 UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PWorldMatchSelectionPanelView = LuaClass(UIView, true)

function PWorldMatchSelectionPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnSelect01 = nil
	--self.BtnSelect02 = nil
	--self.BtnSelect03 = nil
	--self.PanelBottom = nil
	--self.PanelBottomEnglish = nil
	--self.PanelTab01 = nil
	--self.PanelTab02 = nil
	--self.PanelTab03 = nil
	--self.SelectFrame01 = nil
	--self.SelectFrame02 = nil
	--self.SelectFrame03 = nil
	--self.TableViewTab = nil
	--self.TextSelect01 = nil
	--self.TextSelect02 = nil
	--self.TextSelect03 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PWorldMatchSelectionPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.SelectFrame01)
	self:AddSubView(self.SelectFrame02)
	self:AddSubView(self.SelectFrame03)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PWorldMatchSelectionPanelView:OnInit()
	PWorldEntVM = _G.PWorldEntVM
	self.AdpTableSelection = UIAdapterTableView.CreateAdapter(self, self.TableViewTab)
	self.AdpTableSelection:SetOnClickedCallback(self.OnMenuItemClicked)
	self.Binders = {
		{ "MatchSelectionTypes",    UIBinderUpdateBindableList.New(self, self.AdpTableSelection) },
		{ "ChineseTabVisibility", UIBinderSetIsVisible.New(self, self.PanelBottom) },
		{ "OtherTabVisibility", UIBinderSetIsVisible.New(self, self.PanelBottomEnglish) },
	}
end


function PWorldMatchSelectionPanelView:OnRegisterBinder()
	self:RegisterBinders(PWorldEntVM, self.Binders)
end

local function SelectTabItem(Index)
	PWorldEntVM:ChangePWorldEntranceMenu(Index)
	_G.EventMgr:SendEvent(_G.EventID.PWorldEntSwitch, Index)
end

function PWorldMatchSelectionPanelView:SetDefaultSelected(JumpTab)
	self.AdpTableSelection:SetSelectedIndex(JumpTab)
	if JumpTab ~= 1 then
		SelectTabItem(JumpTab)
	end
end

---@param Index number
---@param ItemData PWorldSelectionItemVM
function PWorldMatchSelectionPanelView:OnMenuItemClicked(Index, ItemData)
	if not ItemData then
		return
	end

	if not ItemData.bTabUnlock then
		_G.MsgTipsUtil.ShowTipsByID(146060)
		return 
	end

	SelectTabItem(Index)
end

return PWorldMatchSelectionPanelView