# Funkcionalnost Dugmadi u Radijalnom Meniju

## Centralno Dugme
- **Izgled**: 
  - Krug sa ikonicom "plus" kada je meni zatvoren
  - Krug sa ikonicom "x" kada je meni otvoren
- **Funkcionalnost**:
  - Otvara/zatvara radijalni meni
  - Rotira se za 45° pri otvaranju
  - Animacija: spring (response: 0.3, dampingFraction: 0.7)

## Radijalna Dugmad

### 1. Zumiranje Iz (minus.magnifyingglass)
- **Izgled**: Krug sa ikonicom minus u lupi
- **Funkcionalnost**:
  - Dupli tap: Zumira na minimalnu veličinu
  - Dugo držanje: Kontinuirano zumira iz
  - Pusti prst: Zaustavlja zumiranje

### 2. Zumiranje Unutra (plus.magnifyingglass)
- **Izgled**: Krug sa ikonicom plus u lupi
- **Funkcionalnost**:
  - Dupli tap: Zumira na maksimalnu veličinu
  - Dugo držanje: Kontinuirano zumira unutra
  - Pusti prst: Zaustavlja zumiranje

### 3. Reset Slike (arrow.counterclockwise.circle)
- **Izgled**: Krug sa ikonicom strelice u krugu
- **Funkcionalnost**:
  - Jedan tap: Resetuje sliku na početno stanje
    - Vraća na početnu veličinu
    - Resetuje rotaciju
    - Resetuje poziciju
    - Isključuje praćenje pokreta

### 4. Rotacija U Smeru Kazaljke (arrow.clockwise)
- **Izgled**: Krug sa ikonicom strelice u smeru kazaljke
- **Funkcionalnost**:
  - Dupli tap: Rotira za 45° u smeru kazaljke
  - Dugo držanje: Kontinuirano rotira u smeru kazaljke
  - Pusti prst: Zaustavlja rotaciju

### 5. Rotacija Suprotno od Kazaljke (arrow.counterclockwise)
- **Izgled**: Krug sa ikonicom strelice suprotno od kazaljke
- **Funkcionalnost**:
  - Dupli tap: Rotira za 45° suprotno od kazaljke
  - Dugo držanje: Kontinuirano rotira suprotno od kazaljke
  - Pusti prst: Zaustavlja rotaciju

### 6. Praćenje Pokreta (move.3d)
- **Izgled**: Krug sa ikonicom 3D pomeranja
- **Funkcionalnost**:
  - Jedan tap: Uključuje/isključuje praćenje pokreta
  - Kada je uključeno:
    - Slika se pomera u skladu sa pokretima telefona
    - Osetljivost je prilagođena za levu/desnu ruku
    - Postoji deadzone za male pokrete
    - Pomeranje je ograničeno na maksimalne vrednosti

### 7. Podešavanja (slider.horizontal.3)
- **Izgled**: Krug sa ikonicom podešavanja
- **Funkcionalnost**:
  - Jedan tap: Otvara meni sa podešavanjima
  - U podešavanjima se može:
    - Izabrati ruka (leva/desna)
    - Izabrati prikazivanje Welcomme Guide
    - Izabrati Auto-hide Interface

## Opšte Napomene
- Sva dugmad imaju:
  - Senku za bolju vidljivost
  - Plavu ivicu
  - Polutransparentnu pozadinu
  - Animaciju pri otvaranju menija
- Pozicioniranje:
  - Za desnoruke: 70% od leve ivice ekrana
  - Za levoruke: 30% od leve ivice ekrana
  - Udaljenost od dna: 230 piksela
- Radijus menija: 90 piksela
- Animacije: spring sa delay-om za svako dugme 