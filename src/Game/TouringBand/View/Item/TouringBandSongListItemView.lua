---
--- Author: Administrator
--- DateTime: 2024-07-08 15:13
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local TimeUtil = require("Utils/TimeUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")

local UpdateTimerID = 0
local LeftTime = 0
---@class TouringBandSongListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field IconLock UFImage
---@field IconPlaySong UFImage
---@field ImgFocus UFImage
---@field TextName UFTextBlock
---@field TextSequence UFTextBlock
---@field TextTime UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TouringBandSongListItemView = LuaClass(UIView, true)

function TouringBandSongListItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.IconLock = nil
	--self.IconPlaySong = nil
	--self.ImgFocus = nil
	--self.TextName = nil
	--self.TextSequence = nil
	--self.TextTime = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TouringBandSongListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TouringBandSongListItemView:OnInit()

end

function TouringBandSongListItemView:OnDestroy()

end

function TouringBandSongListItemView:OnShow()

end

function TouringBandSongListItemView:OnHide()

end

function TouringBandSongListItemView:OnRegisterUIEvent()

end

function TouringBandSongListItemView:OnRegisterGameEvent()

end

function TouringBandSongListItemView:OnRegisterBinder()
    local Params = self.Params
    if nil == Params then
        return
    end

    local Data = Params.Data
    if nil == Data then
        return
    end

    local ViewModel = Data
    self.VM = ViewModel

    local Binders = {
        { "TextSequence", UIBinderSetText.New(self, self.TextSequence)},
        { "TextName", UIBinderSetText.New(self, self.TextName)},
        { "TextTime", UIBinderSetText.New(self, self.TextTime)},
        { "IsSelect", UIBinderSetIsVisible.New(self, self.IconPlaySong) },
        { "IsSelect", UIBinderSetIsVisible.New(self, self.ImgFocus) },
        { "IsShowTextSequence", UIBinderSetIsVisible.New(self, self.TextSequence) },
        { "IsLock", UIBinderSetIsVisible.New(self, self.IconLock) },
        { "TextColor", UIBinderSetColorAndOpacityHex.New(self, self.TextTime) },
        { "TextColor", UIBinderSetColorAndOpacityHex.New(self, self.TextName) },
    }
    self:RegisterBinders(ViewModel, Binders)
end

function TouringBandSongListItemView:OnSelectChanged(Value)
    if self.VM == nil then return end
    
    if self.VM.IsLock then return end

    self.VM:SetSelect(Value)
    if Value then
        _G.TouringBandMgr:StopBandSong()
        local Suc = _G.TouringBandMgr:PlayBandSong(self.VM.ID)
        if Suc then
            LeftTime = self.VM.Time
            UpdateTimerID = self:RegisterTimer(self.UpdateLeftTime, 0, 1, 0)
        end
    else
        if UpdateTimerID > 0 then
            self:UnRegisterTimer(UpdateTimerID)
            UpdateTimerID = 0
        end
        local LeftTimeStr = TimeUtil.GetTimeFormat("%M:%S", self.VM.Time or 0)
        self.TextTime:SetText(LeftTimeStr)
    end
end

function TouringBandSongListItemView:UpdateLeftTime()
    LeftTime = LeftTime - 1
    if (LeftTime <= 0) then
        LeftTime = 0
        _G.TouringBandMgr:StopBandSong()
        self:UnRegisterTimer(UpdateTimerID)
        ---- 循环播放
        local Suc = _G.TouringBandMgr:PlayBandSong(self.VM.ID)
        if Suc then
            LeftTime = self.VM.Time
            UpdateTimerID = self:RegisterTimer(self.UpdateLeftTime, 0, 1, 0)
        end
    end

    local LeftTimeStr = TimeUtil.GetTimeFormat("%M:%S", LeftTime)
    self.TextTime:SetText(LeftTimeStr)
end

return TouringBandSongListItemView