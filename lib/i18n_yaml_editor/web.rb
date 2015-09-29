# encoding: utf-8

require "cuba"
require "cuba/render"

require File.join File.dirname(__FILE__), "app.rb"

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
      else # It's a text
        new_text
      end
    end

    define do
      relative_root = app.relative_root
      on get, root do
        on param("filters") do |filters|
          options = {}
          options[:key] = /#{filters["key"]}/ if filters["key"].to_s.size > 0
          options[:text] = /#{filters["text"]}/i if filters["text"].to_s.size > 0
          options[:complete] = false if filters["incomplete"] == "on"
          options[:empty] = true if filters["empty"] == "on"

          keys = app.store.filter_keys(options)

          res.write view("translations.html", keys: keys, filters: filters, :relative_root => relative_root)
        end

        on default do
          categories = app.store.categories.sort
          res.write view("categories.html", categories: categories, filters: {}, :relative_root => relative_root)
        end
      end

      on post, "update" do
        if translations = req["translations"]
          translations.each {|name, text|
            app.store.translations[name].text = convert_to_right_fromat(app.store.translations[name].text, text)
          }
          app.save_translations
        end

        res.redirect "/#{relative_root}/?#{Rack::Utils.build_nested_query(filters: req["filters"])}"
      end

      on get, "debug" do
        res.write partial("debug.html", translations: app.store.translations.values, :relative_root => relative_root)
      end

      on get, "restart" do
        system File.join File.dirname(__FILE__), "../../bin/restart_mso.sh"
        system File.join File.dirname(__FILE__), "../../bin/restart_so.sh"
        sleep 7

        res.redirect "/#{relative_root}/"
      end
    end
  end
end
