require 'digest'
require 'securerandom'

class Account
  include TinyDyno::Document

  hash_key :id, type: String

  field :email, type: String, range_key: true
  field :label, type: String
  field :active, type: TinyDyno::Boolean

  validates_presence_of :id, :email, :label

  def initialize(attrs = nil)
    super
    set_id if id.nil?
  end

  def set_id
    self.id ||= SecureRandom.uuid
  end

end
