---
--- Author: v_vvxinchen
--- DateTime: 2025-06-06 11:53
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local TimeUtil = require("Utils/TimeUtil")
local ItemCfg = require("TableCfg/ItemCfg")
local LSTR = _G.LSTR

---@class FishGuideChatTipsPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ButtonClose UFButton
---@field Common_PopUpBG CommonPopUpBGView
---@field FishDetail UFCanvasPanel
---@field ImgFish UFImage
---@field ImgFishBg1 UFImage
---@field ImgFishCrown UFImage
---@field ImgFishDetailBg UFImage
---@field ImgInch UFImage
---@field PanelFish1 UFCanvasPanel
---@field SkillHandleCloseBtn SkillHandleCloseBtnView
---@field TextFishDetail UFTextBlock
---@field TextFishName URichTextBox
---@field TextFishNumber UFTextBlock
---@field TextMaxSize UFTextBlock
---@field TextName UFTextBlock
---@field TextTime UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimInheritTips UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FishGuideChatTipsPanelView = LuaClass(UIView, true)

function FishGuideChatTipsPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ButtonClose = nil
	--self.Common_PopUpBG = nil
	--self.FishDetail = nil
	--self.ImgFish = nil
	--self.ImgFishBg1 = nil
	--self.ImgFishCrown = nil
	--self.ImgFishDetailBg = nil
	--self.ImgInch = nil
	--self.PanelFish1 = nil
	--self.SkillHandleCloseBtn = nil
	--self.TextFishDetail = nil
	--self.TextFishName = nil
	--self.TextFishNumber = nil
	--self.TextMaxSize = nil
	--self.TextName = nil
	--self.TextTime = nil
	--self.AnimIn = nil
	--self.AnimInheritTips = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FishGuideChatTipsPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Common_PopUpBG)
	self:AddSubView(self.SkillHandleCloseBtn)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FishGuideChatTipsPanelView:OnInit()

end

function FishGuideChatTipsPanelView:OnDestroy()

end

function FishGuideChatTipsPanelView:OnShow()
	-- 鱼的配表ID、尺寸、渔场类型、钓到鱼时间、历史最高排名
	local Params = self.Params
	if Params == nil then
		return
	end

	local FishData = _G.FishNotesMgr:GetFishCfg(Params.ID)
	self.TextFishName:SetText(FishData.Name)
	local RoleVM = _G.RoleInfoMgr:FindRoleVM(Params.RoleID)
	local PlayerName = RoleVM and RoleVM.Name or ""
	self.TextName:SetText(string.format("%s：%s", LSTR(180110), PlayerName))--180110玩家名称
	if Params.Ranking == 0 then
		self.TextFishNumber:SetText(string.format("%s：%s", LSTR(180111), LSTR(70008)))--180111历史最高排名70008"无"
	else
		self.TextFishNumber:SetText(string.format("%s：%d%%", LSTR(180111), math.floor(Params.Ranking * 100)))--180111历史最高排名
	end
	self.TextMaxSize:SetText(string.format("%s：%d%s", LSTR(180112), Params.Size, LSTR(180061)))--180112最大星寸 --星寸
    local FishSizeTime = TimeUtil.GetTimeFormat("%Y/%m/%d", Params.SizeTime)
	self.TextTime:SetText(FishSizeTime)
	self.TextFishDetail:SetText(FishData.Description)

	local InchIconPath = _G.FishGuideVM:GetInchIconPath(FishData.Size, Params.Size)
	UIUtil.ImageSetBrushFromAssetPath(self.ImgInch, InchIconPath)
	local ItemData = ItemCfg:FindCfgByKey(FishData.ItemID)
    if ItemData then
		UIUtil.ImageSetBrushFromAssetPath(self.ImgFish, UIUtil.GetIconPath(ItemData.IconID))
    end

	local IsKing = Params.Ranking == 1
	UIUtil.SetIsVisible(self.ImgFishCrown, IsKing)
end

function FishGuideChatTipsPanelView:OnHide()

end

function FishGuideChatTipsPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.ButtonClose, self.OnClickButtonCloseClick)
end

function FishGuideChatTipsPanelView:OnRegisterGameEvent()

end

function FishGuideChatTipsPanelView:OnRegisterBinder()

end

function FishGuideChatTipsPanelView:OnClickButtonCloseClick()
	_G.UIViewMgr:HideView(_G.UIViewID.FishGuideChatTips)
end

return FishGuideChatTipsPanelView