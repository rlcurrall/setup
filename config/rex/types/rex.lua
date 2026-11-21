---@meta

-- Editor definitions only: never require this file from init.lua.
-- Covers the APIs used by this config, not the entire Rex API.
-- Checked against https://www.superlogical.com/rex/docs/reference/lua
-- on 2026-11-21. Update individual definitions when adopting API changes.

---@class RexContext
---@field session_id? string
---@field block_id? string
---@field client_id? string
---@field origin? string
---@field server? string

---@class RexKeyEvent
---@field keybinding string
---@field prefix? string[]

---@class RexModeOptions
---@field exclusive? boolean Defaults to false.

---@class RexAction
---@field name string Lowercase letters, digits, and underscores.
---@field title string Label in the command palette.
---@field run fun(ctx: RexContext, args: table<string, any>): any
---@field description? string
---@field category? string Defaults to Actions.
---@field keywords? string
---@field args? table<string, any> Argument type names (append ? for optional), or JSON Schema.
---@field repeats? boolean Repeat while held.

---@class RexClient
local client = {}

---Schedule a client action. In a custom action, runs after successful completion.
---Requires a connected client; use inside an action, not at config load time.
---@param name string
---@param args? table<string, any>
function client.queue(name, args) end

---@class Rex
---@field client RexClient
rex = { client = client }

---Bind a key, sequence (using >), or mode/key to an action or callback.
---Callbacks receive context and key details; return true to handle the key.
---Callback bindings cannot belong to a mode.
---@param key string
---@param action string
---@param args? table<string, any>
---@overload fun(key: string, callback: fun(ctx: RexContext, ev: RexKeyEvent): boolean?)
function rex.bind(key, action, args) end

---Declare a key mode while loading the config.
---@param name string
---@param options? RexModeOptions
function rex.mode(name, options) end

---Register a custom action while loading the config.
---The run callback receives context and arguments; its return value is the result.
---@param definition RexAction
function rex.action(definition) end
