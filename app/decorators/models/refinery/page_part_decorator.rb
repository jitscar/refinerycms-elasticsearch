begin
  Refinery::PagePart.class_eval do
    after_commit :update_page

    def update_page
      page.index_document
    end

  end
rescue NameError
end
