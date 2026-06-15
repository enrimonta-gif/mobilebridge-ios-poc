# Mobile Bridge iOS PoC v0.9

Nono test iOS, sempre senza Mac fisico, compilando con GitHub Actions su runner macOS.

## Cosa fa

- Pair URL manuale e QR scanner pairing.
- Login/sessione.
- Home.
- Ordini, dettaglio ordine e cambio stato ordine.
- Clienti.
- Prodotti.
- Online/carrelli.
- Corriere/tracking modificabili.
- Scanner barcode tracking.
- Nuova funzione v0.9:
  - apertura dettaglio prodotto dalla lista prodotti;
  - lettura dettaglio da `get_product_info`;
  - prezzo IVA incluso modificabile;
  - quantità modificabile;
  - attivo/non attivo modificabile;
  - supporto base per combinazioni;
  - salvataggio tramite `update_product`.

## Cosa NON fa ancora

- Non installa su iPhone reale.
- Non usa TestFlight.
- Non usa firma/certificati Apple.
- Non ha notifiche push iOS.
- Il salvataggio prodotti è volutamente minimale: prezzo, quantità e stato attivo.

## Come provarlo su GitHub

1. Carica il contenuto dello ZIP nel repo `mobilebridge-ios-poc`.
2. Se la cartella `.github` non compare, crea manualmente:
   `.github/workflows/ios-build.yml`
   e incolla il contenuto di `_COPY_THIS_TO_GITHUB_WORKFLOW_ios-build.yml`.
3. Vai su Actions.
4. Lancia `Build iOS proof of concept`.

Se la build passa, l’app iOS PoC ha ormai quasi tutte le sezioni operative principali.
