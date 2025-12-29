require "learnosity/sdk/version"
require "learnosity/sdk/request/data_api"
require "learnosity/sdk/utils/uuid"

module Learnosity
  module Sdk
    # Export DataApi class for convenient access
    DataApi = Request::DataApi

    # Export Uuid utility for convenient access
    Uuid = Utils::Uuid
  end
end

# vim: sw=2
