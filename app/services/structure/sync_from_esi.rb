# frozen_string_literal: true

class Structure < ApplicationRecord
  class SyncFromESI < ApplicationService
    include ESIHelpers

    class Error < RuntimeError; end

    def initialize(structure_id, authorization)
      super

      @structure_id = structure_id
      @authorization = authorization
    end

    def call # rubocop:disable Metrics/AbcSize
      struct = Structure.find_by(id: structure_id)
      if struct&.esi_expires_at&.>= Time.zone.now
        logger.debug("ESI response for structure (#{struct.name}) #{struct.id} is not expired: #{struct.esi_expires_at.iso8601}") # rubocop:disable Metrics/LineLength
        return struct
      end

      struct_attrs = structure_attrs_from_esi
      struct ? struct.update!(struct_attrs) : struct = Structure.create!(struct_attrs.merge(id: structure_id))

      debug("Synced structure #{structure_id} from ESI")
      struct
    rescue ESI::Errors::ClientError => e
      msg = "Unable to sync structure #{structure_id} from ESI: #{e.message}"
      raise Error, msg, cause: e
    end

    private

    attr_reader :authorization, :structure_id

    def structure_attrs_from_esi
      esi_retriable do
        esi_authorize!(authorization)
        auth = { Authorization: "Bearer #{authorization.access_token}" }
        resp = esi.get_universe_structure_raw(structure_id: structure_id, headers: auth)
        expires = DateTime.parse(resp.headers['expires'])
        last_modified = DateTime.parse(resp.headers['last-modified'])
        data = resp.json

        Corporation::SyncFromESI.call(data['owner_id'])

        {
          esi_expires_at: expires,
          esi_last_modified_at: last_modified,
          id: structure_id,
          owner_id: data['owner_id'],
          name: data['name'],
          solar_system_id: data['solar_system_id'],
          type_id: data['type_id']
        }
      end
    rescue ESI::Errors::ForbiddenError, ESI::Errors::UnauthorizedError
      logger.error("Authorization for character #{authorization.character_id} is not allowed to read structure #{structure_id}")

      {
        esi_expires_at: nil,
        esi_last_modified_at: nil,
        id: structure_id,
        owner_id: nil,
        name: "Unknown Structure - #{structure_id}",
        solar_system_id: nil,
        type_id: nil
      }
    end
  end
end