# ## Schema Information
#
# Table name: `locations`
#
# ### Columns
#
# Name                  | Type               | Attributes
# --------------------- | ------------------ | ---------------------------
# **`locatable_type`**  | `string`           | `not null`
# **`name`**            | `text`             | `not null`
# **`created_at`**      | `datetime`         | `not null`
# **`updated_at`**      | `datetime`         | `not null`
# **`locatable_id`**    | `bigint`           | `not null, primary key`
#
# ### Indexes
#
# * `index_locations_on_locatable`:
#     * **`locatable_type`**
#     * **`locatable_id`**
# * `index_unique_locations` (_unique_):
#     * **`locatable_id`**
#     * **`locatable_type`**
#
class Location < ApplicationRecord
  self.primary_key = :locatable_id

  belongs_to :locatable, polymorphic: true

  has_many :market_locations_as_source, class_name: 'MarketLocation', foreign_key: :source_location_id, dependent: :restrict_with_exception
  has_many :markets, through: :market_locations_as_source
end
