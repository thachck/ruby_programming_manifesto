module GoogleMatchers
  extend self

  def match(html)
    matches(html) || 0
  end
  alias_method :call, :match

protected

  def matchers
    private_methods.map(&:to_s).select {|m| m =~ /match_/}
  end

  def matches(html)
    results = matchers.map {|matcher| send(matcher, html) }
    results.compact.any? ? results[0] : nil
  end
end
