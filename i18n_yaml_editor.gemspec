# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name     = 'i18n_yaml_editor'
  s.version  = '2.1.0'
  s.date     = '2018-05-04'
  s.summary  = 'I18n Yaml Editor'
  s.email    = 'miquel.oliete@sage.com'
  s.homepage = 'http://github.com/Sage/i18n_yaml_editor'
  s.description = 'I18n Yaml Editor'
  s.authors = ['Harry Vangberg', 'Wolfgang Teuber', 'Miquel Oliete']
  s.executables << 'i18n_yaml_editor'
  s.files = %w[
    README.md
    Rakefile
    i18n_yaml_editor.gemspec
    bin/i18n_yaml_editor
    lib/i18n_yaml_editor.rb
    lib/i18n_yaml_editor/app.rb
    lib/i18n_yaml_editor/category.rb
    lib/i18n_yaml_editor/key.rb
    lib/i18n_yaml_editor/store.rb
    lib/i18n_yaml_editor/filter.rb
    lib/i18n_yaml_editor/update.rb
    lib/i18n_yaml_editor/cast.rb
    lib/i18n_yaml_editor/translation.rb
    lib/i18n_yaml_editor/web.rb
    views/categories.html.erb
    views/debug.html.erb
    views/layout.erb
    views/translations.html.erb
  ]
  s.test_files = %w[
    test/test_helper.rb
    test/unit/test_app.rb
    test/unit/test_app_load_translations.rb
    test/unit/test_app_new.rb
    test/unit/test_app_start.rb
    test/unit/test_category.rb
    test/unit/test_key.rb
    test/unit/test_store.rb
    test/unit/test_store_data.rb
    test/unit/test_store_filter.rb
    test/unit/test_translation.rb
    test/unit/test_web.rb
  ]
  s.add_dependency 'activesupport', '>= 4.0.2'
  s.add_dependency 'cuba', '>= 3'
  s.add_dependency 'psych', '>= 1.3.4'
  s.add_dependency 'tilt', '>= 1.3'
  s.add_dependency 'yaml_normalizer', '>= 0'

  s.add_development_dependency 'awesome_print'
  s.add_development_dependency 'cane'
  s.add_development_dependency 'flay'
  s.add_development_dependency 'flog'
  s.add_development_dependency 'github-markup'
  s.add_development_dependency 'guard'
  s.add_development_dependency 'guard-minitest'
  s.add_development_dependency 'guard-rubocop'
  s.add_development_dependency 'inch'
  s.add_development_dependency 'minitest-line'
  s.add_development_dependency 'minitest-reporters'
  s.add_development_dependency 'pry-byebug'
  s.add_development_dependency 'pry-doc'
  s.add_development_dependency 'rack-test'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'redcarpet'
  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'yard'
end
