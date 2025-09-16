---
--- Author: Administrator
--- DateTime: 2024-10-23 11:30
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")

local ArmyMainVM = require("Game/Army/VM/ArmyMainVM")
local ArmyMgr = require("Game/Army/ArmyMgr")
local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoRes = require("Protocol/ProtoRes")
local GroupPermissionType = ProtoRes.GroupPermissionType
local UIViewMgr = _G.UIViewMgr
local UIViewID = _G.UIViewID

local ArmyMemberPanelVM = nil
local ArmyMemberPageVM = nil

---@class ArmyMemberAskForPageView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field PanelEmpty UFCanvasPanel
---@field TableViewAskFor UTableView
---@field TextNobody UFTextBlock
---@field AnimShowPanel UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmyMemberAskForPageView = LuaClass(UIView, true)

function ArmyMemberAskForPageView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.PanelEmpty = nil
	--self.TableViewAskFor = nil
	--self.TextNobody = nil
	--self.AnimShowPanel = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ArmyMemberAskForPageView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmyMemberAskForPageView:OnInit()
	ArmyMemberPanelVM = ArmyMainVM:GetMemberPanelVM()
    ArmyMemberPageVM = ArmyMemberPanelVM:GetArmyMemberPageVM()
    self.TableViewAskForAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewAskFor)
    self.Binders = {
        {"bApplyEmpty", UIBinderSetIsVisible.New(self, self.PanelEmpty)},
        {"JoinApplyList", UIBinderUpdateBindableList.New(self, self.TableViewAskForAdapter)},
    }
end

function ArmyMemberAskForPageView:OnDestroy()

end

function ArmyMemberAskForPageView:OnShow()
    -- LSTR string:没有任何入队申请
    self.TextNobody:SetText(LSTR(910309))
end

function ArmyMemberAskForPageView:OnHide()

end

function ArmyMemberAskForPageView:OnRegisterUIEvent()
    --UIUtil.AddOnClickedEvent(self, self.BtnInfo, self.OnClickedUpdateRecruit)
end

function ArmyMemberAskForPageView:OnRegisterGameEvent()

end

function ArmyMemberAskForPageView:OnRegisterBinder()
    self:RegisterBinders(ArmyMemberPageVM, self.Binders)
end

-- --- 修改招募信息
-- function ArmyMemberAskForPageView:OnClickedUpdateRecruit()
--     local IsAllowEditor = false
--     for _, PermisstionType in ipairs(ArmyMemberPageVM.MyPermissionTypes) do
--         if PermisstionType ==  GroupPermissionType.GROUP_PERMISSION_TYPE_EditNotice then
--             IsAllowEditor = true
--             break
--         end
--     end
--     UIViewMgr:ShowView(
--         UIViewID.ArmyEditRecruitPanel,
--         {
-- LSTR string:请输入招募标语
--             HintText = LSTR(910228),
--             Callback = function(RecruitSlogan, RecruitStatus)
--                 ArmyMgr:SendArmyEditRecruitInfoMsg(RecruitSlogan, RecruitStatus)
--             end,
--             IsHavePermission = IsAllowEditor,
--         }
--     )
-- end

return ArmyMemberAskForPageView