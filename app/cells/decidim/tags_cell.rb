# frozen_string_literal: true

module Decidim
  # This cell renders the category of a resource
  # shown with the translated name and links to
  # the resource parent `component` and `participatory space` index.
  # The context `resource` must be present
  # example use inside another `cell`:
  #   <%= cell("decidim/category", model.category, context: {resource: model}) %>
  #
  class TagsCell < Decidim::ViewModel
    include Decidim::SanitizeHelper

    def show
      render if category? || scope?
    end

    def category
      render if category?
    end

    def scope
      render if scope?
    end

    private

    def tags_classes
      (["tags"] + context[:extra_classes].to_a).join(" ")
    end

    def category?
      model.category.present?
    end

    def link_to_category
      accessible_title = t("decidim.tags.filter_results_for_category", resource: decidim_html_escape(category_name))

      link_to category_path, title: accessible_title do
        sr_title = content_tag(
          :span,
          accessible_title,
          class: "show-for-sr overrides-octree"
        )
        display_title = content_tag(
          :span,
          decidim_html_escape(category_name),
          "aria-hidden": true, 
          class: "overrides-octree"
        )

        sr_title + display_title
      end
    end

    def category_name
      decidim_html_escape(model.category.translated_name)
    end

    def category_path
      resource_locator(model).index(filter: { category_id: [model.category.id.to_s] })
    end

    def scope?
      has_visible_scopes?(model)
    end

    def link_to_scope
      accessible_title = t("decidim.tags.filter_results_for_scope", resource: decidim_html_escape(scope_name))

      link_to scope_path, title: accessible_title do
        sr_title = content_tag(
          :span,
          accessible_title,
          class: "show-for-sr overrides-octree"
        )
        display_title = content_tag(
          :span,
          decidim_html_escape(scope_name),
          "aria-hidden": true, 
          class: "overrides-octree"
        )

        sr_title + display_title
      end
    end

    def scope_name
      decidim_html_escape(translated_attribute(model.scope.name))
    end

    def scope_path
      resource_locator(model).index(filter: { scope_id: [model.scope.id] })
    end
  end
end
