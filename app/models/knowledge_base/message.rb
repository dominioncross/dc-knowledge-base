# frozen_string_literal: true

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
    include Universal::Concerns::Polymorphic # A model that this message is related to
    include Universal::Concerns::HasAttachments

    store_in collection: 'kb_messages'

    field :a, as: :author
    field :m, as: :message
    field :sn, as: :subject_name
    field :cn, as: :channel
    field :p, as: :pinned, type: Boolean, default: false

    statuses %w[pending active closed deleted], default: :active

    validates :scope, :channel, :message, presence: true

    scope :for_channel, ->(channel) { where(channel: channel) }
    scope :pinned, -> { where(pinned: true) }
    default_scope -> { order_by(pinned: :desc, created_at: :desc) }

    before_save :update_relations

    if Universal::Configuration.class_name_user.present?
      belongs_to :user, class_name: Universal::Configuration.class_name_user
    end

    def name
      message
    end

    def kind
      nil
    end

    def pin!
      update(pinned: !pinned)
    end

    def to_json(*_args)
      {
        id: id.to_s,
        author: author,
        message: message,
        status: status,
        tags: tags,
        flags: flags,
        channel: channel,
        subject_name: subject_name,
        user_id: user_id.to_s,
        pinned: pinned,
        created: created_at&.strftime('%b %d, %Y - %-I:%M%p'),
        comment_count: comments.count,
        related_content: related_content,
        attachments: attachments.map do |a|
          { name: a.name, url: a.file.url, filename: a.file_filename, image: a.image? }
        end
      }
    end

    def related_content
      c = []
      youtube_matches = message.scan(%r{\bhttp[s]?://www.youtube.com/watch\?v=([\w\-]*)\b})
      if youtube_matches.any?
        youtube_matches.each do |m|
          con = { type: 'youtube', content: m[0] }
          c.push(con) unless c.include?(con)
        end
      end
      c
    end

    private

    def update_relations
      if author.blank? && Universal::Configuration.class_name_user.present? && user_id.present? && !user.nil?
        self.author = user.name
      end
      return unless subject_id.present? && !subject.nil?

      self.subject_name = subject.log_subject_name
    end
  end
end
