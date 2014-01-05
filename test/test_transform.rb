require 'test/unit'
require 'enumerable_lz'

class TransformTest < Test::Unit::TestCase
  def test_instance
    transform_class = RUBY_VERSION < "1.9.0" ? Enumerable::Enumerator::Transform : Enumerator::Transform
    enum = transform_class.new []
    assert_not_nil(enum)
    assert_kind_of(Enumerable, enum)
  end

  def test_transform_array
    transform_class = RUBY_VERSION < "1.9.0" ? Enumerable::Enumerator::Transform : Enumerator::Transform
    array = %w[Yes I have a number]
    enum = array.transform{|letters|letters.swapcase}
    assert_instance_of(transform_class, enum)
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

  def test_transform_with_index
    range = -10..10
    a = 0
    result = range.transform.with_index{|n,i|n+a=i}.take(10)
    assert_equal(9, a)
  end

  def test_transform_with_index2
    range = -10..10
    a = 0
    result = range.transform.with_index{|n,i|n+a=i}.take(10)
    assert_equal([-10, -8, -6, -4, -2, 0, 2, 4, 6, 8], result)
  end

  def test_transform_with_index_no_block
    range = -10..10
    result = range.transform.with_index(2).filter{|n,i|n+i<10}.to_a
    assert_equal([[-10, 2], [-9, 3], [-8, 4], [-7, 5], [-6, 6], [-5, 7], [-4, 8], [-3, 9], [-2, 10]], result)
  end
end