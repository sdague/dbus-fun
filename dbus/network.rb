module DBUS
    class Network
        @conn = nil
        def initialize(bus)
            n_dbus = bus.service("org.freedesktop.NetworkManager")
            netman = n_dbus.object("/org/freedesktop/NetworkManager")
            # @conn.introspect
            @conn = DBus::ProxyObjectInterface.new(netman, "org.freedesktop.NetworkManager")
#            if @conn.has_iface? "org.freedesktop.NetworkManager"
#                @conn.default_iface = "org.freedesktop.NetworkManager"
#            end
            return @conn
        end
        
        def Network.ip_to_str(ip)
            d = ip & 0xFF
            c = (ip >> 8) & 0xFF
            b = (ip >> 16) & 0xFF
            a = (ip >> 24) & 0xFF
            
            return "#{d}.#{c}.#{b}.#{a}"
        end
        
        # if there is anything we haven't caught yet, just pass it on down
        def method_missing(sym, *args, &block)
            @conn.send sym, *args, &block
        end

    end
        
    class NetDevice
        @conn = nil
        def initialize(bus, dev)
            n_dbus = bus.service("org.freedesktop.NetworkManager")
            netdev = n_dbus.object(dev)
            @conn = DBus::ProxyObjectInterface.new(netdev, "org.freedesktop.NetworkManager.Devices")
            @conn.define_method("getIP4Address","")
        end
    end
end
