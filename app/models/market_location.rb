# ## Schema Information
#
# Table name: `market_locations`
#
# ### Columns
#
# Name                 | Type               | Attributes
# -------------------- | ------------------ | ---------------------------
# **`location_type`**  | `string`           | `not null`
# **`created_at`**     | `datetime`         | `not null`
# **`updated_at`**     | `datetime`         | `not null`
# **`location_id`**    | `bigint`           | `not null`
# **`market_id`**      | `bigint`           | `not null`
#
# ### Indexes
#
# * `index_market_locations_on_location`:
#     * **`location_type`**
#     * **`location_id`**
# * `index_market_locations_on_market_id`:
#     * **`market_id`**
#
# ### Foreign Keys
#
# * `fk_rails_...`:
#     * **`market_id => markets.id`**
#
class MarketLocation < ApplicationRecord
  belongs_to :location, polymorphic: true
  belongs_to :market, inverse_of: :market_locations
end
