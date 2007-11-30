#!/usr/bin/ruby

require "dbus"
require "pp"

@@vol = 0

bus = DBus::SystemBus.instance
session_bus = DBus::SessionBus.instance

def connect_screensaver(session_bus)
    ss_dbus = session_bus.service("org.gnome.ScreenSaver")
    ss = ss_dbus.object("/org/gnome/ScreenSaver")
    ss.introspect
    if ss.has_iface? "org.gnome.ScreenSaver"
        ss.default_iface = "org.gnome.ScreenSaver"
        puts "Connected to screensaver"
    end
    return ss
end

def connect_pidgin(session_bus)
    # Get the pidgin service
    pidgin_dbus = session_bus.service("im.pidgin.purple.PurpleService")
    
    # Get the object from this service
    pidgin = pidgin_dbus.object("/im/pidgin/purple/PurpleObject")
    
    # Introspect it
    pidgin.introspect
    if pidgin.has_iface? "im.pidgin.purple.PurpleInterface"
        pidgin.default_iface = "im.pidgin.purple.PurpleInterface"
        puts "We have Pidgin interface"
    end
    return pidgin
end

def connect_netman(bus)
    n_dbus = bus.service("org.freedesktop.NetworkManager")
    netman = n_dbus.object("/org/freedesktop/NetworkManager")
    poi = DBus::ProxyObjectInterface.new(netman, "org.freedesktop.NetworkManager")
    return poi
end

def recycle_pidgin(pidgin)
    accounts = pidgin.PurpleAccountsGetAll
    for account in accounts[0]
        if pidgin.PurpleAccountIsConnected(account)[0] > 0
            pidgin.PurpleAccountDisconnect(account)
        end
        pidgin.PurpleAccountConnect(account)
    end
end

def mute()
    IO.popen("aumix -vq") {|r|
        r.read.scan(/(\d+)/) {|m|
            @@vol = m
            puts "saved volume: #{@@vol}"
            break
        }
    }
    puts "muting"
    system("aumix -v 0")
end

def unmute()
    puts "unmuting"
    system("aumix -v #{@@vol}")
end

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

netman.on_signal(bus, "DeviceNowActive") { 
    recycle_pidgin(pidgin) 
}

main = DBus::Main.new
main << bus
main << session_bus
main.run
