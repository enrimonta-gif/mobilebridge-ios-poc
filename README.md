# Mobile Bridge iOS PoC v0.2

Secondo test iOS senza Mac fisico, usando GitHub Actions su runner macOS.

## Cosa fa

- App SwiftUI minimale ma già con flusso più simile ad Android.
- Campo Pair URL.
- Lettura del payload `pairing` dal modulo PrestaShop.
- Login QR verso endpoint `call_function=login`.
- Salvataggio sessione in `UserDefaults`.
- Recupero sessione al riavvio.
- Home minimale.
- Chiamata dashboard `get_store_stats` con periodo `today`.
- Pull-to-refresh nella Home.

## Cosa NON fa ancora

- Non ha ancora QR scanner.
- Non installa su iPhone reale.
- Non usa TestFlight.
- Non ha ancora lista ordini/dettaglio ordine.
- Non ha push notification.

## Come provarlo su GitHub

1. Usa il repository già creato per il PoC iOS, oppure creane uno nuovo privato.
2. Carica il contenuto di questo ZIP nella root del repo.
3. Se la cartella `.github` non compare, crea manualmente:
   `.github/workflows/ios-build.yml`
   e incolla il contenuto di `_COPY_THIS_TO_GITHUB_WORKFLOW_ios-build.yml`.
4. Vai su Actions.
5. Lancia `Build iOS proof of concept`.

Se la build passa anche qui, il prossimo step sarà la lista ordini.

## Nota importante

Questa build è per iOS Simulator e non è firmata. Serve solo a confermare che il codice SwiftUI compila. Per installarla su iPhone reale serviranno Apple Developer, firma e TestFlight.
