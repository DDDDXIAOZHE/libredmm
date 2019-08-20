module Admin
  class MoviesController < Admin::ApplicationController
    # To customize the behavior of this controller,
    # you can overwrite any of the RESTful actions. For example:
    #
    # def index
    #   super
    #   @resources = Movie.
    #     page(params[:page]).
    #     per(10)
    # end

    # Define a custom finder by overriding the `find_resource` method:
    def find_resource(param)
      Movie.find_by!(code: param)
    end

    # See https://administrate-prototype.herokuapp.com/customizing_controller_actions
    # for more information

    def resource_params
      arr_fields = %i[actresses actress_types categories directors genres sample_images tags]
      arr_fields.each do |field|
        params[resource_name.to_s][field.to_s] = params[resource_name.to_s][field.to_s].split(" ")
      end
      params.require(resource_name).permit(
        *(dashboard.permitted_attributes - arr_fields),
              **arr_fields.map { |field| [field, []] }.to_h,
      )
    end
  end
end
