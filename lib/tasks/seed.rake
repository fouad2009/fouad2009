puts "▶️  Exécution des seeds du plugin prestation_manager..."
puts "📦  Chargement des prestataires..."

prestataires = [
  { nom: "Société ALPHA", identifiant: "ALP-001", nif: "100100100", registre_commerce: "RC-ALP-2025-A" },
  { nom: "Bureau BETA", identifiant: "BET-002", nif: "200200200", registre_commerce: "RC-BET-2025-B" },
  { nom: "Entreprise GAMMA", identifiant: "GAM-003", nif: "300300300", registre_commerce: "RC-GAM-2025-C" },
  { nom: "SARL DELTA", identifiant: "DEL-004", nif: "400400400", registre_commerce: "RC-DEL-2025-D" },
  { nom: "Technologies EPSILON", identifiant: "EPS-005", nif: "500500500", registre_commerce: "RC-EPS-2025-E" },
  { nom: "Services ZETA", identifiant: "ZET-006", nif: "600600600", registre_commerce: "RC-ZET-2025-F" },
  { nom: "Engineering ETA", identifiant: "ETA-007", nif: "700700700", registre_commerce: "RC-ETA-2025-G" },
  { nom: "Consulting THETA", identifiant: "THE-008", nif: "800800800", registre_commerce: "RC-THE-2025-H" },
  { nom: "Industrie IOTA", identifiant: "IOT-009", nif: "900900900", registre_commerce: "RC-IOT-2025-I" },
  { nom: "Groupe KAPPA", identifiant: "KAP-010", nif: "101010101", registre_commerce: "RC-KAP-2025-J" }
]

prestataires.each do |data|
  Prestataire.create!(data)
end

puts "✔️  Seed terminé avec succès !"

