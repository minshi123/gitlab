# frozen_string_literal: true

module Gitlab
  module I18n
    extend self

    AVAILABLE_LANGUAGES = {
      'bg' => 'Bulgarian - български',
      'zh_CN' => 'Chinese (Simplified) - 简体中文',
      'zh_HK' => 'Chinese (Hong Kong) - 繁體中文 (香港)',
      'zh_TW' => 'Chinese (Traditional) - 繁體中文 (臺灣)',
      'cs_CZ' => 'Czech - čeština',
      'nl_NL' => 'Dutch - Nederlands',
      'en' => 'English',
      'eo' => 'Esperanto - esperanto',
      'fil_PH' => 'Filipino',
      'fr' => 'French - français',
      'gl_ES' => 'Galician - galego',
      'de' => 'German - Deutsch',
      'id_ID' => 'Indonesian - Bahasa Indonesia',
      'it' => 'Italian - italiano',
      'ja' => 'Japanese - 日本語',
      'ko' => 'Korean - 한국어',
      'pl_PL' => 'Polish - polski',
      'pt_BR' => 'Portuguese (Brazil) - português (Brasil)',
      'ru' => 'Russian - Русский',
      'es' => 'Spanish - español',
      'tr_TR' => 'Turkish - Türkçe',
      'uk' => 'Ukrainian - українська'
    }.freeze

    def available_locales
      AVAILABLE_LANGUAGES.keys
    end

    def locale
      FastGettext.locale
    end

    def locale=(locale_string)
      requested_locale = locale_string || ::I18n.default_locale
      new_locale = FastGettext.set_locale(requested_locale)
      ::I18n.locale = new_locale
    end

    def use_default_locale
      FastGettext.set_locale(::I18n.default_locale)
      ::I18n.locale = ::I18n.default_locale
    end

    def with_locale(locale_string)
      original_locale = locale

      self.locale = locale_string
      yield
    ensure
      self.locale = original_locale
    end

    def with_user_locale(user, &block)
      with_locale(user&.preferred_language, &block)
    end

    def with_default_locale(&block)
      with_locale(::I18n.default_locale, &block)
    end
  end
end
