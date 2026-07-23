{
  uuid,
  ssid,
  psk,
}:
{
  connection = {
    inherit uuid;
    id = ssid;
    type = "wifi";
  };
  wifi = {
    inherit ssid;
    mode = "infrastructure";
  };
  wifi-security = {
    inherit psk;
    key-mgmt = "sae";
  };
  ipv4 = {
    method = "auto";
  };
  ipv6 = {
    method = "auto";
  };
}
