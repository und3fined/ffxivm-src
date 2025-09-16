---
--- Author: Administrator
--- DateTime: 2023-11-01 15:37
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ProtoRes = require("Protocol/ProtoRes")
local ChocoboUiIconCfg = require("TableCfg/ChocoboUiIconCfg")

---@class ChocoboRaceNumberItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgArrow UFImage
---@field ImgBG UFImage
---@field TextNumber UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimReach UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChocoboRaceNumberItemView = LuaClass(UIView, true)

function ChocoboRaceNumberItemView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgArrow = nil
	--self.ImgBG = nil
	--self.TextNumber = nil
	--self.AnimIn = nil
	--self.AnimReach = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChocoboRaceNumberItemView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChocoboRaceNumberItemView:OnInit()
    self.IsPlayAnimReach = false
    self.RaceFlagBgIconPath = {
        Major = ChocoboUiIconCfg:FindPathByKey(ProtoRes.CHOCOBO_UI_ICON_TYPE.RANK_FLAG_ICON_MAJOR),
        Other = ChocoboUiIconCfg:FindPathByKey(ProtoRes.CHOCOBO_UI_ICON_TYPE.RANK_FLAG_ICON_OTHER),
    }
end

function ChocoboRaceNumberItemView:OnDestroy()

end

function ChocoboRaceNumberItemView:OnShow()

end

function ChocoboRaceNumberItemView:OnHide()

end

function ChocoboRaceNumberItemView:OnRegisterUIEvent()

end

function ChocoboRaceNumberItemView:OnRegisterGameEvent()

end

function ChocoboRaceNumberItemView:OnRegisterBinder()

end

function ChocoboRaceNumberItemView:SetIndex(num)
    self.TextNumber:SetText(tostring(num))
    if _G.ChocoboRaceMgr:IsMajorByIndex(num) or _G.ChocoboRaceMainVM:IsNpcChallengeByIndex(num) then
        UIUtil.ImageSetBrushFromAssetPath(self.ImgBG, self.RaceFlagBgIconPath.Major)
    else
        UIUtil.ImageSetBrushFromAssetPath(self.ImgBG, self.RaceFlagBgIconPath.Other)
    end
end

function ChocoboRaceNumberItemView:ShowImgArrow(IsOn)
    UIUtil.SetIsVisible(self.ImgArrow, IsOn)
end

function ChocoboRaceNumberItemView:PlayAnimReach()
    if self.IsPlayAnimReach then return end

    self.IsPlayAnimReach = true
    self:PlayAnimation(self.AnimReach)
end

return ChocoboRaceNumberItemView