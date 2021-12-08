# frozen_string_literal: true

class Contract < ApplicationRecord
  class SyncItemsFromESIWorker < ApplicationWorker
    sidekiq_options retry: 5, lock: :until_and_while_executing, on_conflict: :log

    sidekiq_throttle(
      threshold: { limit: 20, period: 10.seconds }
    )

    def perform(contract_id)
      contract = Contract.find(contract_id)
      # Retriable.retriable on: [ESI::Errors::EveServerError], tries: 5, max_elapsed_time: 180, base_interval: 10.0 do
        Contract::SyncItemsFromESI.call(contract)
      # end
    rescue ActiveRecord::RecordNotFound
      debug "Contract #{contract_id} no longer exists"
    end
  end
end
