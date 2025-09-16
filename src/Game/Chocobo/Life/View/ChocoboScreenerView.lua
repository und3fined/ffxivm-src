---
--- Author: Administrator
--- DateTime: 2024-10-22 15:56
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local ChocoboScreenerVM = require("Game/Chocobo/Life/VM/ChocoboScreenerVM")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetIsEnabled = require("Binder/UIBinderSetIsEnabled")

---@class ChocoboScreenerView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Bg Comm2FrameLView
---@field BtnConfirm CommBtnLView
---@field BtnReset CommBtnLView
---@field TableViewGender UTableView
---@field TableViewGeneration UTableView
---@field TableViewOwner UTableView
---@field TextContent UFTextBlock
---@field TextContent_1 UFTextBlock
---@field TextContent_2 UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChocoboScreenerView = LuaClass(UIView, true)

function ChocoboScreenerView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Bg = nil
	--self.BtnConfirm = nil
	--self.BtnReset = nil
	--self.TableViewGender = nil
	--self.TableViewGeneration = nil
	--self.TableViewOwner = nil
	--self.TextContent = nil
	--self.TextContent_1 = nil
	--self.TextContent_2 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChocoboScreenerView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Bg)
	self:AddSubView(self.BtnConfirm)
	self:AddSubView(self.BtnReset)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChocoboScreenerView:OnInit()
	self.ViewModel = ChocoboScreenerVM.New()
	
	self.TableViewGenerationAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewGeneration)
	self.TableViewOwnerAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewOwner)
	self.TableViewGenderAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewGender)
	
	self.TableViewGenerationAdapter:SetOnClickedCallback(self.OnConditionStrChange)
	self.TableViewOwnerAdapter:SetOnClickedCallback(self.OnConditionStrChange)
	self.TableViewGenderAdapter:SetOnClickedCallback(self.OnConditionStrChange)
end

function ChocoboScreenerView:OnDestroy()

end

function ChocoboScreenerView:OnShow()
	self:InitConstInfo()
	self.BtnConfirm:SetIsDisabledState(true, false)
end

function ChocoboScreenerView:InitConstInfo()
	if self.IsInitConstInfo then
		return
	end

	self.IsInitConstInfo = true

	-- LSTR string: 筛选器
	self.Bg:SetTitleText(_G.LSTR(420054))
	-- LSTR string: 代数
	self.TextContent:SetText(_G.LSTR(420019))
	-- LSTR string: 归属
	self.TextContent_1:SetText(_G.LSTR(420020))
	-- LSTR string: 性别
	self.TextContent_2:SetText(_G.LSTR(420021))
	-- LSTR string: 重置
	self.BtnReset:SetText(_G.LSTR(420158))
	-- LSTR string: 确定
	self.BtnConfirm:SetText(_G.LSTR(420159))
end

function ChocoboScreenerView:OnHide()

end

function ChocoboScreenerView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnReset.Button, self.OnClickedResetBtn)
	UIUtil.AddOnClickedEvent(self, self.BtnConfirm.Button, self.OnClickedConfirmBtn)
end

function ChocoboScreenerView:OnRegisterGameEvent()

end

function ChocoboScreenerView:OnRegisterBinder()
	local Binders = {
		{ "GenerationListVMList", UIBinderUpdateBindableList.New(self, self.TableViewGenerationAdapter) },
		{ "OwnerListVMList", UIBinderUpdateBindableList.New(self, self.TableViewOwnerAdapter) },
		{ "GenderListVMList", UIBinderUpdateBindableList.New(self, self.TableViewGenderAdapter) },
	}
	
	self:RegisterBinders(self.ViewModel, Binders)
end

function ChocoboScreenerView:OnTableViewOwnerItemClicked(Index, ItemData, ItemView)
	self.ViewModel:ResetOwnerScreener()
end

function ChocoboScreenerView:OnTableViewGenderItemClicked(Index, ItemData, ItemView)
	self.ViewModel:ResetGenderScreener()
end

function ChocoboScreenerView:OnClickedResetBtn()
	self.ViewModel:ResetScreener()
	self:OnConditionStrChange()
end

function ChocoboScreenerView:OnClickedConfirmBtn()
	self.ViewModel:SureScreener()
	self:Hide()
end

function ChocoboScreenerView:OnConditionStrChange()
	self.BtnConfirm:SetIsNormalState(true)
end

return ChocoboScreenerView