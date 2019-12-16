namespace :gitlab do
  namespace :secrets do
    desc "GitLab | Check if the database encrypted values can be decrypted using current secrets"
    task check: :gitlab_environment do
      Rails.application.eager_load!

      attributes_to_check = {}

      models_with_encrypted_attributes.each do |model|
        attributes_to_check[model] ||= []
        attributes_to_check[model] += model.encrypted_attributes.keys
      end

      models_with_encrypted_tokens.each do |model|
        attributes_to_check[model] ||= []
        attributes_to_check[model] += model.encrypted_token_authenticatable_fields
      end

      attributes_to_check.each {|model, attributes| check_model_attributes(model, attributes)}
    end

    desc "GitLab | Attempt to fix undecryptable values in the database"
    task fix: :gitlab_environment do
      Rails.application.eager_load!

      models_with_encrypted_attributes.each {|model| fix_attr_encrypted_for_model(model)}
      models_with_encrypted_tokens.each {|model| fix_token_encrypted_for_model(model)}
    end

    def models_with_encrypted_attributes
      ApplicationRecord.descendants.select {|d| !d.encrypted_attributes.empty? }
    end

    def models_with_encrypted_tokens
      ApplicationRecord.descendants.select do |d|
        d.include?(TokenAuthenticatable) && !d.encrypted_token_authenticatable_fields.empty?
      end
    end

    def check_model_attributes(model, attributes)
      gen_results(model) do |results|
        results[:total] *= attributes.count

        model.find_each do |data|
          attributes.each do |attr|
            results[:bad] += 1 unless valid_attribute?(data, attr)
          end
        end
      end
    end

    def fix_attr_encrypted_for_model(model)
      gen_results(model) do |results|
        results[:total] *= model.encrypted_attributes.count

        model.find_each do |data|
          model.encrypted_attributes.each do |attr, options|
            next if valid_attribute?(data, attr)

            results[:bad] += 1

            fields_to_clear = [options[:attribute].to_s, options[:attribute].to_s + "_iv"]
            fields_to_clear.push(options[:attribute].to_s + "_salt") if options[:mode] == :per_attribute_iv_and_salt
            fields_to_clear.each {|f| data[f] = ""}

            results[:fixed] += 1 if data.save
          end
        end
      end
    end

    def fix_token_encrypted_for_model(model)
      gen_results(model) do |results|
        results[:total] *= model.encrypted_token_authenticatable_fields.count

        model.find_each do |data|
          model.encrypted_token_authenticatable_fields.map {|attr| attr.to_s}.each do |attr|
            attr_encrypted = attr + "_encrypted"
            # Note that we can save some attributes using valid_decrypt vs valid_attribute
            # that are being set retroactively like through background migrations where
            # the current values can still be read
            next if valid_decrypt?(data, attr_encrypted)

            results[:bad] += 1

            data[attr_encrypted] =
              if data[attr].nil?
                nil
              else
                ::Gitlab::CryptoHelper.aes256_gcm_encrypt(data[attr])
              end

            results[:fixed] += 1 if data.save
          end
        end
      end
    end

    def valid_attribute?(data, attr)
      data.public_send(attr)

      true
    rescue OpenSSL::Cipher::CipherError, TypeError
      false
    end

    def valid_decrypt?(data, attr)
      ::Gitlab::CryptoHelper.aes256_gcm_decrypt(data[attr])

      true
    rescue OpenSSL::Cipher::CipherError, TypeError
      false
    end

    def gen_results(model)
      results = { total: model.count, fixed: 0, bad: 0 }

      yield results

      output_results(model, results)
    end

    def output_results(model, results)
      puts "#{model}: #{results[:bad]} bad, #{results[:fixed]} fixed, #{results[:total]} total"
    end
  end
end
