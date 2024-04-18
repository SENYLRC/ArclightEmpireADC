ArclightHelper.class_eval do
  def search_without_group
    search_state.params_for_search.merge('group' => 'false').except('page')
  end
end
