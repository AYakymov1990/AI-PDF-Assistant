# AI PDF Assistant — Mobilny asystent do pracy z plikami PDF


**AI PDF Assistant** to prototyp aplikacji mobilnej stworzonej we Flutterze w celu demonstracji umiejętności integracji generatywnej sztucznej inteligencji (LLM) z aplikacjami mobilnymi. Aplikacja pozwala użytkownikowi wgrać plik PDF i prowadzić z nim dialog: zadawać pytania dotyczące treści dokumentu i otrzymywać odpowiedzi wygenerowane przez sieć neuronową.

Projekt ten powstał jako zadanie testowe, aby pokazać praktyczne umiejętności w tworzeniu oprogramowania z podejściem "AI-native", gdzie sztuczna inteligencja jest kluczowym komponentem produktu.

## 🚀 Główne funkcje

*   **Wgrywanie PDF:** Użytkownik może wybrać i wgrać dowolny plik PDF z pamięci urządzenia.
*   **Ekstrakcja tekstu:** Aplikacja automatycznie wyodrębnia całą treść tekstową z dokumentu w celu jej późniejszej analizy.
*   **Interaktywny czat:** Użytkownik może zadawać pytania w języku naturalnym w interfejsie przypominającym komunikator.
*   **Odpowiedzi oparte na AI:** Aplikacja wykorzystuje model Google Gemini do generowania odpowiedzi na podstawie kontekstu wyodrębnionego z dokumentu PDF (mechanizm RAG).
*   **Asynchroniczne przetwarzanie:** Wskaźniki ładowania informują użytkownika o przetwarzaniu pliku i generowaniu odpowiedzi.

## 🛠️ Stos technologiczny

Projekt został zbudowany z uwzględnieniem nowoczesnych praktyk i technologii wymienionych w ofercie pracy.

*   **Framework:** Flutter 3.x
*   **Język:** Dart 3.x
*   **Architektura:** **Clean Architecture** (Czysta Architektura) z wyraźnym podziałem na warstwy:
    *   **Presentation (UI):** Wyświetlanie interfejsu i obsługa interakcji z użytkownikiem.
    *   **Domain:** Logika biznesowa, encje i przypadki użycia (use cases).
    *   **Data:** Repozytoria i źródła danych (lokalne i zdalne).
*   **Zarządzanie stanem:** **Riverpod** (`flutter_riverpod`) do deklaratywnego, reaktywnego i skalowalnego zarządzania stanem.
*   **Integracja z AI:**
    *   **Google Gemini Pro** za pomocą pakietu `google_generative_ai`.
    *   Zaimplementowano podstawowy mechanizm **RAG** (Retrieval-Augmented Generation), gdzie pełny tekst dokumentu jest przekazywany jako kontekst dla LLM.
*   **Praca z plikami:**
    *   `file_picker` do wybierania plików.
    *   `syncfusion_flutter_pdf` do parsowania i ekstrakcji tekstu z PDF.
*   **Zapytania sieciowe:** Pakiet `http` (jako alternatywna implementacja `AIDataSource` ).
*   **Pakiety pomocnicze:** `uuid` do generowania unikalnych ID.

## 🏛️ Decyzje architektoniczne

Kluczową cechą projektu jest jego architektura, zaprojektowana z myślą o elastyczności i skalowalności.

1.  **Abstrakcyjna warstwa danych:** Logika pobierania odpowiedzi od AI została wyodrębniona za interfejs `AIDataSource`. Pozwala to na łatwą wymianę implementacji. W kodzie znajdują się przykłady:
    *   `GeminiAIDataSource`: Bezpośrednia integracja z API Google Gemini.
    *   `ManusAIDataSource` (koncepcja): Przykład implementacji przez bramkę API (API Gateway), co zwiększa bezpieczeństwo (ukrywa klucz API na backendzie) i elastyczność (pozwala na zmianę dostawcy LLM po stronie serwera bez aktualizacji aplikacji).

2.  **Niezmienny stan (Immutable State):** Stan ekranu czatu jest zarządzany przez `StateNotifier` i niemutowalną klasę `ChatState`, co sprawia, że przepływ danych jest przewidywalny i łatwy do debugowania.

3.  **Podział według funkcji (Features):** Struktura projektu jest zorganizowana według modułów funkcjonalnych, co upraszcza nawigację i utrzymanie kodu.

## ⚙️ Jak uruchomić projekt

1.  **Sklonuj repozytorium:**
    ```bash
    git clone https://github.com/twoja-nazwa-uzytkownika/ai_pdf_assistant.git
    cd ai_pdf_assistant
    ```

2.  **Zainstaluj zależności:**
    ```bash
    flutter pub get
    ```

3.  **Uzyskaj klucz API:**
    *   Przejdź do [Google AI Studio](https://aistudio.google.com/app/apikey ).
    *   Utwórz i skopiuj swój klucz API.

4.  **Dodaj klucz API do kodu:**
    *   Otwórz plik `lib/features/chat/data/datasources/ai_datasource.dart`.
    *   Znajdź implementację `GeminiAIDataSource`.
    *   Wklej swój klucz w miejsce `YOUR_API_KEY_HERE`.

    ```dart
    // lib/features/chat/data/datasources/ai_datasource.dart

    final model = GenerativeModel(model: 'gemini-pro', apiKey: "TWÓJ_KLUCZ_API_TUTAJ");
    ```
    > **Uwaga:** Przechowywanie klucza w kodzie jest stosowane wyłącznie w celach demonstracyjnych. W projekcie produkcyjnym klucz powinien być zabezpieczony (np. przez `--dart-define` lub backend proxy).

5.  **Uruchom aplikację:**
    *   Wybierz urządzenie (Chrome dla wersji webowej, emulator lub fizyczne urządzenie).
    *   Naciśnij **F5** w VS Code / Cursor, aby uruchomić aplikację w trybie debugowania.

## 🌟 Możliwe ulepszenia (Next Steps)

*   **Bezpieczeństwo:** Przeniesienie klucza API z kodu klienta na backend (implementacja pełnoprawnej bramki API).
*   **Optymalizacja RAG:** Zamiast wysyłać cały tekst, wdrożenie wektoryzacji (embeddings) i wektorowej bazy danych (np. ChromaDB, Pinecone). Pozwoliłoby to na wysyłanie do LLM tylko najbardziej trafnych fragmentów dokumentu, oszczędzając tokeny i zwiększając precyzję.
*   **Obsługa dużych plików:** Implementacja strumieniowego przetwarzania i parsowania PDF w tle (isolate), aby nie blokować interfejsu użytkownika.
*   **Pamięć dialogu:** Zapisywanie historii czatu pomiędzy sesjami.
*   **UI/UX:** Ulepszenie interfejsu, dodanie obsługi błędów sieciowych, animacji oraz możliwości pracy z wieloma dokumentami.
