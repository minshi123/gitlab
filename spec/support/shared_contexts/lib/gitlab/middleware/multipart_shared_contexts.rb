# frozen_string_literal: true

# This context provides one temporary file for the multipart spec
# It simulates the local mode where the uploaded file is present in the file system
# Given that T is the temporary folder, multipart spec will need to be able to have the file in:
# - /T/                                    # within_tmp_sub_dir: false, path_in_tmp_sub_dir: ''
# - /T/*random_dir_name*/                  # within_tmp_sub_dir: true, path_in_tmp_sub_dir: ''
# - /T/*random_dir_name*/fixed/folder/name # within_tmp_sub_dir: true, path_in_tmp_sub_dir: 'fixed/folder/name'
#
# Here are the available variables:
# - uploaded_file
# - uploaded_filepath
# - filename
# - remote_id
# - tmp_sub_dir (only when using within_tmp_sub_dir: true)
RSpec.shared_context 'with one temporary file for multipart' do |within_tmp_sub_dir: false, path_in_tmp_sub_dir: ''|
  let(:uploaded_filepath) { uploaded_file.path }

  around do |example|
    @filename = 'test_file1.png'
    @remote_id = 'remote_id'

    if within_tmp_sub_dir
      Dir.mktmpdir do |dir|
        @tmp_sub_dir = dir

        if path_in_tmp_sub_dir.present?
          dir_in_tmp_sub_dir = File.join(dir, path_in_tmp_sub_dir)
          FileUtils.mkdir_p(dir_in_tmp_sub_dir)

          with_tmp_file('uploaded_file', dir_in_tmp_sub_dir) { example.run }
        else
          with_tmp_file('uploaded_file', dir) { example.run }
        end
      end
    else
      with_tmp_file('uploaded_file') { example.run }
    end
  end

  attr_reader :uploaded_file, :filename, :remote_id, :tmp_sub_dir

  def with_tmp_file(filename, dir = nil)
    Tempfile.open(filename, dir) do |file1|
      @uploaded_file = file1

      yield
    end
  end
end

# This context provides two temporary files for the multipart spec
#
# Here are the available variables:
# - uploaded_file
# - uploaded_filepath
# - filename
# - remote_id
# - tmp_sub_dir (only when using within_tmp_sub_dir: true)
# - uploaded_file2
# - uploaded_filepath2
# - filename2
# - remote_id2
RSpec.shared_context 'with two temporary files for multipart' do
  include_context 'with one temporary file for multipart'

  let(:uploaded_filepath2) { uploaded_file2.path }

  around do |example|
    Tempfile.open('uploaded_file2') do |file2|
      @uploaded_file2 = file2
      @filename2 = 'test_file2.png'
      @remote_id2 = 'remote_id2'

      example.run
    end
  end

  attr_reader :uploaded_file2, :filename2, :remote_id2
end

# This context provides three temporary files for the multipart spec
#
# Here are the available variables:
# - uploaded_file
# - uploaded_filepath
# - filename
# - remote_id
# - tmp_sub_dir (only when using within_tmp_sub_dir: true)
# - uploaded_file2
# - uploaded_filepath2
# - filename2
# - remote_id2
# - uploaded_file3
# - uploaded_filepath3
# - filename3
# - remote_id3
RSpec.shared_context 'with three temporary files for multipart' do
  include_context 'with two temporary files for multipart'

  let(:uploaded_filepath3) { uploaded_file3.path }

  around do |example|
    Tempfile.open('uploaded_file3') do |file1|
      @uploaded_file3 = file1
      @filename3 = 'test_file1.png'
      @remote_id3 = 'remote_id'

      example.run
    end
  end

  attr_reader :uploaded_file3, :filename3, :remote_id3
end

RSpec.shared_context 'with Dir.tmpdir stubbed to a tmp sub dir' do
  before do
    # We are using the tmp dir (see `with one temporary file for multipart context`) and tmp is automatically accepted by UploadedFile
    # Moving temporarly tmp dir to a *sub* tmp dir helps us testing multipart Handler#allowed_paths
    allow(Dir).to receive(:tmpdir).and_return(File.join(Dir.tmpdir, 'tmpsubdir'))
  end
end
