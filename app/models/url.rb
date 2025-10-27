class Url < ApplicationRecord
  validates :origin_url, presence: true, uniqueness: true,
    format: {with: URI.regexp}
end
