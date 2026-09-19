require "test_helper"
require "net/http"
require "vips"

class ImgproxyScenario < ActiveSupport::TestCase
  self.use_transactional_tests = false

  setup do
    @blob = ActiveStorage::Blob.create_and_upload!(io: file_fixture("sample.png").open,
      filename: "sample.png", content_type: "image/png")
  end

  teardown { @blob.purge }

  test "Go преобразует файл Active Storage и защищает обработку" do
    path = Rails.application.routes.url_helpers.polymorphic_url(@blob.variant(resize_to_limit: [ 32, 32 ], format: :webp))
    response = fetch_image(path)
    assert_equal "200", response.code
    assert_equal "image/webp", response.content_type
    image = Vips::Image.new_from_buffer(response.body, "")
    assert_equal [ 32, 16 ], [ image.width, image.height ]
    assert_empty ActiveStorage::VariantRecord.where(blob: @blob)

    altered = path.sub("/s:32:32", "/s:33:32")
    refute_equal path, altered
    assert_equal "403", fetch_image(altered).code
    unsigned = path.sub(%r{\A/images/[^/]+/}, "/images/unsafe/")
    assert_equal "403", fetch_image(unsigned).code

    expired = travel(-16.minutes) { Images::VariantUrl.call(@blob.variant(resize_to_limit: [ 32, 32 ])) }
    assert_equal "404", fetch_image(expired).code
    external = Imgproxy.url_for("http://169.254.169.254/metadata", width: 32)
    assert_equal "404", fetch_image(external).code
  end

  private

  def fetch_image(path)
    Net::HTTP.get_response(URI("http://127.0.0.1:8382#{path}"))
  end
end
