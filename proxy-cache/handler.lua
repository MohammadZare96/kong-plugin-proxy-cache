local BasePlugin = require "kong.plugins.base_plugin"
local access = require 'kong.plugins.proxy-cache.access'
local body_filter = require 'kong.plugins.proxy-cache.body_filter'
local LRUCache = require "resty.lrucache"

local ProxyCaching = BasePlugin:extend()

ProxyCaching.PRIORITY = 1006
ProxyCaching.VERSION = '1.2.0'

local lrucache = LRUCache.new(200)

function ProxyCaching:new()
    ProxyCaching.super.new(self, "proxy-cache")
end

function ProxyCaching:init_worker()
    ProxyCaching.super.init_worker(self)
end

function ProxyCaching:access(config)
    ProxyCaching.super.access(self)
    local ok, err = pcall(access.execute, config, lrucache)
    if not ok then
        ngx.log(ngx.CRIT, err)
    end
end

function ProxyCaching:body_filter(config)
    ProxyCaching.super.body_filter(self)
    local ok, err = pcall(body_filter.execute, config, lrucache)
    if not ok then
        ngx.log(ngx.CRIT, err)
    end
end

return ProxyCaching
