require "twitter"
require "yaml"

module DBUS
    class Status
        @services = []
        def initialize(pidgin, file)

            @services = []
            if s = Status::Twitter.new(file)
                    @services << s
            end
            # if s = Status::Identica.new(pidgin, file)
            #     @services << s
            # end
        end
        
        def status=(s)
            @services.each do |svr|
                svr.status = s
            end
        end
        
        def status
            puts "Retrieving status"
            a = @services[0].status
            puts "Status: #{a}"
            return a
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
            begin
                @atoken = config["twitter"]["atoken"]
                @asecret = config["twitter"]["asecret"]
                @token = config["twitter"]["token"]
                @me = config["twitter"]["me"]
                @secret = config["twitter"]["secret"]
             
                Twitter.configure do |config|
                    config.consumer_key = @token
                    config.consumer_secret = @secret
                    config.oauth_token = @atoken
                    config.oauth_token_secret = @asecret
                end
                
#                 oauth = Twitter::OAuth.new(@token, @secret)
                
#                 if not @atoken or not @asecret 
                    
                    
#                     pp oauth
#                     rtoken  = oauth.request_token.token
#                     rsecret = oauth.request_token.secret
                    
                    
#                     puts "> redirecting you to twitter to authorize..."
#                     %x(firefox #{oauth.request_token.authorize_url})
                    
#                     print "> what was the PIN twitter provided you with? "
#                     pin = gets.chomp
                
                                
#                     oauth.authorize_from_request(rtoken, rsecret, pin)
                
#                     access_token = oauth.access_token
#                     pp access_token
                    
#                     puts <<END
# Now put the following into your twitter section of your accounts.yml

# atoken = #{access_token.token}
# asecret = #{access_token.secret}
# END
#                 else
#                     oauth.authorize_from_access(@atoken, @asecret)
#                 end
                @conn = Twitter::Client.new
            rescue => e
                puts "#{$!} => #{e}"
                return nil
            end
        end
        
        def status
            msg = ""
            begin
                puts "Retrieving twitter status"
                timeline = @conn.user_timeline(@me)
                timeline.each do |entry|
                    if not entry.text =~ /^@/
                        msg = entry.text
                        break
                    end
                end
                puts "Status #{msg}"
            rescue => e
                puts "#{$!} => #{e}"
            end
            return msg
        end

        def status=(s)
            return
            begin
                puts "Pushing '#{s}' to twitter"
                @conn.update(s)
            rescue => e
                puts "#{$!} => #{e}"
            end
        end
    end
end
