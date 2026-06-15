# Mobile Bridge iOS PoC v0.10

Decimo test iOS, sempre senza Mac fisico, compilando con GitHub Actions su runner macOS.

## Cosa fa

- Pair URL manuale e QR scanner pairing.
- Login/sessione.
- Home.
- Ordini, dettaglio ordine e cambio stato ordine.
- Clienti.
- Prodotti.
- Dettaglio/modifica prodotto.
- Online/carrelli.
- Corriere/tracking modificabili.
- Scanner barcode tracking.
- Nuova funzione v0.10:
  - icona Mobile Bridge integrata in `Assets.xcassets`;
  - `ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon`;
  - workflow GitHub che carica anche l’artifact `ios-simulator-app`.

## Cosa NON fa ancora

- Non installa su iPhone reale.
- Non usa TestFlight.
- Non usa firma/certificati Apple.
- Non ha notifiche push iOS.

## Come provarlo su GitHub

1. Carica il contenuto dello ZIP nel repo `mobilebridge-ios-poc`.
2. Se la cartella `.github` non compare, crea manualmente:
   `.github/workflows/ios-build.yml`
   e incolla il contenuto di `_COPY_THIS_TO_GITHUB_WORKFLOW_ios-build.yml`.
3. Vai su Actions.
4. Lancia `Build iOS proof of concept`.

Se la build passa, il passo successivo vero è preparare la strada TestFlight/firma Apple.
