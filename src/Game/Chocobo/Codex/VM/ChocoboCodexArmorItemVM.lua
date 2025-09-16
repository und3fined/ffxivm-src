local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIUtil = require("Utils/UIUtil")
local RichTextUtil = require("Utils/RichTextUtil")

local BuddyEquipCfg  = require("TableCfg/BuddyEquipCfg")
local UIBindableList = require("UI/UIBindableList")
local ChocoboCodexArmorSlotVM = require("Game/Chocobo/Codex/VM/ChocoboCodexArmorSlotVM")

local ProtoCS = require("Protocol/ProtoCS")
local ChocoboArmorPos = ProtoCS.ChocoboArmorPos

local FLinearColor = _G.UE.FLinearColor

---@class ChocoboCodexArmorItemVM : UIViewModel
local ChocoboCodexArmorItemVM = LuaClass(UIViewModel)

---Ctor
function ChocoboCodexArmorItemVM:Ctor()
    self.ArmorName = "" 
    self.ArmorNum = "" 
    self.ImgShow = "" 
    self.TextOwnNum = ""
    --self.ItemColorAndOpacity = FLinearColor(1, 1, 1, 1)
    self.IsMask = false
    self.ImgShowVisible = false
    self.ImgSelectVisible = false 
    self.PanelShowSelectVisible = false
    self.ArmorPartList = UIBindableList.New(ChocoboCodexArmorSlotVM)
end

function ChocoboCodexArmorItemVM:OnInit()
end

function ChocoboCodexArmorItemVM:OnBegin()
end

function ChocoboCodexArmorItemVM:Clear()
end

function ChocoboCodexArmorItemVM:IsEqualVM(Value)
	return nil ~= Value and Value.ArmorName == self.ArmorName
end

function ChocoboCodexArmorItemVM:UpdateVM(Value)
    if Value == nil then return end

    local ArmorPartList = {}
    local Item = {Value.HeadItem,Value.BodyItem,Value.FootItem}
    local ArmorPos = { ChocoboArmorPos.ChocoboArmorPosHead,ChocoboArmorPos.ChocoboArmorPosBody,ChocoboArmorPos.ChocoboArmorPosLeg }
    local ArmorPartList = {}
    for i = 1,3 do
        if Item[i] ~= nil then
            local ItemCfg = BuddyEquipCfg:FindCfgByKey(Item[i].ItemID)
            if ItemCfg ~= nil then 
                local ArmorPart = {}
                ArmorPart.IconID = ItemCfg.IconID
                ArmorPart.IsMask = Item[i].Owned
                ArmorPart.ItemID = Item[i].ItemID
                ArmorPart.ChocoboArmorPos = ArmorPos[i]
                ArmorPart.IsSpoiler = Value.IsSpoiler
                table.insert(ArmorPartList,ArmorPart)
            end
        end
    end

    self.ArmorPartList:UpdateByValues(ArmorPartList)

    if Value.IconID ~= nil and Value.IconID ~= 0 then
        self.ImgShowVisible = true
        if Value.IsSpoiler == 1 then
            self.ArmorName = LSTR("???")
            self.ImgShow = "Texture2D'/Game/UI/Texture/Chocobo/UI_ChocoboCodex_Image_Unknown.UI_ChocoboCodex_Image_Unknown'"
        else
            self.ArmorName = Value.Name
            self.ImgShow = string.format("PaperSprite'/Game/Assets/Icon/ItemIcon/903000/UI_Icon_%s.UI_Icon_%s'",Value.IconID,Value.IconID)--UIUtil.GetIconPath(Value.IconID)
        end
    else
        self.ImgShowVisible = false
        self.ArmorName = ""
    end

    if Value.PartCount ~= nil and  Value.PartOwnedCount ~= nil then 
        local PartCount =  Value.PartCount 
        local PartOwnedCount = Value.PartOwnedCount
        self.TextOwnNum = string.format("(%d/%d)",PartOwnedCount,PartCount)

        if 0 == Value.PartOwnedCount then
            self.IsMask = true
            --self.ItemColorAndOpacity = FLinearColor(1, 1, 1, 0.6)
        else 
            self.IsMask = false
            --self.ItemColorAndOpacity = FLinearColor(1, 1, 1, 1)
        end
    else
        self.TextOwnNum = ""
    end
end

return ChocoboCodexArmorItemVM