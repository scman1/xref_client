module XrefClient
  class MappingsController < ApplicationController
    before_action :set_mapping, only: %i[ show edit update destroy ]

    # GET /mappings
    def index
      @mappings = Mapping.all
    end

    # GET /mappings/1
    def show
    end

    # GET /mappings/new
    def new
      @mapping = Mapping.new
    end

    # GET /mappings/1/edit
    def edit
    end

    # POST /mappings
    def create
      @mapping = Mapping.new(mapping_params)

      if @mapping.save
        redirect_to @mapping, notice: "Mapping was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /mappings/1
    def update
      if @mapping.update(mapping_params)
        redirect_to @mapping, notice: "Mapping was successfully updated.", status: :see_other
      else
        render :edit, status: :unprocessable_entity
      end
    end

    # DELETE /mappings/1
    def destroy
      @mapping.destroy!
      redirect_to mappings_url, notice: "Mapping was successfully destroyed.", status: :see_other
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_mapping
        @mapping = Mapping.find(params[:id])
      end

      # Only allow a list of trusted parameters through.
      def mapping_params
        params.require(:mapping).permit(:obj_name, :origin, :target, :target_type, :default, :json_paths, :evaluate, :other)
      end
  end
end
