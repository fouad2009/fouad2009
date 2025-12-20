module PrestationManager
  module Patches
    module ApplicationControllerPatch
      def authorize(ctrl = params[:controller], action = params[:action], global = false)
        Rails.logger.info "=== AUTHORIZE DEBUG (PrestationManager) ==="
        Rails.logger.info "User: #{User.current.login}"
        Rails.logger.info "Controller: #{ctrl}"
        Rails.logger.info "Action: #{action}"
        Rails.logger.info "Project: #{@project&.identifier}"
        Rails.logger.info "Global: #{global}"

        super
      end
    end
  end
end

