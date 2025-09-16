---
--- Author: v_hggzhang
--- DateTime: 2022-05-19 17:15
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetSelectedIndex = require("Binder/UIBinderSetSelectedIndex")
local BuffUIUtil = require("Game/Buff/BuffUIUtil")
local MainTargetBuffsVM = require("Game/Buff/VM/MainTargetBuffsVM")
local MajorBuffVM = require("Game/Buff/VM/MajorBuffVM")

---@class ActorBuffDetailView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ActorBuffDetail UFCanvasPanel
---@field BuffInfoTips MainBuffInfoTipsNewView
---@field TableViewActor UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ActorBuffDetailView = LuaClass(UIView, true)

function ActorBuffDetailView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ActorBuffDetail = nil
	--self.BuffInfoTips = nil
	--self.TableViewActor = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ActorBuffDetailView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BuffInfoTips)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ActorBuffDetailView:OnInit()
    -- self.AdapterBuffAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewActor, self.OnBuffItemSelected, true)

    -- self.BuffListBinders = {
    --     {"BuffList", UIBinderUpdateBindableList.New(self, self.AdapterBuffAdapter)},
    --     {"SelectedBuffIndex", UIBinderSetSelectedIndex.New(self, self.AdapterBuffAdapter)},
    -- }
end

function ActorBuffDetailView:OnDestroy()
end

function ActorBuffDetailView:OnShow()
    -- -- 与MajorInfo的buff栏互斥
    -- MajorBuffVM:SetIsMajorBuffDetailVisiable(false)
    -- MajorBuffVM:SetMainSelectedIdx(nil)

    -- self.AdapterBuffAdapter:ScrollIndexIntoView(MainTargetBuffsVM.SelectedBuffIndex or 1)
end

function ActorBuffDetailView:OnHide()
    -- self.AdapterBuffAdapter:CancelSelected()
end

function ActorBuffDetailView:OnRegisterGameEvent()
	-- self:RegisterGameEvent(_G.EventID.PreprocessedMouseButtonDown, self.OnPreprocessedMouseButtonDown)
end

function ActorBuffDetailView:OnRegisterBinder()
    -- self:RegisterBinders(MainTargetBuffsVM, self.BuffListBinders)
end

-- function ActorBuffDetailView:OnPreprocessedMouseButtonDown(MouseEvent)
-- 	local MousePosition = UE.UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(MouseEvent)
-- 	if not UIUtil.IsUnderLocation(self.BuffInfoTips, MousePosition) and
--     not UIUtil.IsUnderLocation(self.TableViewActor, MousePosition) then
--         MainTargetBuffsVM:SetSelectedIndex(nil)
--     end
-- end

-- function ActorBuffDetailView:OnBuffItemSelected(Index, ItemVM)
--     MainTargetBuffsVM:SetSelectedIndex(Index)
--     self.BuffInfoTips:ChangeVMAndUpdate(ItemVM)
-- end

return ActorBuffDetailView
