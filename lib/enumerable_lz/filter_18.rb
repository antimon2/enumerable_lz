# for Ruby1.8.7
module Enumerable
  def filter pattern = nil, &block
    Filter.new self, pattern||block
  end

  def filter_with_initproc init_proc, pattern = nil, &block
    Filter.new self, init_proc, pattern||block
  end

  class Filter < Enumerator
    require 'generator'
    def initialize obj, *args
      the_filter = args.shift
      init_block, the_filter = [the_filter, args.shift] unless args.empty?
      filter! the_filter if the_filter
      @org_enum = obj
      @init_block = init_block unless init_block.nil?
    end

    def each &block
      return self unless block_given?
      catch :do_break do
        @init_block.call unless @init_block.nil?
        @org_enum.each do |*el|
          block.call(*el) if matches_filter? *el
        end
      end
      self
    end

    def filter! pattern=nil, &block
      @filter||=[]
      if pattern.is_a? Array
        @filter.push(*pattern)
      else
        @filter<<(pattern || block)
      end
      self
    end

    #[override]
    def filter pattern=nil, &block
      return super unless @init_block.nil?
      # clone.filter! pattern, &block
      patterns = @filter.nil? ? [] : @filter.clone
      if pattern.is_a? Array
        patterns.push(*pattern)
      else
        patterns << (pattern || block)
      end
      Filter.new @org_enum, patterns
    end

    private
    def matches_filter? obj, *others
      return true if @filter.nil?
      args = [obj, *others]
      @filter.all? do |filter|
        case filter
        when nil
          true
        when Proc
          filter[*args]
        else
          filter===obj
        end
      end
    end
  end
end
