class Consul < Formula
  desc "Tool for service discovery, monitoring and configuration"
  homepage "https://www.consul.io"
  url "https://github.com/hashicorp/consul.git",
      :tag      => "v1.7.4",
      :revision => "d149d7e9f2d5e4f609fca95fc1d797275c407e8a"
  head "https://github.com/hashicorp/consul.git",
       :shallow => false

  bottle do
    cellar :any_skip_relocation
    sha256 "2ce8cc7bd25c3d53064f06b1a97de9bc562a2b0aace6ead69580063e8fc53d49" => :catalina
    sha256 "6926dfcb37d2fb6d045ec49c7d88fe09250e6ff40f8dd7a08fd0388265231e30" => :mojave
    sha256 "c60c41c2e4174aa6c46bf93115c49562b32c1a411dc5595c7b9712b0a6a1a017" => :high_sierra
    sha256 "0fdfbc41120319f311f2afcf7cc79d28bd25119a356b97f64ead0f06397c159e" => :x86_64_linux
  end

  depends_on "go" => :build
  depends_on "gox" => :build
  depends_on "zip" => :build unless OS.mac?

  def install
    ENV["XC_OS"] = OS.mac? ? "darwin" : "linux"
    ENV["XC_ARCH"] = "amd64"
    ENV["GOPATH"] = buildpath
    contents = Dir["{*,.git,.gitignore}"]
    (buildpath/"src/github.com/hashicorp/consul").install contents

    (buildpath/"bin").mkpath

    cd "src/github.com/hashicorp/consul" do
      system "make"
      bin.install "bin/consul"
      prefix.install_metafiles
    end
  end

  plist_options :manual => "consul agent -dev -advertise 127.0.0.1"

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
            <string>#{opt_bin}/consul</string>
            <string>agent</string>
            <string>-dev</string>
            <string>-advertise</string>
            <string>127.0.0.1</string>
          </array>
          <key>RunAtLoad</key>
          <true/>
          <key>WorkingDirectory</key>
          <string>#{var}</string>
          <key>StandardErrorPath</key>
          <string>#{var}/log/consul.log</string>
          <key>StandardOutPath</key>
          <string>#{var}/log/consul.log</string>
        </dict>
      </plist>
    EOS
  end

  test do
    fork do
      exec "#{bin}/consul", "agent", *("-bind" unless OS.mac?), *("127.0.0.1" unless OS.mac?), "-data-dir", "."
    end
    sleep 3
    system "#{bin}/consul", "leave"
  end
end
