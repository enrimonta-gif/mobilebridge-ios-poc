# Mobile Bridge iOS PoC v0.7

Settimo test iOS, sempre senza Mac fisico, compilando con GitHub Actions su runner macOS.

## Cosa fa

- Pair URL dal modulo `mobilebridge`.
- Login QR.
- Salvataggio sessione in UserDefaults.
- Recupero sessione al riavvio.
- Home minimale.
- Ordini, dettaglio ordine e cambio stato ordine.
- Clienti.
- Prodotti.
- Online/carrelli.
- Corriere/tracking modificabili.
- Nuova funzione v0.7:
  - scanner barcode iOS per compilare il tracking;
  - permesso camera `NSCameraUsageDescription`;
  - lettura barcode con AVFoundation;
  - il codice letto viene copiato nel campo tracking.

## Cosa NON fa ancora

- Non installa su iPhone reale.
- Non usa TestFlight.
- Non usa firma/certificati Apple.
- Il QR scanner per pairing non è ancora presente.
- Non modifica ancora prodotti da iOS.
- Non ha notifiche push iOS.

## Come provarlo su GitHub

1. Carica il contenuto dello ZIP nel repo `mobilebridge-ios-poc`.
2. Se la cartella `.github` non compare, crea manualmente:
   `.github/workflows/ios-build.yml`
   e incolla il contenuto di `_COPY_THIS_TO_GITHUB_WORKFLOW_ios-build.yml`.
3. Vai su Actions.
4. Lancia `Build iOS proof of concept`.

Se la build passa, il prossimo step può essere dettaglio/modifica prodotto oppure QR scanner per pairing.
