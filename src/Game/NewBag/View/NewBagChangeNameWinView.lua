---
--- Author: Administrator
--- DateTime: 2024-10-30 10:12
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MajorUtil = require("Utils/MajorUtil")
local PersonInfoDefine = require("Game/PersonInfo/PersonInfoDefine")

---@class NewBagChangeNameWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnCancel CommBtnLView
---@field BtnItem UFButton
---@field BtnUse CommBtnLView
---@field Comm2FrameM_UIBP Comm2FrameMView
---@field Comm58Slot CommBackpack58SlotView
---@field CommInputBox CommInputBoxView
---@field FButton_62 UFButton
---@field Icon UFImage
---@field PanelConsume UFHorizontalBox
---@field RichTextBox_56 URichTextBox
---@field TextNameDisabled UFTextBlock
---@field TextQuantity URichTextBox
---@field Textconsume UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local NewBagChangeNameWinView = LuaClass(UIView, true)

local LSTR = _G.LSTR

local RenameCardDefine = PersonInfoDefine.RenameCardID
function NewBagChangeNameWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnCancel = nil
	--self.BtnItem = nil
	--self.BtnUse = nil
	--self.Comm2FrameM_UIBP = nil
	--self.Comm58Slot = nil
	--self.CommInputBox = nil
	--self.FButton_62 = nil
	--self.Icon = nil
	--self.PanelConsume = nil
	--self.RichTextBox_56 = nil
	--self.TextNameDisabled = nil
	--self.TextQuantity = nil
	--self.Textconsume = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY

	self.RecordName = ""
end

function NewBagChangeNameWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnCancel)
	self:AddSubView(self.BtnUse)
	self:AddSubView(self.Comm2FrameM_UIBP)
	self:AddSubView(self.Comm58Slot)
	self:AddSubView(self.CommInputBox)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function NewBagChangeNameWinView:OnInit()
	self.CommInputBox:SetCallback(self, self.OnInputBoxTextChanged, self.OnTextCommitted)
	
end

function NewBagChangeNameWinView:OnRegisterBinder()
	self.RichTextBox_56:SetText(LSTR(990062))
	self.Textconsume:SetText(LSTR(990063))
	self.Comm2FrameM_UIBP:SetTitleText(LSTR(990033))
	self.BtnCancel:SetButtonText(LSTR(10003))
	self.BtnUse:SetButtonText(LSTR(10002))
	self.CommInputBox:SetHintText(LSTR(990034))
end

function NewBagChangeNameWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnCancel, self.OnClickBtnCancel)
	UIUtil.AddOnClickedEvent(self, self.BtnUse, self.OnClickBtnUse)
	UIUtil.AddOnClickedEvent(self, self.FButton_62, self.OnClickBtnFormerName)
	UIUtil.AddOnClickedEvent(self, self.Comm58Slot.Btn, self.OnClickItemTips)
end

function NewBagChangeNameWinView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.RenameCardCheckRepeat, self.OnCheckResult)
	self:RegisterGameEvent(EventID.ChaneNameNotify, 	self.OnRenameNotify)
	self:RegisterGameEvent(EventID.GetHistoryNameSuccess, self.OnGetHistoryName)
end

function NewBagChangeNameWinView:OnCheckResult(ErrorCode)
	UIUtil.SetIsVisible(self.TextNameDisabled, true)
	if ErrorCode == 100004 then
		self.TextNameDisabled:SetText(_G.LSTR(990030))
	else
		self.TextNameDisabled:SetText(_G.LSTR(990031))
	end
end

function NewBagChangeNameWinView:OnRenameNotify(RoleID, EntityID, NewName)
	local MajorRoleID = MajorUtil.GetMajorRoleID()
	if RoleID == MajorRoleID then
		self:Hide()
	end
end

function NewBagChangeNameWinView:OnGetHistoryName(Data)
	if Data and next(Data) then
		_G.RoleInfoMgr:ShowFormerNameTips(self.FButton_62, _G.UE.FVector2D(0, 0), Data)
	else
		_G.MsgTipsUtil.ShowTips(_G.LSTR(990032))
	end
end

function NewBagChangeNameWinView:OnShow()
	self:InitUIData()
	--self.Comm2FrameM_UIBP:SetTitleText(_G.LSTR(990033))
	--self.BtnCancel:SetBtnName(_G.LSTR(10003))
	--self.BtnUse:SetBtnName(_G.LSTR(10002))
	--self.CommInputBox:SetHintText(_G.LSTR(990034))
	local Params = self.Params 
	self.Item = Params and Params.Item or {}
	if not next(self.Item) then
		self.Item.GID = _G.BagMgr:GetItemGIDByResID(RenameCardDefine)
		self.Item.ResID = RenameCardDefine
	end

	self:SetItemIcon()
end       

function NewBagChangeNameWinView:InitUIData()
	self.BtnUse:SetIsDisabledState(true, true)
	UIUtil.SetIsVisible(self.TextNameDisabled, false)
	self.RecordName = ""
	self.CommInputBox:SetText("")
end

function NewBagChangeNameWinView:OnInputBoxTextChanged(Text, Len)
	UIUtil.SetIsVisible(self.TextNameDisabled, false)
	self.CommInputBox:SetText(Text)
	if Len > 0 then
		self.BtnUse:SetIsDisabledState(false)
	else
		self.BtnUse:SetIsDisabledState(true, true)
	end
end

function NewBagChangeNameWinView:OnTextCommitted(Name)
	if not string.isnilorempty(Name) then
		self.RecordName = Name
	end
end

function NewBagChangeNameWinView:OnClickBtnCancel()
	self:Hide()
end

function NewBagChangeNameWinView:OnClickBtnUse()
	if string.isnilorempty(self.RecordName) then
		_G.MsgTipsUtil.ShowTips(_G.LSTR(990035))
	else
		local ItemGID = self.Item.GID
		_G.RoleInfoMgr:SendRenameReq(ItemGID, self.RecordName)
	end
end

function NewBagChangeNameWinView:OnClickBtnFormerName()
	local MajorRoleID = MajorUtil.GetMajorRoleID()
	_G.RoleInfoMgr:GetPersonHistoryNameByRoleID(MajorRoleID)
end

function NewBagChangeNameWinView:OnClickItemTips()
	local ItemTipsUtil = require("Utils/ItemTipsUtil")
	local ResID = self.Item.ResID
	ItemTipsUtil.ShowTipsByResID(ResID, self.Comm58Slot)
end

function NewBagChangeNameWinView:SetItemIcon()
	local ItemCfg = require("TableCfg/ItemCfg")
	local ItemUtil = require("Utils/ItemUtil")
	local ResID = self.Item.ResID
	local Cfg = ItemCfg:FindCfgByKey(ResID)
	local ImgPath = ItemCfg.GetIconPath(Cfg.IconID or 0) or ""
	self.Comm58Slot:SetIconImg(ImgPath)
	self.Comm58Slot:SetQualityImg(ItemUtil.GetItemColorIcon(ResID))
	self.Comm58Slot:SetNumVisible(false)
	UIUtil.SetIsVisible(self.Comm58Slot.IconChoose, false)
	UIUtil.SetIsVisible(self.Comm58Slot.RichTextLevel, false)
	self.TextQuantity:SetText(string.format("%d/1", _G.BagMgr:GetItemNum(ResID)))
end

return NewBagChangeNameWinView