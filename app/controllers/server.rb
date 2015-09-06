module TrafficSpy
  class Server < Sinatra::Base

    get '/' do
      erb :index
    end

    post '/sources' do
      messenger = Messenger.new(params, "Source")
      status messenger.status
      body messenger.message
    end

    post '/sources/:identifier/data' do
      if !Source.find_by(identifier: params[:identifier])
        status 403
        body "Application Not Registered"
      elsif params[:payload].nil? || params[:payload].empty?
        status 400
        body "Missing Payload"
      else
        messenger = Messenger.new(build_attributes(params), "Visit")
        status messenger.status
        body messenger.message
      end
    end

    get '/sources/:identifier' do
      if source = Source.find_by(identifier: params[:identifier])
        builder = VariableBuilder.new(params, source)
        erb :show, locals: builder.variables
      else
        erb :error
      end
    end

    not_found do
      erb :error
    end

    get '/sources/:identifier/urls/:relative_path' do
      source_id = Source.find_by(identifier: params[:identifier])
      urls = Url.where(source_id: source_id)
      url = urls.select{|url| url.address.include?(params[:relative_path])}
      visits = Visit.where(url_id: url.first.id)
      refs = top_referrers(visits)
      erb :url_stats, :locals => {:url => url, :visits => visits, :refs => refs}
    end

    private

    def build_attributes(params)
      attributes = JSON.parse(params[:payload])
      sha_identifier = Digest::SHA1.hexdigest(params[:payload])
      attributes[:sha_identifier] = sha_identifier
      attributes[:source_id] = Source.find_by(identifier: params[:identifier]).id
      attributes
    end

    def top_referrers(visits)
      visits.group(:referred_by).count.max_by(5) do |key, value|
        value
      end
    end
  end
end
