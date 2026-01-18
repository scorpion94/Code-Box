
- A list needs an index when you want to access a specific element.
- A list can include values, dictionaries, or even other lists.
- Keys in dictionaries can be accessed directly via dot notation (or bracket notation).

### Example:
````yaml
services:                    # ← List of Dicts
  - name: api
    config:                  # ← Dict
      port: 8080
      endpoints:             # ← Liste
        - health
        - metrics

  - name: web
    config:
      port: 80
      endpoints:
        - /
````
### Zugriffe:
````yaml
services[0]                         # <- Zugriff auf der erste Element in der Liste (api)
services[0].config.port             # <- Zugriff auf den Port -> Dadurch das es sich um Dictonarys handelt kann der Key direkt angesprochen werden und benötigt kein Index
services[0]['config']['port']       # <- Gleiches Spiel wie darüber nur das hier Klammern verwendet werden, dies wird benötigt wenn beim Namen sonderzeichen im Spiel sind!
services[0].config.endpoints[0]     # <- Gebe das erste Element der Endpoints aus -> Config kann wieder durch den Key angesprochen werden, allerdings ist endpoints eine Liste und benötigt daher den Index
````