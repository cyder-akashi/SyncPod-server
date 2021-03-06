require "google/apis/youtube_v3"

class YoutubeVideo
  include AttrAccessorExtension

  attr_reader :youtube_video_id,
              :channel_title,
              :time,
              :thumbnail_url,
              :published,
              :description,
              :view_count,
              :title

  def initialize(id)
    service = Google::Apis::YoutubeV3::YouTubeService.new
    service.key = ENV["GOOGLE_API_KEY"]
    result = service.list_videos("snippet, contentDetails, statistics", { id: id }).items[0]

    @youtube_video_id = id
    @time = VideoDuration.new(result.content_details.duration)
    @view_count = result.statistics.view_count
    @restriction = result.content_details.region_restriction
    analyze_snippet(result.snippet)
  end

  def restricted?
    !@restriction.nil?
  end

  def live?
    @live_broadcast_content == "live"
  end

  private

    def analyze_snippet(snippet)
      @channel_title = snippet.channel_title
      @thumbnail_url = snippet.thumbnails.medium.url
      @published = snippet.published_at
      @description = snippet.description
      @title = snippet.title
      @live_broadcast_content = snippet.live_broadcast_content
    end
end
