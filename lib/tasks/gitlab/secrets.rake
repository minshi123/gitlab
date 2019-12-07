namespace :gitlab do
  namespace :secrets do
    desc "GitLab | Check if the database encrypted values can be decrypted using current secrets"
    task check: :gitlab_environment do
      Rails.application.eager_load!

      attributes_to_check = Hash.new

      models_with_encrypted_attributes.each do |model|
        attributes_to_check[model] = [] if attributes_to_check[model].nil?
        attributes_to_check[model] += model.encrypted_attributes.keys
      end

      models_with_encrypted_tokens.each do |model|
        attributes_to_check[model] = [] if attributes_to_check[model].nil?
        attributes_to_check[model] += model.token_authenticatable_fields
      end

      attributes_to_check.each do |model, attributes|
        results = check_model_attributes(model, attributes)

        output_results(model, results)
      end
    end

    def models_with_encrypted_attributes
      ApplicationRecord.descendants.select {|d| !d.encrypted_attributes.empty? }
    end

    def models_with_encrypted_tokens
      ApplicationRecord.descendants.select {|d| d.include?(TokenAuthenticatable) }
    end

    def check_model_attributes(model, attributes)
      total_columns = model.count * attributes.count
      bad_columns = 0

      model.find_each do |data|
        attributes.each do |attr|
          bad_columns += 1 unless valid_attribute?(data, attr)
        end
      end

      { total_columns: total_columns, bad_columns: bad_columns }
    end

    def valid_attribute?(data, attr)
      data.public_send(attr)

      true
    rescue OpenSSL::Cipher::CipherError
      false
    end

    def output_results(model, results)
      puts "#{model}: #{results[:bad_columns]} columns bad out of #{results[:total_columns]} total"
    end
  end
end
