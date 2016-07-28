# == Schema Information
#
# Table name: urls
#
#  id           :integer          not null, primary key
#  url          :string(255)
#  keyword      :string(255)
#  total_clicks :integer
#  group_id     :integer
#  modified_by  :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
class Url < ApplicationRecord
  belongs_to :group
  has_many :clicks, dependent: :destroy
  has_and_belongs_to_many :transfer_requests, join_table: :transfer_request_urls

  # this next bit of magic removes any associations in the transfer_request_urls
  # table
  before_destroy { |url| url.transfer_requests.clear }

  validates :keyword, uniqueness: true, presence: true

  validates :url, presence: true

  before_validation(on: :create) do
    # Set clicks to zero
    self.total_clicks = 0
  end

  before_validation do
    # Add http:// if necessary
    unless url =~ /\A#{URI.regexp(%w(http https))}\z/ || url.blank?
      self.url = "http://#{url}"
    end

    # Set keyword if it's blank
    if keyword.blank?
      index = Url.maximum(:id).to_i.next
      index += 1 while Url.exists?(keyword: index.to_s(36))
      self.keyword = index.to_s(36)
    end

    # Downcase the keyword
    self.keyword = keyword.downcase

    # Strip URL of any invalid characters, only allow alphanumeric
    self.keyword = keyword.gsub(/[^0-9a-z\\s]/i, '')
  end

  def add_click!
    clicks << Click.create(country_code: 'US')
    self.total_clicks = total_clicks + 1
    save
  end

  #
  # Click group by times
  # These methods are used to count the number of clicks in a given time period
  # Used mostly for the show page -- reporting and charting
  # Gem used: 'groupdate'
  #
  def clicks_hrs24
    clicks.group_by_hour(:created_at, last: 24, format: '%I:%M%p').count
  end

  def clicks_days7
    clicks.group_by_day(:created_at, last: 7, format: '%m/%d').count
  end

  def clicks_days30
    clicks.group_by_day(:created_at, last: 30, format: '%m/%d').count
  end

  def clicks_alltime
    clicks.group_by_month(:created_at, format: '%m/%Y').count
  end

  def best_day
    clicks.group_by_day(:created_at).count.max_by { |_k, v| v }
  end

  #
  # End click groups
  #


end
