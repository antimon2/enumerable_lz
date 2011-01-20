require 'test/unit'
require 'enumerable_lz'

class TransformTest < Test::Unit::TestCase
  def test_instance
    enum = Enumerable::Transform.new []
    assert_not_nil(enum)
    assert_kind_of(Enumerable, enum)
  end

  def test_transform_array
    array = %w[Yes I have a number]
    enum = array.transform{|letters|letters.swapcase}
    assert_instance_of(Enumerable::Transform, enum)
    assert_equal(%w[yES i HAVE A NUMBER], enum.to_a)
  end

  def test_multi_transform_1
    range = -10..10
    pr1 = lambda{|n|n**2}
    pr2 = lambda{|n|10-n}
    enum1 = range.transform(&pr1).transform(&pr2)
    assert_equal(range.map{|n|10-n**2}, enum1.to_a)
  end

  def test_multi_transform_2
    range = -10..10
    pr1 = lambda{|n|n**2}
    pr2 = lambda{|n|10-n}
    enum2 = range.transform(&pr2).transform(&pr1)
    assert_equal(range.map{|n|(10-n)**2}, enum2.to_a)
  end

  def test_multi_transform_3
    range = -10..10
    pr1 = lambda{|n|n**2}
    pr2 = lambda{|n|10-n}
    enum1 = range.transform(&pr1)
    arr1 = enum1.to_a
    enum1.transform(&pr2)
    assert_equal(arr1, enum1.to_a)
  end

  def test_transform_not_same
    enum1 = [].transform
    enum2 = enum1.transform
    assert_not_same(enum1, enum2)
  end

  def test_transform!
    enum1 = [].transform
    enum2 = enum1.transform!
    assert_same(enum1, enum2)
  end
end