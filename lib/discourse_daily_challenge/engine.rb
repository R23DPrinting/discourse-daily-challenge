# frozen_string_literal: true

module ::DiscourseDailyChallenge
  class Engine < ::Rails::Engine
    engine_name PLUGIN_NAME
    isolate_namespace DiscourseDailyChallenge
  end
end
