# TD5 Report — Secure Remote Access: SSH Hardening + Site-to-Site IPsec VPN

## 1. Threat model

Asset: accès administratif aux systèmes entre deux sites.

Adversary: attaquant externe sur le segment WAN ou poste interne compromis.

Key threats:
- attaque par mot de passe contre SSH
- vol de clé privée SSH
- interception du trafic inter-site sans protection
- extension latérale si le tunnel VPN est trop large

Security goals:
- seul l'utilisateur d'administration autorisé peut se connecter en SSH
- l'authentification par mot de passe est désactivée
- le login root direct en SSH est désactivé
- le trafic entre 10.10.10.0/24 et 10.10.20.0/24 est chiffré et protégé en intégrité
- le tunnel est limité aux sous-réseaux prévus
- les accès et échecs sont auditables

## 2. Policy statement

Seul l'utilisateur adminX est autorisé à administrer srv-web en SSH avec une clé publique. L'authentification par mot de passe est désactivée. Le login root direct est désactivé. Le trafic entre le LAN du site A et la DMZ du site B passe par un tunnel IPsec IKEv2 entre gw-fw et gw-fw-b. Le tunnel est limité à 10.10.10.0/24 <-> 10.10.20.0/24.

## 3. SSH configuration

Voir:
- config/ssh_hardening.md
- config/sshd_config_excerpt.txt

Contrôles appliqués:
- PasswordAuthentication no
- PermitRootLogin no
- AllowUsers adminX
- PubkeyAuthentication yes
- MaxAuthTries 3
- LoginGraceTime 30

## 4. IPsec configuration

Voir:
- config/ipsec_siteA.conf
- config/ipsec_siteB.conf
- config/ipsec.secrets

Choix de conception:
- IKEv2 avec strongSwan
- PSK en simplification de labo
- recommandation production: certificats

Portée du tunnel:
- Site A: 10.10.10.0/24
- Site B: 10.10.20.0/24

## 5. Test plan

Tests positifs:
- connexion SSH par clé pour adminX
- tunnel IKEv2 établi
- ping entre client-kali et srv-web

Tests négatifs:
- mot de passe SSH refusé
- root SSH refusé

## 6. Telemetry proof

Voir:
- evidence/preflight_topology.txt
- evidence/ssh_tests.txt
- evidence/authlog_excerpt.txt
- evidence/ipsec_status.txt
- evidence/tunnel_ping.txt

## 7. Residual risks

- PSK non adapté à la production
- pas de MFA SSH
- rotation de clés non automatisée
- dépendance au VPN pour certains contrôles réseau
