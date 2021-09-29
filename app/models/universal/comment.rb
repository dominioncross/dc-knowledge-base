module Universal
  class Comment
    include Universal::Models::Comment
    
    def to_json
      {
        id: self.id.to_s,
        kind: self.kind.to_s,
        author: (self.user.nil? ? self.author : self.user.name),
        content: self.content.html_safe,
        html_body: self.html_body.html_safe,
        when: self.when,
        created_at: self.created_at.strftime('%b %d, %Y, %l:%M%P'),
        when_formatted: self.when.strftime('%b %d, %Y, %l:%M%P'),
        system_generated: self.system_generated,
        incoming: self.incoming,
        scope_type: self.scope_type,
        scope_id: self.scope_id.to_s,
        subject_type: self.subject_type,
        subject_id: self.subject_id.to_s,
        subject_name: self.subject_name,
        subject_kind: self.subject_kind,
        related_content: self.related_content
      }
    end
    
    def related_content
      c = []
      youtube_matches = self.content.scan(/\bhttp[s]?\:\/\/www.youtube.com\/watch\?v\=([\w\-]*)\b/)
      if youtube_matches.any?
        youtube_matches.each do |m|
          con = {type: 'youtube', content: m[0]}
          c.push(con) if !c.include?(con)
        end
      end
      return c
    end
        
  end
end