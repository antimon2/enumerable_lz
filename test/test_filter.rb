require 'test/unit'
require 'enumerable_lz'

class FilterTest < Test::Unit::TestCase
  def test_instance
    enum = Enumerable::Filter.new []
    assert_not_nil(enum)
    assert_kind_of(Enumerable, enum)
  end

  def test_filter_array
    array = %w[Yes I have a number]
    enum = array.filter{|letters|letters.size > 1}
    assert_instance_of(Enumerable::Filter, enum)
    assert_equal(%w[Yes have number], enum.to_a)
  end

  def test_pattern_filtering_1
    range = "a"..."aaa"
    enum = range.filter(/[aeiou]{2}/)
    assert_equal(%w[aa ae ai ao au ea ee ei eo eu ia ie ii io iu oa oe oi oo ou ua ue ui uo uu], enum.to_a)
  end

  def test_pattern_filtering_2_1
    array = [123, "abc", Math::PI, %q[q], nil]
    enum1 = array.filter(String)
    assert_equal(["abc", "q"], enum1.to_a)
  end

  def test_pattern_filtering_2_2
    array = [123, "abc", Math::PI, %q[q], nil]
    enum2 = array.filter(Numeric)
    assert_equal([123, Math::PI], enum2.to_a)
  end

  def test_pattern_filtering_2_3
    array = [123, "abc", Math::PI, %q[q], nil]
    enum3 = array.filter(1..100)
    assert_equal([Math::PI], enum3.to_a)
  end

  def test_multi_filter_1
    range = -10..10
    pr1 = lambda{|n|n>2}
    pr2 = lambda{|n|n**2<10}
    enum1 = range.filter(&pr1).filter(&pr2)
    assert_equal([3], enum1.to_a)
  end

  def test_multi_filter_2
    range = -10..10
    pr1 = lambda{|n|n>2}
    pr2 = lambda{|n|n**2<10}
    enum2 = range.filter(&pr2).filter(&pr1)
    assert_equal([3], enum2.to_a)
  end

  def test_multi_filter_3
    range = -10..10
    pr1 = lambda{|n|n>2}
    pr2 = lambda{|n|n**2<10}
    enum2 = range.filter([pr1, pr2])
    assert_equal([3], enum2.to_a)
  end

  def test_multi_filter_4
    range = -10..10
    pr1 = lambda{|n|n>2}
    pr2 = lambda{|n|n**2<10}
    enum1 = range.filter(&pr1)
    arr1 = enum1.to_a
    enum2 = enum1.filter(&pr2)
    assert_equal(arr1, enum1.to_a)
  end

  def test_filter_not_same
    enum1 = [].filter
    enum2 = enum1.filter
    assert_not_same(enum1, enum2)
  end

  def test_filter!
    enum1 = [].filter
    enum2 = enum1.filter!
    assert_same(enum1, enum2)
  end

  def test_init_block
    range = -10..10
    cnt = 0
    init_pr = Proc.new{cnt = 0}
    filter_pr = Proc.new{(cnt+=1)<=10}
    enum = Enumerable::Filter.new range, init_pr, filter_pr
    assert_equal([-10, -9, -8, -7, -6, -5, -4, -3, -2, -1], enum.to_a)
  end

  def test_filter_with_initproc_1
    range = -10..10
    cnt = 0
    init_pr = Proc.new{cnt = 0}
    filter_pr = Proc.new{(cnt+=1)<=10}
    enum = range.filter_with_initproc init_pr, &filter_pr
    assert_equal([-10, -9, -8, -7, -6, -5, -4, -3, -2, -1], enum.to_a)
    # v-- same result when execute twice or more
    assert_equal([-10, -9, -8, -7, -6, -5, -4, -3, -2, -1], enum.to_a)
  end

  def test_filter_with_initproc_2
    range = 1..20
    sum = 0
    init_pr = Proc.new{sum = 0}
    enum1 = range.filter_with_initproc(init_pr) {|n|(sum+=n)>100}
    enum2 = enum1.filter(&:odd?)
    assert_equal([15, 17, 19], enum2.to_a)
  end

  def test_filter_with_throw_do_break
    range = 1..20
    sum = 0
    init_pr = Proc.new{sum = 0}
    enum = range.filter_with_initproc(init_pr) {|n|throw :do_break if (sum+=n)>100;true}
    assert_equal([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13], enum.to_a)
  end
end