if defined?(Refinery::Terms::Term)
  begin
    Refinery::Terms::Term.class_eval do
      include ::Refinery::Elasticsearch::Searchable

      define_mapping do
        {
            title: { type:'string', boost:1.5 },
            body: { type:'string', analyzer: (I18n.locale.eql?(:ru) ? 'russian_morphology' : 'snowball') },
            created_at: { type:'date' },
            updated_at: { type:'date' }
        }
      end

      def to_index
        {
            title:self.title,
            body:self.body,
            created_at:self.created_at,
            updated_at:self.updated_at
        }
      end

    end
  rescue NameError
  end
end
