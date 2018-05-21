# == Schema Information
#
# Table name: services
#
#  id         :integer          not null, primary key
#  type       :string
#  title      :string
#  project_id :integer
#  active     :boolean          default(FALSE), not null
#  properties :text
#  template   :boolean          default(FALSE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Service < ApplicationRecord
  serialize :properties, JSON

  after_initialize :initialize_properties
  after_commit :reset_updated_properties

  belongs_to :environment, inverse_of: :services, optional: true
  validates :environment_id, presence: true, unless: Proc.new {|service| service.template?}

  scope :active, -> {where(active: true)}
  enum service_type: %i(notification publish)

  def api_data
    {
        id: to_param,
        title: title,
        desc: description,
        active: active,
        help: help,
        fields: global_fields,
        service_type: service_type,
        updated_at: I18n.l(updated_at)
    }
  end

  def service_type
    Service.service_types[:notification]
  end

  def activated?
    active
  end

  def template?
    template
  end

  def category
    read_attribute(:category).to_sym
  end

  def initialize_properties
    self.properties = {} if properties.nil?
  end

  def title
    # implement inside child
  end

  def description
    # implement inside child
  end

  def help
    # implement inside child
  end

  def to_param
    # implement inside child
  end

  def fields
    []
  end

  def global_fields
    [
        {type: 'checkbox', name: 'active', title: 'Active', value: active}
    ] + fields.map {|field|
      if properties[field[:name]].present?
        field[:value]=properties[field[:name]]
      else
        field[:value]=''
      end
      field
    }
  end

  def execute(data)
    # implement inside child
  end

  # Provide convenient accessor methods
  # for each serialized property.
  # Also keep track of updated properties in a similar way as ActiveModel::Dirty
  def self.prop_accessor(*args)
    args.each do |arg|
      class_eval %{
        def #{arg}
          properties['#{arg}']
        end

        def #{arg}=(value)
          self.properties ||= {}
          updated_properties['#{arg}'] = #{arg} unless #{arg}_changed?
          self.properties['#{arg}'] = value
        end

        def #{arg}_changed?
          #{arg}_touched? && #{arg} != #{arg}_was
        end

        def #{arg}_touched?
          updated_properties.include?('#{arg}')
        end

        def #{arg}_was
          updated_properties['#{arg}']
        end
      }
    end
  end

  # Provide convenient boolean accessor methods
  # for each serialized property.
  # Also keep track of updated properties in a similar way as ActiveModel::Dirty
  def self.boolean_accessor(*args)
    self.prop_accessor(*args)

    args.each do |arg|
      class_eval %{
        def #{arg}?
          ActiveRecord::ConnectionAdapters::Column::TRUE_VALUES.include?(#{arg})
        end
      }
    end
  end

  # Returns a hash of the properties that have been assigned a new value since last save,
  # indicating their original values (attr => original value).
  # ActiveRecord does not provide a mechanism to track changes in serialized keys,
  # so we need a specific implementation for service properties.
  # This allows to track changes to properties set with the accessor methods,
  # but not direct manipulation of properties hash.
  def updated_properties
    @updated_properties ||= ActiveSupport::HashWithIndifferentAccess.new
  end

  def reset_updated_properties
    @updated_properties = nil
  end

  def self.available_services_names
    %w[
      fir
      bugly
      ding
    ]
  end

  def self.build_from_template(environment_id, template)
    service = template.dup
    service.template = false
    service.environment_id = environment_id
    service.created_at = template.created_at
    service.updated_at = template.updated_at
    service
  end

end
