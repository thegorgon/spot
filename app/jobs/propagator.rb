module Jobs
  class Propagator
    @queue = :processing
  
    def self.perform(class_name, id)
      record = class_name.constantize.find(id)
      record.propagate!
    end
  end
end