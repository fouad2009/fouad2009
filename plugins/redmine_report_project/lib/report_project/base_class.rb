module ReportProject
  module BaseClass

    # =========================
    # Context métier partagé
    # =========================
    Context = Struct.new(
      :tracker_id,
      :status,
      :ratio,

      :capacite_acces_odn_prevue,
      :km_alveole_realise,
      :capacite_realisee,
      :distance_fo_prevue_km,
      :km_alveole_prevue,
      :distance_fo_posee_km,
      :acces_cuivre_raccordes,
      :acces_ftth_raccordes,
      :splitter_1_8_client_engage,
      :budget_notifie,
      :date_achevement,
      :acces_cuivre_prevue,
      :acces_ftth_prevue,
      :commercialisable,
      :action,

      :exercice_RAR,
      :exercice_HP,
      :exercice_PA,

      :scenario_dev,
      :scenario_mod,
      :scenario_tdm,

      keyword_init: true
    )

    class Base
      include ReportProject::ReportSchema

      CF = CUSTOM_FIELDS_NAME

      # =========================
      # Normalisation des champs
      # =========================
      def self.normalize_fields(issue)
        CF.each_with_object({}) do |(name, (field_id, cast)), h|
          value = issue[field_id]

          h[name] =
            if value.nil?
              nil
            elsif value.respond_to?(cast)
              value.public_send(cast)
            else
              value
            end
        end
      end

      # =========================
      # Traitement principal
      # =========================
      def self.process(issue, tracker_struct)
        fields = normalize_fields(issue)

        exercice_value = fields[:exercice].to_s
        exercice_RAR   = exercice_value.include?('RAR-')
        exercice_HP    = exercice_value.include?('HP-')
        exercice_PA    = !exercice_RAR && !exercice_HP

        scenario_value = fields[:scenario].to_i
        scenario_dev   = scenario_value == 291
        scenario_mod   = scenario_value == 292
        scenario_tdm   = scenario_value == 293

        Context.new(
          tracker_id:                 issue[:tracker_id],
          status_id:                     issue[:status_id],
          ratio:                      issue[:done_ratio].to_i,

          capacite_acces_odn_prevue:  fields[:capacite_acces_odn_prevue].to_f,
          km_alveole_realise:         fields[:km_alveole_realise].to_f,
          capacite_realisee:          fields[:capacite_realisee].to_i,
          distance_fo_prevue_km:      fields[:distance_fo_prevue_km].to_f,
          km_alveole_prevue:          fields[:km_alveole_prevue].to_f,
          distance_fo_posee_km:       fields[:distance_fo_posee_km].to_f,
          acces_cuivre_raccordes:     fields[:acces_cuivre_raccordes].to_i,
          acces_ftth_raccordes:       fields[:acces_ftth_raccordes].to_i,
          splitter_1_8_client_engage: fields[:splitter_1_8_client_engage].to_i,
          budget_notifie:             fields[:budget_notifie].to_f,
          date_achevement:            fields[:date_achevement].to_i,
          acces_cuivre_prevue:        fields[:acces_cuivre_prevue].to_i,
          acces_ftth_prevue:          fields[:acces_ftth_prevue].to_i,
          commercialisable:           fields[:commercialisable].to_i,
          action:                     fields[:action].to_i,

          exercice_RAR:               exercice_RAR,
          exercice_HP:                exercice_HP,
          exercice_PA:                exercice_PA,

          scenario_dev:               scenario_dev,
          scenario_mod:               scenario_mod,
          scenario_tdm:               scenario_tdm
        )
      end
    end
  end
end
