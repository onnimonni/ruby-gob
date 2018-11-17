class Gob::Utils::Decoder
	def initialize(content)
		@content = content
	end

	# Calculates the content length according to the first bytes
	# Source: https://golang.org/pkg/encoding/gob/
	def content_byte_length
		first_byte = @content[0].unpack('C')[0]
		if first_byte <= 128
			# First byte tells the length if byte count is smaller than 128
			content_length = first_byte
			content_length_check_byte_count = 1
		else
			# First byte holds the byte count, negated
			content_length_check_byte_count = (first_byte ^ 0xFF) + 1 + 1

			# Take as many bytes as the first byte mentioned and unpack them as unsigned integer in big endian encoding
			content_length = @content[1..content_length_check_byte_count].unpack('S>')[0]
		end

		# Tells how big the content is and how many bytes in beginning are just for the checksum
		[content_length, content_length_check_byte_count]
	end

	# Checks if the gob encoded content length is valid and
	# no bytes were missing in the transit
	def content_length_correct?
		length, check_bytes = content_byte_length
		length == @content.length - check_bytes
	end
end