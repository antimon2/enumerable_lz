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
        the_enum = (@filter||[]).inject(@org_enum) do |r,f|
          Enumerator.new do |iy|
            r.each do |el|
              iy.yield el if f.call(el)
            end
          end
        end
        catch :do_break do
          the_enum.each {|el| y.yield el}
        end
      end
      filter! the_filter if the_filter
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
        patterns<<(pattern || block)
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