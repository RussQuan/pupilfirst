ActiveAdmin.register TimelineEvent do
  menu parent: 'Startups'
  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  permit_params :title, :description, :iteration, :event_type, :image, :links, :event_on, :startup_id
  #
  # or
  #
  # permit_params do
  #   permitted = [:permitted, :attributes]
  #   permitted << :other if resource.something?
  #   permitted
  # end

  index do
    selectable_column

    column :iteration
    column :title
    column :event_type
    column :event_on

    actions
  end

  member_action :delete_link, method: :put do
    timeline_event = TimelineEvent.find params[:id]
    timeline_event.links.delete_at(params[:link_index].to_i)
    timeline_event.save!

    redirect_to action: :show
  end

  member_action :add_link, method: :put do
    timeline_event = TimelineEvent.find params[:id]
    timeline_event.links << { title: params[:link_title], url: params[:link_url] }
    timeline_event.save!

    redirect_to action: :show
  end

  form do |f|
    f.inputs 'Event Details' do
      f.input :startup
      f.input :title
      f.input :event_type, collection: TimelineEvent.valid_event_types, include_blank: false
      f.input :description
      f.input :iteration
      f.input :image
      f.input :event_on, as: :datepicker
    end

    f.actions
  end

  show do |timeline_event|
    attributes_table do
      row :startup
      row :title
      row :event_type
      row :description
      row :iteration
      row :image
      row :event_on
    end

    panel 'Links' do
      render partial: 'links', locals: {timeline_event: timeline_event}
    end
  end
end
