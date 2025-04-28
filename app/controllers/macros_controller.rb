class MacrosController < ApplicationController

  def display_form
    render({:template => "macros/blank_form"})
  end

  def process_form
    # can also do
    # @the_image = params.fetch("image_param", nil)
    @the_image = params[:image_param]
    @the_description = params[:text_param]

    c = OpenAI::Chat.new
    c.system("You are an expert nutritionist. The user will give you an image and/or a description of a meal. Your job is to estimate the number of macronutrients and calories in it.")
    
    if @the_image.blank? && @the_description.blank?
      @notes = "You must provide at least one of image or description."
    else
      if @the_image.present?
        c.user("Here's an image:", image: @the_image)
      end

      if @the_description.present?
        c.user(@the_description)
      end
    end

    c.user(@the_description)

    c.schema = '{
          "name": "nutrition_info",
          "schema": {
            "type": "object",
            "properties": {
              "carbohydrates": {
                "type": "number",
                "description": "Amount of carbohydrates in grams."
              },
              "protein": {
                "type": "number",
                "description": "Amount of protein in grams."
              },
              "fat": {
                "type": "number",
                "description": "Amount of fat in grams."
              },
              "total_calories": {
                "type": "number",
                "description": "Total calories in kcal."
              },
              "notes": {
                "type": "string",
                "description": "A breakdown of how you arrived at the values, and additional notes."
              }
            },
            "required": [
              "carbohydrates",
              "protein",
              "fat",
              "total_calories",
              "notes"
            ],
            "additionalProperties": false
          },
          "strict": true
    }'

    @structured_output = c.assistant!

    @g_carbs = @structured_output["carbohydrates"]
    @g_protein = @structured_output["protein"]
    @g_fat = @structured_output["fat"]
    @g_kcal = @structured_output["total_calories"]
    @notes = @structured_output["notes"]

    render({:template => "macros/process_form"})

  end


end
