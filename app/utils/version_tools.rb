class VersionTools
  include Comparable
  attr_reader :major, :minor, :patch

  def initialize(number)
    @major, @minor, @patch = number.split('.').map(&:to_i)
  end

  def to_a
    [major, minor, patch].compact
  end

  def <=>(version)
    (major.to_i <=> version.major.to_i).nonzero? ||
    (minor.to_i <=> version.minor.to_i).nonzero? ||
    patch.to_i <=> version.patch.to_i
  end

  def matches?(operator, number)
    version = VersionTools.new(number)
    self == version

    return self == version if operator == '='
    return self > version  if operator == '>'
    return self >= version  if operator == '>='
    return self < version  if operator == '<'
    return self <= version  if operator == '<='
    return version <= self && version.next > self if operator  == '~>'
  end

  def next
    next_splits = to_a

    if next_splits.length == 1
      next_splits[0] += 1
    else
      next_splits[-2] += 1
      next_splits[-1] = 0
    end

    VersionTools.new(next_splits.join('.'))
  end
end