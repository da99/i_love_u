
require 'rubygems'
require 'bundler'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.print e.message, "\n"
  $stderr.print "Run `bundle install` to install missing gems\n"
  exit e.status_code
end

require 'bacon'
require 'Bacon_Colored'
require 'pry'

Bacon.summary_on_exit

# ================= Custom code
#
require 'Uni_Lang'


# ======== Include the tests.
if ARGV.size > 1 && ARGV[1, ARGV.size - 1].detect { |a| File.exists?(a) }
  # Do nothing. Bacon grabs the file.
else
  Dir.glob('spec/*.rb').each { |file|
    require File.expand_path(file.sub('.rb', '')) if File.file?(file)
  }
end
