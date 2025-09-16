---
--- Author: qibaoyiyi
--- DateTime: 2023-03-13 17:16
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")

local ArmyMainVM = _G.ArmyMainVM

local ArmyMgr = require("Game/Army/ArmyMgr")
local TipsUtil = require("Utils/TipsUtil")

---@class ArmyMemberAskForItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnOk UFButton
---@field BtnRefuse UFButton
---@field BtnReport UFButton
---@field ImgJob UFImage
---@field PlayerItem CommPlayerItemView
---@field TextJobNum UFTextBlock
---@field TextWord2 UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmyMemberAskForItemView = LuaClass(UIView, true)

function ArmyMemberAskForItemView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnOk = nil
	--self.BtnRefuse = nil
	--self.BtnReport = nil
	--self.ImgJob = nil
	--self.PlayerItem = nil
	--self.TextJobNum = nil
	--self.TextWord2 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ArmyMemberAskForItemView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.PlayerItem)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmyMemberAskForItemView:OnInit()
    self.IsCanAgreeJoin = nil
    self.bFullCapacity = nil
    self.Binders = {
        {"Message", UIBinderSetText.New(self, self.TextWord2)},
        {"JobLevel", UIBinderSetText.New(self, self.TextJobNum)},
        {"JobIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgJob)},
        {"IsShowBtnReport", UIBinderSetIsVisible.New(self, self.BtnReport, nil, true)},
    }
end

function ArmyMemberAskForItemView:OnDestroy()
end

function ArmyMemberAskForItemView:OnShow()
    local MemberPanelVM = ArmyMainVM:GetMemberPanelVM()
    local MemberPageVM = MemberPanelVM:GetArmyMemberPageVM()
    self.IsCanAgreeJoin = MemberPageVM.bAcceptJoin
    self.bFullCapacity = MemberPageVM.bFullCapacity
    UIUtil.SetIsVisible(self.BtnOk, self.IsCanAgreeJoin, true, false)
    UIUtil.SetIsVisible(self.BtnRefuse, self.IsCanAgreeJoin, true, false)
end

function ArmyMemberAskForItemView:OnHide()
end

function ArmyMemberAskForItemView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.BtnOk, self.OnClickAcceptRoleJoin)
    UIUtil.AddOnClickedEvent(self, self.BtnRefuse, self.OnClickRefuseRoleJoin)
    UIUtil.AddOnClickedEvent(self, self.BtnReport, self.OnClickBtnReport)
end

function ArmyMemberAskForItemView:OnRegisterGameEvent()
end

function ArmyMemberAskForItemView:OnRegisterBinder()
    local Params = self.Params
	if nil == Params then
		return
	end
	local VM = Params.Data
	if nil == VM then
		return
	end
	self.ViewModel = VM
    self:RegisterBinders(self.ViewModel, self.Binders)
end

--- 同意玩家加入部队
function ArmyMemberAskForItemView:OnClickAcceptRoleJoin()
    if self.bFullCapacity then
        -- LSTR string:部队人数达到上限
        _G.MsgTipsUtil.ShowTips(_G.LSTR(910246))
    else
        ArmyMgr:SendArmyAcceptApplyMsg(self.ViewModel.RoleID)
    end
end

--- 拒绝玩家加入部队
function ArmyMemberAskForItemView:OnClickRefuseRoleJoin()
    ArmyMgr:SendArmyRefuseApplyMsg({self.ViewModel.RoleID})
end

--- 举报玩家申请留言
function ArmyMemberAskForItemView:OnClickBtnReport()
    if self.ViewModel then
        local Params = {
            ReporteeRoleID = self.ViewModel.RoleID,
            ReportContent = self.ViewModel.Message,
        }
        
        local WidgetSize = UIUtil.GetLocalSize(self.TextWord2)

        TipsUtil.ShowReportTips(self.TextWord2, _G.UE.FVector2D(-WidgetSize.X - 12, WidgetSize.Y), _G.UE.FVector2D(0, 0), function()
            _G.ReportMgr:OpenViewByArmyRequest(Params)
        end, false)
    end
end

return ArmyMemberAskForItemView
