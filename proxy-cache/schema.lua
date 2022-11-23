local typedefs = require "kong.db.schema.typedefs"

return {
    name = "proxy-cache",
    fields = {
          {
            -- this plugin will only be applied to Services or Routes
            consumer = typedefs.no_consumer
          },
          {
            config = {
                type = "record",
                fields = {
                    {
                        response_code = {
                            type = "array",
                            default = {"200", "301", "302"},
                            required = true,
                            elements = {type = "string"}
                        }
                    },
                    {
                        vary_headers = {
                            type = "array",
                            required = false,
                            elements = {type = "string"}
                        }
                    },
                    {
                        vary_nginx_variables = {
                            type = "array",
                            required = false,
                            elements = {type = "string"}
                        }
                    },
                    {
                        cache_ttl = {
                            type = "number",
                            default = 300,
                            required = true
                        }
                    },
                    {
                        cache_control = {type = "boolean", default = true}
                    },
                    {
                        host = {type = "string", required = false}
                    },
                    {
                        sentinel_master_name = {type = "string", required = false}
                    },
                    {
                        sentinel_role = {type = "string", required = false, default = "master"}
                    },
                    {
                        sentinel_addresses = {type = "array", required = false, elements = {type = "string"}}
                    },
                    {
                        port = {
                            type = "number",
                            default = 6379,
                            required = true
                        }
                    },
                    {
                        timeout = {type = "number", required = true, default = 2000}
                    },
                    {
                        password = {type = "string", required = false}
                    },
                    {
                        database = {type = "number", required = true, default = 0}
                    },
                    {
                        max_idle_timeout = {type = "number", required = true, default = 10000}
                    },
                    {
                        pool_size = {type = "number", required = true, default = 1000}
                    }
                }
            }
        }
    }
}