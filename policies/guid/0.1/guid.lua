local policy = require('apicast.policy')
local _M = policy.new('GUID policy', '0.1')

local new = _M.new
local random = math.random

function _M.new(config)
  local self = new(config)

  self.header_name = config.header_name

  return self
end

function _M:rewrite()
  local header_name = self.header_name or 'GUID'

  ngx.req.set_header(header_name, uuid())
end

local function uuid()
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
        return string.format('%x', v)
    end)
end

return _M
