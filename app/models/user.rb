class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

  # Auto-confirm user after creation use for deploy to Render
  after_create :auto_confirm_user

  has_many :lesson_users
  has_many :course_users

  private

  def auto_confirm_user
    self.confirm unless confirmed?
  end
end
