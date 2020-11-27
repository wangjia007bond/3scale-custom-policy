local policy = require('apicast.policy')
local _M = policy.new('GUID policy', '0.1')

local new = _M.new

function _M.new(config)
  local self = new(config)
  self.header_name = config.header_name or "GUID"
  return self
end

function _M:rewrite()
  set_request_header(self.header_name, "3f596908-6822-402a-bf3c-e1679f188d56")
end

local function set_request_header(header_name, value)
  ngx.req.set_header(header_name, value)
end

return _M
