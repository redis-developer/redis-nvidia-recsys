---

- hosts: all
  become: yes
  become_user: root
  become_method: sudo
  gather_facts: yes


  pre_tasks:
    - name: Load vars
      include_vars: "{{ item }}"
      with_first_found:
        - "{{ ansible_hostname }}.yaml"
        - "default.yaml"

    - name: Update Apt Cache
      apt: 
        update_cache: yes
    - name: Ubuntu Packages
      package:
        name: "{{ deb_packages }}"
    - name: Stop systemd Resolver
      systemd:
        name: systemd-resolved
        state: stopped
        enabled: no
    - name: Removing bad resolver
      lineinfile: 
        path: /etc/resolv.conf
        regexp: 'nameserver\s+127\.0\.0\.53'
        state: absent
    - name: Adding known good resolver
      lineinfile: 
        path: /etc/resolv.conf
        regexp: '^nameserver\s+1.1.1.1'
        line: 'nameserver 1.1.1.1'
        state: present

    - name: create re home dir
      file:
        state: directory
        path: "/redis"


  tasks:
    - name: create download directory
      file:
        state: directory
        path: "/var/tmp/re-download"
    - name: Unarchive software
      unarchive: 
        src: ${re_download_url}

        dest: /var/tmp/re-download
        remote_src: yes
    - name: Install the software
      command: "./install.sh -y"
      args:
        chdir: /var/tmp/re-download
        creates: /var/opt/redislabs/log/rlcheck.log