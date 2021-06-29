class TODO < Exception
  def initialize(msg)
    if msg
      @message = "This feature (#{msg}) is not implemented yet. Feel free to do so :^)"
    else
      @message = "This feature is not implemented yet. Feel free to do so :^)"
    end
  end
end
