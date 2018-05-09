class Dashboard::ContactsController < Dashboard::AdminController
  before_action :set_contact, only: %i[show edit update destroy]

  def index
    @contacts = current_account.contacts.page(params[:page])
  end

  def new
    @contact = Contact.new
  end

  def create
    @contact = current_account.contacts.build(contact_params)
    save_contact
    respond_with_contact
  end

  def update
    @contact.assign_attributes(contact_params)
    save_contact
    respond_with_contact
  end

  def destroy
    @contact.destroy
    respond_with_contact location: dashboard_contacts_path
  end

  private

  def set_contact
    @contact = current_account.contacts.find(params[:id])
  end

  def save_contact
    @contact.save(context: :dashboard)
  end

  def respond_with_contact(location: nil)
    respond_with @contact, location: -> { location || dashboard_contact_path(@contact) }
  end

  def contact_params
    params.require(:contact).permit(
      :msisdn, :province_id, :district_id, :commune_id
    )
  end
end
