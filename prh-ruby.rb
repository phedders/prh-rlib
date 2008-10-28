# This is a small library of "essential" routines

%w(
  rubygems
  net/ssh
  pp
  git
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
        @r[:start] = st
        @r[:out] = []
        @r[:all] = []
        @r[:err] = []
        raise "FAILED: couldn't execute command" unless st
        ch.on_data {|ch,data| @r[:out] << data; @r[:all] << data}
        ch.on_extended_data {|ch,type,data| if type == 1; @r[:err] << data; @r[:all] << data; end}
        ch.on_request("exit-status") {|ch,data| @r[:status] = data.read_long }
        ch.on_request("exit-signal") {|ch,data| @r[:signal] = data.read_long }
      end
    end
    c.wait
    return @r
  end
end

# This stolen from: http://www.rubyquiz.com/quiz38.html
class SerializableProc
  def self._load( proc_string )
    new(proc_string)
  end

  def initialize( proc_string )
    @code = proc_string
    @proc = nil
  end

  def _dump( depth )
    @code
  end

  def method_missing( method, *args )
    if to_lambda.respond_to? method
      @proc.send(method, *args)
    else
      super
    end
  end

  def to_proc( )
    return @proc unless @proc.nil?

    if @code =~ /\A\s*(?:lambda|proc)(?:\s*\{|\s+do).*(?:\}|end)\s*\Z/
    @proc = eval @code
    elsif @code =~ /\A\s*(?:\{|do).*(?:\}|end)\s*\Z/
    @proc = eval "Proc.new #{@code}"
    else
      @proc = eval "Proc.new { #{@code} }"
    end
  end

  def to_lambda( )
    return @proc unless @proc.nil?

    if @code =~ /\A\s*(?:lambda|proc)(?:\s*\{|\s+do).*(?:\}|end)\s*\Z/
    @proc = eval @code
    elsif @code =~ /\A\s*(?:\{|do).*(?:\}|end)\s*\Z/
    @proc = eval "lambda #{@code}"
    else
      @proc = eval "lambda { #{@code} }"
    end
  end

  def to_yaml( )
    @proc = nil
    super
  end
end

def debug(level,*objects)
  return if level > $debug
  objects.each do |o|
    if o.class == String
      puts o
    else
      pp o
    end
  end
  return nil
end

class Git::Base
  def get_branch(branch,*opts)
    debug 6, "get_branch #{branch} opts=#{opts}"
    local=self.branches.local.map{|l| l.full}.grep(Regexp.new("^#{branch}$"))
    remote=self.branches.remote.map{|l| l.full}.grep(Regexp.new("^origin/#{branch}$"))
    if local.any? and remote.any?
      debug 7, "just checkout and update"
      self.config("remote.#{branch}.remote", "origin")
      self.config("remote.#{branch}.merge", "refs/heads/#{branch}")
      self.checkout(branch)
      self.pull
    elsif local.any?
      debug 7, "get local and push"
      self.push("origin",branch)
    elsif remote.any?
      debug 7, "get remote"
      self.config("remote.#{branch}.remote", "origin")
      self.config("remote.#{branch}.merge", "refs/heads/#{branch}")
      self.checkout("origin/#{branch}", :new_branch => branch)
      self.pull("origin")
    else
      debug 7, "new branch"
      self.checkout("zero",:new_branch => branch)
      self.config("remote.#{branch}.remote", "origin")
      self.config("remote.#{branch}.merge", "refs/heads/#{branch}")
      self.push("origin")
    end
  end
end

