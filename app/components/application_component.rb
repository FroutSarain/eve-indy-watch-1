# frozen_string_literal: true

class ApplicationComponent < ViewComponent::Base
  delegate :heroicon, :turbo_frame_tag, to: :helpers
end
