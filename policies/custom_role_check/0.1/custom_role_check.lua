--- Custom Role Check Policy
-- This policy verifies the roles in the JWT.
--
--
-- When you specify the roles, the JWT includes them as follows:
--
-- {
--     "roles": [
--       "<role_A>", "<role_B>"
--     ]
-- }
--
-- And you need to specify the "roles" in this policy as follows:
--
-- "roles": [
--   { "name": "<role_A>" }, { "name": "<role_B>" }
-- ]

local policy = require('apicast.policy')
local _M = policy.new('Custom Role Check Policy', '0.1')

local ipairs = ipairs
local MappingRule = require('apicast.mapping_rule')
local TemplateString = require('apicast.template_string')
local errors = require('apicast.errors')
local default_type = 'plain'

local new = _M.new

local any_method = MappingRule.any_method

local function create_template(value, value_type)
  return TemplateString.new(value, value_type or default_type)
end

local function build_scopes(scopes)
  for _, scope in ipairs(scopes) do

    if scope.roles then
      for _, role in ipairs(scope.roles) do
        role.template_string = create_template(
          role.name, role.name_type)
      end
    end

    scope.resource_template_string = create_template(
      scope.resource, scope.resource_type)
    if (not scope.methods) or (scope.methods and #scope.methods == 0 ) then
      scope.methods = { any_method }
    end

  end

end

function _M.new(config)
  local self = new()
  self.type = config.type or "whitelist"
  self.scopes = config.scopes or {}

  build_scopes(self.scopes)

  return self
end

local function check_roles_in_token(role, roles_in_token)
  for _, role_in_token in ipairs(roles_in_token) do
    if role == role_in_token then return true end
  end

  return false
end

local function match_roles(scope, context)
  if not scope.roles then return true end

  for _, role in ipairs(scope.roles) do
    if not context.jwt.roles then
      return false
    end

    local name = role.template_string:render(context)

    if not check_roles_in_token(name, context.jwt.roles or {}) then
      return false
    end
  end

  return true
end

local function validate_scope_access(scope, context, uri, request_method)
  for _, method  in ipairs(scope.methods) do

    local resource = scope.resource_template_string:render(context)

    local mapping_rule = MappingRule.from_proxy_rule({
      http_method = method,
      pattern = resource,
      querystring_parameters = {},
      -- the name of the metric is irrelevant
      metric_system_name = 'hits'
    })

    if mapping_rule:matches(request_method, uri) then
      if match_roles(scope, context) then
        return true
      end
    end
  end
  return false
end

local function scopes_check(scopes, context)
  local uri = ngx.var.uri
  local request_method =  ngx.req.get_method()

  if not context.jwt then
    return false
  end

  for _, scope in ipairs(scopes) do
    if validate_scope_access(scope, context, uri, request_method) then
      return true
    end
  end

  return false
end

function _M:access(context)
  if scopes_check(self.scopes, context) then
    if self.type == "blacklist" then
      return errors.authorization_failed(context.service)
    end
  else
    if self.type == "whitelist" then
      return errors.authorization_failed(context.service)
    end
  end
  return true
end

return _M