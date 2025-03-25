# OneHand Simple App

Jednostavna iOS aplikacija koja omogućava interaktivno upravljanje slikama pomoću senzora pokreta uređaja.

## Funkcionalnosti

- Izbor slike iz galerije
- Interaktivno pomeranje slike pomoću nagiba uređaja
- Podrška za levoruke i desnoruke korisnike
- Zumiranje i rotacija slike
- Radijalni meni za brzi pristup funkcijama
- Automatsko sakrivanje UI elemenata nakon 5 sekundi neaktivnosti
- Fade animacije za glatke prelaze
- Precizno praćenje granica pomeranja slike
- Intuitivan Welcome Guide sa prilagođenim UI za obe orijentacije
- Optimizovan tok za izbor dominantne ruke

## Tehnički detalji

- Razvijeno u SwiftUI
- Koristi CoreMotion za praćenje pokreta
- Minimalna veličina aplikacije (~1.4MB)
- Podržava iOS 15.0 i novije verzije
- Optimizovano za performanse i glatke animacije
- Adaptivni UI za portrait i landscape orijentacije

## Instalacija

1. Klonirajte repozitorijum
2. Otvorite `UhIH.xcodeproj` u Xcode-u
3. Izaberite ciljani uređaj ili simulator
4. Pritisnite Run (⌘R)

## Korišćenje

1. Pokrenite aplikaciju
2. U landscape modu, prvo izaberite dominantnu ruku
3. Pratite Welcome Guide za upoznavanje sa funkcijama
4. Izaberite sliku iz galerije
5. Koristite nagibe uređaja za pomeranje slike
6. Koristite gestikulacije za zumiranje i rotaciju
7. UI elementi se automatski sakrivaju nakon 5 sekundi neaktivnosti
8. Tap bilo gde na ekranu prikazuje UI elemente
9. Koristite radijalni meni za brzi pristup funkcijama

## Razvoj

Projekat je organizovan u sledeće direktorijume:
- `Views/` - SwiftUI view komponente
- `ViewModels/` - View modeli i logika
- `Components/` - Pregradne komponente
- `Screens/` - Glavni ekrani aplikacije
- `Onboarding/` - Welcome Guide i onboarding komponente

## Licenca

MIT License 