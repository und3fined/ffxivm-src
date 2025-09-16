---
--- Author: xingcaicao
--- DateTime: 2023-04-13 16:03
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local PersonInfoVM = require("Game/PersonInfo/VM/PersonInfoVM")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

---@class PersonInfoProfPerferredItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnDelete UFButton
---@field DeleteNode UFCanvasPanel
---@field EditableStateNode UFCanvasPanel
---@field EmptyStateNode UFCanvasPanel
---@field ProfItemPanel PersonInfoProfItemView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PersonInfoProfPerferredItemView = LuaClass(UIView, true)

function PersonInfoProfPerferredItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnDelete = nil
	--self.DeleteNode = nil
	--self.EditableStateNode = nil
	--self.EmptyStateNode = nil
	--self.ProfItemPanel = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PersonInfoProfPerferredItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.ProfItemPanel)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PersonInfoProfPerferredItemView:OnInit()
	self.Binders = {
		{ "IsEmpty", UIBinderSetIsVisible.New(self, self.EmptyStateNode) },
		{ "IsEmpty", UIBinderSetIsVisible.New(self, self.EditableStateNode, true) },
	}

	self.BindersPersonInfoVM = {
		{ "IsMajor", UIBinderSetIsVisible.New(self, self.DeleteNode, false, true) },
	}
end

function PersonInfoProfPerferredItemView:OnDestroy()

end

function PersonInfoProfPerferredItemView:OnShow()

end

function PersonInfoProfPerferredItemView:OnHide()

end

function PersonInfoProfPerferredItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnDelete, self.OnClickButtonDelete)
end

function PersonInfoProfPerferredItemView:OnRegisterGameEvent()

end

function PersonInfoProfPerferredItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if ViewModel then
		self:RegisterBinders(ViewModel, self.Binders)
	end
	
	self.TextPlayerName:SetText(_G.LSTR(620102))

	self:RegisterBinders(PersonInfoVM, self.BindersPersonInfoVM)
end

function PersonInfoProfPerferredItemView:OnClickButtonDelete()
	if nil == self.Params or nil == self.Params.Data then
		return
	end

	local CurCnt = PersonInfoVM.PerfProfCnt

	if CurCnt <= 1 then
		_G.MsgTipsUtil.ShowTips(_G.LSTR(620142))
		return
	end

	PersonInfoVM:DeletePerferredProf(self.Params.Data.ProfID)
end

return PersonInfoProfPerferredItemView