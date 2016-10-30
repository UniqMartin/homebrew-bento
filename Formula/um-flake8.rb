class UmFlake8 < Formula
  include Language::Python::Virtualenv

  desc "Lint your Python code for style and logical errors (supercharged)"
  homepage "http://flake8.pycqa.org/"
  url "https://files.pythonhosted.org/packages/b0/56/48727b2a6c92b7e632180cf2c1411a0de7cf4f636b4f844c6c46f7edc86b/flake8-3.0.4.tar.gz"
  sha256 "b4c210c998f07d6ff24325dd91fbc011f2c37bcd6bf576b188de01d8656e970d"

  depends_on :python3

  resource "mccabe" do
    url "https://files.pythonhosted.org/packages/f1/b7/ff36d1a163079688633a776e1717b5459caccbb68973afab2aa8345ac40f/mccabe-0.5.2.tar.gz"
    sha256 "3473f06c8b757bbb5cdf295099bf64032e5f7d6fe0ec2f97ee9b23cb0a435aff"
  end

  resource "pycodestyle" do
    url "https://files.pythonhosted.org/packages/db/b1/9f798e745a4602ab40bf6a9174e1409dcdde6928cf800d3aab96a65b1bbf/pycodestyle-2.0.0.tar.gz"
    sha256 "37f0420b14630b0eaaf452978f3a6ea4816d787c3e6dcbba6fb255030adae2e7"
  end

  resource "pyflakes" do
    url "https://files.pythonhosted.org/packages/54/80/6a641f832eb6c6a8f7e151e7087aff7a7c04dd8b4aa6134817942cdda1b6/pyflakes-1.2.3.tar.gz"
    sha256 "2e4a1b636d8809d8f0a69f341acf15b2e401a3221ede11be439911d23ce2139e"
  end

  # Needed for patched `flake8-docstrings`.
  resource "flake8-polyfill" do
    url "https://files.pythonhosted.org/packages/71/6e/dd7e0f0ddf146213d0cc0b963b3d4c6434823ebe3992c29b523182bbf785/flake8-polyfill-1.0.1.tar.gz"
    sha256 "c77056b1e2cfce7b39d7634370062baf02438962a7d176ea717627b83b17f609"
  end

  # Extension `flake8-docstrings` and its dependencies.
  resource "flake8-docstrings" do
    url "https://files.pythonhosted.org/packages/0e/66/5ba0b2498e5964f85ba2d51152453d389a1485ecb114c7544366afc948e7/flake8-docstrings-1.0.2.tar.gz"
    sha256 "65860ba7ccbe29b339eae985d6a4f794b074f66c7bd9f858d78838e263a54596"
  end

  resource "pydocstyle" do
    url "https://files.pythonhosted.org/packages/c1/08/14df5ee08a1bce1598de4e1cdedb7e55e09060971a7241d40d15a1d7a14a/pydocstyle-1.1.1.zip"
    sha256 "f808d8fc23952fe93c2d85598732bfa854cb5ee8a25f8191f60600710f898e8d"
  end

  # Extension `flake8-quotes` and its dependencies.
  resource "flake8-quotes" do
    url "https://files.pythonhosted.org/packages/18/71/9ab02f3777951b871f2ffaf9b7b6d11b6c77894d0260ab3f002e032b0c1e/flake8-quotes-0.8.1.tar.gz"
    sha256 "668ec2fb0fbf1574a95f49e393364f8a114c7180e5cedc7377c5f4b5257e00fb"
  end

  # Extension `flake8-commas` and its dependencies.
  resource "flake8-commas" do
    url "https://files.pythonhosted.org/packages/ba/f7/22180831da432a7072d86f934b164810d9d7cd804439150f5b10b465d1cd/flake8-commas-0.1.6.tar.gz"
    sha256 "05d7a232746bffd3a2e1d9f6992d7fea6abe3e6b5b2864c40070621270e70be2"
  end

  resource "pep8" do
    url "https://files.pythonhosted.org/packages/3e/b5/1f717b85fbf5d43d81e3c603a7a2f64c9f1dabc69a1e7745bd394cc06404/pep8-1.7.0.tar.gz"
    sha256 "a113d5f5ad7a7abacef9df5ec3f2af23a20a28005921577b15dd584d099d5900"
  end

  def install
    virtualenv_create(libexec, "python3")
    virtualenv_install_with_resources

    site_packages = libexec/"lib/python3.5/site-packages"

    # Fix flake8 3.x incompatibility with declaring error codes/handlers, taken
    # from <https://github.com/trevorcreech/flake8-commas/pull/21>.
    inreplace site_packages/"flake8_commas-0.1.6-py3.5.egg-info/entry_points.txt",
              /^flake8_commas =/, "C812 ="

    # Fix flake8 3.x incompatibility with handling standard input, taken from
    # <https://github.com/trevorcreech/flake8-commas/pull/16>.
    patch_file = buildpath/"flake8-commas-0.1.6.patch"
    patch_file.write <<-EOS.undent
      diff --git a/flake8_commas/__init__.py b/flake8_commas/__init__.py
      index 523d103..b14aa6c 100644
      --- a/flake8_commas/__init__.py
      +++ b/flake8_commas/__init__.py
      @@ -1,6 +1,9 @@
       import tokenize

      -import pep8
      +try:
      +    import pycodestyle
      +except ImportError:
      +    import pep8 as pycodestyle

       from flake8_commas.__about__ import __version__

      @@ -30,9 +33,9 @@ def __init__(self, tree, filename='(none)', builtins=None):
           def get_file_contents(self):
               if self.filename in ('stdin', '-', None):
                   self.filename = 'stdin'
      -            return pep8.stdin_get_value().splitlines(True)
      +            return pycodestyle.stdin_get_value().splitlines(True)
               else:
      -            return pep8.readlines(self.filename)
      +            return pycodestyle.readlines(self.filename)

           def run(self):
               file_contents = self.get_file_contents()
    EOS
    site_packages.cd do
      safe_system "/usr/bin/patch", "-g", "0", "-f", "-p1", "-i", patch_file
    end

    # Fix flake8 3.x incompatibility with handling standard input, taken from
    # <https://gitlab.com/pycqa/flake8-docstrings/commit/9444f242>.
    patch_file = buildpath/"flake8-docstrings-1.0.2.patch"
    patch_file.write <<-EOS.undent
      diff --git a/flake8_docstrings.py b/flake8_docstrings.py
      index 2c219b8..608ee3a 100644
      --- a/flake8_docstrings.py
      +++ b/flake8_docstrings.py
      @@ -6,6 +6,7 @@ included as module into flake8
       """
       import sys

      +from flake8_polyfill import stdin
       import pycodestyle
       try:
           import pydocstyle as pep257
      @@ -15,7 +16,9 @@ except ImportError:
           module_name = 'pep257'

       __version__ = '1.0.2'
      -__all__ = ['pep257Checker']
      +__all__ = ('pep257Checker',)
      +
      +stdin.monkey_patch('pycodestyle')


       class EnvironError(pep257.Error):
    EOS
    site_packages.cd do
      safe_system "/usr/bin/patch", "-g", "0", "-f", "-p1", "-i", patch_file
    end
  end

  test do
    system "#{bin}/flake8", "--exit-zero",
                            "#{libexec}/lib/python3.5/site-packages/flake8"
  end

  # Not used by formula, but possibly helpful when recreating the `virtualenv`.
  def pip_freeze
    <<-EOS
      flake8==3.0.4
      flake8-commas==0.1.6
      flake8-docstrings==1.0.2
      flake8-polyfill==1.0.1
      flake8-quotes==0.8.1
      mccabe==0.5.2
      pep8==1.7.0
      pycodestyle==2.0.0
      pydocstyle==1.1.1
      pyflakes==1.2.3
    EOS
  end
end
