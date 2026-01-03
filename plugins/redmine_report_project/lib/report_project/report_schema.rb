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
    STATUSES = {
    # ===============================
    # 🔹 Statut commun
    # ===============================
    1   => :INITIALISATION,

    # ===============================
    # 🔹 Actions APS
    # ===============================
    66  => :ZONAGE,
    47  => :POINTAGE,
    60  => :NOTE_CALCULE,
    67  => :BOQ,
    68  => :EN_SIGNATURE,
    56  => :APS_APPROUVE_DO,
    45  => :SOUS_RESERVE_DIRA,
    88  => :RESERVE_DIRA_LEVEE,
    64  => :APS_APPROUVE_DIRA,
    69  => :BESOIN_EXPRIME,

    # ===================================
    # 🔹 Cité_DEV & Cité_Mod
    # ===================================
    70  => :SITE_SURVEY,
    76  => :PLAN_SCHEMA,
    77  => :DEVIS,
    78  => :APD_SIGNE_VALIDE,

    # ========================================
    # 🔹 4G / OLT / Extension GPON
    # ========================================
    51  => :ETUDE_RADIO,
    52  => :ETUDE_RADIO_VALIDEE,
    72  => :ETUDE_RADIO_NON_VALIDEE,
    53  => :ETUDE_TSSR,
    54  => :ETUDE_TSSR_VALIDEE,
    58  => :AUTORISATION,
    79  => :AUTORISATION_ACCORDEE,
    55  => :PREPARATION_SITE,
    80  => :SITE_PRET,
    49  => :DEMANDE_DOTATION,
    50  => :DOTATION_VALIDEE,
    39  => :DOTER,
    74  => :DEMANDE_INSTALLATION,
    75  => :INSTALLATION_ACCORDEE,
    40  => :INSTALLE,
    41  => :MES,
    57  => :PRET_A_L_EXPLOITATION,

    # ========================================
    # 🔹 PRESTATION
    # ========================================
    2   => :PHASE_ETUDE,
    3   => :PHASE_CONSULTATION,
    42  => :PRET_AU_LANCEMENT,
    4   => :DEBUT_EXECUTION,
    5   => :EN_PROGRESSION,
    6   => :EN_DIFFICULTE,
    7   => :A_L_ARRET,
    61  => :TRAVAUX_ACHEVES,
    9   => :SERVICE_FAIT,
    10  => :EN_TRAITEMENT,
    11  => :PAIEMENT_SOUS_RESERVE,
    12  => :PAIEMENT_VALIDE,
    46  => :FINALISEE,
    13  => :CLOTURE,

    71  => :EN_REALISATION,
    65  => :ACHEVE,

    # ===============================
    # 🔹 Phases projet
    # ===============================
    105 => :EN_EXECUTION,
    107 => :RECEPTIONNE,

    # ===============================
    # 🔹 Demandes / Validations
    # ===============================
    48  => :DEMANDE,
    43  => :VALIDE,
    44  => :PROGRAMME,
    59  => :DEMANDE_TRANSFERT,
    62  => :TRANSFERT_VALIDE,

    # ===============================
    # 🔹 Prospection / PA
    # ===============================
    81  => :PROSPECTION,
    82  => :EXPRESSION_BESOIN,
    83  => :ETUDE_FAISABILITE,
    84  => :ELABORATION_OFFRE,
    85  => :RECEPTION_BC,
    86  => :ENVOI_BC,
    87  => :LANCEMENT_OC_OP,
    89  => :RECENSEMENT_APPROUVE,
    113 => :CLASSEMENT_GEO,
    90  => :ESTIMATION,
    91  => :PA_VALIDE,

    # ===============================
    # 🔹 ODN
    # ===============================
    92  => :ODN_EN_TRAITEMENT,
    93  => :ODN_SOUS_RESERVE,
    94  => :ODN_APPROUVE,
    97  => :ODN_EDITION,
    95  => :ODN_TRANSMIS,
    104 => :ODN_TRANSMIS_MAIL,

    # ===============================
    # 🔹 Exceptions / Décisions
    # ===============================
    98  => :ANNULE_JUMELAGE,
    99  => :ACTION_APPROUVEE,

    # ===============================
    # 🔹 Commissions / Contrats
    # ===============================
    108 => :COMMISSION_GRE_A_GRE,
    100 => :COMMISSION_CDC,
    101 => :ETABLISSEMENT_CDC_CPT,
    103 => :CDC_CPT_APPROUVE,
    111 => :VISA_CCM_ACCORDEE,
    112 => :NEGOCIATION_EN_COURS,
    102 => :CONTRAT_NOTIFIE,
    109 => :GRE_A_GRE_REFUSE,
    110 => :GRE_A_GRE_APPROUVE
  }.freeze

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



