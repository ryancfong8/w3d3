# == Schema Information
#
# Table name: tag_topics
#
#  id         :integer          not null, primary key
#  topic      :string           not null
#  created_at :datetime
#  updated_at :datetime
#

class TagTopic < ActiveRecord::Base
  validates :topic, presence: true, uniqueness: true

  has_many :taggings,
    class_name: :Taggings,
    foreign_key: :tag_topic_id,
    primary_key: :id

  has_many :tagged_urls,
    through: :taggings,
    source: :shortened_url

  def popular_links
    tagged_urls.join(:visits)
    .group(:short_url)
    .order('COUNT(visit.id) DESC')
    .select('long_url, short_url, COUNT(visits.id), as number_of_visits')
    .limit(5)

  def popular_links
    tagged_urls.sort_by { |url| url.num_clicks }.first(5)
  end
end
