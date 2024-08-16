# frozen_string_literal: true

module Arclight
  # Override Blacklight's SearchBarComponent to add a dropdown for choosing
  # the context of the search (within "this collection" or "all collections").
  # If a collection has not been chosen, it displays a dropdown with only "all collections"
  # as the only selectable option.

  
class SearchBarComponent < Blacklight::SearchBarComponent
    def initialize(**kwargs)
      super

      @kwargs = kwargs
    end

    def within_collection_options
      all_collections_option = [t('arclight.within_collection_dropdown.all_collections'), '']
      this_collection_option = [collection_name&.truncate(45), collection_name || 'none-selected'].compact
      #this_collection_option = [t('arclight.within_collection_dropdown.this_collection'), collection_name || 'none-selected']
      #this_repository_option = [t('arclight.within_collection_dropdown.this_repository'), repository_name].compact
      this_repository_option = [repository_name, repository_name].compact	
      options = [all_collections_option]
      options << this_collection_option if collection_name.present?
      #did the codion like this to keep repo option off the EAD page, since the search was not working right
      options << this_repository_option if repository_name.present? && collection_name.blank?
      options_for_select(
        options,
        selected: selected_option(options),
        disabled: 'none-selected'
      )
    end

    def collection_name
      @collection_name ||= Array(@params.dig(:f, :collection)).reject(&:empty?).first ||
                           helpers.current_context_document&.collection_name
    end

def repository_name
  if controller.controller_name == "repositories" && controller.action_name == "show"
    @repository_name ||= Repository.find_by!(slug: params[:id]).name
  else
    # This was used when viewing the EAD page to get the Repo Name for the drop down
    solr_url = URI("http://localhost:8983/solr/blacklight-core/select?q=id:#{params[:id]}")
    response = Net::HTTP.get(solr_url)
    solr_data = JSON.parse(response)

    if solr_data['response'].present? && solr_data['response']['docs'].present? && solr_data['response']['docs'].first.present?
      @repository_name = solr_data['response']['docs'].first['repository_ssm']
      
      if @repository_name.is_a?(Array)
        # Extract the first element from the array (if it exists)
        @repository_name = @repository_name.first
      end

      # Remove the starting and trailing square brackets if present
      @repository_name = @repository_name[0..-1] if @repository_name.is_a?(String)
    else
      Rails.logger.error "Solr response does not contain the expected data: #{solr_data.inspect}"
      @repository_name = nil
    end
  end
end

    def selected_option(options)
      options.detect { |option| option.last.present? }&.last || ''
    end
  end
end
