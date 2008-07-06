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


