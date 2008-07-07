require "twitter"

module DBUS
    class Status
        @services = nil
        def initialize(pidgin, file)
            @services = [
                         Status::Twitter.new(file),
                         Status::Identica.new(pidgin, file)
                       ]
        end
        
        def status=(s)
            @services.each do |svr|
                svr.status = s
            end
        end
        
        def status
            return @services[0].status
        end
    end

    class Status::Identica
        @account = ""
        @pidgin = nil
        def initialize(pidgin, file)
            config = YAML.load_file(file)
            @account = config["identica"]["user"]
            @pidgin = pidgin
        end
        
        def status=(s)
            @pidgin.send_im(@account, "update@identi.ca", s)
        end
    end
    
    class Status::Twitter
        @user = ""
        @me = ""
        @passwd = ""
        @conn = nil
        def initialize(file)
            config = YAML.load_file(file)
            @user = config["twitter"]["user"]
            @me = config["twitter"]["me"]
            @passwd = config["twitter"]["passwd"]
            @conn = Twitter::Base.new(@user, @passwd)
        end
        
        def status
            msg = ""
            begin
                puts "Retrieving twitter status"
                msg = @conn.user(@me).status.text
            rescue => e
                puts "#{$!} => #{e}"
            end
            return msg
        end
        
        def status=(s)
            begin
                puts "Pushing '#{s}' to twitter"
                @conn.post(s)
            rescue => e
                puts "#{$!} => #{e}"
            end
        end
    end
end
