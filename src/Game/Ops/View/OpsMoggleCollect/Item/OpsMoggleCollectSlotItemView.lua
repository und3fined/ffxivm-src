---
--- Author: jususchen
--- DateTime: 2025-07-29 17:11
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ItemTipsUtil = require("Utils/ItemTipsUtil")

---@class OpsMoggleCollectSlotItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn UFButton
---@field BtnCheck UFButton
---@field IconCheck UFImage
---@field ImgIcon UFImage
---@field TextName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsMoggleCollectSlotItemView = LuaClass(UIView, true)

function OpsMoggleCollectSlotItemView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btn = nil
	--self.BtnCheck = nil
	--self.IconCheck = nil
	--self.ImgIcon = nil
	--self.TextName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsMoggleCollectSlotItemView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsMoggleCollectSlotItemView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.Btn, self.OnClick)
    UIUtil.AddOnClickedEvent(self, self.BtnCheck, self.OnClickCheck)
end

---@param VM OpsMoggleCollectNodeVM
function OpsMoggleCollectSlotItemView:UpdateVM(VM)
    self.VM = VM

    UIUtil.SetIsVisible(self.IconCheck, VM and VM:IsJumpNode())
    if not VM then
        return
    end

    if VM:IsJumpNode() then
        UIUtil.ImageSetBrushFromAssetPath(self.ImgIcon, VM:GetIcon())
        self.TextName:SetText(VM.Title)
        return
    end

    local RewardVM1 = self.VM:GetMoggleRewardItem(1)
    if RewardVM1 then
        UIUtil.ImageSetBrushFromAssetPath(self.ImgIcon, RewardVM1.Icon)
        self.TextName:SetText(RewardVM1.Name)
    end
end

function OpsMoggleCollectSlotItemView:OnClick()
    if not self.VM then
        return
    end

    if self.VM.RewardVMs then
        local RewardVM1 = self.VM.RewardVMs:Get(1)
        if RewardVM1 then
            ItemTipsUtil.ShowTipsByResID(RewardVM1.ItemID, self)
        end
    end
end

function OpsMoggleCollectSlotItemView:OnClickCheck()
    if not self.VM then
        return
    end

   if self.VM:IsJumpNode() then
        _G.OpsMoggleCollectMgr.ClickNodeVM(self.VM)
    end
end

return OpsMoggleCollectSlotItemView
