---
--- Author: Administrator
--- DateTime: 2024-07-08 14:46
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView =  require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetSelectedIndex = require("Binder/UIBinderSetSelectedIndex")
local PhotoActorUtil = require("Game/Photo/Util/PhotoActorUtil")
local PhotoDefine = require("Game/Photo/PhotoDefine")

local PhotoMgr
local PhotoVM
local PhotoActionVM
local PhotoRoleStatVM


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
	PhotoVM = _G.PhotoVM
	PhotoActionVM = _G.PhotoActionVM
	PhotoMgr = _G.PhotoMgr
	self.AdpRoleStat = UIAdapterTableView.CreateAdapter(self, self.TableViewState)--, self.OnAdpItemTableRoleStat)
	self.AdpRoleStat:SetOnClickedCallback(self.OnStatItemClicked)

	self.BinderRoleStat =
	{
		{ "StatList", 		UIBinderUpdateBindableList.New(self, self.AdpRoleStat) },
		{ "StatIdx",   		UIBinderSetSelectedIndex.New(self, self.AdpRoleStat, true)},
	}
end

function PhotoStatePanelView:OnDestroy()

end

function PhotoStatePanelView:OnShow()
	PhotoRoleStatVM:UpdFilterList()
	if PhotoMgr:IsCurSeltMajor() then
		PhotoRoleStatVM:UpdateCurIdx()
	end
end

function PhotoStatePanelView:OnHide()

end

function PhotoStatePanelView:OnRegisterUIEvent()

end

function PhotoStatePanelView:OnRegisterGameEvent()
    self:RegisterGameEvent(_G.EventID.PhotoSeltEntChg, self.OnEvePhotoSeltChg)
end

function PhotoStatePanelView:OnRegisterBinder()
	self:RegisterBinders(PhotoRoleStatVM, 		self.BinderRoleStat)
end

function PhotoStatePanelView:OnEvePhotoSeltChg()
	PhotoRoleStatVM:UpdFilterList()
	if PhotoMgr:IsCurSeltMajor() then
		PhotoRoleStatVM:UpdateCurIdx()
	end
end

function PhotoStatePanelView:OnStatItemClicked(Idx, ItemData, ItemView)
	if not PhotoMgr:IsCurSeltMajor() then
		_G.MsgTipsUtil.ShowTips(_G.LSTR(630078))
		return
	end

	if PhotoActorUtil.IsActorMoving(PhotoMgr.SeltEntID) then
		_G.MsgTipsUtil.ShowTips(_G.LSTR(630060))
		self.AdpRoleStat:CancelSelected()
		return
	end

	if PhotoRoleStatVM.StatIdx == Idx then
		PhotoRoleStatVM:SetStatIdx(nil, nil)
		self.AdpRoleStat:CancelSelected()
		return
	end

	PhotoRoleStatVM:SetStatIdx(Idx, ItemData.ID)
	if ItemData.ID then
		PhotoVM:SetIsPauseSelect(false)
		PhotoActionVM:SetAmimIsPause(false)
	end
end

return PhotoStatePanelView