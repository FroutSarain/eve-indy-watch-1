class MarketOrder < ApplicationRecord
  class CompleteBatch < ApplicationService
    def initialize(batch)
      super

      @batch = batch
    end

    def call
      return if batch.completed?

      return unless batch.pages.all? { |p| p.imported? }

      batch.transaction do
        batch.update!(completed_at: Time.zone.now)

        if location.orders_updated_at.nil? || (location.orders_updated_at && location.orders_updated_at <= time)
          location.update!(
            esi_market_orders_last_modified_at: time,
            orders_updated_at: time
          )
        end

        location_ids = MarketOrder.distinct(:location_id).where(time: time).pluck(:location_id)
        @markets = Market.joins(:market_locations).where("market_locations.location_id IN (?)", location_ids)
        fitting_markets = []
        markets.each do |market|
          if market.orders_updated_at.nil? || (market.orders_updated_at && market.orders_updated_at <= time)
            market.update!(orders_updated_at: time)
          end
          market.aggregate_type_stats!(time)

          fitting_markets << market if market.trade_hub || market.owner
        end

        args = fitting_markets.each_with_object([]) do |market, a|
          scope = market.owner ? market.owner.fittings.kept : Fitting.kept
          scope.find_each do |fitting|
            a << [market.id, fitting.id, time]
          end
        end
        Market::AggregateFittingStatsWorker.perform_bulk(args)
      end

      markets.map(&:id)
    end

    private

    attr_reader :batch, :markets

    delegate :location, :time, to: :batch
  end
end