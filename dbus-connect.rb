#!/usr/bin/ruby

require "dbus"

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

def connect_netman(bus)
    n_dbus = bus.service("org.freedesktop.NetworkManager")
    netman = n_dbus.object("/org/freedesktop/NetworkManager")
    poi = DBus::ProxyObjectInterface.new(netman, "org.freedesktop.NetworkManager")
    return poi
end

def connect_netdev(bus, dev)
    n_dbus = bus.service("org.freedesktop.NetworkManager")
    netdev = n_dbus.object(dev)
    poi = DBus::ProxyObjectInterface.new(netdev, "org.freedesktop.NetworkManager.Devices")
    poi.define_method("getIP4Address","")
    return poi
end

