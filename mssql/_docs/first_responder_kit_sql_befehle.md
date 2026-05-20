# First Responder Kit – SQL-Befehle für `test_performance`

Diese Datei dokumentiert die von dir genannten First-Responder-Kit-Aufrufe für eine SQL-Server-Installation, bei der die Prozeduren in der Datenbank `maintenanceDB` liegen.

> Hinweis: Die Beispiele gehen davon aus, dass das First Responder Kit in `maintenanceDB` installiert wurde und die zu analysierende Datenbank `test_performance` heißt.

---

## Befehl: `sp_BlitzIndex`

**Description:**  
Analysiert Indexe, Tabellenstrukturen und Index-Nutzungsmuster einer Datenbank. Nützlich zum Finden von fehlenden, doppelten, überlappenden oder ungenutzten Indexen.

**Mögliche Parameter:**

| Parameter | Beschreibung |
|---|---|
| `@DatabaseName` | Name der zu analysierenden Datenbank. |
| `@SchemaName` | Optional: Einschränkung auf ein bestimmtes Schema, z. B. `dbo`. |
| `@TableName` | Optional: Einschränkung auf eine bestimmte Tabelle. |
| `@Mode` | Steuert die Detailtiefe der Ausgabe. `@Mode = 2` liefert eine detailliertere Index-/Tabellensicht. |

<details>
<summary>SQL-Befehl aufklappen</summary>

```sql
USE maintenanceDB;
GO

EXEC dbo.sp_BlitzIndex
    @DatabaseName = 'test_performance';
```

</details>

---

## Befehl: `sp_BlitzCache`

**Description:**  
Analysiert den SQL Server Plan Cache und zeigt ressourcenintensive Abfragen. Damit kannst du Queries nach CPU, Reads, Writes, Laufzeit oder Ausführungshäufigkeit priorisieren.

**Mögliche Parameter:**

| Parameter | Beschreibung |
|---|---|
| `@DatabaseName` | Optional: Filtert die Analyse auf eine bestimmte Datenbank. |
| `@Top` | Anzahl der zurückgegebenen Top-Abfragen. |
| `@SortOrder` | Sortierkriterium, z. B. `cpu`, `reads`, `writes`, `duration`, `executions`. |

<details>
<summary>SQL-Befehl aufklappen</summary>

```sql
USE maintenanceDB;
GO

EXEC dbo.sp_BlitzCache
    @DatabaseName = 'test_performance',
    @Top = 20,
    @SortOrder = 'writes';
```

</details>

---

## Befehl: `sp_BlitzFirst`

**Description:**  
Zeigt, was auf dem SQL Server gerade passiert. Besonders hilfreich bei akuter Langsamkeit, Wait-Stats, Blockings, aktuellen Requests und Storage-/CPU-Indikatoren.

**Mögliche Parameter:**

| Parameter | Beschreibung |
|---|---|
| `@Seconds` | Messdauer in Sekunden. Beispiel: `30` misst über 30 Sekunden. |
| `@ExpertMode` | Aktiviert zusätzliche Detailausgaben. Typisch: `1`. |

<details>
<summary>SQL-Befehl aufklappen</summary>

```sql
USE maintenanceDB;
GO

EXEC dbo.sp_BlitzFirst
    @Seconds = 30,
    @ExpertMode = 1;
```

</details>

---

## Befehl: `sp_BlitzCache` nach CPU

**Description:**  
Zeigt die CPU-intensivsten Abfragen aus dem Plan Cache. Gut geeignet, wenn CPU-Auslastung oder CPU-Wartezeiten auffällig sind.

**Mögliche Parameter:**

| Parameter | Beschreibung |
|---|---|
| `@Top` | Anzahl der zurückgegebenen Abfragen. |
| `@SortOrder` | Mit `cpu` wird nach CPU-Verbrauch sortiert. |

<details>
<summary>SQL-Befehl aufklappen</summary>

```sql
USE maintenanceDB;
GO

EXEC dbo.sp_BlitzCache
    @Top = 20,
    @SortOrder = 'cpu';
```

</details>

---

## Befehl: `sp_BlitzCache` nach Ausführungen

**Description:**  
Zeigt Abfragen mit besonders vielen Ausführungen. Hilfreich, wenn viele kleine Abfragen in Summe hohe Last erzeugen.

**Mögliche Parameter:**

| Parameter | Beschreibung |
|---|---|
| `@Top` | Anzahl der zurückgegebenen Abfragen. |
| `@SortOrder` | Mit `executions` wird nach Ausführungshäufigkeit sortiert. |

<details>
<summary>SQL-Befehl aufklappen</summary>

```sql
USE maintenanceDB;
GO

EXEC dbo.sp_BlitzCache
    @Top = 20,
    @SortOrder = 'executions';
```

</details>

---

## Befehl: `sp_BlitzIndex` für eine Tabelle

