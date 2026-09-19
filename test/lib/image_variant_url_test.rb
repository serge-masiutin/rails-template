require "test_helper"

class ImageVariantUrlTest < ActiveSupport::TestCase
  setup do
    @blob = ActiveStorage::Blob.create_and_upload!(io: file_fixture("sample.png").open,
      filename: "sample.png", content_type: "image/png")
  end

  teardown { @blob.purge }

  test "standard variant creates a signed expiring URL with format and no local processing" do
    freeze_time do
      variant = @blob.variant(resize_to_limit: [ 32, 32 ], format: :webp, imgproxy_options: { quality: 75 })
      original = variant.variation.transformations.deep_dup
      assert_no_difference("ActiveStorage::VariantRecord.count") do
        path = Rails.application.routes.url_helpers.polymorphic_url(variant)
        assert_match %r{\A/images/(?!unsafe/)[^/]+/}, path
        assert_includes path, "exp:#{15.minutes.from_now.to_i}"
        assert_includes path, "q:75"
        assert path.end_with?(".webp")
        assert_equal path, Rails.application.routes.url_helpers.polymorphic_url(variant)
      end
      assert_equal original, variant.variation.transformations
    end
  end

  test "unknown transformations raise rather than being skipped silently" do
    assert_raises(ArgumentError) { Images::VariantUrl.call(@blob.variant(unknown_resize: [ 10, 10 ])) }
  end

  test "explicit imgproxy_options format overrides the Rails default" do
    variant = @blob.variant(resize_to_limit: [ 32, 32 ], imgproxy_options: { format: :webp })
    assert Images::VariantUrl.call(variant).end_with?(".webp")
  end

  test "original uses the standard proxy route with bounded expiry" do
    path = Rails.application.routes.url_helpers.polymorphic_url(@blob, only_path: true)
    assert_match %r{\A/rails/active_storage/blobs/proxy/}, path
    token = path.split("/")[-2]
    assert_equal @blob, ActiveStorage::Blob.find_signed!(token)
    travel 16.minutes do
      assert_nil ActiveStorage::Blob.find_signed(token)
    end
  end
end
