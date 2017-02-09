# == Schema Information
#
# Table name: shortened_urls
#
#  id        :integer          not null, primary key
#  long_url  :string           not null
#  short_url :string           not null
#  user_id   :integer          not null
#

class ShortenedUrl < ActiveRecord::Base
  validates :short_url, uniqueness: true, presence: true
  validates :long_url, :user_id, presence: true

  belongs_to :submitter,
    class_name: :User,
    foreign_key: :user_id,
    primary_key: :id

  has_many :visits,
    class_name: :Visit,
    foreign_key: :shortened_url_id,
    primary_key: :id

  has_many :visitors,
    -> { distinct },
    through: :visits,
    source: :user

  has_many :taggings,
    class_name: :Taggings,
    foreign_key: :shortened_url_id,
    primary_key: :id

  has_many :tags,
    through: :taggings,
    source: :tag_topic
    
  def self.create_shortened_url(user, long_url)
    random = random_code
    ShortenedUrl.create!(long_url: long_url, short_url: random, user_id: user.id)
  end

  def self.random_code
    begin
    random_code = SecureRandom.urlsafe_base64
  rescue
    retry if exists?(short_url: random_code)
  end
  end

  def num_clicks
    visits.count
  end

  def num_uniques
    visitors.count
  end

  def num_recent_uniques
    visits
      .select("user_id")
      .where("created_at > ?", 120.minutes.ago)
      .distinct
      .count
  end
end
