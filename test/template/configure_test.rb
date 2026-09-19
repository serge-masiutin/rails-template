require "minitest/autorun"
require "fileutils"
require "json"
require "open3"
require "tmpdir"

class TemplateConfigureTest < Minitest::Test
  def setup
    @root = Dir.mktmpdir("template-configure-")
    FileUtils.mkdir_p(File.join(@root, "bin"))
    FileUtils.cp(File.expand_path("../../bin/configure", __dir__), File.join(@root, "bin/configure"))
    write("config/template.json", JSON.generate(version: 1, configured: false, name: "starter_app", module_name: "StarterApp", prefix: "starterapp", android_id: "com.example.starterapp"))
    write("config/application.rb", "module StarterApp; end\n")
    write("config/database.yml", "database: starter_app_test\n")
    write("lib/starterapp_provider.rb", "class StarterappProvider; end\n")
    write("native/com/example/starterapp/StarterAppApplication.kt", "package com.example.starterapp\nclass StarterAppApplication\n")
    write("config/metrics.yml", "group: starterapp\napplication: StarterApp\n")
    write("docs/application.md", "[Provider](../lib/starterapp_provider.rb)\n")
    write("vendor/source.txt", "StarterApp starter_app com.example.starterapp\n")
    write("public/font.bin", "\xFF\x00starterapp".b)
    write("bin/run", "#!/bin/sh\necho starterapp\n")
    File.chmod(0o755, File.join(@root, "bin/run"))
    git!("init", "--quiet")
    git!("add", ".")
    git!("-c", "user.name=Template Test", "-c", "user.email=test@example.test", "-c", "commit.gpgsign=false", "commit", "--quiet", "--no-verify", "-m", "fixture")
  end

  def teardown
    FileUtils.remove_entry(@root)
  end

  def test_renames_contracts_paths_and_preserves_vendor_and_binary
    output, status = configure
    assert status.success?, output
    assert_equal "module AcmePortal; end\n", read("config/application.rb")
    assert_equal "database: acme_portal_test\n", read("config/database.yml")
    assert_equal "class AcmeportalProvider; end\n", read("lib/acmeportal_provider.rb")
    assert_equal "package com.acme.portal\nclass AcmePortalApplication\n", read("native/com/acme/portal/AcmePortalApplication.kt")
    assert_equal "group: acmeportal\napplication: AcmePortal\n", read("config/metrics.yml")
    assert_equal "[Provider](../lib/acmeportal_provider.rb)\n", read("docs/application.md")
    assert_equal "StarterApp starter_app com.example.starterapp\n", read("vendor/source.txt")
    assert_equal "\xFF\x00starterapp".b, File.binread(File.join(@root, "public/font.bin"))
    assert File.executable?(File.join(@root, "bin/run"))
    refute File.exist?(File.join(@root, "lib/starterapp_provider.rb"))
    assert JSON.parse(read("config/template.json")).fetch("configured")
    first = read("config/application.rb")
    output, status = configure
    assert status.success?, output
    assert_equal first, read("config/application.rb")
    output, status = configure(name: "other_app")
    refute status.success?, output
    assert_equal first, read("config/application.rb")
  end

  def test_dry_run_does_not_modify_the_checkout
    output, status = configure(extra: [ "--dry-run" ])
    assert status.success?, output
    assert_equal "", git!("status", "--porcelain")
    refute JSON.parse(read("config/template.json")).fetch("configured")
  end

  def test_invalid_identifiers_do_not_modify_files
    [ [ "../escape", "com.acme.portal" ], [ "rails", "com.acme.portal" ], [ "acme_portal", "com.class.portal" ], [ "acme_portal", "com.example.starterapp" ] ].each do |name, id|
      output, status = configure(name: name, android_id: id)
      refute status.success?, output
      assert_equal "", git!("status", "--porcelain")
    end
  end

  def test_dirty_checkout_is_preserved
    write("config/application.rb", "local edit\n")
    output, status = configure
    refute status.success?, output
    assert_equal "local edit\n", read("config/application.rb")
    refute JSON.parse(read("config/template.json")).fetch("configured")
  end

  def test_existing_target_is_rejected_before_any_change
    write("lib/acmeportal_provider.rb", "keep\n")
    git!("add", ".")
    git!("-c", "user.name=Template Test", "-c", "user.email=test@example.test", "-c", "commit.gpgsign=false", "commit", "--quiet", "--no-verify", "-m", "collision")
    output, status = configure
    refute status.success?, output
    assert_equal "keep\n", read("lib/acmeportal_provider.rb")
    assert_equal "", git!("status", "--porcelain")
  end

  private

  def configure(name: "acme_portal", android_id: "com.acme.portal", extra: [])
    output, error, status = Open3.capture3(RbConfig.ruby, "bin/configure", "--name", name, "--android-id", android_id, *extra, chdir: @root)
    [ output + error, status ]
  end

  def write(path, content)
    target = File.join(@root, path)
    FileUtils.mkdir_p(File.dirname(target))
    File.binwrite(target, content)
  end

  def read(path)
    File.read(File.join(@root, path))
  end

  def git!(*arguments)
    output, error, status = Open3.capture3("git", *arguments, chdir: @root)
    raise error unless status.success?
    output
  end
end
