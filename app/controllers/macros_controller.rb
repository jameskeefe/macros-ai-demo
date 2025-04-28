class MacrosController < ApplicationController

  def display_form
    render({:template => "macros/blank_form"})
  end

  def process_form
    @the_image = params[:image_param]
    @the_description = params[:text_param]

    render({:template => "macros/process_form"})
  end


end