**Description:**  
Analysiert gezielt die Indexsituation einer einzelnen Tabelle. Besonders sinnvoll, wenn bereits klar ist, welche Tabelle problematisch oder besonders groß ist.

**Mögliche Parameter:**

| Parameter | Beschreibung |
|---|---|
| `@DatabaseName` | Name der Datenbank. |
| `@SchemaName` | Schema der Tabelle, z. B. `dbo`. |
| `@TableName` | Name der zu analysierenden Tabelle. |

<details>
<summary>SQL-Befehl aufklappen</summary>

```sql
USE maintenanceDB;
GO

EXEC dbo.sp_BlitzIndex
    @DatabaseName = 'test_performance',
    @SchemaName = 'dbo',
    @TableName = 'Fahrzeug';
```

</details>

---

## Befehl: `sp_BlitzIndex` mit `@Mode = 2`

**Description:**  
Liefert eine detailliertere Indexanalyse als der Standardmodus. Nützlich, wenn du Indexgrößen, Nutzung und Details genauer betrachten willst.

**Mögliche Parameter:**

| Parameter | Beschreibung |
|---|---|
| `@DatabaseName` | Name der zu analysierenden Datenbank. |
| `@Mode` | Detailmodus. `2` steht für eine detailliertere Ausgabe. |

<details>
<summary>SQL-Befehl aufklappen</summary>

```sql
USE maintenanceDB;
GO

EXEC dbo.sp_BlitzIndex
    @DatabaseName = 'test_performance',
    @Mode = 2;
```

</details>

---

## Befehl: `sp_BlitzWho`

**Description:**  
Zeigt aktuelle Sessions, Requests und Blockings. Gut geeignet als schnelle Übersicht, wer gerade was auf dem SQL Server macht.

**Mögliche Parameter:**

| Parameter | Beschreibung |
|---|---|
| Keine Pflichtparameter | Der Standardaufruf reicht für eine schnelle Session-Übersicht. |

<details>
<summary>SQL-Befehl aufklappen</summary>

```sql
USE maintenanceDB;
GO

EXEC dbo.sp_BlitzWho;
```

</details>

---

## Befehl: `sp_BlitzLock`

**Description:**  
Analysiert Deadlocks aus den verfügbaren SQL-Server-Quellen, typischerweise aus dem System-Health-Extended-Event. Hilft beim Erkennen von Deadlock-Victims, beteiligten Statements, Tabellen und Indexen.

**Mögliche Parameter:**

| Parameter | Beschreibung |
|---|---|
| `@DatabaseName` | Optional: Filter auf Deadlocks einer bestimmten Datenbank. |

<details>
<summary>SQL-Befehl aufklappen</summary>

```sql
USE maintenanceDB;
GO

EXEC dbo.sp_BlitzLock
    @DatabaseName = 'test_performance';
```

</details>

---

## Befehl: `sp_BlitzBackups`

**Description:**  
Analysiert die Backup-Historie des SQL Servers. Hilfreich zum Prüfen von fehlenden Backups, Backup-Dauer, Backup-Größen und Recovery-Risiken.

**Mögliche Parameter:**

| Parameter | Beschreibung |
|---|---|
| Keine Pflichtparameter | Der Standardaufruf analysiert die vorhandene Backup-Historie. |

<details>
<summary>SQL-Befehl aufklappen</summary>

```sql
USE maintenanceDB;
GO

EXEC dbo.sp_BlitzBackups;
```

</details>

---

## Empfohlene Reihenfolge für eine schnelle Analyse

```sql
USE maintenanceDB;
GO

-- 1. Live-Zustand / aktuelle Last
EXEC dbo.sp_BlitzFirst
    @Seconds = 30,
    @ExpertMode = 1;

-- 2. Indexanalyse der Datenbank
EXEC dbo.sp_BlitzIndex
    @DatabaseName = 'test_performance';

-- 3. Teure Queries nach CPU
EXEC dbo.sp_BlitzCache
    @Top = 20,
    @SortOrder = 'cpu';

-- 4. Teure Queries nach Writes
EXEC dbo.sp_BlitzCache
    @DatabaseName = 'test_performance',
    @Top = 20,
    @SortOrder = 'writes';

-- 5. Sessions / Blocking
EXEC dbo.sp_BlitzWho;

-- 6. Deadlocks
EXEC dbo.sp_BlitzLock
    @DatabaseName = 'test_performance';

-- 7. Backup-Historie
EXEC dbo.sp_BlitzBackups;
```

---

## Quellen

- Brent Ozar Unlimited – First Responder Kit GitHub Repository: https://github.com/BrentOzarULTD/SQL-Server-First-Responder-Kit
- Brent Ozar – How I Use the First Responder Kit: https://www.brentozar.com/training/how-i-use-the-first-responder-kit/
- Brent Ozar – sp_Blitz Documentation: https://www.brentozar.com/blitz/documentation/
