#!/usr/bin/ruby

require "dbus"
require "pp"
require "dbus-connect"
require "dbus-actions"

bus = DBus::SystemBus.instance
session_bus = DBus::SessionBus.instance

netman = connect_netman(bus)
pidgin = connect_pidgin(session_bus)
ss = connect_screensaver(session_bus)
# pidgin.on_signal("WroteImMsg") { |a, b, c, d|
#     pp a
#     pp b
#     pp c
#     pp d
# }
ss.on_signal("ActiveChanged") {|s|
    if s
        mute
    else
        unmute
    end
}

netman.on_signal(bus, "DeviceNowActive") { |d, n|
    dev = connect_netdev(bus, d)
    puts "0x%08x" % dev.getIP4Address
    pp d
    pp n
    recycle_pidgin(pidgin) 
}

main = DBus::Main.new
main << bus
main << session_bus
main.run
