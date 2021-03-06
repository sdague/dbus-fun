require "pp"

PIDGIN_AWAY = 5
PIDGIN_ACTIVE = 2

module DBUS
    class Pidgin
        @conn = nil
        @msg = ""
        
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
        
        def status_msg(msg)
            @msg = msg
            status = self.status
            status.msg = msg
            self.status = status
        end
        
        def set_status(msg)
            self.status = Pidgin::Status.new(msg, PIDGIN_ACTIVE, "Available")
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
            @msg = s.msg
            status = @conn.PurpleSavedstatusFind(s.name)[0]
            if not status > 0
                status = @conn.PurpleSavedstatusNew(s.name, s.type)[0]
            end
            
            @conn.PurpleSavedstatusSetMessage(status, s.msg)
            @conn.PurpleSavedstatusActivate(status)
        end

        def send_im(from, to, msg)
            begin 
                account = @conn.PurpleAccountsFind(from,"")[0]
                conv = @conn.PurpleConversationNew(1, account, to)[0]
                im = @conn.PurpleConvIm(conv)[0]
                @conn.PurpleConvImSend(im, msg)
                @conn.PurpleConversationDestroy(conv)
            rescue => e
                puts "#{$!} => #{e}"
            end
        end
        
        def away!(msg=nil)
            if msg == nil
                msg = @msg
            end
            s = Pidgin::Status.new(msg, PIDGIN_AWAY, "Away")
            self.status = s
        end

        def active!(msg=nil)
            s = Pidgin::Status.new(msg, PIDGIN_ACTIVE, "Available")
            if not msg
                s = self.status
                s.type = PIDGIN_ACTIVE
            end
            self.status = s
        end

        # if there is anything we haven't caught yet, just pass it on down
        def method_missing(sym, *args, &block)
            @conn.send sym, *args, &block
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
