# OpenPKW Weryfikator Presentation Service

Próba stworzenia mikroserwisu odpowiedzialnego za prezentowanie danych zebranych przez Weryfikator OpenPKW.

## Założenia
- Ma działać szybko.
- Minimalna architektura (żadnych warstw abstrakcji, serwisów, wyrafinowanych wzorców projektowych, ORM-ów itd.).
- Jak najniższa bariera technologiczna (klasyczne, znane i lubiane technologie, żadnych nowinek, żadnych niszowych wynalazków).
- Szybki cykl deweloperski (hot-deploy, czyli naciskam CTRL-S w IDE, naciskam F5 w przeglądarce i już mam wyniki).

## Realizacja założeń
- W chwili obecnej serwis oparty jest o Ninja Framework, co daje hot-deploy. Niestety, nie jest to ,,klasyczna, znana i lubiana technologia'', więc może technologia zostanie zmieniona.
- Backend: 
  - jeden kontroler do generowania widoków HTML + jeden kontroler do zwracania danych w formacie JSON.
  - Żadnych ORM-ów, dane potrzebne w GUI są udostępniane przez widoki stworzone w bazie danych. ResultSety konwertowane są bezpośrednio na JSON.
- Frontend:
  - statyczny HTML + JQuery do robienia calli ajaxowych
  - Google Charts do generowania wykresów
  - mapy - technologia jeszcze nie wybrana, może będzie taka sama, jak w openpkw-weryfikator-frontend

## Jak zbudować

mvn clean install

## Jak uruchomić

mvn ninja:run

Do uruchomienia potrzebna jest działająca baza openpkw, z użytkownikiem openpkw, z załadowanymi danymi.

jdbc:mysql://localhost/openpkw

## Projekt

https://moqups.com/rafreg/RT9xAvLL
