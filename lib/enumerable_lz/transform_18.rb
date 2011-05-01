# for Ruby1.8.7
module Enumerable
  def transform &block
    Transform.new self, &block
  end

  class Transform < Enumerator
    def initialize obj, &transformer
      @org_enum = obj
      transform! &transformer if block_given?
    end

    def each &block
      return self unless block_given?
      the_transformer = compile_transformer
      @org_enum.each do |el|
        block.call the_transformer[el]
      end
      self
    end

    def transform! &block
      @transformer||=[]
      @transformer << block if block_given?
      self
    end

    #[override]
    def transform &block
      # clone.transform! &block
      cp = Transform.new @org_enum
      @transformer.each do |org_block|
        cp.transform! &org_block
      end unless @transformer.nil?
      cp.transform! &block
    end

    private
    def compile_transformer
      return Proc.new{|a|a} if @transformer.nil? || @transformer.size==0
      @transformer.inject do |r,f|
        Proc.new{|el|f[r[el]]}
      end
    end
  end
end