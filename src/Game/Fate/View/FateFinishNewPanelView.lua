---
--- Author: michaelyang_lightpaw
--- DateTime: 2024-08-30 11:40
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local FateMgr = require("Game/Fate/FateMgr")
local FateFinishVM = require("Game/Fate/VM/FateFinishVM")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIAdapterCountDown = require("UI/Adapter/UIAdapterCountDown")
local AudioUtil = require("Utils/AudioUtil")
local SuccessMusicPath = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_INGAME/Play_Zingle_Fate_S_Start.Play_Zingle_Fate_S_Start'"
local FailedMusicPath = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_INGAME/Play_Zingle_Fate_S_Clear.Play_Zingle_Fate_S_Clear'"
local ConditionFinishMusicPath = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/Play_SE_UI_SE_UI_tell_18.Play_SE_UI_SE_UI_tell_18'"
local LSTR = _G.LSTR

---@class FateFinishNewPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnGoLook CommBtnLView
---@field BtnQuit CommBtnLView
---@field CommonPlaySound_Failed CommonPlaySoundView
---@field CommonPlaySound_Success CommonPlaySoundView
---@field CommonPopUpBG CommonPopUpBGView
---@field MedalItem FateFinishMedalItemView
---@field PanelFailed UFCanvasPanel
---@field PanelSuccess UFCanvasPanel
---@field TableViewCondition UTableView
---@field TableViewRewardItem UTableView
---@field TextFailed UFTextBlock
---@field TextHideCondition UFTextBlock
---@field TextMissionName UFTextBlock
---@field TextRewardTitle UFTextBlock
---@field TextSuccess UFTextBlock
---@field AnimFailed UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field AnimSuccess UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FateFinishNewPanelView = LuaClass(UIView, true)

function FateFinishNewPanelView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnGoLook = nil
	--self.BtnQuit = nil
	--self.CommonPlaySound_Failed = nil
	--self.CommonPlaySound_Success = nil
	--self.CommonPopUpBG = nil
	--self.MedalItem = nil
	--self.PanelFailed = nil
	--self.PanelSuccess = nil
	--self.TableViewCondition = nil
	--self.TableViewRewardItem = nil
	--self.TextFailed = nil
	--self.TextHideCondition = nil
	--self.TextMissionName = nil
	--self.TextRewardTitle = nil
	--self.TextSuccess = nil
	--self.AnimFailed = nil
	--self.AnimOut = nil
	--self.AnimSuccess = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FateFinishNewPanelView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnGoLook)
	self:AddSubView(self.BtnQuit)
	self:AddSubView(self.CommonPlaySound_Failed)
	self:AddSubView(self.CommonPlaySound_Success)
	self:AddSubView(self.CommonPopUpBG)
	self:AddSubView(self.MedalItem)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FateFinishNewPanelView:OnInit()
    self.BtnGoLook:SetButtonText(LSTR(190001))
    self.BtnQuit:SetButtonText(LSTR(190002))
    self.TextRewardTitle:SetText(LSTR(190117))
    
    self.TextFailed:SetText(LSTR(190003))
    self.TextSuccess:SetText(LSTR(190005))

    self.TableViewRewardItemAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewRewardItem, nil)
    self.TableViewRewardItemAdapter:SetOnClickedCallback(self.OnItemClickCallback)
    self.TableViewConditionAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewCondition)
    self.BtnCountDown = UIAdapterCountDown.CreateAdapter(self, self.BtnQuit, nil, LSTR(190006), self.ClosePanel)
end

function FateFinishNewPanelView:OnDestroy()
end

function FateFinishNewPanelView:OnItemClickCallback(Index, ItemData, ItemView)
    local ItemTipsUtil = require("Utils/ItemTipsUtil")
    ItemTipsUtil.ShowTipsByResID(ItemData.ItemResID, ItemView)
end

