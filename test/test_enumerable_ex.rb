require 'test/unit'
require 'enumerable_lz'
require 'enumerable_lz/enumerable_ex'

class EnumerableExTest < Test::Unit::TestCase
  def test_basic
    cnt=0
    (1..1000000).map_lz{|n|(cnt=n)**2}.take_while{|n|n<10000}
    assert(cnt<1000000)
#    cnt=0
#    (0..1000000).map{|n|(cnt=n)**2}.take_while{|n|n<10000}
#    assert_equal(1000001, cnt)
  end

  def setup
    @arr_str = %w[Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum]
  end

  def test_select_lz
    enum = @arr_str.select_lz{|letters|letters.size==5}
    assert_kind_of(Enumerable, enum)
    assert_equal(@arr_str.select{|letters|letters.size==5}, enum.to_a)
  end

  def test_find_all_lz
    enum = @arr_str.find_all_lz{|letters|letters.size==4}
    assert_kind_of(Enumerable, enum)
    assert_equal(@arr_str.find_all{|letters|letters.size==4}, enum.to_a)
  end

  def test_reject_lz
    enum = @arr_str.reject_lz{|letters|letters.size>5}
    assert_kind_of(Enumerable, enum)
    assert_equal(@arr_str.reject{|letters|letters.size>5}, enum.to_a)
  end

  def test_grep_lz
    enum = @arr_str.grep_lz(/^[A-Z]/)
    assert_kind_of(Enumerable, enum)
    assert_equal(@arr_str.grep(/^[A-Z]/), enum.to_a)
  end

  def test_grep_lz_block
    enum = @arr_str.grep_lz(/^[A-Z]/){|c|c.swapcase}
    assert_kind_of(Enumerable, enum)
    assert_equal(@arr_str.grep(/^[A-Z]/){|c|c.swapcase}, enum.to_a)
  end

  def test_map_lz
    enum = @arr_str.map_lz{|c|c.swapcase}
    assert_kind_of(Enumerable, enum)
    assert_equal(@arr_str.map{|c|c.swapcase}, enum.to_a)
  end

  def test_collect_lz
    enum = @arr_str.collect_lz{|c|c.downcase}
    assert_kind_of(Enumerable, enum)
    assert_equal(@arr_str.collect{|c|c.downcase}, enum.to_a)
  end

  def test_drop_lz
    enum = @arr_str.drop_lz(10)
    assert_kind_of(Enumerable, enum)
    assert_equal(@arr_str.drop(10), enum.to_a)
  end

  def test_drop_while_lz
    enum = @arr_str.drop_while_lz{|letters|letters.size < 6}
    assert_kind_of(Enumerable, enum)
    assert_equal(@arr_str.drop_while{|letters|letters.size < 6}, enum.to_a)
  end

  def test_take_lz
    enum = @arr_str.take_lz(10)
    assert_kind_of(Enumerable, enum)
    assert_equal(@arr_str.take(10), enum.to_a)
  end

  def test_take_while_lz
    enum = @arr_str.take_while_lz{|letters|letters.size < 6}
    assert_kind_of(Enumerable, enum)
    assert_equal(@arr_str.take_while{|letters|letters.size < 6}, enum.to_a)
  end
end