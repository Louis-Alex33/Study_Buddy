class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  has_many :lectures
  has_many :categories, through: :lectures
  has_many :flashcard_completions
  has_many :flashcards, through: :flashcard_completions
  has_many :attempts
  has_many :challenges
  has_many :challenger_users
  has_many :invited_challenges, through: :challenger_users, source: :challenge
  has_one :user_league, dependent: :destroy
  has_many :quiz_participants, dependent: :destroy
  has_many :quiz_rooms, through: :quiz_participants

  # Friendships - demandes envoyées
  has_many :sent_friendships, class_name: 'Friendship', foreign_key: 'user_id', dependent: :destroy
  # Friendships - demandes reçues
  has_many :received_friendships, class_name: 'Friendship', foreign_key: 'friend_id', dependent: :destroy

  devise :database_authenticatable, :registerable,
        :recoverable, :rememberable, :validatable

  # Retourne tous les amis acceptés (dans les deux sens)
  def friends
    friend_ids = sent_friendships.accepted.pluck(:friend_id) +
                 received_friendships.accepted.pluck(:user_id)
    User.where(id: friend_ids)
  end

  # Demandes d'ami en attente reçues
  def pending_friend_requests
    received_friendships.pending
  end

  # Demandes d'ami en attente envoyées
  def sent_pending_requests
    sent_friendships.pending
  end

  # Vérifie si deux utilisateurs sont amis
  def friend_with?(user)
    friends.include?(user)
  end

  # Vérifie s'il y a une demande en attente avec un utilisateur
  def pending_request_with?(user)
    sent_friendships.pending.exists?(friend_id: user.id) ||
      received_friendships.pending.exists?(user_id: user.id)
  end

  # Retourne le nom complet ou l'email
  def display_name
    if first_name.present? || last_name.present?
      "#{first_name} #{last_name}".strip
    else
      email.split('@').first
    end
  end
end
