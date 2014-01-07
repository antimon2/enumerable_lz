require File.expand_path('..', __FILE__)

module Enumerable
  # @!group Expanded Method Summary

  # lazy equivalent of `Enumerable#select`
  # @yield [el]
  # @note available only requiring "enumerable_lz/enumerable_ex"
  # @return [Enumerator::Filter]
  def select_lz &block
    filter &block
  end
  alias :find_all_lz :select_lz

  # lazy equivalent of `Enumerable#reject`
  # @yield [el]
  # @note available only requiring "enumerable_lz/enumerable_ex"
  # @return [Enumerator::Filter]
  def reject_lz &block
    filter {|e|!block.call(e)}
  end

  # lazy equivalent of `Enumerable#grep`
  # @yield [el]
  # @note available only requiring "enumerable_lz/enumerable_ex"
  # @overload grep_lz(pattern)
  #   @return [Enumerator::Filter]
  # @overload grep_lz(pattern, &block)
  #   @yield [el]
  #   @return [Enumerator::Transform]
  # @return [Enumerator::Filter, Enumerator::Transform]
  def grep_lz pattern, &block
    enum = filter pattern
    block_given? ? enum.transform(&block) : enum
  end

  # @!method map_lz(&block)
  #   lazy equivalent of `Enumerable#map`
  #   @yield [el]
  #   @note available only requiring "enumerable_lz/enumerable_ex"
  #   @return [Enumerator::Transform]
  self.__send__(:alias_method, :map_lz, :transform)
  alias :collect_lz :map_lz

  # lazy equivalent of `Enumerable#drop`
  # @note available only requiring "enumerable_lz/enumerable_ex"
  # @return [Enumerator::Filter]
  def drop_lz n
    raise ArgumentError, "attempt to take negative size" if n < 0
    # each_with_index.filter{|el,idx|idx >= n}.transform{|el,idx|el}
    # cnt = 0
    # filter_with_initproc(Proc.new{cnt=0}) {|el| (cnt+=1) > n}
    filter.with_index {|el, i| i >= n}
  end

  # lazy equivalent of `Enumerable#drop_while`
  # @yield [el]
  # @note available only requiring "enumerable_lz/enumerable_ex"
  # @return [Enumerator::Filter]
  def drop_while_lz &block
    return self if !block_given?
    flg = false
    # filter_with_initproc(Proc.new{flg=false}) {|el|flg || (!block.call(el) ? flg = true : false)}
    filter.with_initializer(Proc.new{flg=false}) {|el|flg || (!block.call(el) ? flg = true : false)}
  end

  # lazy equivalent of `Enumerable#take`
  # @note available only requiring "enumerable_lz/enumerable_ex"
  # @return [Enumerator::Filter]
  def take_lz n
    raise ArgumentError, "attempt to take negative size" if n < 0
    # each_with_index.filter{|el,idx|throw :do_break if idx >= n;true}.transform{|el,idx|el}
    # cnt = 0
    # filter_with_initproc(Proc.new{cnt=0}) {|el| throw :do_break if (cnt+=1) > n;true}
    filter.with_index {|el, i| throw :do_break if i >= n; true}
  end

  # lazy equivalent of `Enumerable#take_while`
  # @yield [el]
  # @note available only requiring "enumerable_lz/enumerable_ex"
  # @return [Enumerator::Filter]
  def take_while_lz &block
    return self if !block_given?
    filter {|el|throw :do_break unless block.call(el); true}
  end

  # @!endgroup

#  def zip_lz *lists
#    enums = lists.map{|list|list.each rescue [].each}
#    Enumerator.new do |y|
#      self.each do |el|
#        y << enums.each_with_object([el]){|enum, a|a << (enum.next rescue nil)}
#      end
#    end
#  end
end