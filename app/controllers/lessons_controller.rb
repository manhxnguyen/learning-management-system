class LessonsController < ApplicationController
  before_action :set_lesson, only: %i[ show update ]
  before_action :set_course

  # GET /lessons or /lessons.json
  def index
    @lessons = Lesson.all
  end

  # GET /lessons/1 or /lessons/1.json
  def show
    @completed_lessons = current_user.lesson_users.where(completed: true).pluck(:id)
    @course = @lesson.course
    @paid_for_course = current_user.course_users.where(course: @course).exists?
  end

  # GET /lessons/new
  def new
    @lesson = Lesson.new
  end

  # GET /lessons/1/edit
  def edit
  end

  # POST /lessons or /lessons.json
  def create
    @lesson = Lesson.new(lesson_params)

    respond_to do |format|
      if @lesson.save
        format.html { redirect_to @lesson, notice: "Lesson was successfully created." }
        format.json { render :show, status: :created, location: @lesson }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @lesson.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /lessons/1 or /lessons/1.json
  def update
    @lesson_user = LessonUser.find_or_create_by(user: current_user, lesson: @lesson)
    @lesson_user.update!(completed: true)
    next_lesson = @course.lessons.where("position > ?", @lesson.position).order(:position).first
    if next_lesson
      redirect_to course_lesson_path(@course, next_lesson)
    else
      redirect_to course_path(@course), notice: "You've completed the course!"
    end

    # respond_to do |format|
    #   if @lesson.update(lesson_params)
    #     format.html { redirect_to @lesson, notice: "Lesson was successfully updated.", status: :see_other }
    #     format.json { render :show, status: :ok, location: @lesson }
    #   else
    #     format.html { render :edit, status: :unprocessable_entity }
    #     format.json { render json: @lesson.errors, status: :unprocessable_entity }
    #   end
    # end
  end

  # DELETE /lessons/1 or /lessons/1.json
  def destroy
    @lesson.destroy!

    respond_to do |format|
      format.html { redirect_to lessons_path, notice: "Lesson was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_lesson
      @lesson = Lesson.find(params.expect(:id))
    end

    def set_course
      @course = Course.find(params[:course_id])
    end

    # Only allow a list of trusted parameters through.
    def lesson_params
      params.expect(lesson: [ :title, :description, :paid, :course_id ])
    end

    def check_paid
      if @lesson.paid && !current_user.course_users.where(course_id: params[:course_id]).exists?
        if @lesson.previous_lesson
          redirect_to course_lesson_path(@course, @lesson.previous_lesson), notice: "You must purchase the full course to access the next lesson"
        else
          redirect_to course_path(@course), notice: "You must purchase the full course to access the next lesson"
        end
      end
    end
end
