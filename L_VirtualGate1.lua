---------
-- Version 2017_0123.0
---------

local PLUGIN_VERSION  = "1.10"

local Device = nil
local SERVICE_ID = "urn:upnp-bhomesa-co-za:serviceId:VirtualGate1"
local SID_SwitchPower1 = "urn:upnp-org:serviceId:SwitchPower1"

local lul_tmp = ""

function readVariableOrInit(lul_device, devicetype, name, defaultValue)
  local var = luup.variable_get(devicetype,name, lul_device)
  if (var == nil) then
    var = defaultValue
    luup.variable_set(devicetype,name,var,lul_device)
  end
  return var
end

function readSettings(lul_device)
  local data = {}

  data.pluginversion           = readVariableOrInit(lul_device,SERVICE_ID, "PluginVersion", PLUGIN_VERSION )
  if (data.pluginversion ~= PLUGIN_VERSION ) then
    luup.variable_set(SERVICE_ID, "PluginVersion", PLUGIN_VERSION, lul_device)
  end

  data.toggletimer             = readVariableOrInit(lul_device,SERVICE_ID, "ToggleTimer", 3)
  data.VID_Notify              = tonumber(readVariableOrInit(lul_device,SERVICE_ID, "NotifyID", 11))
  data.DID_GateController      = tonumber(readVariableOrInit(lul_device,SERVICE_ID, "GateControllerID", 3))

  return data
end

function initialize(lul_device)
luup.log("[bHomeGate:] Starting")
  Device = lul_device
  local data = {}
  data = readSettings(Device)

  luup.call_action("urn:veramate-com:serviceId:VeraMatePN", "SendAlert", {Msg="GateControl: Start"}, data.VID_Notify )

  return true
end

--TODO: Add function to reset arm/disarm device after 3sec

function Toggle()
  luup.log("[bHomeGate]: Toggle Requested")
  local data = {}
  data = readSettings(Device)
  luup.call_action(SID_SwitchPower1 ,"SetTarget",{ newTargetValue="1" },data.DID_GateController)
  luup.call_action("urn:veramate-com:serviceId:VeraMatePN", "SendAlert", {Msg="GateControl: Toggle"}, data.VID_Notify )
  --return true
end
