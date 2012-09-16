require 'digest/md5'

class Gravatar
  def self.for(email, size=80)
    digest = Digest::MD5.hexdigest(email)
    # "http://www.gravatar.com/avatar/#{digest}.jpg?s=#{size}&d=404"
    "http://www.gravatar.com/avatar/#{digest}.jpg?s=#{size}&d=mm"
  end
end
