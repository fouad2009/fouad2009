# frozen_string_literal: true

module ReportProject
  module ReportSchema

    # =====================================================
    # 🔹 Metrics (champs de mesure pour chaque état)
    # =====================================================
    # count : nombre d'éléments
    # quantity : consistance ou quantité associée
    METRIC_FIELDS = %i[
      count
      quantity
    ].freeze

     # =====================================================
     # 🔹 Metrics Entête de la structure 
     # =====================================================
     # entête de la structure

    STATES_HEADER = %i[
        project_id,
        tracker_id,
        category,
        position
    ].freeze


    # =====================================================
    # 🔹 États du workflow (workflow states)
    # =====================================================
    # Chaque état représente une étape dans le processus projet/tracker.
    # Ces états seront utilisés pour initialiser la structure de chaque tracker.
    
    STATES_CORE = %i[
      planned           # prévu
      planned_hp        # prévu HP
      not_started       # non entamé
      study_in_progress # étude en cours
      study_completed   # étude finalisée
      consultation      # consultation
      committed         # engagé
      in_progress_pa    # en cours PA
      in_progress_hp    # en cours HP
      in_progress_rar   # en cours RAR
      completed_pa      # réalisé PA
      completed_hp      # réalisé HP
      completed_rar     # réalisé RAR
      odn_completed     # ODN achevé
      sellable          # vendable
      global_stop       # arrêt global
      closed            # clôturé
      site_preparation  # préparation site
      site_validated    # site validé
      equipment_request      # demande dotation
      installation_request   # demande installation
      request_approved       # dotation validée
      equipped          # dotation réalisée
      installed         # installé
      service_activated # MES / service activé
      in_operation      # en exploitation
      service_preparation  # prestation préparation
      service_committed    # prestation engagée
      service_execution    # prestation en cours/exécution
      service_completed    # prestation achevée
    ].freeze


     # =====================================================
     # 🔹 PARENTS PROJECTS
     # =====================================================
  
     PARENT_PROJECT = { DO_2019: 1, DO_2020: 2, DO_2021: 3, DO_2022: 4, DO_2023: 5,
                        DO_2024: 6, DO_2025: 7, DO_2026: 8,DG_PA: 10
                      } 



    # =====================================================
    # 🔹 Trackers Redmine
    # =====================================================
    # Association entre les noms logiques et les IDs Redmine.
    TRACKERS = {
      canalisation:   4,
      pose_fo:        6,
      odn_dev:       47,
      odn_mod:       58,
      pa_4g:         10,
      rar_4g:        10,
      aps:           29,
      odn_service:   60
    }.freeze

    # =====================================================
    # 🔹 Custom Fields  Redmine
    # =====================================================
      
    CUSTOM_FIELDS_LIST = %i[
     6 #-- Exercice
     24 #-- Capacité accès ODN prévue
     27 #-- Km/alvéole réalisé
     28 #-- Capacité réalisée
     73 #-- Dist- FO prévue KM
     74 #-- Km/alvéole prévue
     83 #-- Distance FO posée /KM
     241 #-- Accès_cuivre_raccordés
     242 #-- Accés_FTTH_raccordés
     253 #-- Scénario
     262 #-- Spliter_1:8_Client_engagé
     267 #-- Budget_notifié
     286 #-- Date_achèvement
     288 #-- Acces_cuivre_prevue
     289 #-- Acces_FTTH_prévue
     293 #-- Commercialisable
    367 #-- Action ].freeze


    # =====================================================
    # 🔹 Catégories de projet
    # =====================================================
    # Définition des types de projet pour classification
   
    CATEGORIES = %i[
      development
      modernization
      maintenance
      densification
      corporate
    ].freeze

    # =====================================================
    # 🔹 Construction des métriques pour chaque état
    # =====================================================
    # Retourne un hash { état => { count: 0, quantity: 0 } }
    # Ce sera le “grand tableau” initialisé à zéro pour chaque tracker
  
     def self.build_state_metrics
       # Initialiser les champs de header à nil
       header_hash = STATES_HEADER.index_with { nil }

       # Initialiser les états avec metrics
       states_hash = STATES_CORE.each_with_object({}) do |state, hash|
        hash[state] = METRIC_FIELDS.index_with { 0 }
       end

      # Fusionner header + states
      header_hash.merge(states_hash)
   end


    # =====================================================
    # 🔹 Structure d’un tracker
    # =====================================================
    # Chaque tracker contient :
    # - project_id
    # - tracker_id
    # - category (optionnelle)
    # - position (optionnelle)
    # - et les métriques pour tous les états initialisées à zéro
    def self.build_tracker_struct(project_id:, tracker_id:, category: nil, position: nil)
      {
        project_id: project_id,
        tracker_id: tracker_id,
        category: category,
        position: position
      }.merge(build_state_metrics)
    end

    # =====================================================
    # 🔹 Structure complète du projet
    # =====================================================
    # Retourne un hash : tracker_id => tracker_struct
    # Chaque projet contient tous les trackers initialisés
    def self.build_project_struct(project_id)
      TRACKERS.each_value.each_with_object({}) do |tracker_id, hash|
        hash[tracker_id] = build_tracker_struct(
          project_id: project_id,
          tracker_id: tracker_id
        )
      end
    end

  end
end

