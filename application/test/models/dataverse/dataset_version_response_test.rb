require "test_helper"

class DataverseDatasetVersionResponseTest < ActiveSupport::TestCase

  def setup
    valid_json = load_file_fixture(File.join('dataverse', 'dataset_version_response', 'valid_response.json'))
    @dataset = DataverseDatasetVersionResponse.new(valid_json)
  end

  def empty_json
    "{}"
  end

  def empty_string
    ""
  end

  def incomplete_json_body
    load_file_fixture(File.join('dataverse', 'dataset_version_response', 'incomplete_response.json'))
  end

  test "valid json parses @dataset version response" do
    assert_instance_of DataverseDatasetVersionResponse, @dataset
    assert_equal "OK", @dataset.status
    assert_instance_of DataverseDatasetVersionResponse::Data, @dataset.data
  end

  test "valid json parses @dataset version response data" do
    data = @dataset.data
    assert_equal 2, data.id
    assert_equal "2025-01-20", data.publication_date
    assert_equal 2, data.parents.size
    assert_equal "parent", data.parents.last[:identifier]
    assert_equal "Parent Dataverse", data.parents.last[:name]
    assert_equal "grandparent", data.parents.first[:identifier]
    assert_equal "Grandparent Dataverse", data.parents.first[:name]
    assert_equal 2, data.version_number
    assert_equal "RELEASED", data.version_state
    assert_equal 3, data.dataset_id
    assert_equal "doi:10.5072/FK2/4INDFN", data.dataset_persistent_id
  end

  test "valid json parses dataset version response files metadata fields title" do
    assert_equal "sample dataset", @dataset.metadata_field("title")
  end

  test "valid json parses dataset version response files metadata fields author" do
    assert_equal "Admin, Dataverse", @dataset.authors
  end

  test "valid json parses dataset version response files metadata fields description" do
    assert_equal "This is the description of the dataset", @dataset.description
  end

  test "valid json parses dataset version response files metadata fields subjects" do
    assert_equal "Astronomy and Astrophysics", @dataset.subjects
  end

  test "valid json parses dataset response license" do
    license = @dataset.data.license
    assert_instance_of DataverseDatasetVersionResponse::Data::License, license
    assert_equal "CC0 1.0", license.name
    assert_equal "http://creativecommons.org/publicdomain/zero/1.0", license.uri
    assert_equal "https://licensebuttons.net/p/zero/1.0/88x31.png", license.icon_uri
  end

  test "empty version json does not throw exception" do
    @invalid_dataset = DataverseDatasetVersionResponse.new(empty_json)
    assert_instance_of DataverseDatasetVersionResponse, @invalid_dataset
    assert_equal "", @invalid_dataset.authors
    assert_equal "", @invalid_dataset.description
    assert_equal "", @invalid_dataset.subjects
    assert_nil @invalid_dataset.data.dataset_persistent_id
    assert_nil @invalid_dataset.metadata_field('title')
    assert_nil @invalid_dataset.data.publication_date
    assert_nil @invalid_dataset.data.license.name
    assert_nil @invalid_dataset.data.license.icon_uri
  end

  test "empty string raises JSON::ParserError on version" do
    assert_raises(JSON::ParserError) { DataverseDatasetVersionResponse.new(empty_string) }
  end

  test "licence as string is supported" do
    @target = DataverseDatasetVersionResponse.new(load_file_fixture(File.join('dataverse', 'dataset_version_response', 'license_as_string_response.json')))
    assert_equal "string-license", @target.data.license.name
  end

  test "incomplete json does not throw exception" do
    @invalid_dataset = DataverseDatasetVersionResponse.new(incomplete_json_body)
    assert_instance_of DataverseDatasetVersionResponse, @invalid_dataset
    assert_equal "", @invalid_dataset.authors
    assert_equal "", @invalid_dataset.description
    assert_equal "", @invalid_dataset.subjects
    assert_equal "doi:10.5072/FK2/4INDFN", @invalid_dataset.data.dataset_persistent_id
    assert_nil @invalid_dataset.metadata_field('title')
    assert_nil @invalid_dataset.data.publication_date
    assert_nil @invalid_dataset.data.license.name
    assert_nil @invalid_dataset.data.license.icon_uri
  end

  test "dataset incomplete with no license" do
    json = load_file_fixture(File.join('dataverse', 'dataset_version_response', 'incomplete_no_license.json'))
    @dataset_incomplete = DataverseDatasetVersionResponse.new(json)
    assert_instance_of DataverseDatasetVersionResponse, @dataset_incomplete
    assert_equal "Admin, Dataverse", @dataset_incomplete.authors
    assert_match /This is the description of the dataset/, @dataset_incomplete.description
    assert_equal "Astronomy and Astrophysics", @dataset_incomplete.subjects
    assert_equal "doi:10.5072/FK2/4INDFN", @dataset_incomplete.data.dataset_persistent_id
    assert_equal "sample dataset", @dataset_incomplete.metadata_field('title')
    assert_equal "2025-01-20", @dataset_incomplete.data.publication_date
    assert_nil @dataset_incomplete.data.license.name
    assert_nil @dataset_incomplete.data.license.icon_uri
  end

  test "dataset incomplete with no data" do
    json = load_file_fixture(File.join('dataverse', 'dataset_version_response', 'incomplete_no_data.json'))
    @dataset_incomplete = DataverseDatasetVersionResponse.new(json)
    assert_instance_of DataverseDatasetVersionResponse, @dataset_incomplete
    assert_equal "", @dataset_incomplete.authors
    assert_equal "", @dataset_incomplete.description
    assert_equal "", @dataset_incomplete.subjects
    assert_nil @dataset_incomplete.data.dataset_persistent_id
    assert_nil @dataset_incomplete.metadata_field('title')
    assert_nil @dataset_incomplete.data.publication_date
    assert_nil @dataset_incomplete.data.license.name
    assert_nil @dataset_incomplete.data.license.icon_uri
  end

  test "dataset incomplete with no metadata blocks" do
    json = load_file_fixture(File.join('dataverse', 'dataset_version_response', 'incomplete_no_metadata_blocks.json'))
    @dataset_incomplete = DataverseDatasetVersionResponse.new(json)
    assert_instance_of DataverseDatasetVersionResponse, @dataset_incomplete
    assert_equal "", @dataset_incomplete.authors
    assert_equal "", @dataset_incomplete.description
    assert_equal "", @dataset_incomplete.subjects
    assert_equal "doi:10.5072/FK2/4INDFN", @dataset_incomplete.data.dataset_persistent_id
    assert_nil @dataset_incomplete.metadata_field('title')
    assert_equal "2025-01-20", @dataset_incomplete.data.publication_date
    assert_equal "CC0 1.0", @dataset_incomplete.data.license.name
    assert_equal "https://licensebuttons.net/p/zero/1.0/88x31.png", @dataset_incomplete.data.license.icon_uri
  end
end
