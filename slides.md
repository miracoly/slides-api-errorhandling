# Errorhandling in Web-APIs

---

Wie übermittelt man Errors klar und konsistent in API's?

---

* Kein verpflichtendes Format für API-Fehler im HTTP-Standard
* HTTP-Status-Codes?
  * 400 Bad Request: Was war "*Bad"*?
  * 403 Forbidden: "*Warum*"? z.B. Credits aufgebraucht

---

* **Inkonsistenz**
  * Ohne Standards erfinden Entwickler für jede API ihr eigenes System
  * Unterschiedliche Strukturen und Felder in verschiedenen APIs

---

* **Fehlerhafte Verwendung von HTTP-Statuscodes**

  * Nutzung von 200 OK mit eingebetteten Fehlermeldungen
  * Nicht-standardisierte oder irreführende Codes

---

* **Fehlende maschinenlesbare Struktur**

  * Erschwert die automatische Verarbeitung
  * Zwingt Clients dazu, für Menschen geschriebene Texte zu parsen

---

* **Standardisierung im Web** erfolgt über IETF-RFCs
  * Request for Comments
* Viele RFCs definieren wichtige Aspekte von HTTP und APIs
* **2016**: RFC 7807 – *Problem Details for HTTP APIs* führte ein standardisiertes Format ein

---

* **2023**: RFC 9457 ersetzt RFC 7807 (Proposal)
  * Verbesserte und erweiterte die ursprüngliche Version
  * Führte Registries, bessere Erweiterbarkeit und Richtlinien für mehrere Fehler ein

---

## Problem Details

* konsistente, strukturierte Fehlerinformationen
* Eine maschinenlesbare Basis für Tools und Automatisierungen

---

### Beispiel

```sh
curl http://example.com/v1/users -d $BODY
```

```json
{
  "name": "Klaus"
  "email": "klaus.de",
  "password": "123"
}
```

---

### Header

```json
{
  "Content-Type": "application/problem+json"
}
```

---

### Body

```json
{
  "type": "https://example.com/problems/invalid-user-input",
  "title": "Ungültige Benutzereingabe.",
  "status": 400,
  "detail": "Die Felder 'email' und 'password' sind ungültig.",
  "instance": "/v1/users",
}
```

---

### Type

* eine URI, die den Problemtyp identifiziert
* kann auf Dokumentation verweisen

```json [2]
{
  "type": "https://example.com/problems/invalid-user-input",
  "title": "Ungültige Benutzereingabe.",
  "status": 400,
  "detail": "Die Felder 'email' und 'password' sind ungültig.",
  "instance": "/v1/users",
}
```

---

### Title

* kurze, Klartext-Zusammenfassung des Problemtyps
* sollte sich nicht mehr ändern

```json [3]
{
  "type": "https://example.com/problems/invalid-user-input",
  "title": "Ungültige Benutzereingabe.",
  "status": 400,
  "detail": "Die Felder 'email' und 'password' sind ungültig.",
  "instance": "/v1/users",
}
```

---

### Status

* HTTP-Statuscode
* Duplikat vom Header Statuscode

```json [4]
{
  "type": "https://example.com/problems/invalid-user-input",
  "title": "Ungültige Benutzereingabe.",
  "status": 400,
  "detail": "Die Felder 'email' und 'password' sind ungültig.",
  "instance": "/v1/users",
}
```

---

### Detail

* eine Klartext-Beschreibung
* dynamisch, kann sich ändern zwischen Aufrufen

```json [5]
{
  "type": "https://example.com/problems/invalid-user-input",
  "title": "Ungültige Benutzereingabe.",
  "status": 400,
  "detail": "Die Felder 'email' und 'password' sind ungültig.",
  "instance": "/v1/users",
}
```

---

### Instance

* URI des Vorfalls
* in RESTful API wäre dies die Resource

```json [6]
{
  "type": "https://example.com/problems/invalid-user-input",
  "title": "Ungültige Benutzereingabe.",
  "status": 400,
  "detail": "Die Felder 'email' und 'password' sind ungültig.",
  "instance": "/v1/users",
}
```

---

### Extension Members

* optionale, domänenspezifische Informationen

```json [7-10]
{
  "type": "https://example.com/problems/invalid-user-input",
  "title": "Ungültige Benutzereingabe.",
  "status": 400,
  "detail": "Die Felder 'email' und 'password' sind ungültig.",
  "instance": "/v1/users",
  "invalid_fields": [
    { "field": "email", "error": "Ungültiges E-Mail-Format." },
    { "field": "password", "error": "Mindestens 8 Zeichen lang." }
  ],
}
```

---

## Sicherheit

* Keine sensiblen Daten in Fehlermeldungen preisgeben
  (z. B. interne IDs, Stacktraces, Sicherheitstoken)
* Beachten, dass `detail` und Erweiterungsfelder Implementierungsdetails verraten könnten

---

## Implementierungen

* Viele Sprachen und Frameworks unterstützen RFC 9457 bereits

  * JSON- und XML-Serialisierungshelfer
  * Middleware für Fehlerbehandlung

---

* Falls nicht vorhanden:
  * Leicht selbst umzusetzen anhand der Spezifikation

---

### Spring Framework

<https://docs.spring.io/spring-framework/reference/web/webmvc/mvc-ann-rest-exceptions.html>

---

## Best Practices

---

* **Debug extension feld**
  * enthält Implementierungsdetails
  * für den Entwickler
  * *disabled* auf Prod

---

```json [7]
{
  "type": "https://example.com/problems/no-more-credits",
  "title": "Not enough credits",
  "status": 403,
  "detail": "Not enough credits for user 123",
  "instance": "/v1/example",
  "debug": "Exception: CreditLimitException at CreditService.java:42",
}
```

---

* Schritt für Schritt Migration
  * bei bestehenden Systemen Problem Details für neue Endpunkte verwenden
  * bestehende Endpunkte mit der Zeit nachziehen

---

### Danke für eure Aufmerksamkeit

---

## Fragen?
