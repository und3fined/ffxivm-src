---
--- Author: sammrli
--- DateTime: 2024-02-02 17:09
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local TravelLogFilmItemVMClass = require("Game/TravelLog/VM/TravelLogFilmItemVM")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

local NUM_CAN_SCROLL = 7

---@class TravelLogFilmItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FTextBlock UFTextBlock
---@field FTextBlock_53 UFTextBlock
---@field ImgFilmBg UFImage
---@field TabeViewVideo UTableView
---@field AnimChangeMission UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimShow UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TravelLogFilmItemView = LuaClass(UIView, true)

function TravelLogFilmItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.FTextBlock = nil
	--self.FTextBlock_53 = nil
	--self.ImgFilmBg = nil
	--self.TabeViewVideo = nil
	--self.AnimChangeMission = nil
	--self.AnimIn = nil
	--self.AnimShow = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TravelLogFilmItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TravelLogFilmItemView:OnInit()
	self.TravelLogFilmItemVM = TravelLogFilmItemVMClass:New()
	self.VideoListAdapter = UIAdapterTableView.CreateAdapter(self, self.TabeViewVideo, self.OnVideoSelectChanged)
end

function TravelLogFilmItemView:OnDestroy()

end

function TravelLogFilmItemView:OnShow()
	self.FTextBlock_53:SetText(_G.LSTR(530008)) --530008("过场动画")
end

function TravelLogFilmItemView:OnHide()

end

function TravelLogFilmItemView:OnRegisterUIEvent()

end

function TravelLogFilmItemView:OnRegisterGameEvent()

end

function TravelLogFilmItemView:OnRegisterBinder()
	local Binders = {
		{"FilmVMList", UIBinderUpdateBindableList.New(self, self.VideoListAdapter)},
		{"TextNum", UIBinderSetText.New(self, self.FTextBlock)},
		{"FilmNum", UIBinderValueChangedCallback.New(self, nil, self.OnFilmNumChange)},
	}
	self:RegisterBinders(self.TravelLogFilmItemVM ,Binders)
end

function TravelLogFilmItemView:OnVideoSelectChanged(Index, ItemData, ItemView)
	--播放cut scene
	local VM = self.TravelLogFilmItemVM.FilmVMList:Get(Index)
    if VM then
        if string.isnilorempty(VM.Path) then
            return
        end
    end
	self.TravelLogFilmItemVM:Switch(Index)
	self.VideoListAdapter:ScrollToIndex(Index)
end

function TravelLogFilmItemView:OnFilmNumChange(Val)
	if Val >= NUM_CAN_SCROLL then
		self.TabeViewVideo:SetScrollEnabled(true)
	else
		self.TabeViewVideo:SetScrollEnabled(false)
	end
end

-- ==================================================
-- 外部接口
-- ==================================================

---@param LogID number
function TravelLogFilmItemView:Show(LogID)
	self.TravelLogFilmItemVM:Show(LogID)
	self.VideoListAdapter:ScrollToTop()
end

---@param TabIndex number
---@param ScrollOffset number
---@param SubGenreIndex number
function TravelLogFilmItemView:Play(TabIndex, ScrollOffset, SubGenreIndex)
	self.TravelLogFilmItemVM:Play(TabIndex, ScrollOffset, SubGenreIndex)
end

return TravelLogFilmItemView