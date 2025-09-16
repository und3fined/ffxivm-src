--[[
Author: v_hggzhang
Date: 2023-02-03 10:32
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2025-01-03 16:07:23
FilePath: \Script\Game\PWorld\Match\View\PWorldMatchDetailWinView.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIAdapterTableView =  require("UI/Adapter/UIAdapterTableView")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIUtil = require("Utils/UIUtil")

local PWorldMatchVM

---@class PWorldMatchDetailWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BG Comm2FrameLView
---@field CommSingleBoxAll CommSingleBoxView
---@field FHorizontalBox_0 UFHorizontalBox
---@field RichTextTips URichTextBox
---@field TableViewList UTableView
---@field TextTips URichTextBox
---@field AnimFirstShowTips UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PWorldMatchDetailWinView = LuaClass(UIView, true)

function PWorldMatchDetailWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BG = nil
	--self.CommSingleBoxAll = nil
	--self.FHorizontalBox_0 = nil
	--self.RichTextTips = nil
	--self.TableViewList = nil
	--self.TextTips = nil
	--self.AnimFirstShowTips = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PWorldMatchDetailWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BG)
	self:AddSubView(self.CommSingleBoxAll)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PWorldMatchDetailWinView:OnPostInit()
	PWorldMatchVM = _G.PWorldMatchVM
	self.AdpMatchItem = UIAdapterTableView.CreateAdapter(self, self.TableViewList)
	self.Binders = {
		{ "MatchItemVMs",   UIBinderUpdateBindableList.New(self, self.AdpMatchItem) },
		{ "Title",    	    UIBinderSetText.New(self, self.TextTips) },
		{ "bShowRobotGuide", UIBinderValueChangedCallback.New(self, nil, self.OnShowRobotGuide)},
		{ "bRobotGuideChecked", UIBinderValueChangedCallback.New(self, nil, function(_, Value)
			self.CommSingleBoxAll:SetChecked(Value, false)
		end)},
	}

	self.CommSingleBoxAll:SetStateChangedCallback(self, self.OnClickCheckAll)

	self.BG:SetTitleText(_G.LSTR(1320148))
	self.RichTextTips:SetText(_G.LSTR(1320218))
end

function PWorldMatchDetailWinView:OnRegisterTimer()
	local PWorldEntDefine = require("Game/PWorld/Entrance/PWorldEntDefine")
	self:RegisterTimer(function()
		_G.PWorldMatchMgr:ReqQueryRankMatch()
	end, PWorldEntDefine.MatchRankUpdInv, PWorldEntDefine.MatchRankUpdInv, 0)
end

function PWorldMatchDetailWinView:OnHide()
	_G.PWorldMatchMgr:TryResumeSideBar()
	_G.SidebarMgr:TryOpenSidebarMainWin()
end
function PWorldMatchDetailWinView:OnRegisterBinder()
	self:RegisterBinders(PWorldMatchVM, self.Binders)
end

function PWorldMatchDetailWinView:OnShow()
	self.CommSingleBoxAll:SetText(_G.LSTR(1320229))

	_G.PWorldMatchMgr:ReqQueryRankMatch()
end

function PWorldMatchDetailWinView:OnClickCheckAll(bChecked)
	for _, Item in ipairs(PWorldMatchVM.MatchItemVMs:GetItems()) do
		if Item.bShowRobotMatchCheck then
			Item:SetRobotMatchChecked(bChecked)
		end
	end
end

local bShowGuideAnim

function PWorldMatchDetailWinView:OnShowRobotGuide(Value)
	UIUtil.SetIsVisible(self.CommSingleBoxAll, Value)
	UIUtil.SetIsVisible(self.RichTextTips, Value)

	if Value and not bShowGuideAnim then
		bShowGuideAnim = true
		self:PlayAnimation(self.AnimFirstShowTips)
	end
end

return PWorldMatchDetailWinView