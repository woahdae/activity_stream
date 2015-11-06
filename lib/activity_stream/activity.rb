require Rails.root + 'lib/json_serializer'

class ActivityStream::Activity < ActiveRecord::Base
  self.table_name = :activity_stream_activities

  belongs_to :actor,  :polymorphic => true
  belongs_to :object, :polymorphic => true,
    :foreign_key => 'obj_id', :foreign_type => 'obj_type'
  belongs_to :target, :polymorphic => true

  scope :since, lambda { |time|
    where(['created_at > ?', time]) }

  scope :not_by_actor, lambda { |actor|
    where(['actor_type = ? AND actor_id != ?',
           actor.class.base_class.name, actor.id]) }

  scope :having_key, lambda { |actor_class, verb_s, object_class, target_class|
    query = 'actor_type = ? AND verb IN(?) AND obj_type = ?'
    values = [actor_class.name, Array(verb_s), object_class.name]

    if target_class
      query += ' AND target_type = ?'
      values << target_class.name if target_class
    end

    where([query, *values])
  }

  serialize :data, JSONSerializer

  after_initialize {|obj| obj.data ||= {}}

  validate :presence_of => [:actor, :object, :verb]

  def actor_class
    actor_type.constantize
  end

  def object_class
    obj_type.constantize
  end

  def target_class
    target_type.try(:constantize) || NilClass
  end
end
