# for Ruby1.8.7
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
      filter! the_filter if the_filter
      @org_enum = obj
      @init_block = init_block unless init_block.nil?
    end

    def each &block
      return self unless block_given?
      @init_block.call unless @init_block.nil?
      the_enum = (@filter||[]).inject(@org_enum) do |r,f|
        CompliedFilter.new r, f
      end
      catch :do_break do
        the_enum.each{|el| block.call(el)}
      end
      self
    end

    def filter! pattern=nil, &block
      @filter||=[]
      if pattern.is_a? Array
        pattern.each{|el| @filter << conv_proc(el)}
      else
        @filter << conv_proc(pattern || block)
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
    def conv_proc pattern
      case pattern
      when nil
        Proc.new{true}
      when Proc
        pattern
      else
        pattern.respond_to?(:to_proc) ? pattern.to_proc : Proc.new{|el|pattern===el}
      end
    end

    class CompliedFilter
      def initialize org_enum, filter
        @org_enum = org_enum
        @filter = filter
      end

      def each &block
        @org_enum.each do |el|
          block.call(el) if @filter.call(el)
        end
      end
    end
  end
end
