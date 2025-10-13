class Lesson < ApplicationRecord
  has_one_attached :video
  belongs_to :course
  has_many :lesson_users

  def next_lesson
    course.lessons.where("position > ?", position).order(:position).first
  end

  def previous_lesson
    course.lessons.where("position < ?", position).order(:position).last
  end
end