function FateFinishNewPanelView:OnShow()
    self.bPlayedConditionFinishSound = false
    self.BtnGoLook:SetButtonText(LSTR(190001))
    self.BtnQuit:SetButtonText(LSTR(190002))
    self.CommonPopUpBG:SetHideOnClick(false)

    self.CommonPopUpBG:SetCallback(
        self,
        function(TargetView)
        end
    )

    if (self.Params ~= nil) then
        if(self.Params.bHighRisk) then
            self.TextFailed:SetText(string.format(LSTR(190126), LSTR(190003)))-- %s·高危
            self.TextSuccess:SetText(string.format(LSTR(190126), LSTR(190005)))-- %s·高危
        else
            self.TextFailed:SetText(LSTR(190003))
            self.TextSuccess:SetText(LSTR(190005))
        end

        self.CloseCallback = self.Params.CloseCallback
        if (self.Params.bFinished) then
            AudioUtil.LoadAndPlayUISound(SuccessMusicPath, nil)
            -- 胜利
            self:PlayAnimation(self.AnimSuccess)

            local AwardType = self.Params.AwardType
            self:RegisterTimer(
                function()
                    UIUtil.SetIsVisible(self.MedalItem, true)
                    if (AwardType ~= nil) then
                        if (AwardType == 1) then
                            -- 播放金牌
                            self.MedalItem:PlayAnimation(self.MedalItem.AnimGoldIn)
                        elseif (AwardType == 2) then
                            -- 播放银牌
                            self.MedalItem:PlayAnimation(self.MedalItem.AnimSilverIn)
                        else
                            -- 播放铜牌
                            self.MedalItem:PlayAnimation(self.MedalItem.AnimCopperIn)
                        end
                    else
                        -- 没有数据，默认播放铜牌
                        self.MedalItem:PlayAnimation(self.MedalItem.AnimCopperIn)
                    end
                end,
                1,
                0,
                1
            )
        else
            AudioUtil.LoadAndPlayUISound(FailedMusicPath, nil)
            -- 失败
            self:PlayAnimation(self.AnimFailed)
            UIUtil.SetIsVisible(self.MedalItem, false)
        end
    else
        FLOG_ERROR("self.Params 为空，请检查")
    end
end

function FateFinishNewPanelView:OnHide()
    if (self.CloseCallback ~= nil) then
        self.CloseCallback()
    end
    self.CloseCallback = nil
end

function FateFinishNewPanelView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.BtnQuit, self.ClosePanel)
    UIUtil.AddOnClickedEvent(self, self.BtnGoLook, self.OnClickBtnGoLook)
end

function FateFinishNewPanelView:OnClickBtnGoLook()
    local TargetFateID = self.ViewModel.FateID
    _G.FateMgr:ShowFateArchive(TargetFateID)
    _G.UIViewMgr:HideView(self.ViewID)
end

function FateFinishNewPanelView:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.FateFinishCondition, self.OnFateFinishCondition)
end

function FateFinishNewPanelView:OnFateFinishCondition()
    if (self.bPlayedConditionFinishSound) then
        return
    end
    AudioUtil.LoadAndPlayUISound(ConditionFinishMusicPath)
    self.bPlayedConditionFinishSound = true
end

function FateFinishNewPanelView:ClosePanel()
    self:Hide()
end

function FateFinishNewPanelView:OnRegisterBinder()
    local Params = self.Params
    if Params == nil then
        return
    end

    local Binders = {
        {"FateName", UIBinderSetText.New(self, self.TextMissionName)},
        {"HideConditionText", UIBinderSetText.New(self, self.TextHideCondition)},
        {"RewardList", UIBinderUpdateBindableList.New(self, self.TableViewRewardItemAdapter)},
        {"ConditionList", UIBinderUpdateBindableList.New(self, self.TableViewConditionAdapter)}
    }

    self.ViewModel = FateFinishVM.CreateVM(Params)
    self:RegisterBinders(self.ViewModel, Binders)
end

return FateFinishNewPanelView
