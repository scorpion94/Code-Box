Gerne! Hier ist die Übersicht als **saubere, gut strukturierte Tabelle**:

***


| **Art des Logs**            | **Ort in SSMS (GUI)**                                                 | **Dateisystem‑Pfad**                     | **Beschreibung / Inhalt**                                         |
| --------------------------- | --------------------------------------------------------------------- | ---------------------------------------- | ----------------------------------------------------------------- |
| **SQL Server Error Log**    | Management → **SQL Server Logs**                                      | `...\MSSQL\Log\ERRORLOG`                 | Start/Stop, DB‑Fehler, AlwaysOn, Deadlocks, Login‑Fehler          |
| **Ältere Error Logs**       | Management → SQL Server Logs → ERRORLOG.1, .2, …                      | `...\MSSQL\Log\ERRORLOG.1` usw.          | Historische Protokolle                                            |
| **SQL Agent Logs**          | SQL Server Agent → **Error Logs**                                     | `...\MSSQL\Log\SQLAGENT.OUT`             | Job‑Fehler, Agent‑Start, Scheduler‑Probleme                       |
| **T‑SQL Log-Abfrage**       | Kann in SSMS ausgeführt werden                                        | –                                        | `xp_readerrorlog` liest Error Logs direkt aus                     |
| **Windows Application Log** | Event Viewer → Windows Logs → **Application**                         | Windows Systempfad                       | Service‑Startfehler, Speicherprobleme, Korruption, Cluster‑Fehler |
| **AlwaysOn Dashboard**      | Always On High Availability → **Availability Group → Show Dashboard** | –                                        | Synchronisation, Zustand der Replicas, Datenbankstatus            |
| **Cluster Logs**            | Failover Cluster Manager → Cluster Events                             | `C:\Windows\Cluster\Reports\Cluster.log` | Cluster‑Fehler, Failover‑Details (`cluster log /g`)               |

***


