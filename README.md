# Mobile Bridge iOS PoC v0.4

Quarto test iOS per proseguire la strada senza Mac fisico, compilando con GitHub Actions su runner macOS.

## Cosa fa

- Pair URL dal modulo `mobilebridge`.
- Login QR.
- Salvataggio sessione in UserDefaults.
- Recupero sessione al riavvio.
- Home minimale con statistiche di oggi.
- Pull-to-refresh sulla Home.
- Lista ordini recenti.
- Pull-to-refresh sulla lista ordini.
- Dettaglio ordine:
  - cliente;
  - stato;
  - totali;
  - indirizzo consegna;
  - prodotti;
  - corriere/tracking se disponibili;
  - storico stati.
- Nuova funzione v0.4:
  - lettura stati ordine da `get_orders_statuses`;
  - cambio stato ordine da dettaglio tramite `update_order_state`;
  - aggiornamento del dettaglio e della lista ordini dopo il cambio stato.

## Cosa NON fa ancora

- Non installa su iPhone reale.
- Non usa TestFlight.
- Non usa firma/certificati Apple.
- Non ha QR scanner.
- Non modifica ancora tracking/corriere da iOS.
- Non ha ancora clienti/prodotti/online-carrelli.

## Come provarlo su GitHub

1. Carica il contenuto dello ZIP nel repo `mobilebridge-ios-poc`.
2. Se la cartella `.github` non compare, crea manualmente:
   `.github/workflows/ios-build.yml`
   e incolla il contenuto di `_COPY_THIS_TO_GITHUB_WORKFLOW_ios-build.yml`.
3. Vai su Actions.
4. Lancia `Build iOS proof of concept`.

Se la build passa, il prossimo step consigliato è la v0.5 con clienti/prodotti oppure online-carrelli.
