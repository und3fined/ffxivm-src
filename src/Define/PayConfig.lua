---@class PayConfig
local PayConfig =
{
	Env = "release", -- 请求的米大师环境，可传入 release / test / dev / dev_test，依次分别表示现网 / 沙箱 / 米大师内部开发环境 / 米大师内部测试环境
	bLogEnabled = false, -- 是否开启米大师日志
}

return PayConfig