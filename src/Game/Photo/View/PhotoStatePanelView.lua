---
--- Author: Administrator
--- DateTime: 2024-07-08 14:46
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIAdapterTableView =  require("UI/Adapter/UIAdapterTableView")

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
local PhotoActorUtil = require("Game/Photo/Util/PhotoActorUtil")

---@class PhotoStatePanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TableViewState UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PhotoStatePanelView = LuaClass(UIView, true)

function PhotoStatePanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TableViewState = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PhotoStatePanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PhotoStatePanelView:OnInit()
	PhotoRoleStatVM = _G.PhotoRoleStatVM
	self.AdpRoleStat 			= UIAdapterTableView.CreateAdapter(self, self.TableViewState, self.OnAdpItemTableRoleStat)

	self.BinderRoleStat = 
	{
		{ "StatList", 		UIBinderUpdateBindableList.New(self, self.AdpRoleStat) },
		{ "StatIdx",   		UIBinderSetSelectedIndex.New(self, self.AdpRoleStat, true)},
	}
end

function PhotoStatePanelView:OnDestroy()

end

function PhotoStatePanelView:OnShow()
end

function PhotoStatePanelView:OnHide()

end

function PhotoStatePanelView:OnRegisterUIEvent()

end

function PhotoStatePanelView:OnRegisterGameEvent()

end

function PhotoStatePanelView:OnRegisterBinder()
	self:RegisterBinders(PhotoRoleStatVM, 		self.BinderRoleStat)
end

function PhotoStatePanelView:OnAdpItemTableRoleStat(Idx, ItemVM)
	local EntID = _G.PhotoMgr.SeltEntID
	if PhotoActorUtil.IsActorMoving(EntID) then 
		_G.MsgTipsUtil.ShowTips(_G.LSTR(630060))
		self.AdpRoleStat:CancelSelected()
		return 
	end

	PhotoRoleStatVM:SetStatIdx(Idx, ItemVM.ID)
	-- _G.FLOG_INFO("[Photo][PhotoRolePanelView][OnAdpItemTableRoleStat] Idx = " .. tostring(Idx))
end

return PhotoStatePanelView