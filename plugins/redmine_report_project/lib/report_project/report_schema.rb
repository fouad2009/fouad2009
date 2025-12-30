# frozen_string_literal: true

module ReportProject
  module ReportSchema

     # =====================================================
     # 🔹 Type Exercice 
     # =====================================================
      
      EXERCICES_TYPE = %i[pa hp rar].freeze

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
   
    STATES_CORE = [
  :planned,              # Action prévue (planifiée, non démarrée)
  :not_started,          # Créée mais pas encore entamée
  :study_in_progress,    # Étude en cours (APS / APD / faisabilité)
  :study_completed,      # Étude finalisée / validée
  :consultation,         # Phase de consultation / appel d’offres
  :committed,            # Action engagée (marché / BC / décision validée)
  :in_progress,          # Travaux / exécution en cours
  :completed,            # Travaux / action réalisés
  :odn_completed,        # ODN achevé / clôturé techniquement
  :sellable,             # Infrastructure vendable / commercialisable
  :global_stop,          # Arrêt global (blocage, suspension)
  :closed,               # Action clôturée administrativement

  # --- Phase site ---
  :site_preparation,     # Préparation du site (autorisation, logistique)
  :site_validated,       # Site validé et prêt (technique / administratif)

  # --- Équipement ---
  :equipment_request,    # Demande de dotation / équipement
  :installation_request, # Demande d’installation
  :request_approved,     # Demande approuvée
  :equipped,             # Équipement livré / installé
  :installed,            # Installation physique terminée

  # --- Service ---
  :service_preparation,  # Préparation de la prestation
  :service_committed,    # Prestation engagée
  :service_execution,    # Prestation en cours d’exécution
  :service_completed,    # Prestation achevée
  :service_activated,    # Mise en service (MES / activation)
  :in_operation          # En exploitation / en service
].freeze


 # =====================================================
 # 🔹 PARENTS PROJECTS
 # =====================================================
  
     PARENT_PROJECT = { DO_2019: 1, DO_2020: 2, DO_2021: 3, DO_2022: 4, DO_2023: 5,
                        DO_2024: 6, DO_2025: 7, DO_2026: 8,DG_PA: 10
                      } 

# ====================== orkflow par statuts ===============================
    
# ===============================
    # 🔹 Statut commun
# ===============================
    INITIALISATION          = 1 # tous sauf ODN_prestation, Extenstion 4G, OLT
# ===============================

# ===============================
#   Action   APS 
# ===============================
    ZONAGE                  = 66
    POINTAGE                = 47
    NOTE_CALCULE            = 60
    BOQ                     = 67
    EN_SIGNATURE            = 68
    APS_APPROUVE_DO         = 56
    SOUS_RESERVE_DIRA       = 45
    RESERVE_DIRA_LEVEE      = 88
    APS_APPROUVE_DIRA       = 64
    BESOIN_EXPRIME          = 69


# ===================================
#   Action Cité_DEV & Cité_Mod 
# ===================================
    
    SITE_SURVEY             = 70
    PLAN_SCHEMA             = 76
    DEVIS                   = 77
    APD_SIGNE_VALIDE        = 78

# ========================================
#   Actions 4G OLT & Extension Carte GPON
# =======================================
  ETUDE_RADIO             = 51 # statut 4G
  ETUDE_RADIO_VALIDEE     = 52 # statut 4G
  ETUDE_RADIO_NON_VALIDEE = 72 # statut 4G
  ETUDE_TSSR              = 53 # statut 4G
  ETUDE_TSSR_VALIDEE      = 54 # statut 4G
  AUTORISATION            = 58 # statut 4G, Canalisation,Pose FO, Pose FO Corporate
  AUTORISATION_ACCORDEE   = 79 # statut 4G
  PREPARATION_SITE        = 55 # statut OLT & 4G
  SITE_PRET               = 80 # statut 4G
  DEMANDE_DOTATION        = 49
  DOTATION_VALIDEE        = 50
  DOTER                   = 39 # statut OLT & Extenstion cartes GPON
  DEMANDE_INSTALLATION    = 74 # statut 4G
  INSTALLATION_ACCORDEE   = 75 # statut 4G
  INSTALLE                = 40
  MES                     = 41
  PRET_A_L_EXPLOITATION   = 57

