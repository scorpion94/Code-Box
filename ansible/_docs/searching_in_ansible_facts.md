# Small Tipp for Searching in ansible notes

````yaml
- name: "Search in Facts"
    ansible.builtin.debug: 
        var: ansible_facts | dict2items | selectattr('key', 'match', '^distribution') | list
````