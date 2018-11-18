class Gob::Utils::Decoder
	def initialize(content)
		@content = content
	end

	# Reads next integer from content
	def read_next_int(content,opts={signed: true})
		first_byte = content[0].unpack('C')[0]
		if first_byte <= 128 # Source: https://golang.org/pkg/encoding/gob/
			# First byte tells the length if byte count is smaller than 128
			int = first_byte
			int_byte_count = 1
		else
			# First byte holds the byte count, negated
			int_byte_count = (first_byte ^ 0xFF) + 1

			# TODO: really stupid way to convert golang integer to ruby but I wanted to move forward
			# Problem with unpack is that I would need to know which size it is, and for now I'm just too lazy to figure out
			# This would propably make the encoder much faster if written properly
			int = content[1..int_byte_count].bytes.map{ |b| b.to_s(2).rjust(8,"0") }.join.to_i(2)

			# Also skip the first_byte which told us how many bytes there are
			int_byte_count += 1
		end

		# Check the sign from the last digit and shift
		# This is needed because golang uses last bit for the sign, for example 1000
		# Ruby int: 			00000011 11101000
		# Golang Gob int: 00000111 11010000 
		# As you can see we need to shift the number one bit in order to get real number
		# For negative numbers we need to check the last bit and correct the bits by adding one
		# For example -10
		# Gob int:  00001001
		# Ruby int: 00001010 (this is just 10, we need to also add the sign)
		if opts[:signed]
			if (int % 2) == 0 # Positive
				int = int >> 1
			else # Negative
				int = -(int >> 1) - 1
			end
		end

		# Tells how big the content is and how many bytes in beginning are just for the checksum
		[int, int_byte_count]
	end

	def read_next_uint(content)
		read_next_int(content, signed: false)
	end

	def content_byte_length
		read_next_uint(@content)
	end

	# Checks if the gob encoded content length is valid and
	# no bytes were missing in the transit
	def content_length_correct?(content=@content)
		length, check_bytes = read_next_uint(content)
		length == content.bytes.length - check_bytes
	end

	# These are the supported types for gob encoding
	TYPES = {
		1 => :bool,
		2 => :int,
		3 => :uint,
		4 => :float,
		5 => :byte_array,
		6 => :string,
		7 => :complex,
		8 => :interface,
		# gap for reserved ids.
		16 => :WireType,
		17 => :ArrayType,
		18 => :CommonType,
		19 => :SliceType,
		20 => :StructType,
		21 => :FieldType,
		22 => :FieldType_slice,
		23 => :MapType
	}.freeze

	# Checks which kind of data is included
	def type(content=@content)
		content_length, skip_bytes = read_next_uint(content)
		type_for_byte(content[skip_bytes])
	end

	def type_for_byte(byte)
		type = TYPES[(byte.unpack('C')[0]/2)]
		unless type
			raise NotImplementedError, "Type #{type_byte} is not yet implemented in ruby-gob"
		end
		type
	end

	# Converts gob decoded string into ruby objects
	def decode(content=@content)
		# Start recursing rest of the body
		decode_data_type( go_through_length_bytes(content) )
	end

	def go_through_length_bytes(content)
		# Validate length
		unless content_length_correct?(content)
			raise Gob::Utils::Decoder::ContentMissing, "Content length is too short, retry with all bytes intact"
		end

		content_length, skip_bytes = read_next_uint(content)
		content[skip_bytes..-1]
	end

	def check_for_zero_digit?(byte)
		byte.unpack('C')[0] == 0
	end

	def decode_data_type(content)
		type = type_for_byte(content[0])

		unless check_for_zero_digit?(content[1])
			raise Gob::Utils::Decoder::SkipByteMissing, "Content should have a zero byte after #{type} declaration" 
		end

		# Rest of the content is for the data itself
		content = content[2..-1]

		case type
		when :bool
			case content.unpack('C')[0]
			when 1
				true
			when 0
				false
			else
				raise Gob::Utils::Decoder::DecodingError::ZeroMismatch, "Incorrect byte for boolean type: #{content.unpack('C')[0]}"
			end
		when :int
			read_next_int(content).first
		when :uint
			read_next_uint(content).first
		when :string
			go_through_length_bytes(content)
		else
			raise NotImplementedError, "Type #{@type} is not yet implemented in ruby-gob"
		end
	end
end