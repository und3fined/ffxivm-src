---
--- Author: Administrator
--- DateTime: 2024-07-08 14:49
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local PhotoDefine = require("Game/Photo/PhotoDefine")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIAdapterTableView =  require("UI/Adapter/UIAdapterTableView")
local SaveKey = require("Define/SaveKey")

local LSTR = _G.LSTR
local TimeUtil = _G.TimeUtil
local PhotoMgr
local PhotoTemplateVM
local PhotoActionVM
local PhotoEmojiVM
local PhotoRoleStatVM

---@class PhotoAddTemplatePanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnAdd UFButton
---@field TableViewTemplate UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PhotoAddTemplatePanelView = LuaClass(UIView, true)

function PhotoAddTemplatePanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnAdd = nil
	--self.TableViewTemplate = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PhotoAddTemplatePanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PhotoAddTemplatePanelView:OnInit()
	self.TextAddTemplate:SetText(_G.LSTR(630054))

	PhotoMgr = _G.PhotoMgr
	PhotoTemplateVM = _G.PhotoTemplateVM
	self.AdpTemplate = UIAdapterTableView.CreateAdapter(self, self.TableViewTemplate)--, self.OnAdpItemTemplate)
	self.AdpTemplate:SetOnClickedCallback(self.OnActionItemClicked)
	-- self.AdpTemplate:SetCanBeSelectedCallback(self.CanBeSelected)
	self.BinderTemplate =
	{
		{ "BtnImage", UIBinderSetBrushFromAssetPath.New(self, self.ImgAddTemplate) },
		{ "Templates", UIBinderUpdateBindableList.New(self, self.AdpTemplate) },
		{ "CurItemVM", UIBinderValueChangedCallback.New(self, nil, self.OnSelctChg) },
	}
	PhotoTemplateVM:UpdTemplates()
end

function PhotoAddTemplatePanelView:OnSelctChg(Item)
	if not Item then
		self.AdpTemplate:CancelSelected()
	end
end

function PhotoAddTemplatePanelView:OnDestroy()

end

function PhotoAddTemplatePanelView:OnShow()
	if PhotoTemplateVM.CurItemIdx then
		PhotoTemplateVM:UpdateSelItem(PhotoTemplateVM.CurItemIdx)
		self.AdpTemplate:SetSelectedIndex(PhotoTemplateVM.CurItemIdx)
	end
end

function PhotoAddTemplatePanelView:OnHide()

end

function PhotoAddTemplatePanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnAdd, self.OnBtnAddTemplate)
end

function PhotoAddTemplatePanelView:OnRegisterGameEvent()

end

function PhotoAddTemplatePanelView:OnRegisterBinder()
	self:RegisterBinders(PhotoTemplateVM, self.BinderTemplate)
end

-- function PhotoAddTemplatePanelView:OnAdpItemTemplate(Idx, ItemVM)
-- 	PhotoTemplateVM:UpdateSelItem(Idx)
-- 	_G.MsgBoxUtil.ShowMsgBoxTwoOp(self, _G.LSTR(630062), _G.LSTR(630063),
-- 		function()
-- 			local Temp = PhotoMgr:GetTemplate(ItemVM.ID, ItemVM.IsCust)
-- 			if Temp then
-- 				PhotoMgr:TemplateApply(Temp)
-- 			end
-- 			PhotoTemplateVM.CurItemVM = ItemVM
-- 			PhotoTemplateVM.CurItemIdx = Idx
-- 		end,
-- 		function()
-- 			PhotoTemplateVM:UpdateSelItem(PhotoTemplateVM.CurItemIdx)
-- 		end,  _G.LSTR(10003), _G.LSTR(10002), nil)
-- end

local function ConfirmCallback(self, ItemData, Idx)
	if not self or not ItemData or not Idx then
		return
	end
	_G.FLOG_INFO(string.format('[Photo][PhotoAddTemplatePanelView][ConfirmCallback]ID = %s, IsCust = %s',
		tostring(ItemData.ID), tostring(ItemData.IsCust)
	))
	local Temp = PhotoMgr:GetTemplate(ItemData.ID, ItemData.IsCust)
	if Temp then
		PhotoMgr:TemplateApply(Temp)
	end
	PhotoTemplateVM.CurItemVM = ItemData
	PhotoTemplateVM.CurItemIdx = Idx
	self.AdpTemplate:SetSelectedIndex(Idx)
end

local function CancelCallback()
	PhotoTemplateVM:UpdateSelItem(PhotoTemplateVM.CurItemIdx)
end

function PhotoAddTemplatePanelView:OnActionItemClicked(Idx, ItemData, ItemView)
	if Idx == PhotoTemplateVM.CurItemIdx then
		return
	end
	_G.FLOG_INFO("[Photo][PhotoAddTemplatePanelView][OnActionItemClicked]")

	PhotoTemplateVM:UpdateSelItem(Idx)

	local LastTimePopTime = _G.UE.USaveMgr.GetInt(SaveKey.PhotoTemplateTipTime, 0, true)
	local IsNotPopTip = LastTimePopTime > 0 and TimeUtil:IsSameDay(LastTimePopTime, TimeUtil:GetLocalTime())
	if IsNotPopTip then
		ConfirmCallback(self, ItemData, Idx)
		return
	end

	_G.MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(630062), LSTR(630063),
		function(_, Params)
			ConfirmCallback(self, ItemData, Idx)
			if Params and Params.IsNeverAgain then
				_G.UE.USaveMgr.SetInt(SaveKey.PhotoTemplateTipTime, TimeUtil:GetLocalTime(), true)
			end
		end, CancelCallback,  LSTR(10003), LSTR(10002),
		{
			CloseClickCB = CancelCallback,
			bUseNever = true,
			NeverMindText = LSTR(630066)
		}
	)
end

function PhotoAddTemplatePanelView:OnBtnAddTemplate()
	local Num = #(PhotoMgr.CustTemplateList)

    if Num >= PhotoDefine.MaxTemplateCnt then
		MsgTipsUtil.ShowTipsByID(PhotoDefine.PhotoTipsID.TemplateIsMaxNum, nil)
        return
    end
	_G.UIViewMgr:ShowView(_G.UIViewID.PhotoAddTemplate)
end

return PhotoAddTemplatePanelView