# Mobile Bridge iOS PoC v0.8

Ottavo test iOS, sempre senza Mac fisico, compilando con GitHub Actions su runner macOS.

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
- Scanner barcode tracking.
- Nuova funzione v0.8:
  - scanner QR per il pairing;
  - pulsante “Scansiona QR del modulo” nella schermata di collegamento;
  - lettura QR con AVFoundation;
  - compilazione automatica del Pair URL;
  - collegamento automatico dopo la scansione.

## Cosa NON fa ancora

- Non installa su iPhone reale.
- Non usa TestFlight.
- Non usa firma/certificati Apple.
- Non modifica ancora prodotti da iOS.
- Non ha notifiche push iOS.

## Come provarlo su GitHub

1. Carica il contenuto dello ZIP nel repo `mobilebridge-ios-poc`.
2. Se la cartella `.github` non compare, crea manualmente:
   `.github/workflows/ios-build.yml`
   e incolla il contenuto di `_COPY_THIS_TO_GITHUB_WORKFLOW_ios-build.yml`.
3. Vai su Actions.
4. Lancia `Build iOS proof of concept`.

Se la build passa, il prossimo step può essere dettaglio/modifica prodotto.
