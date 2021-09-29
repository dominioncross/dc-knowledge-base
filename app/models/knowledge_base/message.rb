module KnowledgeBase
  class Message
    include Mongoid::Document
    include Mongoid::Timestamps::Created
    include Mongoid::Search
    include Universal::Concerns::Status
    include Universal::Concerns::Taggable
    include Universal::Concerns::Flaggable
    include Universal::Concerns::Scoped
    include Universal::Concerns::Commentable
    include Universal::Concerns::Polymorphic #A model that this message is related to
    include Universal::Concerns::HasAttachments
    
    store_in session: KnowledgeBase::Configuration.mongoid_session_name, collection: 'kb_messages'

    field :a, as: :author
    field :m, as: :message
    field :sn, as: :subject_name
    field :cn, as: :channel
    field :p, as: :pinned, type: Boolean, default: false
    
    statuses %w(pending active closed deleted), default: :active
    
    validates :scope, :channel, :message, presence: true

    scope :for_channel, ->(channel){where(channel: channel)}
    scope :pinned, ->(){where(pinned: true)}
    default_scope ->(){order_by(pinned: :desc, created_at: :desc)}
    
    before_save :update_relations
    
    if !Universal::Configuration.class_name_user.blank?
      belongs_to :user, class_name: Universal::Configuration.class_name_user, foreign_key: :user_id
    end
    
    def name
      self.message
    end
    
    def kind
      nil
    end
    
    def pin!
      self.update(pinned: !self.pinned)
    end
    
    def to_json
      {
        id: self.id.to_s,
        author: self.author,
        message: self.message,
        status: self.status,
        tags: self.tags,
        flags: self.flags,
        channel: self.channel,
        subject_name: self.subject_name,
        user_id: self.user_id.to_s,
        pinned: self.pinned,
        created: (self.created_at.nil? ? nil : self.created_at.strftime('%b %d, %Y - %-I:%M%p')),
        comment_count: self.comments.count,
        related_content: self.related_content,
        attachments: self.attachments.map{|a| {name: a.name, url: a.file.url, filename: a.file_filename, image: a.image?}}
      }
    end
    
    def related_content
      c = []
      youtube_matches = self.message.scan(/\bhttp[s]?\:\/\/www.youtube.com\/watch\?v\=([\w\-]*)\b/)
      if youtube_matches.any?
        youtube_matches.each do |m|
          con = {type: 'youtube', content: m[0]}
          c.push(con) if !c.include?(con)
        end
      end
      return c
    end
    
    private
      def update_relations
        if self.author.blank? and !Universal::Configuration.class_name_user.blank? and !self.user_id.blank? and !self.user.nil?
          self.author = self.user.name
        end
        if !self.subject_id.blank? and !self.subject.nil?
          self.subject_name = self.subject.log_subject_name
        end
      end
  end
end