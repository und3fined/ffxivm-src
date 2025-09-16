---
--- Author: xingcaicao
--- DateTime: 2023-04-13 15:49
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local PersonInfoVM = require("Game/PersonInfo/VM/PersonInfoVM")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetIsEnabled = require("Binder/UIBinderSetIsEnabled")

---@class PersonInfoPerferredProfPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnCancel CommBtnLView
---@field BtnOk CommBtnLView
---@field FrameL Comm2FrameLView
---@field TableViewAttack UTableView
---@field TableViewCarpenter UTableView
---@field TableViewEarthMessenger UTableView
---@field TableViewHealth UTableView
---@field TableViewPreference UTableView
---@field TableViewTank UTableView
---@field TextAttack UFTextBlock
---@field TextCrafter UFTextBlock
---@field TextEarthMessenger UFTextBlock
---@field TextHealth UFTextBlock
---@field TextPreference UFTextBlock
---@field TextTank UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PersonInfoPerferredProfPanelView = LuaClass(UIView, true)

function PersonInfoPerferredProfPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnCancel = nil
	--self.BtnOk = nil
	--self.FrameL = nil
	--self.TableViewAttack = nil
	--self.TableViewCarpenter = nil
	--self.TableViewEarthMessenger = nil
	--self.TableViewHealth = nil
	--self.TableViewPreference = nil
	--self.TableViewTank = nil
	--self.TextAttack = nil
	--self.TextCrafter = nil
	--self.TextEarthMessenger = nil
	--self.TextHealth = nil
	--self.TextPreference = nil
	--self.TextTank = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PersonInfoPerferredProfPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnCancel)
	self:AddSubView(self.BtnOk)
	self:AddSubView(self.FrameL)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PersonInfoPerferredProfPanelView:OnInit()
	self.AdapterTableViewPreference 	= UIAdapterTableView.CreateAdapter(self, self.TableViewPreference)
	self.AdapterTableViewTank 			= UIAdapterTableView.CreateAdapter(self, self.TableViewTank)
	self.AdapterTableViewHealth 		= UIAdapterTableView.CreateAdapter(self, self.TableViewHealth)
	self.AdapterTableViewAttack 		= UIAdapterTableView.CreateAdapter(self, self.TableViewAttack)
	self.AdapterTableViewEarthMessenger = UIAdapterTableView.CreateAdapter(self, self.TableViewEarthMessenger)
	self.AdapterTableViewCarpenter 		= UIAdapterTableView.CreateAdapter(self, self.TableViewCarpenter)

	self.AdapterTableViewTank:SetOnClickedCallback(self.OnItemClickedProfItem)
	self.AdapterTableViewHealth:SetOnClickedCallback(self.OnItemClickedProfItem)
	self.AdapterTableViewAttack:SetOnClickedCallback(self.OnItemClickedProfItem)
	self.AdapterTableViewEarthMessenger:SetOnClickedCallback(self.OnItemClickedProfItem)
	self.AdapterTableViewCarpenter:SetOnClickedCallback(self.OnItemClickedProfItem)
	

	self.Binders = {
		{ "CanConfirmPerfProf", 		UIBinderSetIsEnabled.New(self, self.BtnOk, nil, false) },
		{ "PerferredProfSetSlotVMList", UIBinderUpdateBindableList.New(self, self.AdapterTableViewPreference) },
		{ "TankProfVMList", 			UIBinderUpdateBindableList.New(self, self.AdapterTableViewTank) },
		{ "HealthProfVMList", 			UIBinderUpdateBindableList.New(self, self.AdapterTableViewHealth) },
		{ "AttackProfVMList", 			UIBinderUpdateBindableList.New(self, self.AdapterTableViewAttack) },
		{ "EarthMessengerProfVMList", 	UIBinderUpdateBindableList.New(self, self.AdapterTableViewEarthMessenger) },
		{ "CarpenterProfVMList", 		UIBinderUpdateBindableList.New(self, self.AdapterTableViewCarpenter) },
	}

	self:InitLSTR()
end

function PersonInfoPerferredProfPanelView:InitLSTR()
	self.FrameL.FText_Title:SetText(LSTR(620100))

	self.TextPreference:SetText(LSTR(620101))
	self.TextTank:SetText(LSTR(620054))
	self.TextHealth:SetText(LSTR(620055))
	self.TextAttack:SetText(LSTR(620056))
	self.TextCrafter:SetText(LSTR(620057))
	self.TextEarthMessenger:SetText(LSTR(620058))

	self.BtnCancel:SetText(_G.LSTR(10003))
	self.BtnOk:SetText(_G.LSTR(10002))
end

function PersonInfoPerferredProfPanelView:OnDestroy()

end

function PersonInfoPerferredProfPanelView:OnShow()
	PersonInfoVM:TryInitPerferredProfSetInfo()	
	self.Shut = PersonInfoVM.StrPerferredProfSet
end

function PersonInfoPerferredProfPanelView:OnHide()
	PersonInfoVM:SetEditProfStr(nil)
end

function PersonInfoPerferredProfPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnOk, 		self.OnBtnOK)
	UIUtil.AddOnClickedEvent(self, self.BtnCancel, 		self.OnBtnCancel)
	UIUtil.AddOnClickedEvent(self, self.FrameL.ButtonClose, 		self.OnBtnCancel)
end

function PersonInfoPerferredProfPanelView:OnRegisterGameEvent()

end

function PersonInfoPerferredProfPanelView:OnRegisterBinder()
	self:RegisterBinders(PersonInfoVM, self.Binders)

	PersonInfoVM:UpdateAllClassProfVMList()
end

function PersonInfoPerferredProfPanelView:OnItemClickedProfItem(Index, ItemData, ItemView)
	if not PersonInfoVM.IsMajor then
		return
	end

	if nil == ItemData or not ItemData.IsUnLock or ItemData.IsNone then
		MsgTipsUtil.ShowTips(_G.LSTR(620020))
		return
	end

	local ExistItem = PersonInfoVM.PerferredProfSetSlotVMList:Find(function(e) 
		return e.ProfID == ItemData.ProfID 
	end)

	if ExistItem then
		PersonInfoVM:DeletePerferredProf(ItemData.ProfID)
	else
		PersonInfoVM:AddPerferredProf(ItemData.ProfID)
	end
end

function PersonInfoPerferredProfPanelView:OnBtnOK()
	local Str = PersonInfoVM.EditProfStr
	if Str then
		_G.ClientSetupMgr:SetPerferredProf(Str)
	end

	self:Hide()
end

function PersonInfoPerferredProfPanelView:OnBtnCancel()
	-- PersonInfoVM:ResetPerferredProf(self.Shut)
	self:Hide()
end


return PersonInfoPerferredProfPanelView