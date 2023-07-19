component "ruby-shadow" do |pkg, settings, platform|
  pkg.url "https://github.com/apalmblad/ruby-shadow"
  pkg.ref "refs/tags/2.5.0"

  pkg.build_requires "ruby-#{settings[:ruby_version]}"
  pkg.environment "PATH", "$(PATH):/usr/ccs/bin:/usr/sfw/bin"
  pkg.environment "CONFIGURE_ARGS", '--vendor'

  if platform.is_solaris?
    if platform.architecture == 'sparc'
      pkg.environment "RUBY", settings[:host_ruby]
    end
    ruby = "#{settings[:host_ruby]} -r#{settings[:datadir]}/doc/rbconfig-#{settings[:ruby_version]}-orig.rb"
  elsif platform.is_cross_compiled?
    pkg.environment "RUBY", settings[:host_ruby]
    ruby = "#{settings[:host_ruby]} -r#{settings[:datadir]}/doc/rbconfig-#{settings[:ruby_version]}-orig.rb"
  else
    ruby = File.join(settings[:ruby_bindir], 'ruby')
  end

  matchdata = platform.settings[:ruby_version].match /(\d+)\.(\d+)\.\d+/
  ruby_major_version = matchdata[1].to_i
  if ruby_major_version >= 3
    base = "resources/patches/ruby_32"
    # https://github.com/apalmblad/ruby-shadow/issues/26
    # if ruby-shadow gets a 3 release this should be removed
    pkg.apply_patch "#{base}/ruby-shadow-taint.patch", strip: "1"
    pkg.apply_patch "#{base}/ruby-shadow-rbconfig.patch", strip: "1"
  end

  pkg.build do
    [
      "#{ruby} extconf.rb",
      "#{platform[:make]} -e -j$(shell expr $(shell #{platform[:num_cores]}) + 1)"
    ]
  end

  pkg.install do
    ["#{platform[:make]} -e -j$(shell expr $(shell #{platform[:num_cores]}) + 1) DESTDIR=/ install"]
  end
end
