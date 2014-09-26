begin
  Refinery::Page.class_eval do
    include ::Refinery::Elasticsearch::Searchable

    @@mapping = {
        title: { type:'string', boost:2.0 },
        browser_title: { type:'string' },
        menu_title: { type:'string' },
        meta_description: { type:'string' },
        part: {
            type:'object',
            properties: {
                body: { type:'string', analyzer: (I18n.locale.eql?(:ru) ? 'russian_morphology' : 'snowball') }
            }
        },
        created_at: { type:'date' },
        updated_at: { type:'date' }
    }

    define_mapping do
      @@mapping
    end

    def to_index
      if in_menu?
        {
          title:self.title,
          part:self.parts.map{|part| { body:strip_tags(part.body)} },
          browser_title:self.browser_title,
          menu_title:self.menu_title,
          meta_description:self.meta_description,
          created_at:self.created_at,
          updated_at:self.updated_at
        }
      end
    end

    def self.indexable
      live.in_menu
    end

  end
rescue NameError
end
