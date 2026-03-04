# ora_facts

### ansible dictonary
````yaml
    "ora_facts_dict": {
        "CORCL": {
            "home": "/u01/product/db_lnx_1919",
            "pdbs": [
                "ORCL",
                "PDB$SEED"
            ],
            "version": "19.19.0.0.0"
        }
    }
````

In case DB isn't started pdbs will be empty and version will be null