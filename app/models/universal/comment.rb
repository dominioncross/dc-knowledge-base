    require 'action_view'
module Universal
  class Comment
    include Universal::Models::Comment
    include ActionView::Helpers::SanitizeHelper

    def to_json(*_args)
      {
        id: id.to_s,
        kind: kind.to_s,
        author: (user.nil? ? author : user.name),
        content: content.html_safe.presence || strip_tags(html_body).html_safe,
        html_body: html_body.html_safe,
        when: self.when,
        created_at: created_at.strftime('%b %d, %Y, %l:%M%P'),
        when_formatted: self.when.strftime('%b %d, %Y, %l:%M%P'),
        system_generated: system_generated,
        incoming: incoming,
        scope_type: scope_type,
        scope_id: scope_id.to_s,
        subject_type: subject_type,
        subject_id: subject_id.to_s,
        subject_name: subject_name,
        subject_kind: subject_kind,
        related_content: related_content
      }
    end

    def related_content
      c = []
      youtube_matches = content&.scan(%r{\bhttps?://www.youtube.com/watch\?v=([\w-]*)\b})
      if youtube_matches&.any?
        youtube_matches.each do |m|
          con = { type: 'youtube', content: m[0] }
          c.push(con) unless c.include?(con)
        end
      end
      c
    end
  end
end
