---
--- Author: Administrator
--- DateTime: 2025-04-27 10:54
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local FateFinishVM = require("Game/Fate/VM/FateFinishVM")

---@class CommFateRewardPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnCheck1 CommBtnLView
---@field CommonPlaySound_Failed CommonPlaySoundView
---@field CommonPlaySound_Success CommonPlaySoundView
---@field Panel1Btn UFCanvasPanel
---@field PanelFailed UFCanvasPanel
---@field PanelSuccess UFCanvasPanel
---@field PopUpBG CommonPopUpBGView
---@field TableViewRewardList UTableView
---@field TextFailed UFTextBlock
---@field TextTitle UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field Comm title bool
---@field Title text
---@field Number of buttons CommThroughFrameBtn
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommFateRewardPanelView = LuaClass(UIView, true)

function CommFateRewardPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnCheck1 = nil
	--self.CommonPlaySound_Failed = nil
	--self.CommonPlaySound_Success = nil
	--self.Panel1Btn = nil
	--self.PanelFailed = nil
	--self.PanelSuccess = nil
	--self.PopUpBG = nil
	--self.TableViewRewardList = nil
	--self.TextFailed = nil
	--self.TextTitle = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--self.Comm title = nil
	--self.Title = nil
	--self.Number of buttons = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommFateRewardPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnCheck1)
	self:AddSubView(self.CommonPlaySound_Failed)
	self:AddSubView(self.CommonPlaySound_Success)
	self:AddSubView(self.PopUpBG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommFateRewardPanelView:OnInit()
	self.TableViewRewardItemAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewRewardList, nil)
	self.TableViewRewardItemAdapter:SetOnClickedCallback(self.OnItemClickCallback)
end

function CommFateRewardPanelView:OnDestroy()

end

function CommFateRewardPanelView:OnShow()
	self.PopUpBG:SetHideOnClick(false)
	self.BtnCheck1:SetText(LSTR(190002)) -- 退出危命

	self.TextFailed:SetText(LSTR(190003))
	self.TextSuccess:SetText(LSTR(190005))

	if (self.Params ~= nil) then
        if (self.Params.bFinished) then
            -- 胜利
            UIUtil.SetIsVisible(self.PanelFailed, false)
			UIUtil.SetIsVisible(self.PanelSuccess, true)
        else
            -- 失败
			UIUtil.SetIsVisible(self.PanelFailed, true)
			UIUtil.SetIsVisible(self.PanelSuccess, false)
        end
    else
        FLOG_ERROR("self.Params 为空，请检查")
    end
end

function CommFateRewardPanelView:OnHide()

end

function CommFateRewardPanelView:OnItemClickCallback(Index, ItemData, ItemView)
	local ItemTipsUtil = require("Utils/ItemTipsUtil")
    ItemTipsUtil.ShowTipsByResID(ItemData.ItemResID, ItemView)
end

function CommFateRewardPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnCheck1, self.ClosePanel)
end

function CommFateRewardPanelView:ClosePanel()
	self:Hide()
end

function CommFateRewardPanelView:OnRegisterGameEvent()

end

function CommFateRewardPanelView:OnRegisterBinder()
    local Params = self.Params
    if Params == nil then
        return
    end

    local Binders = {
        {"RewardList", UIBinderUpdateBindableList.New(self, self.TableViewRewardItemAdapter)}
    }

    self.ViewModel = FateFinishVM.CreateVM(Params)
    self:RegisterBinders(self.ViewModel, Binders)
end

return CommFateRewardPanelView