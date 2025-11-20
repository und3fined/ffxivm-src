---
--- Author: MichaelYang_LightPaw
--- DateTime: 2025-07-28 20:45
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBindableList = require("UI/UIBindableList")
local ToySlotItemVM = require("Game/Toy/VM/ToySlotItemVM")
local TimeUtil = require("Utils/TimeUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local LSTR = _G.LSTR

---@class ToyMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnArchive UFButton
---@field BtnCall CommBtnMView
---@field BtnCancelCall CommBtnMView
---@field BtnSetting UFButton
---@field CommEmpty CommBackpackEmptyView
---@field PanelSettingTips UFCanvasPanel
---@field PopupBGHideSettingTips CommonPopUpBGView
---@field SettingTips MountSettingSummonView
---@field TableViewItem UTableView
---@field ToggleButtonCollect UToggleButton
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ToyMainPanelView = LuaClass(UIView, true)

function ToyMainPanelView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    --self.BtnArchive = nil
    --self.BtnCall = nil
    --self.BtnCancelCall = nil
    --self.BtnSetting = nil
    --self.CommEmpty = nil
    --self.PanelSettingTips = nil
    --self.PopupBGHideSettingTips = nil
    --self.SettingTips = nil
    --self.TableViewItem = nil
    --self.ToggleButtonCollect = nil
    --AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ToyMainPanelView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    self:AddSubView(self.BtnCall)
    self:AddSubView(self.BtnCancelCall)
    self:AddSubView(self.CommEmpty)
    self:AddSubView(self.PopupBGHideSettingTips)
    self:AddSubView(self.SettingTips)
    --AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ToyMainPanelView:OnInit()
    self.bUseCallorCancel = false -- 这里做一个保护，避免连续点击按钮导致错误操作，使用或者取消玩具都需有1秒的CD
    self.TableViewAdapter = UIAdapterTableView.CreateAdapter(
        self,
        self.TableViewItem,
        self.OnTableViewSelectChange,
        true
    )

    self.TableViewAdapter:SetScrollbarIsVisible(false)
end

function ToyMainPanelView:OnTableViewSelectChange(InIndex, InItemData, InItemView)
    if (self.CurSelectItemData ~= nil) then
        self.CurSelectItemData.bSelected = false
    end
    self.CurSelectItemData = InItemData
    self.CurSelectItemData.bSelected = true

    self:InternalRefreshBtnState()
end

function ToyMainPanelView:InternalRefreshBtnState()
    local bShowCancelUse = false
    if (_G.ToyMgr:GetCurPlayToyResID() == self.CurSelectItemData.ResID and not _G.ToyMgr:IsCurToyPlayTimeOver()) then
        bShowCancelUse = true
    end

    if (bShowCancelUse) then
        -- 显示取消使用
        UIUtil.SetIsVisible(self.BtnCall, false, false)
        UIUtil.SetIsVisible(self.BtnCancelCall, true, true)
    else
        -- 显示使用
        UIUtil.SetIsVisible(self.BtnCall, true, true)
        UIUtil.SetIsVisible(self.BtnCancelCall, false, false)
    end
end

function ToyMainPanelView:OnDestroy()
    self.bUseCallorCancel = false
end

function ToyMainPanelView:OnShow()
    UIUtil.SetIsVisible(self.BtnCall, true, true)
    UIUtil.SetIsVisible(self.BtnCancelCall, false, false)
    self.CommEmpty:SetTipsContent(LSTR(1690004))
    self.BtnCall:SetText(LSTR(1690002))
    self.BtnCancelCall:SetText(LSTR(1690003))

    local AllToyVMList = _G.ToyMgr:GetAllToy() or {}
    if (#AllToyVMList < 1) then
        UIUtil.SetIsVisible(self.CommEmpty, true)
        UIUtil.SetIsVisible(self.BtnCall, false, false)
    else
        UIUtil.SetIsVisible(self.CommEmpty, false)
        UIUtil.SetIsVisible(self.BtnCall, true, true)
    end

    self.TableViewAdapter:UpdateAll(AllToyVMList)
    local DefaultSelect = 1
    self.TableViewAdapter:SetSelectedIndex(DefaultSelect)
end

function ToyMainPanelView:OnHide()
end

function ToyMainPanelView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.BtnCall.Button, self.OnClickCall)
    UIUtil.AddOnClickedEvent(self, self.BtnCancelCall.Button, self.OnClickCancelCall)
end

function ToyMainPanelView:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.PlayToy, self.OnPlayToy)
    self:RegisterGameEvent(EventID.ToyCDOver, self.OnToyCDOver)
end

function ToyMainPanelView:OnToyCDOver(Params)
    self:InternalRefreshBtnState()
end

function ToyMainPanelView:OnPlayToy(Params)
    local AllToyVMList = _G.ToyMgr:GetAllToy() or {}
    self.TableViewAdapter:UpdateAll(AllToyVMList)
    self:InternalRefreshBtnState()
    self:InternalSetClickBtnCD()
end

function ToyMainPanelView:OnRegisterBinder()
end

function ToyMainPanelView:OnClickCall()
    -- 使用玩具
    if (self.CurSelectItemData == nil) then
        _G.FLOG_ERROR("ToyMainPanelView:OnClickCall() 错误，当前没有选中玩具 ")
        return
    end
    local CurTimeMS = TimeUtil.GetServerLogicTimeMS()
    if (self.CurSelectItemData.CD ~= nil and self.CurSelectItemData.CD > 0) then
        if (CurTimeMS < self.CurSelectItemData.CD) then
            MsgTipsUtil.ShowTips("当前玩具还在CD中， 无法使用")
            _G.FLOG_INFO("当前玩具还在CD中， 无法使用")
            return
        end
    end
    self:InternalSetClickBtnCD()
    _G.ToyMgr:SendPlayToyReq(self.CurSelectItemData.ResID)
end

function ToyMainPanelView:OnClickCancelCall()
    -- 取消使用玩具
    if (self.CurSelectItemData == nil) then
        _G.FLOG_ERROR("ToyMainPanelView:OnClickCancelCall() 错误，当前没有选中玩具 ")
        return
    end

    self:InternalSetClickBtnCD()
    _G.ToyMgr:SendCancelToyReq()
end

function ToyMainPanelView:InternalSetClickBtnCD()
    self.bUseCallorCancel = true
    self:RegisterTimer(
        function()
            self.bUseCallorCancel = false
        end,
        1,
        1
    )
end

return ToyMainPanelView
