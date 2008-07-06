require "pp"

PIDGIN_AWAY = 5
PIDGIN_ACTIVE = 2

module DBUS
    class Pidgin
        @conn = nil
        
        def initialize(bus)
            # Get the pidgin service
            pidgin_dbus = bus.service("im.pidgin.purple.PurpleService")
            
            # Get the object from this service
            @conn = pidgin_dbus.object("/im/pidgin/purple/PurpleObject")
    
            # Introspect it
            @conn.introspect
            if @conn.has_iface? "im.pidgin.purple.PurpleInterface"
                @conn.default_iface = "im.pidgin.purple.PurpleInterface"
                puts "We have Pidgin interface"
            end
        end
        
        def reconnect
            accounts = @conn.PurpleAccountsGetAll
            # get rid of active connections
            for account in accounts[0]
                if @conn.PurpleAccountIsConnected(account)[0] > 0
                    @conn.PurpleAccountDisconnect(account)
                end
            end
            #restore new connections
            for account in accounts[0]
                @conn.PurpleAccountConnect(account)
            end
        end

        # get the first active account
        def active_account
            accounts = @conn.PurpleAccountsGetAll
            for account in accounts[0]
                if @conn.PurpleAccountIsConnected(account)[0] > 0
                    return account
                end
            end
        end
        
        def status
            s = @conn.PurpleAccountGetActiveStatus(active_account)[0]
            # s = @conn.PurpleSavedstatusGetCurrent[0]
            msg = @conn.PurpleStatusGetAttrString(s, "message")[0]
            
            # we need to convert to pidgin status types
            native_type = @conn.PurpleStatusGetType(s)[0]
            type = @conn.PurpleStatusTypeGetPrimitive(native_type)[0]
            
            name = @conn.PurpleStatusGetName(s)[0]

            return Pidgin::Status.new(msg, type, name)
        end
        
        def status=(s)
            status = @conn.PurpleSavedstatusFind(s.name)[0]
            if not status > 0
                status = @conn.PurpleSavedstatusNew(s.name, s.type)[0]
            end
            
            @conn.PurpleSavedstatusSetMessage(status, s.msg)
            @conn.PurpleSavedstatusActivate(status)
        end
        
        def away!
            s = status
            if not s.away?
                s.type = PIDGIN_AWAY
                status = s
            end
        end

        def active!
            s = status
            if not s.active?
                s.type = PIDGIN_ACTIVE
                status = s
            end
        end
    end
    
    class Pidgin::Status
        attr_accessor :msg, :type, :name

        def initialize(msg="", type=PIDGIN_ACTIVE, name="Pidgin::Status")
            @msg = msg
            @type = type
            @name = name
        end

        def away?
            return @type == PIDGIN_AWAY
        end
        
        def active?
            return @type == PIDGIN_ACTIVE
        end
        
    end
end
