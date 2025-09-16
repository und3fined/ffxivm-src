---
--- Author: lydianwang
--- DateTime: 2023-05-31 10:32
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")

local EventID = _G.EventID
local EventMgr = _G.EventMgr
---@class CommScreenerBarView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClearTag UFButton
---@field TableViewTags UTableView
---@field TextScreener UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommScreenerBarView = LuaClass(UIView, true)

function CommScreenerBarView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClearTag = nil
	--self.TableViewTags = nil
	--self.TextScreener = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommScreenerBarView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommScreenerBarView:OnInit()
	self.ScreenerTagTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewTags)
end

function CommScreenerBarView:OnDestroy()
end

function CommScreenerBarView:OnShow()
end

function CommScreenerBarView:OnHide()
end

---@type 清理所有tag
function CommScreenerBarView:Clear()
	self.ViewModel:UpdateView(nil)
end

function CommScreenerBarView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnClearTag, self.OnClickedBtnClearTag)
end

function CommScreenerBarView:OnClickedBtnClearTag()
	local Params = self.Params
	if nil == Params then return end

	local ViewModel = Params.Data
	if nil == ViewModel then return end

	if ViewModel.ScreenerTagVMList:Length() == 0 then
		return
	end

	EventMgr:SendEvent(EventID.ScreenerResult, nil)
end

function CommScreenerBarView:OnScreenerAction(ScreenerResult)
	local Params = self.Params
	if nil == Params then return end

	local ViewModel = Params.Data
	if nil == ViewModel then return end

	if ScreenerResult == nil then
		ViewModel:UpdateByScreenerList({})
	else
		ViewModel:UpdateByScreenerList(ScreenerResult.ScreenerList)
	end
end

function CommScreenerBarView:ClearBar()
	local Params = self.Params
	if nil == Params then return end

	local ViewModel = Params.Data
	if nil == ViewModel then return end

	ViewModel:UpdateByScreenerList({})
end

function CommScreenerBarView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.ScreenerResult, self.OnScreenerAction)
end

function CommScreenerBarView:OnUpdateScreenerBarTag(CommScreenerItemList)
	local Params = self.Params
	if nil == Params then return end

	local ViewModel = Params.Data
	if nil == ViewModel then return end

	ViewModel:UpdateVM(CommScreenerItemList)
end

function CommScreenerBarView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then return end

	local ViewModel = Params.Data
	if nil == ViewModel then return end

	local Binders = {
		{ "ScreenerTagVMList", UIBinderUpdateBindableList.New(self, self.ScreenerTagTableViewAdapter) },
	}

	self:RegisterBinders(ViewModel, Binders)
	self.TextScreener:SetText(_G.LSTR(1480001))
	
end

return CommScreenerBarView