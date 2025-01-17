# frozen_string_literal: true

# ## Schema Information
#
# Table name: `groups`
#
# ### Columns
#
# Name               | Type               | Attributes
# ------------------ | ------------------ | ---------------------------
# **`id`**           | `bigint`           | `not null, primary key`
# **`name`**         | `text`             | `not null`
# **`published`**    | `boolean`          | `not null`
# **`created_at`**   | `datetime`         | `not null`
# **`updated_at`**   | `datetime`         | `not null`
# **`category_id`**  | `bigint`           | `not null`
#
# ### Indexes
#
# * `index_groups_on_category_id`:
#     * **`category_id`**
#
# ### Foreign Keys
#
# * `fk_rails_...`:
#     * **`category_id => categories.id`**
#
class Group < ApplicationRecord
  include PgSearch::Model

  multisearchable against: %i[name category_name]

  belongs_to :category, inverse_of: :groups

  has_many :types, inverse_of: :group, dependent: :restrict_with_exception

  delegate :name, to: :category, prefix: true
end
