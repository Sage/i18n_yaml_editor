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

    def cast(klass, value)
      return '' if value.blank?

      if klass < Numeric
        num = BigDecimal.new(value)
        num.frac == 0 ? num.to_i : num.to_f
      elsif [TrueClass, FalseClass].include?(klass)
        value.downcase == "true"
      elsif klass == Array
        value.split("\r\n")
      else #String
        value
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
          options[:missing_locale] = filters["missing_locale"]

          keys = app.store.filter_keys(options)
          locales = app.store.locales

          res.write view("translations.html", keys: keys, filters: filters, locales: locales)
        end

        on default do
          categories = app.store.categories.sort
          locales = app.store.locales

          res.write view("categories.html", categories: categories, filters: {}, locales: locales)
        end
      end

      on post, "update" do
        if translations = req["translations"]
          store = app.store.translations.values.group_by{|e| e.key}

          translations.each {|name, text|
            obj = store[app.store.translations[name].key].map(&:text).find { |t| t.present? || t == false }
            data_type = obj.class
            data_type = String if data_type == NilClass
            if data_type == Array
              klasses = obj.map(&:class).uniq!
              if klasses.length < 2
                app.store.translations[name].text = []
                cast(data_type, text).each do |item|
                  app.store.translations[name].text << cast(klasses[0], item)
                end
              end
            else
              app.store.translations[name].text = cast(data_type, text)
            end
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
