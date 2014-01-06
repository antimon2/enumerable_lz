# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{enumerable_lz}
  s.version = "0.1.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["antimon2"]
  s.date = %q{2014-01-07}
  s.description = %q{Add Enumerable#filter, Enumerable#transform and some equivalent methods on Enumerable with suffix '_lz'.}
  s.email = %q{antimon2.me@gmail.com}
  # s.extra_rdoc_files = ["README", "ChangeLog"]
  s.files = ["README.md", "LICENSE.txt", "ChangeLog", "Rakefile", "test/test_enumerable_ex.rb", "test/test_filter.rb", "test/test_transform.rb", "lib/enumerable_lz", "lib/enumerable_lz/enumerable_ex.rb", "lib/enumerable_lz/filter.rb", "lib/enumerable_lz/filter_18.rb", "lib/enumerable_lz/filter_mrb.rb", "lib/enumerable_lz/transform.rb", "lib/enumerable_lz/transform_18.rb", "lib/enumerable_lz/transform_mrb.rb", "lib/enumerable_lz.rb"]
  s.homepage = %q{https://github.com/antimon2/enumerable_lz}
  # s.rdoc_options = ["--title", "enumerable_lz documentation", "--charset", "utf-8", "--opname", "index.html", "--line-numbers", "--main", "README", "--inline-source", "--exclude", "^(examples|extras)/"]
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.8.7")
  s.rubyforge_project = %q{enumerable_lz}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Add Enumerable#filter, Enumerable#transform and some equivalent methods on Enumerable with suffix '_lz'.}
  s.test_files = ["test/test_enumerable_ex.rb", "test/test_filter.rb", "test/test_transform.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
