class VariableBuilder
  attr_reader :source, :source_visits, :user_agents, :urls, :params

  def initialize(source, params=nil)
    @source = source
    @source_visits = Visit.where(source_id: source.id)
    @user_agents = source_visits.map {|visit| UserAgent.parse(visit.user_agent)}
    @urls = Url.where(source_id: source.id)
    @params = params
  end

  def source_data
    {identifier: identifier,
     addresses: addresses,
     screen_resolutions: screen_resolutions,
     browsers: user_browsers,
     os_platforms: os_platforms,
     url_response_times: url_response_times}
  end

  def url_data
    {url: url,
     url_visits: url_visits,
     refs: refs,
     os_platforms: os_platforms,
     browsers: user_browsers}
  end

  def valid_url?
    !url.empty?
  end

  private

  def url
    urls.select{|url| url.address.include?(params[:relative_path])}
  end

  def identifier
    source.identifier.capitalize
  end

  def addresses
    raw_addresses = urls.map do |url|
      visits_count = Visit.where(url_id: url.id).count
      [url.address, visits_count]
    end
    raw_addresses.max_by(raw_addresses.count) {|address, visits| visits}
  end

  def screen_resolutions
    resolutions = source_visits.map do |visit|
      "#{visit.resolution_width}x#{visit.resolution_height}"
    end
    resolutions.uniq
  end

  def user_browsers
    browsers = user_agents.map.with_object(Hash.new(0)) do |user_agent, hash|
     hash[user_agent.browser] += 1
   end
   browsers.to_a.max_by(user_agents.count) {|browser, visits| visits}
  end

  def os_platforms
    platforms = user_agents.map.with_object(Hash.new(0)) do |user_agent, hash|
     hash[user_agent.platform] += 1
   end
   platforms.to_a.max_by(user_agents.count) {|platform, visits| visits}
  end

  def url_response_times
    raw_times = urls.map do |url|
      path = url.address.gsub(source.root_url, identifier.downcase + "/urls")
      url_visits = Visit.where(url_id: url.id)
      average_response_time = url_visits.average("responded_in").to_i
      [url.address, average_response_time, path]
    end
    raw_times.max_by(raw_times.count) {|address, time| time}
  end

  def refs
    url_visits.group(:referred_by).count.max_by(5) do |key, value|
      value
    end
  end

  def url_visits
    Visit.where(url_id: url.first.id)
  end

end
