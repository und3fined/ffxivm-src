local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCommon = require("Protocol/ProtoCommon")
local MajorUtil = require("Utils/MajorUtil")

---@class LoginCreateSlotItemVM : UIViewModel
local LoginCreateSlotItemVM = LuaClass(UIViewModel)


function LoginCreateSlotItemVM:Ctor()
    --self.bShowImgFace = false  -- 图标
    self.IsSingSelect = false
    self.bShowImgSelectEffect = false --单选
    self.bShowImgTick = false -- 多选
    self.bShowBlank = false -- 空白
    self.bUseCancel = false --可重复点取消
    self.ImgIcon = "Texture2D'/Game/UI/Texture/LoginCreate/UI_LoginCreate_Img_Pattern.UI_LoginCreate_Img_Pattern'"
    self.DataType = nil
    self.DataValue = nil
    --self.bItemSelect = false
    -- 理发屋发型专用
    self.bHaircut = false
    self.bSpecial = false --  特殊发型
    self.bLocked = false    -- 未解锁
    self.bCanUnlock = false -- 可解锁
    self.LockType = nil     -- 解锁类型
    self.HaircutDesc = nil  -- 发型描述
end

function LoginCreateSlotItemVM:UpdateData(SlotData)
    self.IsSingSelect = SlotData.IsSingSelect
    self.bShowBlank = SlotData.bShowBlank
    self.DataValue = SlotData.DataValue
    self.DataType = SlotData.DataType
    self.ImgIcon = SlotData.ImgIcon
    self.bUseCancel = SlotData.bUseCancel
    if self.IsSingSelect == false then
        self.bShowImgTick = SlotData.bShowImgTick
    end
    if SlotData.bHaircut == true then
        self.bHaircut = SlotData.bHaircut
        self.LockType = SlotData.LockType

        if self.LockType ~= nil and self.LockType > 1 then 
            self.bSpecial = true
            self.bLocked = true
            self.HaircutDesc = SlotData.HaircutDesc
        end
        --self.bSpecial = SlotData.bSpecial
        --self.bLocked = SlotData.bLocked
    end
end

function LoginCreateSlotItemVM:OnSelectedChange(IsSelected)
    self.bShowImgSelectEffect = IsSelected and self.IsSingSelect
    if self.bHaircut == true and self.IsSingSelect == false then
        self.bShowImgSelectEffect = false 
    end
    --self.bShowImgTick = IsSelected and (not self.IsSingSelect)
end

-- 可多选时调用
function LoginCreateSlotItemVM:SetSelectState(IsSelected)
    self.bShowImgTick = IsSelected
end

function LoginCreateSlotItemVM:ItemSelectChanged()
    self.bShowImgTick = not self.bShowImgTick
end
return LoginCreateSlotItemVM