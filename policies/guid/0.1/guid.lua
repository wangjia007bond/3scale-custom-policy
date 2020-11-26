local policy = require('apicast.policy')
local _M = policy.new('GUID policy', '0.1')

local new = _M.new

local function init_config(config)
  local res = config or { header_name = "GUID" }
  return res
end

local function set_request_header(header_name, value)
  ngx.req.set_header(header_name, value)
end

function _M.new(config)
  local self = new(config)
  self.config = init_config(config)
  return self
end

function _M:rewrite()
  set_request_header(self.config.header_name, "3f596908-6822-402a-bf3c-e1679f188d56")
end

return _M
