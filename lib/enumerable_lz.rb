if RUBY_VERSION > "1.8.7"
  if RUBY_DESCRIPTION !~ /^macruby/i
    require File.dirname(__FILE__)+'/enumerable_lz/filter'
    require File.dirname(__FILE__)+'/enumerable_lz/transform'
  else
    require File.dirname(__FILE__)+'/enumerable_lz/filter_mrb'
    require File.dirname(__FILE__)+'/enumerable_lz/transform_mrb'
  end
else
  require File.dirname(__FILE__)+'/enumerable_lz/filter_18'
  require File.dirname(__FILE__)+'/enumerable_lz/transform_18'
end

# add {#filter} and {#transform} methods.
module Enumerable
  # @!group Fundamental Method Summary

  # Filter by pattern or block
  # @yield [el] 
  # @overload filter(&block)
  #   filter by block
  #   @yield [el] filterring block.
  #   @yieldparam el each element of original Enumerable
  #   @yieldreturn [Boolean]
  #   @return [Enumerator::Filter]
  # @overload filter(pattern)
  #   filter by pattern
  #   @param [#===] pattern filterring pattern. (uses === method)
  #   @return [Enumerator::Filter]
  # @return [Enumerator::Filter]
  def filter pattern = nil, &block
    Enumerator::Filter.new self, pattern||block
  end

  # @yield [el] 
  # @deprecated Use filter.with_initializer instead of this method
  # @see Enumerator::Filter#with_initializer
  # @return [Enumerator::Filter]
  def filter_with_initproc init_proc, pattern = nil, &block
    filter.with_initializer init_proc, pattern = nil, &block
  end

  # Transform by block
  # @yield [el] transform block.
  # @yieldparam el each element of original Enumerable
  # @yieldreturn [Object]
  # @return [Enumerator::Transform]
  def transform &block
    Enumerator::Transform.new self, &block
  end

  # @!endgroup

  # @private
  module EnumerableLz
    VERSION = "0.1.5"
  end
end