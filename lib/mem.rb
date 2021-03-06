require "mem/version"

module Mem
  def self.included(base)
    base.extend(ClassMethods)
  end

  def has_memoized?(key)
    memoized_table.key?(key)
  end

  def memoize(key, value)
    memoized_table[key] = value
  end

  def memoized(key)
    memoized_table[key]
  end

  def memoized_table
    @memoized_table ||= {}
  end

  def unmemoize(key)
    memoized_table.delete(key)
  end

  module ClassMethods
    def memoize(method_name)
      define_method("#{method_name}_with_memoize") do |*args, &block|
        if has_memoized?(method_name)
          memoized(method_name)
        else
          memoize(method_name, send("#{method_name}_without_memoize", *args, &block))
        end
      end
      alias_method "#{method_name}_without_memoize", method_name
      alias_method method_name, "#{method_name}_with_memoize"

      define_method("unmemoize_#{method_name}") do
        unmemoize(method_name)
      end

      define_method("#{method_name}=") do |value|
        memoize(method_name, value)
      end
    end
  end
end
