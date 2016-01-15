class UmPstree < Formula
  desc "Show ps output as a tree"
  homepage "http://www.thp.uni-duisburg.de/pstree/"
  url "ftp://ftp.thp.uni-duisburg.de/pub/source/pstree-2.39.tar.gz"
  mirror "https://fossies.org/linux/misc/pstree-2.39.tar.gz"
  sha256 "7c9bc3b43ee6f93a9bc054eeff1e79d30a01cac13df810e2953e3fc24ad8479f"

  # This is essentially `pstree` with some custom patches.
  conflicts_with "pstree", :because => "both install a `pstree` binary"

  # Support for excluding `pstree` and its children with '-X' option.
  patch do
    url "https://raw.githubusercontent.com/UniqMartin/patches/6792c5b5/pstree/exclude-self.patch"
    sha256 "a54d40a46da0fe035f4e793b1f9c802a4039fc2a5b4a52a192539acf99ab9e02"
  end

  # Support for relative depth with '-l' option.
  patch do
    url "https://raw.githubusercontent.com/UniqMartin/patches/6792c5b5/pstree/relative-levels.patch"
    sha256 "d0b14ac472b358b2a663de13cb176ac770c6dbd3f6dcf6b09c9b3f3130faa56a"
  end

  def install
    system "make", "pstree"
    bin.install "pstree"
    man1.install "pstree.1"
  end

  test do
    lines = shell_output("#{bin}/pstree #{Process.pid}").strip.split("\n")
    assert_match $0, lines[0]
    assert_match "#{bin}/pstree", lines[1]
  end
end
