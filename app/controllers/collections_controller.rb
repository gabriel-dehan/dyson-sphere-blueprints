class CollectionsController < ApplicationController
  include BlueprintsFilters

  skip_before_action :authenticate_user!, only: [:index, :show, :bulk_download]

  def index
    @collections = policy_scope(Collection)
      .includes(:user)
      .joins(:blueprints)
      .where(type: "Public")
      .where.not(blueprints: { id: nil })
      .where(blueprints: { game_version_id: @game_versions.first.id })
      .group("collections.id")
      .select("collections.*, COUNT(blueprints.id) as blueprints_count, COALESCE(SUM(blueprints.cached_votes_total), 0) as total_votes_sum")
      .order("total_votes_sum DESC")
      .page(params[:page])
  end

  def show
    set_filters
    @collection = Collection.friendly.find(params[:id])
    @blueprints = @collection
      .blueprints
      .light_query
      .with_associations
      .order(cached_votes_total: :desc)
      .page(params[:page])

    @blueprints = filter(@blueprints)

    authorize @collection
  end

  def new
    @collection = current_user.collections.new
    authorize @collection
  end

  def create
    @collection = current_user.collections.new(collection_params)
    authorize @collection

    if @collection.save
      flash[:notice] = "Collection successfully created."
      redirect_to collection_path(@collection)
    else
      render "collection/new"
    end
  end

  def edit
    @collection = current_user.collections.friendly.find(params[:id])

    authorize @collection
  end

  def update
    @collection = current_user.collections.friendly.find(params[:id])
    @collection.assign_attributes(collection_params)
    authorize @collection

    if @collection.save
      flash[:notice] = "Collection successfully updated."
      redirect_to collection_path(@collection)
    else
      render "collection/edit"
    end
  end

  def destroy
    @collection = current_user.collections.friendly.find(params[:id])
    authorize @collection
    @collection.destroy
    flash[:notice] = "Collection successfully deleted."
    redirect_to collections_users_path
  end

  def bulk_download
    # Sanitize for Windows Explorer ZIP viewer (invalid filename chars): \\ / : * ? " < > |
    # Also sanitize historical set used by this app: . / @ , \\
    sanitizer = "\\/:*?\"<>|./@,\\"

    @collection = Collection.friendly.find(params[:id])
    authorize @collection

    safe_collection_name = @collection.name.tr(sanitizer, "_")
    filename = "#{safe_collection_name}.zip"

    zip_buffer = Zip::OutputStream.write_buffer do |io|
      titles = []
      @collection.blueprints.find_each(batch_size: 10) do |blueprint|
        is_mecha = blueprint.type == Blueprint::Mecha.sti_name
        title = blueprint.title.truncate(100)
        title += "_#{titles.count(title)}" if titles.count(title).positive?
        titles += [blueprint.title.truncate(100)]

        safe_title = title.tr(sanitizer, "_")
        extension = is_mecha ? "mecha" : "txt"

        io.put_next_entry("#{safe_collection_name}/#{blueprint.type.pluralize.underscore}/#{safe_title}.#{extension}")
        if is_mecha
          data = blueprint.blueprint_file_data ? blueprint.blueprint_file.open.read : nil
        else
          data = blueprint.encoded_blueprint
        end

        io.write(data) if data
      end
    end

    send_data(zip_buffer.string, type: "application/zip", disposition: "attachment", filename: filename)
  end

  private

  def collection_params
    params.require(:collection).permit(:name, :type)
  end
end
