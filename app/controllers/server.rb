module TrafficSpy
  class Server < Sinatra::Base
    register Sinatra::Partial

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
        builder = VariableBuilder.new(source)
        erb :site_data, locals: builder.source_data
      else
        @error_message = "The identifier #{params[:identifier]} does not exist"
        erb :error
      end
    end

    get '/sources/:identifier.json' do
      content_type :json
      if source = Source.find_by(identifier: params[:identifier])
        builder = VariableBuilder.new(source)
        builder.source_data.to_json
      else
        error_message = "The identifier #{params[:identifier]} does not exist"
        {error: error_message}.to_json
      end
    end

    get '/sources/:identifier/urls/:relative_path' do
        source = Source.find_by(identifier: params[:identifier])
        builder = VariableBuilder.new(source, params)
      if builder.valid_url?
        erb :url_stats, locals: builder.url_data
      else
        @error_message =
        "The requested url '/#{params[:relative_path]}' has not been requested"
        erb :error
      end
    end

    get '/sources/:identifier/events' do
      source = Source.find_by(identifier: params[:identifier])
      received_events = Event.where(source_id: source.id)
      if !received_events.empty?
        e_count = received_events.count
        @events = received_events.group(:name).count.max_by(e_count) do |k, v|
          v
        end
        erb :event_index
      else
        @error_message = "No events have been defined"
        erb :error
      end
    end

    get '/sources/:identifier/events/:eventname' do
      source = Source.find_by(identifier: params[:identifier])
      if event = Event.find_by(name: params[:eventname], source_id: source.id)
        event_visits = Visit.where(event_id: event.id)
        @total_received = event_visits.count
        @hour_hits = event_visits.map.with_object(Hash.new(0)) do |event, hash|
          visit_hour = (event[:requested_at]).hour
          hash[visit_hour] += 1
        end
        erb :event_details
      else
        @error_message =
        "<p>The event #{params[:eventname]} has not been defined.
        Return to the Application Events Index.</p>
        <p><a href='/sources/#{params[:identifier]}/events'>
        #{params[:identifier]} Events</a></p>"
        erb :error
      end
    end

    not_found do
      erb :error
    end

    private

    def build_attributes(params)
      attributes = JSON.parse(params[:payload])
      sha_identifier = Digest::SHA1.hexdigest(params[:payload])
      attributes[:sha_identifier] = sha_identifier
      source = Source.find_by(identifier: params[:identifier])
      attributes[:source_id] = source.id
      attributes
    end

  end
end
