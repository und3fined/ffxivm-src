local LuaClass = require("Core/LuaClass")

local CommonBoxDefine = require("Game/CommMsg/CommonBoxDefine")
local CommonMsgBoxProxy = LuaClass()

local InitBtnInfo = function(self)
    for _, BtnType in pairs(CommonBoxDefine.BtnType) do
        local Info = {}
        Info.bEnable = false
        Info.Name = CommonBoxDefine.BtnInitialName[BtnType]
        self.Data.BtnInfo[BtnType] = Info
    end
end

function CommonMsgBoxProxy:Ctor(Title, Message, Callback, BtnUniformType, bUseCloseOnClick)
    self.Data = {}
    self.Data.BtnInfo = {}
    self:SetTitle(Title)
    self:SetMessage(Message)
    self:SetCallback(Callback)
    self:SetUseCloseOnClick(bUseCloseOnClick)

    InitBtnInfo(self)
    self:SetBtnUniformType(BtnUniformType)

    self:SetUseTips(false)
    self:SetTipsText("")
    self.IsOpen = false
end

function CommonMsgBoxProxy:Open()
    if self.IsOpen == true then
        return
    end

    self.IsOpen = true

    --TODO
end

function CommonMsgBoxProxy:Update()
    if self.IsOpen == false then
        return
    end

    --TODO
end

function CommonMsgBoxProxy:Close()
    if self.IsOpen == false then
        return
    end

    self.IsOpen = false

    --TODO
end

function CommonMsgBoxProxy:SetBtnUniformType(BtnUniformType)
    self.Data.BtnUniformType = BtnUniformType or CommonBoxDefine.BtnUniformType.CancelAndConfirm

    for _, BtnType in pairs(CommonBoxDefine.BtnType) do
        local Flag = 1 << BtnType
        self.Data.BtnInfo[BtnType].bEnable = (BtnUniformType & Flag) == 1
    end
end

function CommonMsgBoxProxy:SetBtnName(BtnType, Name)
    Name = Name or ""
    self.Data.BtnInfo[BtnType].Name = Name
end

function CommonMsgBoxProxy:SetConfirmBtnName(Name)
    self:SetBtnName(CommonBoxDefine.BtnType.Confirm, Name)
end

function CommonMsgBoxProxy:SetCancelBtnName(Name)
    self:SetBtnName(CommonBoxDefine.BtnType.Cancel, Name)
end

function CommonMsgBoxProxy:SetKeepBtnName(Name)
    self:SetBtnName(CommonBoxDefine.BtnType.Keep, Name)
end

function CommonMsgBoxProxy:SetTitle(Title)
    self.Data.Title = Title or ""
end

function CommonMsgBoxProxy:SetMessage(Message)
    self.Data.Message = Message or ""
end

function CommonMsgBoxProxy:SetCallback(Callback)
    self.Data.Callback = Callback
end

function CommonMsgBoxProxy:SetUseCloseOnClick(bUseCloseOnClick)
    self.Data.bUseCloseOnClick = bUseCloseOnClick == nil and false or true
end

function CommonMsgBoxProxy:SetUseTips(bUseTips)
    self.Data.bUseTips = bUseTips or false
end

function CommonMsgBoxProxy:SetTipsText(TipsText)
    self.Data.TipsText = TipsText or ""
end

return CommonMsgBoxProxy


-- -- 使用访问器对象控制访问
-- local A = {}

-- function A.Cotr()
--     local P1 = GetP1()
--     local P2 = self.P2
--     A.CommonMsgBoxProxy = CreateCommonMsgBoxProxy(P1,P2) --必要参数
--     local P4 = GetP4()
--     A.CommonMsgBoxProxy:SetProperty4(P4) --可选参数
--     -- ...
-- end

-- function A.OpenMsgBox()
--     CommonMsgBoxProxy.Open()
-- end

-- --[[
--     好处1：lua不支持指定参数名传参，避免参数多时出现 P1,P2,NIL,P4,P5,NIL,P7
--     好处2：访问器保存参数状态，避免有些参数重复计算
--     好处3：访问器控制对OpenCommonMsg的访问
-- ]]



-- -- 直接访问
-- local B = {}

-- function A.OpenMsgBox()
--     local P1 = GetP1()
--     local P2 = self.P2
--     local P4 = GetP4()

--     Util.OpenMsgBox(P1,P2,nil,P4)
-- end

-- --[[
--     好处1：结构简单，使用方便
-- ]]

