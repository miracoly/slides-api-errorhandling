# Errorhandling in Web-APIs

---

## Das Problem

* Wie übermittelt man Errors klar und konsistent in API's?
* Kein verpflichtendes Format für API-Fehler im HTTP-Standard
* HTTP-Status-Codes?
  * 400 Bad Request: Was war "*Bad"*?
  * 403 Forbidden: "*Warum*"? z.B. Credits aufgebraucht

---

* Ohne Standards erfinden Entwickler für jede API ihr eigenes System

---

* **Inkonsistenz**

  * Viele APIs definieren eigene, benutzerdefinierte Fehlerformate
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
* Viele RFCs definieren wichtige Aspekte von HTTP und APIs
* **2016**: RFC 7807 – *Problem Details for HTTP APIs* führte ein standardisiertes Format ein

---

* **2023**: RFC 9457 ersetzt RFC 7807 (Proposal)
  * Verbesserte und erweiterte die ursprüngliche Version
  * Führte Registries, bessere Erweiterbarkeit und Richtlinien für mehrere Fehler ein

---

## Problem Details

* HTTP-Statuscodes geben nur eine grobe Information
* Aber **was genau** ist schiefgelaufen?
* Wie kann die API dem Client umsetzbare Informationen geben, um dem Benutzer zu helfen?

---

* *Problem Details*-Format:
  * konsistente, strukturierte Fehlerinformationen
  * Eine maschinenlesbare Basis für Tools und Automatisierungen

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
  * Standardfeldnamen und -verhalten beibehalten

---

### Spring Framework

<https://docs.spring.io/spring-framework/reference/web/webmvc/mvc-ann-rest-exceptions.html>

---

## Best Practices

* **OpenAPI-Spezifikation verwenden**
  * Mögliche Fehlerantworten in der API-Spezifikation dokumentieren

---

### OpenAPI Spec

```yaml
paths:
  /v1/users:
    post:
      responses:
        "400":
          description: Invalid input
          content:
            application/problem+json:
              schema:
                $ref: "#/components/schemas/Problem"
```

---

```yaml
components:
  schemas:
    Problem:
      type: object
      required: [type, title, status]
      properties:
        type:
          type: string
          format: uri
        title:
          type: string
        status:
          type: integer
        detail:
          type: string
        instance:
          type: string
          format: uri
```

---

* **API-Schicht generieren**
  * Aus der Spezifikation Handler bzw. Controller/Interfaces generieren
  * *generierter Code ist korrekter code*

---

* Schritt für Schritt Migration
  * bei bestehenden Systemen Problem Details für neue Endpunkte verwenden
  * bestehende Endpunkte mit der Zeit nachziehen

---

### Danke für eure Aufmerksamkeit!

---

## Fragen?
