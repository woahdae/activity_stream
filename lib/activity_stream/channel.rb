class ActivityStream::Channel
  class << self
    def listen(actor, verb, object, target = nil, &block)
      @listening ||= {}
      @listening[ActivityStream::Key.new(actor, verb, object, target)] = block
    end

    def listening?(key_or_activity)
      !!action_for(key_or_activity)
    end

    def notify(actor, verb, object, target = nil, data = {})
      key = ActivityStream::Key.new(actor.class, verb, object.class, target.class)
      action_for(key).call(actor, object, target, data)
    end

    private

    def action_for(key_or_activity)
      @listening[key_for(key_or_activity)]
    end

    def key_for(key_or_activity)
      return key_or_activity if key_or_activity.is_a?(ActivityStream::Key)

      activity = key_or_activity
      ActivityStream::Key.new(activity.actor_class, activity.verb,
                              activity.object_class, activity.target_class)
    end
  end
end
