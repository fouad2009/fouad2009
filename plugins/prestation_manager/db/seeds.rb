# plugins/prestation_manager/db/seeds.rb

puts "📦 Chargement des prestataires..."

prestataires = [
  { nom: "Société ALPHA",      identifiant: "ALP-001", nif: "100100100", rc: "01/123456A" },
  { nom: "Entreprise BETA",    identifiant: "BET-002", nif: "200200200", rc: "02/654321B" },
  { nom: "GAMMA Services",     identifiant: "GAM-003", nif: "300300300", rc: "03/987654C" },
  { nom: "DELTA Construction", identifiant: "DEL-004", nif: "400400400", rc: "04/789456D" },
  { nom: "OMEGA Network",      identifiant: "OMG-005", nif: "500500500", rc: "05/321789E" },
  { nom: "ATLAS Travaux",      identifiant: "ATL-006", nif: "600600600", rc: "06/147258F" },
  { nom: "NOVA Telecom",       identifiant: "NOV-007", nif: "700700700", rc: "07/369258G" },
  { nom: "ORION Projets",      identifiant: "ORI-008", nif: "800800800", rc: "08/852147H" },
  { nom: "SOLARIS Tech",       identifiant: "SOL-009", nif: "900900900", rc: "09/951753I" },
  { nom: "ZENITH Batiment",    identifiant: "ZEN-010", nif: "101010101", rc: "10/123789J" }
]

prestataires.each do |data|
  Prestataire.find_or_create_by!(identifiant: data[:identifiant]) do |p|
    p.nom  = data[:nom]
    p.nif  = data[:nif]
    p.rc   = data[:rc]
  end
end

puts "✔️ 10 prestataires importés avec succès."

