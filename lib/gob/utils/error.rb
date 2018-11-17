class Gob::Utils::Decoder::DecodingError < StandardError; end
class Gob::Utils::Decoder::DecodingError::ContentMissing < Gob::Utils::Decoder::DecodingError; end

class Gob::Utils::Decoder::DecodingError::SkipByteMissing < Gob::Utils::Decoder::DecodingError; end

class Gob::Utils::Decoder::DecodingError::ZeroMismatch < Gob::Utils::Decoder::DecodingError; end