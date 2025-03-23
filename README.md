# OneHand Simple App

Jednostavna iOS aplikacija koja omogućava interaktivno upravljanje slikama pomoću senzora pokreta uređaja.

## Funkcionalnosti

- Izbor slike iz galerije
- Interaktivno pomeranje slike pomoću nagiba uređaja
- Podrška za levoruke i desnoruke korisnike
- Zumiranje i rotacija slike
- Radijalni meni za brzi pristup funkcijama

## Tehnički detalji

- Razvijeno u SwiftUI
- Koristi CoreMotion za praćenje pokreta
- Minimalna veličina aplikacije (~1.4MB)
- Podržava iOS 15.0 i novije verzije

## Instalacija

1. Klonirajte repozitorijum
2. Otvorite `UhIH.xcodeproj` u Xcode-u
3. Izaberite ciljani uređaj ili simulator
4. Pritisnite Run (⌘R)

## Korišćenje

1. Pokrenite aplikaciju
2. Izaberite vašu dominantnu ruku
3. Izaberite sliku iz galerije
4. Koristite nagibe uređaja za pomeranje slike
5. Koristite gestikulacije za zumiranje i rotaciju

## Razvoj

Projekat je organizovan u sledeće direktorijume:
- `Views/` - SwiftUI view komponente
- `ViewModels/` - View modeli i logika
- `Components/` - Pregradne komponente
- `Screens/` - Glavni ekrani aplikacije

## Licenca

MIT License 