STDOUT.sync = true

require "sinatra"
set :inline_templates, caller.first[/[^:]+/]    # https://stackoverflow.com/q/42031829/322020
set :app_file, caller.first[/[^:]+/]            # https://stackoverflow.com/a/10694969/322020

set :bind, "0.0.0.0"
set :port, ENV.fetch("PORT", 8001)
enable :lock

set :environment, :production unless "TRUE" == ENV["TEST"]
if development?
  require "pp"
  # require "sinatra/reloader"
  # register Sinatra::Reloader
else
  disable :show_exceptions
end

set :public_folder, "public"

# set :views, __dir__



# use this class instead of `halt 500, "text"` if you want it to be rendered

not_found do                                                                    ; end
# error   do JSON.dump({status: :error, message: env["sinatra.error"].message}) ; end
class PublicError < RuntimeError ; end
error     do
  begin
    next env["sinatra.error"].to_s if PublicError === env["sinatra.error"]
  rescue => e
    puts e, e.backtrace
  end
  "smth went wrong"
end unless development?
