module DoubleDispatch
  module ClassMethods
    def dispatch_as(id)
      @dispatch_id = id
    end

    def dispatch_id
      @dispatch_id || fail('undefined :dispatch_id for class: ' + self.name)
    end
  end

  def self.included(base)
    base.extend(ClassMethods)
  end

  def double_dispatch(method_name, resolver, *args)
    resolver.send("#{method_name}_#{self.class.dispatch_id}", self, *args)
  end
end
