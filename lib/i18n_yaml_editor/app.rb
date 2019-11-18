# frozen_string_literal: true

require 'psych'
require 'yaml'
require 'active_support/all'

require 'i18n_yaml_editor/web'
require 'i18n_yaml_editor/store'

module I18nYamlEditor
  # App provides I18n Yaml Editor's top-level functionality:
  #   * Starting I18n Yaml Editor
  #   * Loading Translation files
  #   * Saving Translation files
  class App
    attr_accessor :store

    def initialize(path, port = 5050)
      @path = File.expand_path(path)
      @port = port || 5050
      @store = Store.new
      I18nYamlEditor.app = self
    end

    # Starts I18n Yaml Editor server
    def start
      raise "File #{@path} not found." unless File.exist?(@path)

      $stdout.puts " * Loading translations from #{@path}"
      load_translations

      $stdout.puts ' * Creating missing translations'
      store.create_missing_keys

      $stdout.puts " * Starting I18n Yaml Editor at port #{@port}"
      Rack::Server.start app: Web, Port: @port
    end

    # Loads translations from a given path
    def load_translations
      files = if File.directory?(@path)
                Dir[@path + '/**/*.yml']
              elsif File.file?(@path)
                detect_list_or_file @path
              else
                # rubocop:disable Style/StderrPuts
                $stderr.puts 'No valid translation file given'
                # rubocop:enable Style/StderrPuts
                []
              end
      update_store files
    end

    # Write the given translations to the appropriate YAML file
    # example translations:
    # {"en.day_names"=>"Mon\r\nTue", "en.session.new.password"=>"Password"}
    def save_translations(translations)
      store.update(translations)
      changes = files(translations: translations)
      changes.each do |file, yaml|
        yaml.extend(YamlNormalizer::Ext::SortByKey)
        File.open(file, 'w', encoding: 'utf-8') do |f|
          f.puts yaml.sort_by_key.to_yaml
        end
      end
    end

    private

    # Enables I18n Yaml Editor to deal with inputs that reference a file list or
    # a single translation file
    def detect_list_or_file(path)
      file = YAML.load_file(path)
      file.is_a?(Hash) ? [path] : File.read(path).split
    end

    def update_store(files)
      files.each do |file|
        if File.exist?(file)
          yaml = YAML.load_file(file)
          store.from_yaml(yaml, file)
        end
      end
    end

    def files(translations: {})
      store.to_yaml.select do |_, i18n_hash|
        translations.keys.any? do |i18n_key|
          i18n_hash.dig(*i18n_key.split('.'))
        end
      end
    end
  end
end
