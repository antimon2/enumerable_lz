# for Ruby1.8.7

module Enumerable
  def filter pattern = nil, &block
    Enumerator::Filter.new self, pattern||block
  end

  # @deprecated Use filter.with_initializer instead of this method
  def filter_with_initproc init_proc, pattern = nil, &block
    filter.with_initializer init_proc, pattern = nil, &block
  end

  class Enumerator
    class Filter < Enumerator
      def initialize obj, the_filter=nil
        filter! the_filter if the_filter
        @org_enum = obj
      end

      def each &block
        return self unless block_given?
        # compiled_filter = (@filter||[Proc.new{true}]).inject do |r,f|
        #   Proc.new{|el| r[el] && f[el]}
        # end
        compiled_filter = @filter.nil? ? Proc.new{true} : lambda{|f|
          break f[0] if f.size==1
          codes = f.size.times.map do |idx|
            "f[#{idx}][el]"
          end
          eval "Proc.new{|el|"+codes.join(" && ")+"}"
        }.call(@filter)
        catch :do_break do
          @org_enum.each do |el|
            block.call(el) if compiled_filter[el]
          end
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
        # clone.filter! pattern, &block
        patterns = @filter.nil? ? [] : @filter.clone
        if pattern.is_a? Array
          patterns.push(*pattern)
        else
          patterns << (pattern || block)
        end
        Filter.new @org_enum, patterns
      end

      def with_initializer init_proc, pattern = nil, &block
        src_enum = @filter.nil? ? @org_enum : self
        FilterWithInitializer.new src_enum, init_proc, pattern||block
      end

      #[override]
      def with_index offset=0, &block
        raise ArgumentError, "tried to call filter.with_index without a block" unless block_given?
        i = offset - 1
        with_initializer(Proc.new{i = offset - 1}) do |el|
          block.call(el, i += 1)
        end
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
    end

    # private
    class FilterWithInitializer < Filter
      def initialize obj, init_block, the_filter = nil
        super obj, the_filter
        @initializer = init_block
      end

      def each &block
        return self unless block_given?
        @initializer.call
        super &block
      end

      #[override]
      def filter pattern=nil, &block
        Filter.new self, pattern||block
      end
    end
  end
end