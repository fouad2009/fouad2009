# lib/report_project/calculators/base.rb

#require_dependency 'report_project/report_schema'

module ReportProject
  module BaseClass
      class Base

         include ReportProject::ReportSchema

     # CF = ReportProject::ReportSchema::CUSTOM_FIELDS_NAME
      CF = CUSTOM_FIELDS_NAME

      # =========================
      # Normalisation des champs
      # =========================

def self.normalize_fields(issue)
  CF.each_with_object({}) do |(name, (field_id, cast)), h|
    unless issue.key?(field_id)
      h[name] = nil
      next
    end

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
        
        status = issue[:status_id]
        ratio  = issue[:done_ratio].to_i


      tracker_id = issue[:tracker_id]

# Création de variables lisibles (booléens)
   aps            = [29].include?(tracker_id)
   odn_dev        = [47].include?(tracker_id)
   odn_mod        = [58].include?(tracker_id)
   odn_service    = [60].include?(tracker_id)
   canalisation   = [4].include?(tracker_id)
   pose_fo        = [6].include?(tracker_id)
   olt            = [7].include?(tracker_id)
   extension_olt  = [42].include?(tracker_id)
   pa_4g          = [10].include?(tracker_id)
   depose_cable   = [22].include?(tracker_id)
   corporate_fo   = [52].include?(tracker_id)
   reservation_fo = [30].include?(tracker_id)
   pa_mod         = [65].include?(tracker_id)
   pa_dev        = [64].include?(tracker_id)
   pa_fo          = [67].include?(tracker_id)

        # Normalisation est extraction des valeurs des cfs de l'issue
        fields = normalize_fields(issue)
        
        # Champs normalisés
         capacite_acces_odn_prevue      = fields[:capacite_acces_odn_prevue].to_f
        km_alveole_realise             = fields[:km_alveole_realise].to_f
        capacite_realisee              = fields[:capacite_realisee].to_i
        distance_fo_prevue_km          = fields[:distance_fo_prevue_km].to_f
        km_alveole_prevue              = fields[:km_alveole_prevue].to_f
        distance_fo_posee_km           = fields[:distance_fo_posee_km].to_f
        acces_cuivre_raccordes         = fields[:acces_cuivre_raccordes].to_i
        acces_ftth_raccordes           = fields[:acces_ftth_raccordes].to_i
        splitter_1_8_client_engage     = fields[:splitter_1_8_client_engage].to_i
        budget_notifie                 = fields[:budget_notifie].to_f
        date_achevement                = fields[:date_achevement].to_i
        acces_cuivre_prevue            = fields[:acces_cuivre_prevue].to_i
        acces_ftth_prevue              = fields[:acces_ftth_prevue].to_i
        commercialisable               = fields[:commercialisable].to_i
        action                         = fields[:action].to_i

        #====================================
        # Mapping excercice selon le type
        # ====================================
        exercice_value = fields[:exercice].to_s  # toujours string pour inclue?

        exercice_RAR = exercice_value.include?('RAR-')
        exercice_HP  = exercice_value.include?('HP-')
        exercice_PA  = !exercice_RAR && !exercice_HP

        #====================================
        # Mapping scenario en booléens métier
        # ====================================
        scenario_value = fields[:scenario].to_i

        scenario_dev = scenario_value == 291
        scenario_mod = scenario_value == 292
        scenario_tdm = scenario_value == 293
        # logique métier ici...
     
      #--- common logic -----------------
begin
  # ===============================
  # Incrément des compteurs (PLANNED)
  # ===============================
  tracker_struct[:planned][:pa][:count]  += 1 if exercice_PA
  tracker_struct[:planned][:hp][:count]  += 1 if exercice_HP
  tracker_struct[:planned][:rar][:count] += 1 if exercice_RAR

  # ===============================
  # Incrément des quantités (PLANNED)
  # ===============================
  if  odn_dev || odn_mod || pa_dev || pa_mod
    tracker_struct[:planned][:pa][:quantity]  += capacite_acces_odn_prevue if exercice_PA
    tracker_struct[:planned][:hp][:quantity]  += capacite_acces_odn_prevue if exercice_HP
    tracker_struct[:planned][:rar][:quantity] += capacite_acces_odn_prevue if exercice_RAR

  elsif canalisation
    tracker_struct[:planned][:pa][:quantity]  += km_alveole_prevue if exercice_PA
    tracker_struct[:planned][:hp][:quantity]  += km_alveole_prevue if exercice_HP
    tracker_struct[:planned][:rar][:quantity] += km_alveole_prevue if exercice_RAR

  elsif pose_fo || corporate_fo || pa_fo
    tracker_struct[:planned][:pa][:quantity]  += distance_fo_prevue_km if exercice_PA
    tracker_struct[:planned][:hp][:quantity]  += distance_fo_prevue_km if exercice_HP
    tracker_struct[:planned][:rar][:quantity] += distance_fo_prevue_km if exercice_RAR

  elsif pa_4g
    tracker_struct[:planned][:pa][:quantity]  += 600 if exercice_PA
    tracker_struct[:planned][:hp][:quantity]  += 600 if exercice_HP
    tracker_struct[:planned][:rar][:quantity] += 600 if exercice_RAR
  end

  # ===============================
  # NOT STARTED
  # ===============================
  if status == INITIALISATION
    tracker_struct[:not_started][:pa][:count]  += 1 if exercice_PA
    tracker_struct[:not_started][:hp][:count]  += 1 if exercice_HP
    tracker_struct[:not_started][:rar][:count] += 1 if exercice_RAR

    if aps || odn_dev || odn_mod
      tracker_struct[:not_started][:pa][:quantity]  += capacite_acces_odn_prevue if exercice_PA
      tracker_struct[:not_started][:hp][:quantity]  += capacite_acces_odn_prevue if exercice_HP
      tracker_struct[:not_started][:rar][:quantity] += capacite_acces_odn_prevue if exercice_RAR

    elsif canalisation
      tracker_struct[:not_started][:pa][:quantity]  += km_alveole_prevue if exercice_PA
      tracker_struct[:not_started][:hp][:quantity]  += km_alveole_prevue if exercice_HP
      tracker_struct[:not_started][:rar][:quantity] += km_alveole_prevue if exercice_RAR

    elsif pose_fo || corporate_fo
      tracker_struct[:not_started][:pa][:quantity]  += distance_fo_prevue_km if exercice_PA
      tracker_struct[:not_started][:hp][:quantity]  += distance_fo_prevue_km if exercice_HP
      tracker_struct[:not_started][:rar][:quantity] += distance_fo_prevue_km if exercice_RAR

    elsif pa_4g
      tracker_struct[:not_started][:pa][:quantity]  += 600 if exercice_PA
      tracker_struct[:not_started][:hp][:quantity]  += 600 if exercice_HP
      tracker_struct[:not_started][:rar][:quantity] += 600 if exercice_RAR
    end
  end

rescue StandardError => e
  # ===============================
  # Capture des erreurs
  # ===============================
  Rails.logger.error "Type      : #{e.message}"
  puts " Exercice: #{exercice_value.inspect}"
  puts "tracker: #{tracker_id}" 
  # Optionnel : re-raise si tu veux bloquer le traitement
  raise e
end


        
     
 end  # ---- MLethod process ----




    end
  end
end
