# This is a small library of "essential" routines

%w(
  net/ssh
  pp
).each {|r| require r}


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

# Pinched from Ruby Extensions Enumerable
def mapf(message)
  self.map { |elt| elt.send(message) }
end

# I'm lazy...
class Object
  def umethods
    self.methods.sort - self.class.superclass.methods
  end
end

