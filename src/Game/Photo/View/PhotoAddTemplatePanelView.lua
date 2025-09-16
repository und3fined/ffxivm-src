---
--- Author: Administrator
--- DateTime: 2024-07-08 14:49
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local PhotoDefine = require("Game/Photo/PhotoDefine")
local PhotoMgr
local FVector2D = _G.UE.FVector2D
local PhotoVM
local PhotoCamVM
local PhotoFilterVM
local PhotoDarkEdgeVM
local PhotoRoleSettingVM
local PhotoSceneVM
local PhotoTemplateVM
local PhotoActionVM
local PhotoEmojiVM
local PhotoRoleStatVM

local UIBinderSetSlider = require("Binder/UIBinderSetSlider")
local UIAdapterTreeView = require("UI/Adapter/UIAdapterTreeView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetProfIcon = require("Binder/UIBinderSetProfIcon")
local UIBinderSetProfName = require("Binder/UIBinderSetProfName")
local UIBinderSetSelectedIndex = require("Binder/UIBinderSetSelectedIndex")
local UIBinderSetSelectedItem = require("Binder/UIBinderSetSelectedItem")
local UIBinderSetIsEnabled = require("Binder/UIBinderSetIsEnabled")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetRenderTransformAngle = require("Binder/UIBinderSetRenderTransformAngle")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")

local UIAdapterTableView =  require("UI/Adapter/UIAdapterTableView")

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
	self.AdpTemplate 			= UIAdapterTableView.CreateAdapter(self, self.TableViewTemplate, self.OnAdpItemTemplate)

	self.BinderTemplate = 
	{
		{ "BtnImage", 	   UIBinderSetBrushFromAssetPath.New(self, self.ImgAddTemplate) },
		{ "Templates", UIBinderUpdateBindableList.New(self, self.AdpTemplate) },
		{ "CurItemVM",   	  UIBinderValueChangedCallback.New(self, nil, self.OnSelctChg) },
	}

end

function PhotoAddTemplatePanelView:OnSelctChg(Item)
	if not Item then
		self.AdpTemplate:CancelSelected()
	end
end

function PhotoAddTemplatePanelView:OnDestroy()

end

function PhotoAddTemplatePanelView:OnShow()
end

function PhotoAddTemplatePanelView:OnHide()

end

function PhotoAddTemplatePanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self,              self.BtnAdd,    			self.OnBtnAddTemplate)

end

function PhotoAddTemplatePanelView:OnRegisterGameEvent()

end

function PhotoAddTemplatePanelView:OnRegisterBinder()
	self:RegisterBinders(PhotoTemplateVM, 		self.BinderTemplate)
end

function PhotoAddTemplatePanelView:OnAdpItemTemplate(Idx, ItemVM)
	local Temp = PhotoMgr:GetTemplate(ItemVM.ID, ItemVM.IsCust)
	if Temp then
		PhotoMgr:TemplateApply(Temp)
	end
	PhotoTemplateVM.CurItemVM = ItemVM
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