---
--- Author: Administrator
--- DateTime: 2024-01-26 20:13
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ProtoRes = require("Protocol/ProtoRes")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local SystemEntranceMgr = require("Game/Common/Tips/SystemEntranceMgr")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local LSTR = _G.LSTR
local UIViewMgr = _G.UIViewMgr
local UIViewID = _G.UIViewID

---@class MusicAtlasGetWayItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnGo UFButton
---@field ImgArrow UFImage
---@field ImgItemBg UFImage
---@field ImgItemBgSelect UFImage
---@field ImgItemIcon UFImage
---@field TextQuestName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MusicAtlasGetWayItemView = LuaClass(UIView, true)

function MusicAtlasGetWayItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnGo = nil
	--self.ImgArrow = nil
	--self.ImgItemBg = nil
	--self.ImgItemBgSelect = nil
	--self.ImgItemIcon = nil
	--self.TextQuestName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MusicAtlasGetWayItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MusicAtlasGetWayItemView:OnInit()

end

function MusicAtlasGetWayItemView:OnDestroy()

end

function MusicAtlasGetWayItemView:OnShow()
	local Params = self.Params
	if nil == Params then
		return
	end
	local Item = Params.Data
	if nil == Item then
		return
	end
	UIUtil.ImageSetBrushFromAssetPath(self.ImgItemIcon, Item.FunIcon)
	self.TextQuestName:SetText(Item.FunDesc)
	if Item.IsUnLock then
		-- UIUtil.SetIsVisible(self.BtnGo, true, true)
		UIUtil.SetColorAndOpacity(self.TextQuestName, 1, 1, 1, 1)
		UIUtil.SetColorAndOpacity(self.ImgArrow, 1, 1, 1, 1)
		UIUtil.SetColorAndOpacity(self.ImgItemIcon, 1, 1, 1, 1)
		self.IsUnLock = true
	else
		-- UIUtil.SetIsVisible(self.BtnGo, true, false)
		UIUtil.SetColorAndOpacity(self.TextQuestName, 0.4, 0.4, 0.4, 0.4)
		UIUtil.SetColorAndOpacity(self.ImgArrow, 0.4, 0.4, 0.4, 0.4)
		UIUtil.SetColorAndOpacity(self.ImgItemIcon, 0.4, 0.4, 0.4, 0.4)
		self.IsUnLock = false
	end
	if not Item.IsRedirect or Item.IsRedirect == 0 then --是否跳转
		--UIUtil.SetIsVisible(self.ImgArrow, false)
		--UIUtil.SetIsVisible(self.BtnGo, true, false)
	end
end

function MusicAtlasGetWayItemView:OnHide()

end

function MusicAtlasGetWayItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnGo, self.OnGoClicked)
end


function MusicAtlasGetWayItemView:OnRegisterGameEvent()

end

function MusicAtlasGetWayItemView:OnRegisterBinder()

end

function MusicAtlasGetWayItemView:OnGoClicked()
	local Params = self.Params
	if nil == Params then
		return
	end
	local Item = Params.Data

	if nil == Item then
		return
	end
	if not Item.IsUnLock then
		MsgTipsUtil.ShowTips(LSTR(1170005))
		return
	end
	if Item.IsRedirect == 0 then --跳转状态为0不跳转
		return
	end
	local ItemUtil = require("Utils/ItemUtil")
	ItemUtil.JumpGetWayByItemData(Item)

	UIViewMgr:HideView(UIViewID.CommGetWayTipsView)
end

return MusicAtlasGetWayItemView