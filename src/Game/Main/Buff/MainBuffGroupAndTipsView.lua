---
--- Author: v_hggzhang
--- DateTime: 2022-05-16 19:44
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local BuffDefine = require("Game/Buff/BuffDefine")

local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetSelectedIndex = require("Binder/UIBinderSetSelectedIndex")

local BuffUtil = require("Utils/BuffUtil")
local BuffUIUtil = require("Game/Buff/BuffUIUtil")

local MajorBuffVM = require("Game/Buff/VM/MajorBuffVM")
local MainTargetBuffsVM = require("Game/Buff/VM/MainTargetBuffsVM")

---@class MainBuffGroupAndTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field MajorBuffInfoTips MainBuffInfoTipsNewView
---@field TableViewBuff UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MainBuffGroupAndTipsView = LuaClass(UIView, true)

function MainBuffGroupAndTipsView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.MajorBuffInfoTips = nil
	--self.TableViewBuff = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MainBuffGroupAndTipsView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.MajorBuffInfoTips)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MainBuffGroupAndTipsView:OnInit()
    -- self.TableViewAdapterBuff =
    --     UIAdapterTableView.CreateAdapter(self, self.TableViewBuff, self.OnBuffItemSelected, true)
    -- self.Binders = {
    --     { "BuffList",                      UIBinderUpdateBindableList.New(self, self.TableViewAdapterBuff)},
    --     { "MainSelectedIdx",            UIBinderSetSelectedIndex.New(self, self.TableViewAdapterBuff)},
    --     { "MainSelectedItem",           UIBinderValueChangedCallback.New(self, nil, self.OnBuffItemChanged)},
    -- }
end

function MainBuffGroupAndTipsView:OnDestroy()
end

function MainBuffGroupAndTipsView:OnShow()
    -- -- 与MainActorInfo的buff栏互斥
    -- MainTargetBuffsVM:SetSelectedIndex(nil)

    -- self.TableViewAdapterBuff:ScrollIndexIntoView(MajorBuffVM.MainSelectedIdx or 1)
end

function MainBuffGroupAndTipsView:OnHide()
    -- self.TableViewAdapterBuff:CancelSelected()
end

function MainBuffGroupAndTipsView:OnRegisterUIEvent()
end

function MainBuffGroupAndTipsView:OnRegisterGameEvent()
	-- self:RegisterGameEvent(_G.EventID.PreprocessedMouseButtonDown, self.OnPreprocessedMouseButtonDown)
end

function MainBuffGroupAndTipsView:OnRegisterBinder()
    -- self:RegisterBinders(MajorBuffVM, self.Binders)
end

-- function MainBuffGroupAndTipsView:OnPreprocessedMouseButtonDown(MouseEvent)
-- 	local MousePosition = UE.UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(MouseEvent)
-- 	if not UIUtil.IsUnderLocation(self.MajorBuffInfoTips, MousePosition) and
--     not UIUtil.IsUnderLocation(self.TableViewBuff, MousePosition) then
--         MajorBuffVM:SetIsMajorBuffDetailVisiable(false)
--         MajorBuffVM:SetMainSelectedIdx(nil)
--     end
-- end

-- function MainBuffGroupAndTipsView:OnBuffItemSelected(Idx, ItemVM)
--     MajorBuffVM:SetMainSelectedIdx(Idx)
-- end

-- function MainBuffGroupAndTipsView:OnBuffItemChanged(NewValue, OldValue)
--     self.MajorBuffInfoTips:ChangeVMAndUpdate(NewValue)
-- end

return MainBuffGroupAndTipsView
