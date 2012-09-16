module TokenGenerator
  def generate_token(name='token')
    token = loop do
      token = SecureRandom.hex(8)
      break token if self.class.where(name.to_sym => token).empty?
    end

    send("#{name}=", token)
  end
end
