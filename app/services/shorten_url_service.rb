class ShortenUrlService
  SECRET_ALPHABET = ENV["SECRET_ALPHABET"] || "k3G7QAe51FCsPW92uEOyq4B"
  SQIDS = Sqids.new(alphabet: SECRET_ALPHABET, min_length: 6)

  class << self
    def encode(length, id)
      SQIDS.encode([length, id])
    end

    def decode(code)
      _length, id = SQIDS.decode(code)
      id
    end
  end
end
