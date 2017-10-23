STDOUT.sync = true

require "sinatra"
set :inline_templates, caller.first[/[^:]+/]    # https://stackoverflow.com/q/42031829/322020
set :app_file, caller.first[/[^:]+/]            # https://stackoverflow.com/a/10694969/322020

set :bind, "0.0.0.0"
set :port, (ENV["PORT"] || fail("no ENV['PORT'] specified"))
enable :lock

set :environment, :production unless Gem::Platform.local.os == "darwin"
if development?
  require "pp"
  # require "sinatra/reloader"
  # register Sinatra::Reloader
end
disable :show_exceptions

set :public_folder, "public"

# set :views, __dir__


require "google/cloud/error_reporting"
Google::Cloud::ErrorReporting.configure do |config|
  config.keyfile = ENV["ERROR_REPORTING_KEYFILE"] || fail("no ENV['ERROR_REPORTING_KEYFILE'] specified")
  config.project_id = JSON.load(File.read ENV["ERROR_REPORTING_KEYFILE"])["project_id"]
end

# use this class instead of `halt 500, "text"` if you want it to be rendered
class PublicError < RuntimeError ; end

not_found do                                                                    ; end
# error   do JSON.dump({status: :error, message: env["sinatra.error"].message}) ; end
error     do
  begin
    Google::Cloud::ErrorReporting.report env["sinatra.error"]
    next env["sinatra.error"].to_s if PublicError === env["sinatra.error"]
  rescue => e
    puts e, e.backtrace
  end
  "smth went wrong"
end
