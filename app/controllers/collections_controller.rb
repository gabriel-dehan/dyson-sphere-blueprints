class CollectionsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show, :bulk_download]

  def index
    @collections = policy_scope(Collection)
      .includes(:user)
      .joins(:blueprints)
      .where(type: "Public")
      .where.not(blueprints: { id: nil })
      .where(blueprints: { mod_id: @mods.first.id }) # TODO: Remove when Multibuild is removed
      .group("collections.id")
      .order("sum(blueprints.cached_votes_total) DESC")
      .page(params[:page])
  end

  def show
    @collection = Collection.friendly.find(params[:id])
    @blueprints = @collection
      .blueprints
      .where(mod_id: @mods.first.id) # TODO: Remove when Multibuild is removed
      .order(cached_votes_total: :desc)
      .page(params[:page])

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
    @collection = Collection.friendly.find(params[:id])
    authorize @collection
    filename = "#{@collection.name}.zip"
    temp_file = Tempfile.new(filename)

    begin
      File.open(temp_file.path, "wb") do |f|
        zip = Zip::OutputStream.write_buffer(f) do |io|
          titles = []
          mod_id = @mods.first.id
          @collection.blueprints.select([:mod_id, :collection_id, :title, :encoded_blueprint]).where(mod_id: mod_id).each do |blueprint|
            title = blueprint.title.truncate(100)
            title += "_#{titles.count(title)}" if titles.count(title).positive?
            titles += [blueprint.title.truncate(100)]

            io.put_next_entry("#{@collection.name}/#{title.tr('/', '|')}.txt")
            io.write(blueprint.encoded_blueprint)
          end
        end
        zip.flush
      end
      zip_data = File.read(temp_file.path)
      send_data(zip_data, type: "application/zip", disposition: "attachment", filename: filename)
    rescue StandardError => e
      puts e # Still log an error if there is one
    ensure # important steps below
      temp_file.close
      temp_file.unlink
    end
  end

  private

  def collection_params
    params.require(:collection).permit(:name, :type)
  end
end