# ========================================
#   Actions PRESTATION : 
#   Canalisation,Pose FO,Pose FO Coporate, ODN_prestation, Dépose_câble, 
#   Raccordement_client, Abris,Enegie primaire,socle 4G,Pylone,Mat
# =======================================

  # INITIALISATION
  PHASE_ETUDE             = 2
  PHASE_CONSULTATION      = 3
  PRET_AU_LANCEMENT       = 42
  # AUTORISATION : Canalisation et Pose FO,Pose FO Corporate
  DEBUT_EXECUTION         = 4
  EN_PROGRESSION          = 5
  EN_DIFFICULTE           = 6 
  A_L_ARRET               = 7
  TRAVAUX_ACHÈVES         = 61
  SERVICE_FAIT            = 9
  EN_TRAITEMENT           = 10
  PAIEMENT_SOUS_RESERVE   = 11
  PAIEMENT_VALIDE         = 12
  FINALISEE               = 46
  CLOTURE                = 13


    
    EN_REALISATION          = 71
    ACHEVE    = 65

    # ===============================
    # 🔹 PHASES PROJET
    # ===============================
    EN_EXECUTION            = 105
    RECEPTIONNE             = 107

    # ===============================
    # 🔹 DEMANDES / VALIDATIONS
    # ===============================
    DEMANDE                 = 48
    VALIDE                  = 43
    PROGRAMME               = 44
    DEMANDE_TRANSFERT       = 59
    TRANSFERT_VALIDE        = 62
   
    # ===============================
    # 🔹 PROSPECTION / PA
    # ===============================
    PROSPECTION             = 81
    EXPRESSION_BESOIN       = 82
    ETUDE_FAISABILITE       = 83
    ELABORATION_OFFRE       = 84
    RECEPTION_BC            = 85
    ENVOI_BC                = 86
    LANCEMENT_OC_OP         = 87
    RECENSEMENT_APPROUVE    = 89
    CLASSEMENT_GEO          = 113
    ESTIMATION              = 90
    PA_VALIDE               = 91

    # ===============================
    # 🔹 ODN
    # ===============================
    ODN_EN_TRAITEMENT       = 92
    ODN_SOUS_RESERVE        = 93
    ODN_APPROUVE            = 94
    ODN_EDITION             = 97
    ODN_TRANSMIS            = 95
    ODN_TRANSMIS_MAIL       = 104

    # ===============================
    # 🔹 EXCEPTIONS / DÉCISIONS
    # ===============================
    ANNULE_JUMELAGE         = 98
    ACTION_APPROUVEE        = 99

    # ===============================
    # 🔹 COMMISSIONS / CONTRATS
    # ===============================
    COMMISSION_GRE_A_GRE    = 108
    COMMISSION_CDC          = 100
    ETABLISSEMENT_CDC_CPT   = 101
    CDC_CPT_APPROUVE        = 103
    VISA_CCM_ACCORDEE       = 111
    NEGOCIATION_EN_COURS    = 112
    CONTRAT_NOTIFIE         = 102
    GRE_A_GRE_REFUSE        = 109
    GRE_A_GRE_APPROUVE      = 110

    # =====================================================
    # 🔹 Custom Fields  Redmine
    # =====================================================
    
CUSTOM_FIELDS_LIST = [
  6,    # Exercice
  24,   # Capacité accès ODN prévue
  27,   # Km/alvéole réalisé
  28,   # Capacité réalisée
  73,   # Dist- FO prévue KM
  74,   # Km/alvéole prévue
  83,   # Distance FO posée / KM
  217,  # Cana_Linéaire_Prévue
  218,  # Cana_Linéaire_Réalisée
  241,  # Accès cuivre raccordés
  242,  # Accès FTTH raccordés
  253,  # Scénario
  262,  # Splitter 1:8 Client engagé
  267,  # Budget notifié
  286,  # Date achèvement
  288,  # Accès cuivre prévu
  289,  # Accès FTTH prévu
  293,  # Commercialisable
  367   # Action
].freeze



  CUSTOM_FIELDS_NAME = 
      CUSTOM_FIELDS_CONFIG[:custom_fields].each_with_object({}) do |(name, cfg), h|
        h[name.to_sym] = [
          cfg[:id],
          cfg[:cast].to_sym 
          ]
       end.freeze

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
         STATES_CORE.each_with_object({}) do |state, states_hash|
            states_hash[state] =  EXERCICES_TYPE.each_with_object({}) do |exercice, ex_hash|
               ex_hash[exercice] = {count: 0, quantity: 0}
             end
         end
    end

  end
end

