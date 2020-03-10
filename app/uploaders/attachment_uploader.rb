# frozen_string_literal: true

class AttachmentUploader < GitlabUploader
  include RecordsUploads::Concern
  include ObjectStorage::Concern
  prepend ObjectStorage::Extension::RecordsUploads
  include UploaderHelper

  private

  def dynamic_segment
    File.join(model.class.base_class.underscore, mounted_as.to_s, model.id.to_s)
  end

  def mounted_as
    super || 'attachment'
  end
end
