local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCommon = require("Protocol/ProtoCommon")
--local MajorUtil = require("Utils/MajorUtil")
local ProtoEnumAlias = require("Protocol/ProtoEnumAlias")
local LoginCreateSaveVM = require("Game/LoginCreate/LoginCreateSaveVM")
local LoginCreateSaveItemVM = require("Game/LoginCreate/LoginCreateSaveItemVM")


---@class LoginCreateSaveWinVM : UIViewModel
local LoginCreateSaveWinVM = LuaClass(UIViewModel)


function LoginCreateSaveWinVM:Ctor()
    self.ListSaveTableVM = nil
    self.SaveTableIndex = 0
    self.bBtnConfirmEnable = true
    self.TextBtnConfirm = nil
    self.bFirstGetList = true
end
-- 部分数据初始化
function LoginCreateSaveWinVM:InitViewData()
    self.SaveTableIndex = 0
    self.TextBtnConfirm = LoginCreateSaveVM.bSaved and  _G.LSTR(980003) or _G.LSTR(980039)
    -- 读档
	_G.LoginAvatarMgr:SendMsgRoleQuery()
    --self.bBtnConfirmEnable = false
    self:SetSaveList() ---test
    self.bFirstGetList = true
end
-- 确定操作
function LoginCreateSaveWinVM:DoConfirmRole()
    if LoginCreateSaveVM.bSaved then
        local SaveIndex = self.SaveTableIndex
        local SeverList = LoginCreateSaveVM.SaveList
        if SeverList == nil or SaveIndex > #SeverList then
            SaveIndex = 0 -- 未存档操作
        end
        _G.LoginAvatarMgr:SendMsgRoleCreate(SaveIndex)
    else
        -- 读档
        _G.LoginAvatarMgr:LoadServerAvatar(LoginCreateSaveVM.SaveList[self.SaveTableIndex])
    end
    --self.bBtnConfirmEnable = false
end

-- 所选存档变化
function LoginCreateSaveWinVM:UpdateSaveTableSelected(Index)
    self.SaveTableIndex = Index
    --self.bBtnConfirmEnable = true
end

-- 设置存档列表
function LoginCreateSaveWinVM:SetSaveList()
    if LoginCreateSaveVM.SaveList == nil then return end
    local ListVMp = {}
    for Index, RoleData in ipairs(LoginCreateSaveVM.SaveList) do
        local GenderName = RoleData.Gender == 1 and _G.LSTR(980031) or _G.LSTR(980012)
        local TribeName = ProtoEnumAlias.GetAlias(ProtoCommon.tribe_type, RoleData.Tribe or "")
        local TimeData = self:FormatUnixTime(RoleData.CreatedTime)
        local SaveItemVM = LoginCreateSaveItemVM.New()
        local ItemData = {IdText = tostring(Index), TimeText = TimeData, TribeGenderText = TribeName..GenderName, FaceList = RoleData.DataList}
        SaveItemVM:SetItemData(ItemData)
        ListVMp[#ListVMp + 1] = SaveItemVM
    end

    -- 未保存的数据
    local bNewCreate = LoginCreateSaveVM.bSaved and #ListVMp < 5

    if bNewCreate then
        local BlankItemVM = LoginCreateSaveItemVM.New()
        local BlankData = {IdText = tostring(#ListVMp) + 1, TimeText = _G.LSTR(980024), TribeGenderText = "", FaceList = _G.LoginAvatarMgr:GetCurAvatarFace()}
        BlankItemVM:SetItemData(BlankData)
        ListVMp[#ListVMp + 1] = BlankItemVM
    end
    self.ListSaveTableVM = ListVMp
end

-- 获取日期时间展示
function LoginCreateSaveWinVM:FormatUnixTime(unixTime)
    local FormatText = ""
    if unixTime and unixTime >= 0 then
        local RealTime = {}
        RealTime.year = tonumber(os.date("%Y",unixTime))
        RealTime.month =tonumber(os.date("%m",unixTime))
        RealTime.day = tonumber(os.date("%d",unixTime))
        RealTime.hour = tonumber(os.date("%H",unixTime))
        RealTime.minute = tonumber(os.date("%M",unixTime))
        RealTime.second = tonumber(os.date("%S",unixTime))
        FormatText = string.format("%04d/%02d/%02d %02d:%02d:%02d", RealTime.year, RealTime.month, RealTime.day,
                                                                    RealTime.hour, RealTime.minute, RealTime.second)
    end
    return FormatText
end

return LoginCreateSaveWinVM