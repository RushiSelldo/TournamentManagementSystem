class User < ApplicationRecord
  has_secure_password
  has_many :hosted_tournaments, class_name: "Tournament", foreign_key: "host_id"
  has_many :team_members
  has_many :teams, through: :team_members

  # VALID_EMAIL_REGEX = /\A[^@\s]+@[^@\s]+\z/

  validates :name, presence: true, length: { minimum: 2, maximum: 50 }
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role, presence: true, inclusion: { in: %w[host participant admin] }

  before_save :downcase_email
  after_initialize :set_default_role, if: :new_record?

  private

  def downcase_email
    self.email = email&.downcase
  end
  def set_default_role
    self.role ||= "participant"
  end
end
