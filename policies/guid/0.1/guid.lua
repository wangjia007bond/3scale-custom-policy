local policy = require('apicast.policy')
local _M = policy.new('GUID policy', '0.1')

local new = _M.new

function _M.new(config)
  local self = new(config)

  self.header_name = config.header_name

  return self
end

function _M:rewrite()
  local header_name = self.header_name or 'GUID'

  ngx.req.set_header(header_name, '3f596908-6822-402a-bf3c-e1679f188d56')
end

return _M
