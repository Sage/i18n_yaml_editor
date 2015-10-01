# encoding: utf-8

require "cuba"
require "cuba/render"
require 'bigdecimal'

require "i18n_yaml_editor/app"

module I18nYamlEditor
  class Web < Cuba
    plugin Cuba::Render

    settings[:render][:template_engine] = "erb"
    settings[:render][:views] = File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "views"))

    use Rack::ShowExceptions

    def app
      I18nYamlEditor.app
    end

    def convert_to_right_fromat(old_text, new_text)
      if old_text == !!old_text # It's a boolean
        new_text.downcase == "true"
      elsif old_text.is_a?(Numeric) # It's a number
        num = BigDecimal.new(new_text)
        num.frac == 0 ? num.to_i : num.to_f
      else # It's a text
        new_text
      end
    end

    define do
      on get, root do
        on param("filters") do |filters|
          options = {}
          options[:key] = /#{filters["key"]}/ if filters["key"].to_s.size > 0
          options[:text] = /#{filters["text"]}/i if filters["text"].to_s.size > 0
          options[:complete] = false if filters["incomplete"] == "on"
          options[:empty] = true if filters["empty"] == "on"

          keys = app.store.filter_keys(options)

          res.write view("translations.html", keys: keys, filters: filters)
        end

        on default do
          categories = app.store.categories.sort
          res.write view("categories.html", categories: categories, filters: {})
        end
      end

      on post, "update" do
        if translations = req["translations"]
          translations.each {|name, text|
            app.store.translations[name].text = convert_to_right_fromat(app.store.translations[name].text, text)
          }
          app.save_translations
        end

        res.redirect "/?#{Rack::Utils.build_nested_query(filters: req["filters"])}"
      end

      on get, "debug" do
        res.write partial("debug.html", translations: app.store.translations.values)
      end
    end
  end
end
