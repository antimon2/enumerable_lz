# for MacRuby
module Enumerable
  def transform &block
    Transform.new self, &block
  end

  class Transform < Enumerator
    def initialize obj, &transformer
      @org_enum = obj
      outer = self
      super Class.new {
        define_method :each do
          return outer unless block_given?
          the_transformer = outer.__send__(:compile_transformer)
          obj.each do |el|
            yield the_transformer[el]
          end
        end
      }.new
      transform! &transformer if block_given?
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