module Zenodo::LandingPageHelper
  def link_to_search_prev_page(query, search_result, html_options = {})
    return if search_result.first_page?
    html_options['aria-label'] = I18n.t('acts_as_page.link_prev_page_a11y_label')
    html_options[:title] = I18n.t('acts_as_page.link_prev_page_title')
    link_to('<', view_zenodo_landing_path(query: query, page: search_result.prev_page), html_options)
  end

  def link_to_search_next_page(query, search_result, html_options = {})
    return if search_result.last_page?
    html_options['aria-label'] = I18n.t('acts_as_page.link_next_page_a11y_label')
    html_options[:title] = I18n.t('acts_as_page.link_next_page_title')
    link_to('>', view_zenodo_landing_path(query: query, page: search_result.next_page), html_options)
  end
end

