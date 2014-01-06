require File.expand_path('..', __FILE__)

module Enumerable
  def select_lz &block
    filter &block
  end

  alias :find_all_lz :select_lz

  def reject_lz &block
    filter {|e|!block.call(e)}
  end

  def grep_lz pattern, &block
    enum = filter pattern
    block_given? ? enum.transform(&block) : enum
  end

  alias :map_lz :transform
  alias :collect_lz :map_lz

  def drop_lz n
    raise ArgumentError, "attempt to take negative size" if n < 0
    # each_with_index.filter{|el,idx|idx >= n}.transform{|el,idx|el}
    # cnt = 0
    # filter_with_initproc(Proc.new{cnt=0}) {|el| (cnt+=1) > n}
    filter.with_index {|el, i| i >= n}
  end

  def drop_while_lz &block
    return self if !block_given?
    flg = false
    # filter_with_initproc(Proc.new{flg=false}) {|el|flg || (!block.call(el) ? flg = true : false)}
    filter.with_initializer(Proc.new{flg=false}) {|el|flg || (!block.call(el) ? flg = true : false)}
  end

  def take_lz n
    raise ArgumentError, "attempt to take negative size" if n < 0
    # each_with_index.filter{|el,idx|throw :do_break if idx >= n;true}.transform{|el,idx|el}
    # cnt = 0
    # filter_with_initproc(Proc.new{cnt=0}) {|el| throw :do_break if (cnt+=1) > n;true}
    filter.with_index {|el, i| throw :do_break if i >= n; true}
  end

  def take_while_lz &block
    return self if !block_given?
    filter {|el|throw :do_break unless block.call(el); true}
  end

#  def zip_lz *lists
#    enums = lists.map{|list|list.each rescue [].each}
#    Enumerator.new do |y|
#      self.each do |el|
#        y << enums.each_with_object([el]){|enum, a|a << (enum.next rescue nil)}
#      end
#    end
#  end
end