---
--- Author: Administrator
--- DateTime: 2023-11-27 10:54
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetImageBrush = require("Binder/UIBinderSetImageBrush")

---@class ArmyWelfareItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnEnter UFButton
---@field ImgIcon UFImage
---@field ImgMaskGray UFImage
---@field PanelUnLock UFCanvasPanel
---@field PanelWelFareItem UFCanvasPanel
---@field TextGrade UFTextBlock
---@field TextName UFTextBlock
---@field TextUnLock UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmyWelfareItemView = LuaClass(UIView, true)

function ArmyWelfareItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnEnter = nil
	--self.ImgIcon = nil
	--self.ImgMaskGray = nil
	--self.PanelUnLock = nil
	--self.PanelWelFareItem = nil
	--self.TextGrade = nil
	--self.TextName = nil
	--self.TextUnLock = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ArmyWelfareItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmyWelfareItemView:OnInit()
	-- self.Binders = {
	-- 	{ "Name", UIBinderSetText.New(self, self.TextName)},
	-- 	{ "Icon",UIBinderSetImageBrush.New(self, self.ImgIcon)},
	-- 	{ "IsLocked", UIBinderSetIsVisible.New(self, self.Imglock)},
	-- }
end

function ArmyWelfareItemView:OnDestroy()

end

function ArmyWelfareItemView:OnShow()
	if nil == self.Params then
		return
	end
	local Data = self.Params.Data
	if nil == Data then
		return
	end
	if Data.OffsetY then
		UIUtil.CanvasSlotSetPosition(self.PanelWelFareItem,  _G.UE.FVector2D(1, Data.OffsetY))
	end
	-- if Data.IsLocked then
	-- 	self:SetRenderOpacity(0.4)
	-- else
	-- 	self:SetRenderOpacity(1.0)
	-- end
	self.TextName:SetText(Data.Name)
	--UIUtil.ImageSetBrushFromAssetPath(self.ImgIcon, Data.Icon)
	--UIUtil.ImageSetBrushFromAssetPath(self.ImgMaskGray, Data.Icon)
	UIUtil.ImageSetMaterialTextureFromAssetPathSync(self.ImgIcon, Data.Icon,"Texture")
	UIUtil.ImageSetMaterialTextureFromAssetPathSync(self.ImgMaskGray, Data.Icon, "Texture")
	UIUtil.SetIsVisible(self.PanelUnLock, Data.IsLocked)
	UIUtil.SetIsVisible(self.TextGrade, not Data.IsLocked)
	local UnLockStr
	if Data.UnLockLevel then
		-- LSTR string:部队等级%d级解锁
		UnLockStr =  LSTR(910261)
		UnLockStr = string.format(UnLockStr, Data.UnLockLevel)
	else
		-- LSTR string:【敬请期待】
		UnLockStr = LSTR(910024)
	end
	self.TextUnLock:SetText(UnLockStr)
	-- LSTR string:%d级
	local WelfareLevel = LSTR(910005)
	---未开放的item不会有WelfareLevel
	if Data.WelfareLevel then
		WelfareLevel = string.format(WelfareLevel, Data.WelfareLevel)
	end
	self.TextGrade:SetText(WelfareLevel)
	self.TextUnLock:SetText(UnLockStr)
end

function ArmyWelfareItemView:OnHide()

end

function ArmyWelfareItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnEnter, self.OnClickedItem)
end

function ArmyWelfareItemView:OnClickedItem()
	local Params = self.Params
	if nil == Params then
		return
	end
	local Adapter = Params.Adapter
	if nil == Adapter then
		return
	end
	Adapter:OnItemClicked(self, Params.Index)
end

function ArmyWelfareItemView:OnRegisterGameEvent()

end

function ArmyWelfareItemView:OnRegisterBinder()

end

return ArmyWelfareItemView