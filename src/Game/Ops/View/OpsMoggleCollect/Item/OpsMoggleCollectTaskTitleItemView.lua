--[[
Author: jususchen jususchen@tencent.com
Date: 2025-07-29 17:11:26
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2025-08-05 15:59:38
FilePath: \Script\Game\Ops\View\OpsMoggleCollect\Item\OpsMoggleCollectTaskTitleItemView.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local LocalizationUtil = require("Utils/LocalizationUtil")

---@class OpsMoggleCollectTaskTitleItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field IconLock UFImage
---@field IconTime UFImage
---@field TextTime UFTextBlock
---@field TextTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsMoggleCollectTaskTitleItemView = LuaClass(UIView, true)

function OpsMoggleCollectTaskTitleItemView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    --self.IconLock = nil
    --self.IconTime = nil
    --self.TextTime = nil
    --self.TextTitle = nil
    --AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsMoggleCollectTaskTitleItemView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    --AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsMoggleCollectTaskTitleItemView:OnPostInit()
    self.TextTimeBinder = UIBinderValueChangedCallback.New(self, nil, self.UpdateTextTime)

    self.Binders = {
        { "Title",           UIBinderSetText.New(self, self.TextTitle) },
        { "bLock",           UIBinderSetIsVisible.New(self, self.IconLock) },
        { "bLock",           UIBinderSetIsVisible.New(self, self.IconTime, true) },
        { "bLock",           self.TextTimeBinder },
        { "bExpired",        self.TextTimeBinder },
        { "TimeComingStart", self.TextTimeBinder },
        { "TimeComingEnd",   self.TextTimeBinder },
    }
end

function OpsMoggleCollectTaskTitleItemView:OnShow()
    if self.TimerIDUpdateLockTime then
        self:UnRegisterTimer(self.TimerIDUpdateLockTime)
        self.TimerIDUpdateLockTime = nil
    end


    self.TimerIDUpdateLockTime = self:RegisterTimer(function()
        local VM = self:GetViewModel()
        if not VM then
            return
        end
        if VM.bExpired then
            self:UnRegisterTimer(self.TimerIDUpdateLockTime)
            return
        end

        VM:TimerUpdate()
    end, 0, 1, 0)
end

function OpsMoggleCollectTaskTitleItemView:OnRegisterBinder()
    local VM = self:GetViewModel()
    if VM then
        self:RegisterBinders(VM, self.Binders)
    end
end

function OpsMoggleCollectTaskTitleItemView:GetViewModel()
    return self.Params and self.Params.Data or nil
end

function OpsMoggleCollectTaskTitleItemView:UpdateTextTime()
    local VM = self:GetViewModel()
    if not VM then
        return
    end

    if VM.bExpired then
        self.TextTime:SetText(_G.LSTR(1740005))
        return
    end

    local Secs
    if VM.bLock then
        Secs = VM.TimeComingStart
    else
        Secs = VM.TimeComingEnd
    end
    self.TextTime:SetText(string.sformat(_G.LSTR(VM.bLock and 1740003 or 1740004),
        LocalizationUtil.GetCountdownTime(Secs, "smart-t-t")))
end

return OpsMoggleCollectTaskTitleItemView
