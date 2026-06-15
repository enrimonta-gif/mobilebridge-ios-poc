# Mobile Bridge iOS PoC v0.5

Quinto test iOS, sempre senza Mac fisico, compilando con GitHub Actions su runner macOS.

## Cosa fa

- Pair URL dal modulo `mobilebridge`.
- Login QR.
- Salvataggio sessione in UserDefaults.
- Recupero sessione al riavvio.
- Home minimale con statistiche di oggi.
- Pull-to-refresh.
- Ordini recenti.
- Dettaglio ordine.
- Cambio stato ordine.
- Nuove funzioni v0.5:
  - lista clienti da `get_customers`;
  - ricerca clienti;
  - lista prodotti da `get_products`;
  - ricerca prodotti / EAN;
  - immagini prodotto se disponibili;
  - sezione online/carrelli da `get_live_activity`.

## Cosa NON fa ancora

- Non installa su iPhone reale.
- Non usa TestFlight.
- Non usa firma/certificati Apple.
- Non ha QR scanner.
- Non modifica ancora prodotti da iOS.
- Non modifica ancora tracking/corriere da iOS.
- Non ha ancora notifiche push iOS.

## Come provarlo su GitHub

1. Carica il contenuto dello ZIP nel repo `mobilebridge-ios-poc`.
2. Se la cartella `.github` non compare, crea manualmente:
   `.github/workflows/ios-build.yml`
   e incolla il contenuto di `_COPY_THIS_TO_GITHUB_WORKFLOW_ios-build.yml`.
3. Vai su Actions.
4. Lancia `Build iOS proof of concept`.

Se la build passa, il prossimo step consigliato è una v0.6 più operativa: dettaglio/modifica prodotto oppure tracking ordine.
