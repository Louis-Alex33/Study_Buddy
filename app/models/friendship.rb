class Friendship < ApplicationRecord
  belongs_to :user
  belongs_to :friend, class_name: 'User'

  enum status: { pending: 'pending', accepted: 'accepted', rejected: 'rejected' }

  validates :user_id, uniqueness: { scope: :friend_id, message: "Demande d'ami déjà envoyée" }
  validate :not_self_friend

  scope :accepted_friendships, -> { where(status: 'accepted') }
  scope :pending_requests, -> { where(status: 'pending') }

  private

  def not_self_friend
    errors.add(:friend_id, "Tu ne peux pas t'ajouter toi-même") if user_id == friend_id
  end
end
