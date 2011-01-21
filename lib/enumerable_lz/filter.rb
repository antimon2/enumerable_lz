# for Ruby1.9.x except for MacRuby
module Enumerable
  def filter pattern = nil, &block
    Filter.new self, pattern||block
  end

  def filter_with_initproc init_proc, pattern = nil, &block
    Filter.new self, init_proc, pattern||block
  end

  class Filter < Enumerator
    def initialize obj, *args
      the_filter = args.shift
      init_block, the_filter = [the_filter, args.shift] unless args.empty?
      @org_enum = obj
      @init_block = init_block unless init_block.nil?
      super() do |y|
        @init_block.call unless @init_block.nil?
        catch :do_break do
          @org_enum.each do |*el|
            y.yield *el if matches_filter? *el
          end
        end
      end
      filter! the_filter if the_filter
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
        patterns<<(pattern || block)
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