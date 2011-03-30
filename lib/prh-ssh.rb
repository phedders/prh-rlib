# This is a small library of "essential" routines

%w(
  net/ssh
  hashie
).each {|r| require r}

#This are some simple extensions to Net::SSH 
class Net::SSH::Connection::Session
  # execplus! is very much like exec! but it returns a hash containing:
  # :out == standard output (if there is any)
  # :err == standard error (if there is any)
  # :exit == the exist status of the command
  # :sig == the signal the caused the command to stop (if any)
  def execplus!(cmd,supass=nil)
    @supass=supass
    cmd="su root -c \"#{cmd}\"" if @supass
    @r=Hashie::Mash.new
    c=self.open_channel do |ch|
    ch.request_pty do |ch, success| raise "Could not obtain pty (i.e. an interactive ssh session)" if !success; end
      ch.exec(cmd) do |ch,st|
        @r[:start] = st
        @r[:out] = []
        @r[:all] = []
        @r[:err] = []
        raise "FAILED: couldn't execute command" unless st
        ch.on_data do |ch,data|
          if data.match(/^Password:/)
            ch.send_data(@supass.to_s+"\n")
          else
            @r[:out] << data
            @r[:all] << data
            yield(ch,data) if block_given?
          end
        end
        ch.on_extended_data {|ch,type,data| if type == 1; @r[:err] << data; @r[:all] << data; end}
        ch.on_request("exit-status") {|ch,data| @r[:status] = data.read_long }
        ch.on_request("exit-signal") {|ch,data| @r[:signal] = data.read_long }
      end
    end
    c.wait
    return @r
  end
end
