module ModuleExtensions
  def self.included(base)
    base.send(:include, InstanceMethods)
    base.send(:extend, ClassMethods)
  end

  module InstanceMethods
    def uniq_constants!
      values = constants.group_by { |c| const_get(c) }
      dupes = values.values.select { |a| a.length > 1 }
      raise DuplicateConstantError, "Duplicate constants defined #{dupes.flatten.inspect}" if dupes.present?
    end
  end
  
  module ClassMethods
  end
end

Module.send(:include, ModuleExtensions)