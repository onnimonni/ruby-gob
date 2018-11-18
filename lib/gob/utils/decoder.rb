class Gob::Utils::Decoder

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

	def initialize(content)
		@content = content
	end

	def content_byte_length
		read_next_uint(@content)
	end

	# Checks if the gob encoded content length is valid and
	# no bytes were missing in the transit
	def content_length_correct?(content=@content)
		traveled_length = 0
		total_length = content.bytes.length
		until traveled_length >= total_length
			part_length, check_bytes = read_next_uint(content[traveled_length..-1])
			traveled_length += part_length + check_bytes
		end

		# Check if we went through all of the bytes items
		total_length == traveled_length
	end

	# Checks which kind of data is included
	def type(content=@content)
		content_length, skip_bytes = read_next_uint(content)
		get_type(content[skip_bytes..-1])
	end

	# Converts gob decoded string into ruby objects
	def decode(content=@content)
		unless content_length_correct?(content)
			raise Gob::Utils::Decoder::SkipByteMissing, "Content should have a zero byte after #{type} declaration" 
		end
		# Start recursing rest of the body
		result = split_content_into_parts(content).map do |part|
			type_for_part = get_type(part)
			decode_data_type(type,content_without_length(content))
		end

		result.first
	end

	private 

	def get_type(content)
		type_int = read_next_int(content).first
		if type_int < 0 # Spec says that new types are defined with negative number
			# New type definition needs to be done
			raise "Custom types are not yet supported"
		else
			# Basic types are defined in the spec
			type_for_basic_byte(type_int,content)
		end
	end

	def type_for_basic_byte(type_int,content)
		unless TYPES.include? type_int
			#binding.pry
			raise NotImplementedError, "This basic type is not yet implemented in ruby-gob"
		end
		TYPES[type_int]
	end

	def content_without_length(content)
		content_length, skip_bytes = read_next_uint(content)
		content[skip_bytes..-1]
	end

	def check_for_zero_digit?(byte)
		byte.unpack('C')[0] == 0
	end

	def decode_data_type(type, content)
		unless check_for_zero_digit?(content[1])
			raise Gob::Utils::Decoder::SkipByteMissing, "Content should have a zero byte after #{type} declaration" 
		end

		# Rest of the content is for the data itself
		content = content[2..-1]

		case type
		when :bool
			case content.bytes.first
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
		when :float
			read_next_float(content).first
		when :byte_array
			content_without_length(content).bytes # byte array works exactly like string but it's used similiarly here as in golang
		when :string
			content_without_length(content)
		when :complex
			raise NotImplementedError, "Complex type is not yet implemented in ruby-gob"
		when :interface
			raise NotImplementedError, "Interface type is not yet implemented in ruby-gob"
		when :StructType
			binding.pry
		else
			raise NotImplementedError, "Type #{@type} is not yet implemented in ruby-gob"
		end
	end

		# Returns the how many bytes are in the next uint and the bytes as well
	def read_next_uint_bytes(content)
		first_byte = content[0].unpack('C')[0]
		if first_byte <= 128 # Source: https://golang.org/pkg/encoding/gob/
			# First byte tells the length if byte count is smaller than 128
			[1, content[0..0]]
		else
			# First byte holds the byte count, negated
			uint_byte_count = (first_byte ^ 0xFF) + 1

			# Also skip the first_byte which told us how many bytes there are
			# And return the bytes
			[uint_byte_count+1, content[1..uint_byte_count]]
		end
	end

	# Reads next integer from content
	# Returns the integer and tells how many bytes were needed to read it
	def read_next_uint(content)
		byte_count, uint_byte_string = read_next_uint_bytes(content)

		# TODO: really stupid way to convert golang integer to ruby but I wanted to move forward
		# Problem with unpack is that I would need to know which size it is, and for now I'm just too lazy to figure out
		# This would propably make the encoder much faster if written properly
		uint = uint_byte_string.bytes.map{ |b| b.to_s(2).rjust(8,"0") }.join.to_i(2)
		
		# Returns the integer and tells how many bytes were needed to read it
		[uint, byte_count]
	end

	# Reads next integer from content
	# Returns the integer and tells how many bytes were needed to read it
	def read_next_int(content)
		# Int works just like uint but we need to check the last bit of the number
		uint, byte_count = read_next_uint(content)

		# Check the sign from the last digit and shift
		# This is needed because golang uses last bit for the sign, for example 1000
		# Ruby int: 			00000011 11101000
		# Golang Gob int: 00000111 11010000 
		# As you can see we need to shift the number one bit in order to get real number
		# For negative numbers we need to check the last bit and correct the bits by adding one
		# For example -10
		# Gob int:  00001001
		# Ruby int: 00001010 (this is just 10, we need to also add the sign)
		if (uint % 2) == 0 # Positive
			int = uint >> 1
		else # Negative
			int = -(uint >> 1) - 1
		end

		[int, byte_count]
	end

	# Floats are stored as uint64 representation so the first byte tells length
	# Next one is exponent and high-precision part of mantissa
	def read_next_float(content)
		byte_count, float_byte_string = read_next_uint_bytes(content)

		# Here we can see how ruby and gob store floats in different way
		# This is 17.0 in floating point math
		# Gob presentation:
		# 00110001 01000000
		# Ruby presentation:
		# 00000000 00000000 00000000 00000000 00000000 00000000 00110001 01000000
		# Gob skips all zero bytes which ruby keeps

		# TODO: This is also quite stupid like the way we handle integer
		# So we fix this with by adding zero padded bytes to the left side
		# Ruby always uses double precision for floats so this is just fine
		float = float_byte_string.rjust(8,"\x00").unpack("D*").first

		[float, byte_count]
	end

	# Split content into parts which can then be encoded
	def split_content_into_parts(content)
		parts = []
		traveled_length = 0
		total_length = content.bytes.length
		until traveled_length >= total_length
			part_length, check_bytes = read_next_uint(content[traveled_length..-1])
			parts << content[(traveled_length+check_bytes)..(traveled_length+part_length)]
			traveled_length += part_length + check_bytes
		end
		parts
	end
end