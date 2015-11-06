# Used for comparing stream events
class ActivityStream::Key < Struct.new(:actor, :verb, :object, :target)
  def initialize(actor, verb, object, target)
    super(actor, verb.to_sym, object, target || NilClass)
  end

  def verb=(verb)
    super(verb.to_sym)
  end

  def hash
    target_class = target.respond_to?(:base_class) ? target.base_class :
                                                     target

    [actor.base_class, verb, object.base_class, target_class].hash
  end

  def eql?(other)
    if other.is_a?(ActivityStream::Key)
      hash == other.hash
    else
      super
    end
  end
end
