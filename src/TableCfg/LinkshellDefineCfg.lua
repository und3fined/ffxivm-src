local ProtoRes = require("Protocol/ProtoRes")

local GroupChatGlobalCfgID = ProtoRes.GroupChatGlobalCfgID

-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

local CS = {
    _1_1 = '[300]',
}

---@class LinkshellDefineCfg : CfgBase
local LinkshellDefineCfg = {
	TableName = "c_linkshell_define_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = {
        ID = 1,
        _Value = '[5]',
    },
	LuaData = {
        {
            _Value = '[19000002,100]',
        },
        {
            ID = 2,
            _Value = '[50]',
        },
        {
            ID = 3,
        },
        {
            ID = 4,
        },
        {
            ID = 5,
            _Value = CS._1_1,
        },
        {
            ID = 6,
            _Value = CS._1_1,
        },
        {
            ID = 7,
        },
        {
            ID = 8,
            _Value = '[30]',
        },
        {
            ID = 9,
            _Value = '[15]',
        },
        {
            ID = 10,
            _Value = '[10]',
        },
        {
            ID = 11,
            _Value = '[40]',
        },
        {
            ID = 12,
            _Value = '[3]',
        },
	},
}

setmetatable(LinkshellDefineCfg, { __index = CfgBase })

LinkshellDefineCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

function LinkshellDefineCfg:GetDefineValue(GlobalID)
	local Cfg = self:FindCfgByKey(GlobalID)
	if nil == Cfg or nil == Cfg.Value then
		return 0
	end

	return tonumber(Cfg.Value[1]) or 0
end

---通讯贝创建消耗
function LinkshellDefineCfg:GetCreateCost()
	local Cfg = self:FindCfgByKey(GroupChatGlobalCfgID.GroupChatGlobalCfgIDCreateCost)
	if nil == Cfg or nil == Cfg.Value then
		return 0
	end

	local Value = Cfg.Value
	if nil == Value then
		return 0, 0
	end

	return tonumber(Value[1]) or 0, tonumber(Value[2]) or 0
end

---通讯贝人数上限
function LinkshellDefineCfg:GetMemMaxNum()
	return self:GetDefineValue(GroupChatGlobalCfgID.GroupChatGlobalCfgGroupChatMemsMax)
end

---通讯贝数量上限
function LinkshellDefineCfg:GetLinkShellMaxNum()
	return self:GetDefineValue(GroupChatGlobalCfgID.GroupChatGlobalCfgGroupChatMax)
end

---通讯贝申请冷却时间
function LinkshellDefineCfg:GetLinkShellApplyCD()
	return self:GetDefineValue(GroupChatGlobalCfgID.GroupChatGlobalCfgGroupChatJoinCoolDownTime)
end

---通讯贝管理员上限
function LinkshellDefineCfg:GetManagerMaxNum()
	return self:GetDefineValue(GroupChatGlobalCfgID.GroupChatGlobalCfgGroupChatManageNumMax)
end

---通讯贝招募宣言最大字符数量
function LinkshellDefineCfg:GetManifestoMaxLength()
	return self:GetDefineValue(GroupChatGlobalCfgID.GroupChatGlobalCfgDeclarationCharNumMax)
end

---通讯贝名称最大字符数量
function LinkshellDefineCfg:GetNameMaxLength()
	return self:GetDefineValue(GroupChatGlobalCfgID.GroupChatGlobalCfgNameCharNumMax)
end

---加入通讯贝验证信息最大字符数量
function LinkshellDefineCfg:GetApplyJoinMsgMaxLength()
	return self:GetDefineValue(GroupChatGlobalCfgID.GroupChatGlobalCfgJoinReqCharNumMax)
end

---通讯贝公告最大字符数量
function LinkshellDefineCfg:GetNoticeMaxLength()
	return self:GetDefineValue(GroupChatGlobalCfgID.GroupChatGlobalCfgAnnouncementCharNumMax)
end

return LinkshellDefineCfg
