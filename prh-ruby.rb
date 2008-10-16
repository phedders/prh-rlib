# This is a small library of "essential" routines

%w(
  rubygems
  net/ssh
).each {|r| require r}

#This are some simple extensions to Net::SSH 
class Net::SSH::Connection::Session
  # execplus! is very much like exec! but it returns a hash containing:
  # :out == standard output (if there is any)
  # :err == standard error (if there is any)
  # :exit == the exist status of the command
  # :sig == the signal the caused the command to stop (if any)
  def execplus!(cmd)
    @r={}
    c=self.open_channel do |ch|
      ch.exec(cmd) do |ch,st|
        @r[:st] = st
        raise "FAILED: couldn't execute command" unless st
        ch.on_data {|ch,data| @r[:out]=data}
        ch.on_extended_data {|ch,type,data| @r[:err] = data if type == 1}
        ch.on_request("exit-status") {|ch,data| @r[:exit] = data.read_long }
        ch.on_request("exit-signal") {|ch,data| @r[:sig] = data.read_long }
      end
    end
    c.wait
    return @r
  end
end
