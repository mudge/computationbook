require_relative '../syntax/boolean'

class Boolean
  def to_ruby
    "-> e { #{value.inspect} }"
  end

  def to_javascript
    "function (e) { return #{value.inspect}; }"
  end
end
