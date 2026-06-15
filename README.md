# Mobile Bridge iOS PoC v0.1

Primo test iOS per verificare la strada senza Mac fisico, usando GitHub Actions su runner macOS.

## Cosa fa

- App SwiftUI minimale.
- Campo Pair URL.
- Chiamata HTTP al Pair URL del modulo `mobilebridge`.
- Build iOS Simulator senza firma.

## Come provarlo

1. Crea un repo vuoto, ad esempio `mobilebridge-ios-poc`.
2. Carica il contenuto di questo ZIP nella root.
3. Se `.github` non compare, crea manualmente `.github/workflows/ios-build.yml` e incolla `_COPY_THIS_TO_GITHUB_WORKFLOW_ios-build.yml`.
4. Vai su Actions e lancia `Build iOS proof of concept`.

Se la build passa, abbiamo confermato che GitHub/macOS compila il progetto iOS.
