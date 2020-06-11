class Telegraf < Formula
  desc "Server-level metric gathering agent for InfluxDB"
  homepage "https://influxdata.com"
  url "https://github.com/influxdata/telegraf/archive/v1.14.4.tar.gz"
  sha256 "146110daee518a1abf22f03fe87b633fb1d4455c053bf4fdf8b02ea0905d0bca"
  head "https://github.com/influxdata/telegraf.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "45b942611a1205835c3a99a84fe4d267dc763a2dda5b1f5c4fcfaf17c8ee6d5d" => :catalina
    sha256 "8c046bd178ed2e082a4613ad5a3bdeb618c066fd7d58e05a940bef94aaa85285" => :mojave
    sha256 "90fe453c6c58e411db1a48f83cc31f1ae19ce5e6ef3e2571652db52868eccad6" => :high_sierra
    sha256 "488413a8583a7d2f4b8d697a9145eb093ed7c611be48fa66aeae08cf9ccf10b8" => :x86_64_linux
  end

  depends_on "go" => :build

  def install
    ENV["GOPATH"] = buildpath
    dir = buildpath/"src/github.com/influxdata/telegraf"
    dir.install buildpath.children
    cd dir do
      system "go", "mod", "download"
      system "go", "install", "-ldflags", "-X main.version=#{version}", "./..."
      prefix.install_metafiles
    end
    bin.install "bin/telegraf"
    etc.install dir/"etc/telegraf.conf" => "telegraf.conf"
  end

  def post_install
    # Create directory for additional user configurations
    (etc/"telegraf.d").mkpath
  end

  plist_options :manual => "telegraf -config #{HOMEBREW_PREFIX}/etc/telegraf.conf"

  def plist
    <<~EOS
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
        <dict>
          <key>KeepAlive</key>
          <dict>
            <key>SuccessfulExit</key>
            <false/>
          </dict>
          <key>Label</key>
          <string>#{plist_name}</string>
          <key>ProgramArguments</key>
          <array>
            <string>#{opt_bin}/telegraf</string>
            <string>-config</string>
            <string>#{etc}/telegraf.conf</string>
            <string>-config-directory</string>
            <string>#{etc}/telegraf.d</string>
          </array>
          <key>RunAtLoad</key>
          <true/>
          <key>WorkingDirectory</key>
          <string>#{var}</string>
          <key>StandardErrorPath</key>
          <string>#{var}/log/telegraf.log</string>
          <key>StandardOutPath</key>
          <string>#{var}/log/telegraf.log</string>
        </dict>
      </plist>
    EOS
  end

  test do
    (testpath/"config.toml").write shell_output("#{bin}/telegraf -sample-config")
    system "#{bin}/telegraf", "-config", testpath/"config.toml", "-test",
           "-input-filter", "cpu:mem"
  end
end
