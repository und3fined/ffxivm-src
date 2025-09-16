---
--- Author: Administrator
--- DateTime: 2023-11-15 16:35
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIViewID = require("Define/UIViewID")
local UIViewMgr = require("UI/UIViewMgr")

local ProtoRes = require("Protocol/ProtoRes")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local SystemEntranceMgr = require("Game/Common/Tips/SystemEntranceMgr")
local ItemTipsUtil = require("Utils/ItemTipsUtil")

---@class TreasureHuntGetMapItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnGo UFButton
---@field ImgArrow UFImage
---@field ImgIcon UFImage
---@field TextWay UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TreasureHuntGetMapItemView = LuaClass(UIView, true)

function TreasureHuntGetMapItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnGo = nil
	--self.ImgArrow = nil
	--self.ImgIcon = nil
	--self.TextWay = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TreasureHuntGetMapItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TreasureHuntGetMapItemView:OnInit()	
end

function TreasureHuntGetMapItemView:OnDestroy()

end

function TreasureHuntGetMapItemView:OnShow()
	local Params = self.Params
	if nil == Params then
		return
	end
	local Item = Params.Data
	if nil == Item then
		return
	end
	UIUtil.ImageSetBrushFromAssetPath(self.ImgIcon, Item.FunIcon, false, true)
	self.TextWay:SetText(Item.FunDesc)
	if Item.IsUnLock then
		--UIUtil.SetColorAndOpacity(self.TextWay, 1, 1, 1, 1)
		--UIUtil.SetColorAndOpacity(self.ImgArrow, 1, 1, 1, 1)
		--UIUtil.SetColorAndOpacity(self.ImgIcon, 1, 1, 1, 1)
		self.IsUnLock = true
	else
		--UIUtil.SetColorAndOpacity(self.TextWay, 0.4, 0.4, 0.4, 0.4)
		--UIUtil.SetColorAndOpacity(self.ImgArrow, 0.4, 0.4, 0.4, 0.4)
		--UIUtil.SetColorAndOpacity(self.ImgIcon, 0.4, 0.4, 0.4, 0.4)
		self.IsUnLock = false
	end

	if not Item.IsRedirect or Item.IsRedirect == 0 then --是否跳转
		UIUtil.SetIsVisible(self.ImgArrow, false)
	else
		UIUtil.SetIsVisible(self.ImgArrow, true)
	end
end

function TreasureHuntGetMapItemView:OnHide()

end

function TreasureHuntGetMapItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnGo, self.OnGoClicked)
end

function TreasureHuntGetMapItemView:OnRegisterGameEvent()

end

function TreasureHuntGetMapItemView:OnRegisterBinder()
end

function TreasureHuntGetMapItemView:OnGoClicked()
	local Params = self.Params
	if nil == Params then
		return
	end
	local Item = Params.Data

	if nil == Item then
		return
	end
	if not Item.IsUnLock then
		_G.MsgTipsUtil.ShowTips(_G.LSTR(640030))  --暂未解锁
		return
	end
	if Item.IsRedirect == 0 then --跳转状态为0不跳转
		return
	end

	local ItemUtil = require("Utils/ItemUtil")
	ItemUtil.JumpGetWayByItemData(Item)

end

return TreasureHuntGetMapItemView