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
  end
end
