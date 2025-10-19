class CheckoutsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_stripe_api_key

  def create
    course = Course.find(params[:course_id])

    session = Stripe::Checkout::Session.create(
      mode: "payment",
      line_items: [ {
        price: course.stripe_price_id,
        quantity: 1
      } ],
      success_url: request.base_url + "/courses/#{course.id}",
      cancel_url: request.base_url + "/courses/#{course.id}",
      automatic_tax: { enabled: true },
      customer_email: current_user.email,
      metadata: { course_id: course.id }
    )

    redirect_to session.url, allow_other_host: true
  end

  private

  def set_stripe_api_key
    stripe_config = Rails.env.development? ? :stripe_dev : :stripe_production
    @stripe_secret_key = Rails.application.credentials.dig(stripe_config, :secret_key)
    Stripe.api_key = @stripe_secret_key
  end
end
