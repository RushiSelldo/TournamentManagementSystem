class Tournament < ApplicationRecord
  belongs_to :host, class_name: "User", foreign_key: :host_id
  has_many :teams, dependent: :destroy
  has_many :matches, dependent: :destroy

  validates :name, presence: true
  validates :start_date, presence: true
  validate :start_date_cannot_be_in_past


  def start_date_cannot_be_in_past
    if start_date.present? && start_date < Date.today
      errors.add(:start_date, "can't be in the past")
    end
  end
end
