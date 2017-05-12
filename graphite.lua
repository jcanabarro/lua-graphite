local graphite = {
  _VERSION     = 'graphite.lua v0.0.1',
  _DESCRIPTION = 'A simple graphite reporter module for Lua',
  _LICENSE     = [[
    MIT LICENSE

    * Copyright (c) 2017 Yaroslav Syrytsia

    Permission is hereby granted, free of charge, to any person obtaining a
    copy of this software and associated documentation files (the
    "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish,
    distribute, sublicense, and/or sell copies of the Software, and to
    permit persons to whom the Software is furnished to do so, subject to
    the following conditions:

    The above copyright notice and this permission notice shall be included
    in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
    OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
  ]]
}

local socket = require "socket"

------------------------------ PRIVATE METHODS ------------------------------------

local function timestamp()
  return os.time()
end

function format_metric(m)
  return tostring(m.key) .. " " .. tostring(m.value) .. " " .. tostring(m.timestamp or timestamp()) .. "\n"
end

------------------------------ INSTANCE METHODS ------------------------------------
local Graphite = {}
local Graphite_mt = { __index = Graphite }

function Graphite:tag()
  return string.format("graphite: %s:%d", self.host, tostring(self.port))
end

function Graphite:connect()
  local sock = socket.tcp()

  -- wait 3 seconds
  sock:settimeout(self.timeout or 3, "t")

  -- try to connect
  local ok, err = sock:connect(self.host, self.port)
  if not ok then
    return false, string.format("%s: connection error: %s", self:tag(), err)
  end

  -- close old connection if it is available
  self:close()

  self.sock = sock
  return true
end

function Graphite:close()
  if self.sock then
    self.sock:close()
  end
end

function Graphite:send_metric(metric)
  local m = format_metric(metric)

  if not self.sock then
    return false, string.format("%s: cannot send '%s': not connected", self:tag(), m)
  end

  local n, err = self.sock:send(m)
  if n ~= m:len() then
    return false, string.format("%s: cannot send '%s': %s", self:tag(), m, err)
  end
  return true
end

function Graphite:send(metrics)
  for i = 1, #metrics do
    local ok, err = self:send_metric(metrics[i])
    if not ok then
      -- looks like connection is broken
      return false, err
    end
  end
  return true
end

function Graphite:send_simple(key, value, t)
  return self:send{{
    key = key,
    value = value,
    timestamp = t or timestamp(),
  }}
end

------------------------------ PUBLIC INTERFACE ------------------------------------

graphite.new = function(params)
  if not params.port then
    params.port = 2023
  end
  return setmetatable(params, Graphite_mt)
end

return graphite
