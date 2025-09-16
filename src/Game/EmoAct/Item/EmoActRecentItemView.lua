---
--- Author: Administrator
--- DateTime: 2023-09-26 14:52
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIUtil = require("Utils/UIUtil")
local EmotionMgr = require("Game/Emotion/EmotionMgr")
local EmotionDefines = require("Game/Emotion/Common/EmotionDefines")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local EmoActPanelVM = require("Game/EmoAct/EmoActPanelVM")
local EmoActRecentItemVM = require("Game/EmoAct/VM/EmoActRecentItemVM")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")

local LSTR = _G.LSTR

---@class EmoActRecentItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field PanelItem UFCanvasPanel
---@field PanelSort UFCanvasPanel
---@field TableViewEmoAct UTableView
---@field TextSort UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local EmoActRecentItemView = LuaClass(UIView, true)

function EmoActRecentItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.PanelItem = nil
	--self.PanelSort = nil
	--self.TableViewEmoAct = nil
	--self.TextSort = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function EmoActRecentItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function EmoActRecentItemView:OnInit()
	self.TableViewEmoActAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewEmoAct)
	if self.VM == nil then
		self.VM = EmoActRecentItemVM.New()
	end
end

function EmoActRecentItemView:OnDestroy()

end

function EmoActRecentItemView:OnShow()
	if self.TextSort and self.Params.Data and self.Params.Data.TextSort then
		if self.Params.Data.TextSort == EmotionDefines.RecentFavorite.Recent then  			--显示最近使用
			self.TextSort:SetText(LSTR(210024))	--"最近"
			UIUtil.CanvasSlotSetSize(self.TableViewEmoAct, _G.UE.FVector2D(554, 160))

		elseif self.Params.Data.TextSort == EmotionDefines.RecentFavorite.Favorite then		--显示收藏
			self.TextSort:SetText(LSTR(210005))	--"收藏"
			UIUtil.CanvasSlotSetSize(self.TableViewEmoAct, self:GetSize())
		end
	end

	if self.Params.Data then
		self.VM.RecentEmotionList:Clear()
		self.VM.RecentEmotionList:UpdateByValues(self.Params.Data.EmotionList)
	end
end

function EmoActRecentItemView:OnHide()
end

function EmoActRecentItemView:OnRegisterUIEvent()
end

function EmoActRecentItemView:OnRegisterGameEvent()
end

function EmoActRecentItemView:OnRegisterBinder()
	local Binders = {
		{"ListFavorite", UIBinderValueChangedCallback.New(self, nil, self.UpdateAll) },
	}
	self:RegisterBinders(EmoActPanelVM, Binders)
	local Binders2 = {
		{"RecentEmotionList", UIBinderUpdateBindableList.New(self, self.TableViewEmoActAdapter) },
	}
	self:RegisterBinders(self.VM, Binders2)
end

function EmoActRecentItemView:UpdateAll(EmotionList)
	if EmotionList then
		if self.Params.Data.TextSort == EmotionDefines.RecentFavorite.Favorite then	 --显示收藏
			self.VM.RecentEmotionList:Clear()
			self.VM.RecentEmotionList:UpdateByValues(EmotionList)
		end
	end
end

function EmoActRecentItemView:GetSize()
	local MySize = _G.UE.FVector2D(554, 660)
	if EmoActPanelVM and EmoActPanelVM.RecentSize then
		if EmoActPanelVM.RecentSize.Y > 1 then
			MySize.X = EmoActPanelVM.RecentSize.X
			MySize.Y = EmoActPanelVM.RecentSize.Y
		end
		if EmotionMgr:IsRecentTime() then
			-- 存在最近使用时,计算框框的大小 (外包裹框-最近使用框-文本-间隔)
			local Y = MySize.Y - 160 - 50 - 15 - 50 - 15
			if Y > 0 then
				MySize.Y = Y
			end
		else
			-- 无最近使用时 (外包裹框-文本-间隔)
			local Y = MySize.Y - 50 - 15
			if Y > 0 then
				MySize.Y = Y
			end
		end
	end
	return MySize
end

return EmoActRecentItemView